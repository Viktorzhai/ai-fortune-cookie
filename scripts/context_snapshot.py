#!/usr/bin/env python3
"""Collect lightweight local context for the AI Fortune Cookie skill."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Iterable

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None


HISTORY_CANDIDATES = (
    ".codex/command-log.txt",
    ".claude/command-log.txt",
    ".zsh_history",
    ".bash_history",
)

PROFILE_CANDIDATES = (
    ".codex/USER.md",
    ".codex/CLAUDE.md",
    ".claude/CLAUDE.md",
    ".config/ai-fortune-cookie/profile.md",
)

MANIFEST_HINTS = {
    "package.json": ["node"],
    "tsconfig.json": ["typescript"],
    "pyproject.toml": ["python"],
    "requirements.txt": ["python"],
    "Pipfile": ["python"],
    "Cargo.toml": ["rust"],
    "go.mod": ["go"],
    "Gemfile": ["ruby"],
    "composer.json": ["php"],
    "pom.xml": ["java"],
    "build.gradle": ["java"],
    "Package.swift": ["swift"],
}

PACKAGE_HINTS = {
    "next": "nextjs",
    "react": "react",
    "vue": "vue",
    "svelte": "svelte",
    "vite": "vite",
    "tailwindcss": "tailwindcss",
    "typescript": "typescript",
    "jest": "jest",
    "vitest": "vitest",
}

PYPROJECT_HINTS = {
    "fastapi": "fastapi",
    "django": "django",
    "flask": "flask",
    "pytest": "pytest",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cwd", default=".", help="Directory to inspect")
    parser.add_argument(
        "--history-file",
        help="Optional explicit shell history or command log file to read",
    )
    parser.add_argument(
        "--profile-file",
        help="Optional explicit profile or preferences file to read",
    )
    parser.add_argument(
        "--history-lines",
        type=int,
        default=6,
        help="Maximum recent commands to include",
    )
    parser.add_argument(
        "--changed-files",
        type=int,
        default=8,
        help="Maximum changed files to include from git status",
    )
    parser.add_argument(
        "--profile-lines",
        type=int,
        default=3,
        help="Maximum profile hint lines to include",
    )
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="Output format",
    )
    return parser.parse_args()


def run_command(args: list[str], cwd: Path) -> str | None:
    try:
        completed = subprocess.run(
            args,
            cwd=str(cwd),
            check=True,
            capture_output=True,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None

    return completed.stdout.strip()


def unique(items: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for item in items:
        if item and item not in seen:
            ordered.append(item)
            seen.add(item)
    return ordered


def detect_git(cwd: Path, changed_files_limit: int) -> dict[str, object]:
    repo_root = run_command(["git", "rev-parse", "--show-toplevel"], cwd)
    if not repo_root:
        return {"available": False}

    branch = run_command(["git", "branch", "--show-current"], cwd) or "detached"
    status_output = run_command(
        ["git", "status", "--short", "--untracked-files=all"],
        cwd,
    ) or ""
    changed = [line for line in status_output.splitlines() if line][:changed_files_limit]

    return {
        "available": True,
        "repo_root": repo_root,
        "repo_name": Path(repo_root).name,
        "branch": branch,
        "changed_files": changed,
    }


def detect_stack_hints(cwd: Path) -> tuple[list[str], list[str]]:
    hints: list[str] = []
    manifests: list[str] = []

    for manifest, manifest_hints in MANIFEST_HINTS.items():
        if (cwd / manifest).exists():
            manifests.append(manifest)
            hints.extend(manifest_hints)

    package_json = cwd / "package.json"
    if package_json.exists():
        try:
            payload = json.loads(package_json.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            payload = {}
        deps = set()
        for section in ("dependencies", "devDependencies", "peerDependencies"):
            section_payload = payload.get(section, {})
            if isinstance(section_payload, dict):
                deps.update(section_payload.keys())
        for dep_name, hint in PACKAGE_HINTS.items():
            if dep_name in deps:
                hints.append(hint)

    pyproject = cwd / "pyproject.toml"
    if pyproject.exists() and tomllib is not None:
        try:
            payload = tomllib.loads(pyproject.read_text(encoding="utf-8"))
        except (OSError, ValueError, tomllib.TOMLDecodeError):
            payload = {}

        deps = set()
        project = payload.get("project", {})
        if isinstance(project, dict):
            for dependency in project.get("dependencies", []):
                deps.add(str(dependency).lower())
        tool = payload.get("tool", {})
        if isinstance(tool, dict):
            poetry = tool.get("poetry", {})
            if isinstance(poetry, dict):
                poetry_deps = poetry.get("dependencies", {})
                if isinstance(poetry_deps, dict):
                    deps.update(str(key).lower() for key in poetry_deps)

        dep_blob = "\n".join(sorted(deps))
        for dep_name, hint in PYPROJECT_HINTS.items():
            if dep_name in dep_blob:
                hints.append(hint)

    return unique(hints), manifests


def resolve_candidate(explicit_path: str | None, candidates: tuple[str, ...]) -> Path | None:
    if explicit_path:
        path = Path(explicit_path).expanduser()
        return path if path.is_file() else None

    env_history = os.environ.get("HISTFILE")
    if explicit_path is None and candidates is HISTORY_CANDIDATES and env_history:
        path = Path(env_history).expanduser()
        if path.is_file():
            return path

    home = Path.home()
    for relative in candidates:
        path = home / relative
        if path.is_file():
            return path
    return None


def parse_history_line(line: str) -> str:
    raw = line.strip()
    if not raw:
        return ""
    match = re.match(r"^: \d+:\d+;(.*)$", raw)
    if match:
        return match.group(1).strip()
    return raw


def read_recent_history(history_path: Path | None, limit: int) -> tuple[str | None, list[str]]:
    if not history_path:
        return None, []

    try:
        lines = history_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        return None, []

    cleaned = [parse_history_line(line) for line in lines]
    cleaned = [line for line in cleaned if line]
    recent = unique(reversed(cleaned))
    return str(history_path), list(reversed(recent[:limit]))


def read_profile_hints(profile_path: Path | None, limit: int) -> tuple[str | None, list[str]]:
    if not profile_path:
        return None, []

    try:
        lines = profile_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        return None, []

    hints: list[str] = []
    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith("#") or line.startswith("```"):
            continue
        line = re.sub(r"^[-*]\s+", "", line)
        if len(line) > 120:
            line = f"{line[:117].rstrip()}..."
        hints.append(line)
        if len(hints) >= limit:
            break

    return str(profile_path), hints


def build_snapshot(args: argparse.Namespace) -> dict[str, object]:
    cwd = Path(args.cwd).expanduser().resolve()
    git_info = detect_git(cwd, args.changed_files)
    stack_hints, manifests = detect_stack_hints(cwd)
    history_source, history = read_recent_history(
        resolve_candidate(args.history_file, HISTORY_CANDIDATES),
        args.history_lines,
    )
    profile_source, profile_hints = read_profile_hints(
        resolve_candidate(args.profile_file, PROFILE_CANDIDATES),
        args.profile_lines,
    )

    snapshot: dict[str, object] = {
        "cwd": str(cwd),
        "cwd_name": cwd.name,
        "manifests": manifests,
        "stack_hints": stack_hints,
        "recent_history_source": history_source,
        "recent_history": history,
        "profile_source": profile_source,
        "profile_hints": profile_hints,
    }
    snapshot.update(git_info)
    return snapshot


def render_text(snapshot: dict[str, object]) -> str:
    lines = [
        f"cwd: {snapshot['cwd']}",
        f"cwd_name: {snapshot['cwd_name']}",
    ]

    if snapshot.get("available"):
        lines.extend(
            [
                f"repo_root: {snapshot['repo_root']}",
                f"repo_name: {snapshot['repo_name']}",
                f"branch: {snapshot['branch']}",
            ]
        )
    else:
        lines.append("git: unavailable")

    manifests = snapshot.get("manifests") or []
    lines.append(f"manifests: {', '.join(manifests) if manifests else 'none'}")

    stack_hints = snapshot.get("stack_hints") or []
    lines.append(f"stack_hints: {', '.join(stack_hints) if stack_hints else 'none'}")

    changed_files = snapshot.get("changed_files") or []
    lines.append("changed_files:")
    if changed_files:
        lines.extend(f"- {line}" for line in changed_files)
    else:
        lines.append("- none")

    lines.append(
        f"recent_history_source: {snapshot.get('recent_history_source') or 'none'}"
    )
    lines.append("recent_history:")
    history = snapshot.get("recent_history") or []
    if history:
        lines.extend(f"- {line}" for line in history)
    else:
        lines.append("- none")

    lines.append(f"profile_source: {snapshot.get('profile_source') or 'none'}")
    lines.append("profile_hints:")
    hints = snapshot.get("profile_hints") or []
    if hints:
        lines.extend(f"- {line}" for line in hints)
    else:
        lines.append("- none")

    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    snapshot = build_snapshot(args)

    if args.format == "json":
        print(json.dumps(snapshot, indent=2, sort_keys=True))
    else:
        print(render_text(snapshot))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
