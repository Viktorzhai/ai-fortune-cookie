# Host Compatibility

This repo uses one canonical skill package plus one Cursor-specific rule.

## Packaging Decision

- `Codex`: keep the root `SKILL.md` skill package
- `Claude Code`: reuse the same `SKILL.md` package in `~/.claude/skills/`
- `Gemini CLI`: reuse the same `SKILL.md` package in `~/.gemini/skills/`
- `Cursor`: ship a project rule file at `targets/cursor/rules/ai-fortune-cookie.mdc`

## Why This Layout

Claude Code documents `~/.claude/skills/<skill-name>/SKILL.md` and project `.claude/skills/<skill-name>/SKILL.md` as first-class skill locations, with the same `SKILL.md` structure used in this repo.

Gemini CLI also documents Agent Skills as directories containing `SKILL.md`, discovered from `.gemini/skills/` and `~/.gemini/skills/`. That means the existing skill package can be installed there without translation.

Cursor’s reusable instruction system is project rules in `.cursor/rules/*.mdc`, with `AGENTS.md` as a simpler project-root alternative. Cursor does not document a shared `SKILL.md` skill directory, so this repo installs a rule file for Cursor instead of forcing a fake skill abstraction.

## Sources

- Claude Code skills and locations: <https://code.claude.com/docs/en/skills>
- Gemini CLI agent skills and locations: <https://geminicli.com/docs/cli/skills/>
- Gemini CLI skill creation: <https://geminicli.com/docs/cli/creating-skills/>
- Cursor project rules and `AGENTS.md`: <https://docs.cursor.com/context/rules>
- Cursor CLI note about reading `AGENTS.md` and `CLAUDE.md`: <https://docs.cursor.com/en/cli/using>
