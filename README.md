# AI Fortune Cookie

A lightweight cross-agent skill that turns local repo signals into one short fortune while you wait on builds, tests, refactors, or agent runs.

GitHub repo names cannot contain spaces, so the clean public slug for this project should be `ai-fortune-cookie` even though the display name is "AI Fortune Cookie".

Published repo: `https://github.com/Viktorzhai/ai-fortune-cookie`

## What It Does

- Reads lightweight local context only: current directory, Git branch/status, stack hints, optional shell history, and optional profile notes.
- Generates exactly one sentence, designed to feel wise, encouraging, and character-building, with project context used only as a light hint.
- Avoids external APIs and full-repo indexing.

## Host Support

The repo now supports four host families:

- `Codex`: install as a skill via `~/.codex/skills/ai-fortune-cookie`
- `Claude Code`: install as a skill via `~/.claude/skills/ai-fortune-cookie`
- `Gemini CLI`: install as a skill via `~/.gemini/skills/ai-fortune-cookie`
- `Cursor`: install as a project rule via `.cursor/rules/ai-fortune-cookie.mdc`

Codex, Claude Code, and Gemini CLI all consume the same `SKILL.md` package. Cursor uses a separate `.mdc` rule because its reusable instruction system is project rules rather than skills.

## Repo Layout

```text
.
├── SKILL.md
├── agents/openai.yaml
├── scripts/context_snapshot.py
├── references/fortune-patterns.md
├── targets/cursor/rules/ai-fortune-cookie.mdc
├── docs/host-compatibility.md
├── docs/fortune-cookie-skill-research.md
├── install.sh
├── LICENSE
└── AGENTS.md
```

## Install

By default, `install.sh` copies files, which is safer across hosts. Use `--symlink` only if you want the installed skill to track live edits in this repo.

### Codex

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host codex
```

### Claude Code

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host claude
```

### Gemini CLI

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host gemini
```

### Cursor

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host cursor --project /path/to/real/project
```

### Install Everywhere

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host all --project /path/to/real/project
```

Useful flags:

- `--force` replaces an existing install
- `--symlink` links instead of copying
- `--project` is required for Cursor installs
- `CODEX_HOME`, `CLAUDE_HOME`, and `GEMINI_HOME` can override the default home directories

## Updating

There is no background auto-updater in this repo.

How updates work depends on how the user installed it:

- If they cloned the repo directly into a skills directory, they can update with `git pull` inside that installed folder.
- If they cloned the repo elsewhere and used the default copy install, they should run `git pull` in the repo and then rerun `./install.sh --host ... --force`.
- If they installed with `--symlink`, they only need `git pull` in the source repo because the installed host path points back to the repo.
- For Cursor copy installs, rerun `./install.sh --host cursor --project /path/to/project --force` after pulling changes.

Examples:

```bash
cd ~/.codex/skills/ai-fortune-cookie && git pull
cd ~/.claude/skills/ai-fortune-cookie && git pull
cd ~/.gemini/skills/ai-fortune-cookie && git pull
```

If the user installed from a separate repo clone:

```bash
cd ai-fortune-cookie
git pull
./install.sh --host all --project /path/to/project --force
```

## Usage

Prompt examples:

- `Use $ai-fortune-cookie to give me a fortune for this branch.`
- `I am waiting on tests. Use $ai-fortune-cookie and keep it dry.`
- `Use $ai-fortune-cookie for a short philosophical fortune about this refactor.`

Typical output:

> A hard branch can still teach a gentle lesson: patience is often how rough work becomes worthy work.

## Local Context Model

The helper script gathers small, fast signals:

- Git root, branch, and changed files when the directory is a repository
- Stack hints from files like `package.json`, `pyproject.toml`, `Cargo.toml`, and `go.mod`
- Recent shell history from common local history files when available
- Optional user-profile hints from `~/.codex/USER.md`, `~/.codex/CLAUDE.md`, or similar local files

If a source is missing, the skill falls back cleanly instead of guessing.

## Cursor Usage

Cursor does not load `SKILL.md` skills directly. The included rule is installed into the target project's `.cursor/rules/` directory and becomes available to Cursor's agent as a reusable project rule. Ask for a fortune explicitly, or invoke the installed rule from the Cursor rules picker.

## Compatibility Notes

The packaging choices in this repo follow the current host docs summarized in [docs/host-compatibility.md](docs/host-compatibility.md).

## Development

```bash
python3 scripts/context_snapshot.py --cwd .
python3 /path/to/skill-creator/scripts/quick_validate.py .
./install.sh --host all --project /tmp/fortune-cookie-cursor-test --force
```
