# Repository Guidelines

## Project Structure & Module Organization
This repository is a cross-agent package. The canonical skill entrypoint is `SKILL.md`, which is installed for Codex, Claude Code, and Gemini CLI. Cursor-specific packaging lives in `targets/cursor/rules/ai-fortune-cookie.mdc`. Keep executable helpers in `scripts/`, tone or workflow guidance in `references/`, and longer design notes in `docs/`. The main helper script is `scripts/context_snapshot.py`, which collects lightweight local signals for the skill. Avoid adding unrelated files at the root; keep the top level limited to install, runtime, and contributor essentials.

## Build, Test, and Development Commands
There is no compiled build step. Use these commands from the repository root:

```sh
./install.sh --host codex --force
./install.sh --host claude --force
./install.sh --host gemini --force
./install.sh --host cursor --project /tmp/fortune-cookie-cursor-test --force
python3 scripts/context_snapshot.py --cwd .
python3 /path/to/skill-creator/scripts/quick_validate.py .
```

`install.sh` installs the right packaging for each host. `context_snapshot.py` exercises the runtime context collector. `quick_validate.py` checks the skill frontmatter and naming rules when the `skill-creator` tooling is available.

## Coding Style & Naming Conventions
Use Markdown for docs and Python for local helpers. Python should use 4-space indentation, standard-library-first imports, and small focused functions. Keep skill guidance imperative and direct. Use lowercase hyphenated names for skill identifiers and snake_case for Python functions and flags. Wrap commands, paths, and config keys in backticks.

## Testing Guidelines
Test the helper script in both Git and non-Git directories when changing context detection. Verify the script handles missing history files and missing profile files without failing. When changing packaging, test all touched hosts with temporary install roots or a temporary Cursor project. After editing `SKILL.md`, run the validator and do a manual read-through to confirm the trigger description still matches the workflow.

## Commit & Pull Request Guidelines
This repo was initialized locally, so there is no inherited commit history to follow. Use short imperative commit subjects such as `feat: add local context snapshot script` or `docs: tighten install instructions`. Pull requests should summarize the user-facing behavior change, note any install-path or prompt-contract changes, and include sample fortune output when tone or context rules are adjusted.
