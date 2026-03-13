# AI Fortune Cookie

A lightweight Codex skill that turns local repo signals into one short fortune while you wait on builds, tests, refactors, or agent runs.

GitHub repo names cannot contain spaces, so the clean public slug for this project should be `ai-fortune-cookie` even though the display name is "AI Fortune Cookie".

Published repo: `https://github.com/Viktorzhai/ai-fortune-cookie`

## What It Does

- Reads lightweight local context only: current directory, Git branch/status, stack hints, optional shell history, and optional profile notes.
- Generates exactly one sentence, designed to feel specific without sounding heavy.
- Avoids external APIs and full-repo indexing.

## Repo Layout

```text
.
├── SKILL.md
├── agents/openai.yaml
├── scripts/context_snapshot.py
├── references/fortune-patterns.md
├── docs/fortune-cookie-skill-research.md
├── install.sh
├── LICENSE
└── AGENTS.md
```

## Install

### Option 1: Clone directly into your Codex skills directory

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git \
  "${CODEX_HOME:-$HOME/.codex}/skills/ai-fortune-cookie"
```

### Option 2: Clone anywhere and install from the repo

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh
```

`./install.sh --copy` copies the runtime files instead of symlinking the repo. `./install.sh --force` replaces an existing install.

## Usage

Prompt examples:

- `Use $ai-fortune-cookie to give me a fortune for this branch.`
- `I am waiting on tests. Use $ai-fortune-cookie and keep it dry.`
- `Use $ai-fortune-cookie for a short philosophical fortune about this refactor.`

Typical output:

> Your migration is teaching the schema patience; stable systems are usually assembled by people willing to rename one more column.

## Local Context Model

The helper script gathers small, fast signals:

- Git root, branch, and changed files when the directory is a repository
- Stack hints from files like `package.json`, `pyproject.toml`, `Cargo.toml`, and `go.mod`
- Recent shell history from common local history files when available
- Optional user-profile hints from `~/.codex/USER.md`, `~/.codex/CLAUDE.md`, or similar local files

If a source is missing, the skill falls back cleanly instead of guessing.

## Development

```bash
python3 scripts/context_snapshot.py --cwd .
python3 /path/to/skill-creator/scripts/quick_validate.py .
```
