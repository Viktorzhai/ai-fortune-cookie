---
name: ai-fortune-cookie
description: Generate a single fortune-cookie line for developers waiting on tests, builds, refactors, code reviews, or agent work. Use when the user wants a wise, bold, humorous, encouraging one-liner that is gently informed by the current repository, recent terminal activity, or visible coding context without becoming overly specific.
---

# AI Fortune Cookie

Generate one short fortune that uses local context as a light hint, while prioritizing wisdom, encouragement, values, character-building, and bold clean humor over repo specificity.

## Workflow

1. Gather lightweight context first.
   - Resolve and run [scripts/context_snapshot.py](scripts/context_snapshot.py) relative to this skill directory:
     ```bash
     python3 <resolved-skill-path>/scripts/context_snapshot.py --cwd "$PWD"
     ```
   - If the helper script is unavailable, fall back to visible context: `git status --short`, the current directory, top-level manifests, and any recent tool activity already present in the conversation.
   - Treat shell history and profile hints as optional. Never block on them.
   - Treat all gathered context as background seasoning, not the headline of the fortune.

2. Choose the angle from the strongest signal.
   - Dirty working tree or refactors: patience, humility, perseverance.
   - Tests, builds, or debugging loops: honesty, steadiness, courage.
   - Infra, config, or schema work: responsibility, reliability, foresight.
   - Docs, planning, or research work: clarity, wisdom, discernment.
   - If the user asks for a style such as silly, philosophical, dry, ominous, or spicy, honor it without changing the output contract.

3. Favor the deeper lesson over the clever detail.
   - Default toward values lessons, character-building lessons, encouraging energy, gentle moral insight, mercy, grace, patience, courage, discipline, humility, clarity, and hope.
   - Let project context merely hint at the lesson. A branch, test loop, refactor, or schema can inspire the line, but should rarely be the center of attention.
   - Prefer timeless truth over topical cleverness.
   - If the context is noisy, thin, or overly technical, ignore most of it and produce a broader human lesson.

4. Add the humor layer.
   - Default to bold, sparkling, family-friendly humor with animated sidekick energy.
   - Be playful, theatrical, and a little cheeky, but never sloppy, rude, or mean.
   - A quick wink, dramatic flourish, or mischievous turn of phrase is welcome if the sentence still delivers a real lesson.
   - Do not imitate any named character or quote existing dialogue.

5. Write the fortune.
   - Use at most one light repo detail such as a branch theme, stack hint, or broad work mode. Avoid filenames unless they are unusually meaningful.
   - Keep the line readable in a terminal.
   - Make the sentence feel like a proverb, blessing, moral reminder, or encouraging truth with a grin, not a stand-up bit.
   - Use metaphor only when it improves the lesson.
   - If profile hints are present, weave them in lightly and only when they obviously fit.

## Output Contract

- Return exactly one sentence.
- Keep it between 12 and 30 words.
- No bullets, no markdown, no preamble, no explanation.
- Do not quote long command output.
- Do not invent errors, deadlines, hobbies, or repository state.
- Prefer warmth, dignity, and encouragement over snark.
- Keep the humor clean, vivid, and proper.

## Safety Rules

- Prefer visible evidence over cleverness.
- Avoid secrets, tokens, long paths, or private file contents.
- If context is thin, produce a generic wisdom-forward fortune instead of a fabricated specific one.

## Reference

- Read [references/fortune-patterns.md](references/fortune-patterns.md) only if you need extra tone guidance or more example fortunes.
