---
name: ai-fortune-cookie
description: Generate a single, context-aware fortune-cookie line for developers waiting on tests, builds, refactors, code reviews, or agent work. Use when the user wants a witty or motivating one-liner tied to the current repository, recent terminal activity, visible coding context, or a short morale boost during idle time.
---

# AI Fortune Cookie

Generate one short fortune that feels tailored to the current work without scanning the whole repository or inventing facts.

## Workflow

1. Gather lightweight context first.
   - Resolve and run [scripts/context_snapshot.py](scripts/context_snapshot.py) relative to this skill directory:
     ```bash
     python3 <resolved-skill-path>/scripts/context_snapshot.py --cwd "$PWD"
     ```
   - If the helper script is unavailable, fall back to visible context: `git status --short`, the current directory, top-level manifests, and any recent tool activity already present in the conversation.
   - Treat shell history and profile hints as optional. Never block on them.

2. Choose the angle from the strongest signal.
   - Dirty working tree or refactors: patience, momentum, resilience.
   - Tests, builds, or debugging loops: calm skepticism and steady progress.
   - Infra, config, or schema work: foundations, reliability, caution.
   - Docs, planning, or research work: clarity, synthesis, direction.
   - If the user asks for a style such as silly, philosophical, dry, ominous, or spicy, honor it without changing the output contract.

3. Write the fortune.
   - Use at most one concrete repo detail such as a changed file, branch theme, stack hint, or recent command pattern.
   - Keep the line readable in a terminal.
   - Use metaphor only when it improves the sentence.
   - If profile hints are present, weave them in lightly and only when they obviously fit.

## Output Contract

- Return exactly one sentence.
- Keep it between 12 and 30 words.
- No bullets, no markdown, no preamble, no explanation.
- Do not quote long command output.
- Do not invent errors, deadlines, hobbies, or repository state.

## Safety Rules

- Prefer visible evidence over cleverness.
- Avoid secrets, tokens, long paths, or private file contents.
- If context is thin, produce a generic engineering fortune instead of a fabricated specific one.

## Reference

- Read [references/fortune-patterns.md](references/fortune-patterns.md) only if you need extra tone guidance or more example fortunes.
