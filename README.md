# AI Fortune Cookie

Fortune-cookie grammar, repo-aware nuance, and just enough theatrical nerve.

AI Fortune Cookie is a cross-agent skill for `Codex`, `Claude Code`, `Gemini CLI`, and `Cursor`. It treats one-line encouragement like a constrained writing problem: preserve the elegant syntax of fortune-cookie wisdom, borrow only a hint of project context, and land the sentence with clean, memorable humor.

In other words: it is a tiny compiler for morale.

## What Makes It Different

- **Fortune-cookie syntax matters.** The output is intentionally short, aphoristic, and shaped like actual fortune-cookie wisdom instead of generic motivational filler.
- **Project context is seasoning, not soup.** Branch state, test noise, and repo mood can color the line, but the lesson still comes first.
- **Humor with manners.** The tone aims for bold, playful, animated-sidekick energy without turning crude, mean, or sloppy.
- **Local-first by design.** It relies on lightweight local context, not external APIs or heavy indexing.
- **One concept, multiple hosts.** Codex, Claude Code, and Gemini CLI consume the same `SKILL.md` package; Cursor gets a project rule version.

## Sample Fortunes

> This branch may be wearing clown shoes, but patience can still teach it enough manners to enter the palace.

> A noisy test suite is not your enemy; it is a dramatic little trumpet for the truth.

> Refactors rarely arrive in a tuxedo, but good discipline can still teach them to bow.

> Courage, dear builder: even tangled code can be persuaded to sit up straight.

> When the work gets noisy, choose clarity first and let the panic trip over its own cape.

## Host Support

- `Codex`: install as a skill in `~/.codex/skills/ai-fortune-cookie`
- `Claude Code`: install as a skill in `~/.claude/skills/ai-fortune-cookie`
- `Gemini CLI`: install as a skill in `~/.gemini/skills/ai-fortune-cookie`
- `Cursor`: install as a project rule in `.cursor/rules/ai-fortune-cookie.mdc`

Tested install flows:

- Copy install
- Symlink install
- Direct in-place install for Codex, Claude Code, and Gemini CLI
- `--host all`

## Install

By default, `install.sh` copies files, which is the safest cross-host mode. Use `--symlink` if you want the installed host path to track live edits in this repo.

For `Codex`, `Claude Code`, and `Gemini CLI`, there are two valid patterns:

1. Clone anywhere, then run `./install.sh --host ...`
2. Clone directly into the host skill directory, which already counts as the install

### Codex

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host codex
```

Direct install:

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git \
  ~/.codex/skills/ai-fortune-cookie
```

### Claude Code

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host claude
```

Direct install:

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git \
  ~/.claude/skills/ai-fortune-cookie
```

### Gemini CLI

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git
cd ai-fortune-cookie
./install.sh --host gemini
```

Direct install:

```bash
git clone https://github.com/Viktorzhai/ai-fortune-cookie.git \
  ~/.gemini/skills/ai-fortune-cookie
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
- `CODEX_HOME`, `CLAUDE_HOME`, and `GEMINI_HOME` can override default home directories

## Updating

There is no background auto-updater.

How updates work:

- If you cloned directly into a host skills directory, update with `git pull` in that installed folder.
- If you used the default copy install, run `git pull` in your source repo and then rerun `./install.sh --host ... --force`.
- If you used `--symlink`, `git pull` in the source repo is enough.
- For Cursor copy installs, rerun `./install.sh --host cursor --project /path/to/project --force`.
- If you run `install.sh` from a repo that is already cloned directly into the matching skill directory, the installer now safely detects that and does nothing.

Examples:

```bash
cd ~/.codex/skills/ai-fortune-cookie && git pull
cd ~/.claude/skills/ai-fortune-cookie && git pull
cd ~/.gemini/skills/ai-fortune-cookie && git pull
```

Copy-install refresh:

```bash
cd ai-fortune-cookie
git pull
./install.sh --host all --project /path/to/project --force
```

## How It Works

The skill gathers small, fast local signals:

- Git root, branch, and changed files
- Top-level stack hints from files like `package.json`, `pyproject.toml`, `Cargo.toml`, and `go.mod`
- Optional recent shell history
- Optional local profile hints

Then it applies a writing contract:

- exactly one sentence
- 12 to 30 words
- project nuance as a hint, not the whole point
- values and character-building first
- humor that is bold, clean, and proper

## Repo Layout

```text
.
├── SKILL.md
├── agents/openai.yaml
├── scripts/context_snapshot.py
├── scripts/verify_installs.sh
├── references/fortune-patterns.md
├── targets/cursor/rules/ai-fortune-cookie.mdc
├── docs/host-compatibility.md
├── docs/fortune-cookie-skill-research.md
├── install.sh
├── LICENSE
└── AGENTS.md
```

## Development

```bash
python3 scripts/context_snapshot.py --cwd .
python3 /path/to/skill-creator/scripts/quick_validate.py .
./scripts/verify_installs.sh
./install.sh --host all --project /tmp/fortune-cookie-cursor-test --force
```

## Compatibility Notes

Packaging decisions and host-specific constraints are summarized in [docs/host-compatibility.md](docs/host-compatibility.md).
