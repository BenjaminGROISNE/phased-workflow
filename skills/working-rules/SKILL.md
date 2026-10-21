---
name: working-rules
description: The working rules for this way of working with Claude Code — ask before planning, one phase per turn, the phase loop (implement, test, imports, review, commit, recap, stop), the plan format, editing only through Edit/Write, keeping context cheap, a small subagent budget and the code style. Use at the start of planned or multi-step work, before writing a plan, or when unsure how a phase should end. A project's own CLAUDE.md outranks these rules.
---

# working-rules

These rules apply to any project. A project's CLAUDE.md outranks them where the two differ; `/init-rules`
copies them into a project's CLAUDE.md with its build and test commands filled in.

## Planning: ask, don't assume

- Use `AskUserQuestion` before writing a plan whenever the answer changes what gets built. Lead with a
  labelled recommendation (`(Recommended)` on the first option).
- Routine calls are yours: a conventional default, a fact the code answers. Pick, say so, go on.
- Never re-ask a decision the user made; never survey options you will not pursue.

## Plan format

```markdown
# Plan: <title>

## Context
<why, what the user chose>

## Phase 1 — <title>
<files, behaviour, how it is verified>

## Phase 2 — <title> (ask)
<a phase that needs the user's decision says so in its title>

## Verification (plan end)
```

## Multi-phase work: one phase per turn

Each phase runs this loop, then stops:

1. **Implement.** Only the phase's scope.
2. **Build and test.** `/quick-check` first (fast, IDE when connected), then `/test` on the touched module or
   class. A phase commits on its targeted tests; slow whole-project gates run once, at the plan's end.
3. **Imports.** `/unused-imports` once per phase (Java), not file by file while working.
4. **Review.** `/code-review medium` on the phase's diff. Fix what it confirms; list the rest in the recap.
5. **Commit.** One commit per touched repository, Conventional Commits style. Never push unless asked.
6. **Recap.** `/phase-recap`: what changed (commit hashes), how it was verified, what the user should test.
7. **Stop.** The next phase starts on the user's word.

## Editing

- Edit tracked files with `Edit`/`Write` only, never `sed -i`, perl or python heredocs, however mechanical.
  Bash is for reading and building. Writes under a scratch or temp directory are fine.
- Repeat one change in a file with `Edit` `replace_all`; rename a symbol with the IDE's rename when connected.
- A file mostly rewritten is one `Write`, not a run of `Edit`s.

## Context is the cost

Every call re-reads the whole conversation.

- Send independent calls in one message: a file's edits, a phase's reads.
- Find with `grep -n` and read a range; never read a large file whole to find one method.
- Between phases the recap ends with a `/compact Keep: …` line the user can paste; only the user can run it.

## Subagents: budget, not fan-out

Do the work inline. Spawn only when the user asks, or when a search is wide and its answer small: one scoped
search agent with a capped deliverable. Verify what a subagent reports before acting on it.

## Honesty

- Report failures with the decisive output line; say when a step was skipped and why.
- Never claim a test passed, a build is green or a change works without having run it in this turn.
- Leave changes that are not yours (untracked files, other dirty work) alone, and say so.

## Code style

- Type a closed set; never a bare `String`. An enum with `id()` and `displayName()`, and a total `fromId`
  returning `UNKNOWN`.
- A shared type owns the labels and keys its consumers would otherwise rebuild.
- Minimise mutable state.
- Match the surrounding code: its comment density, naming and idiom.
- Import a type; never write it fully qualified in code unless two names really clash.
- A swallowed exception hides a failure: fail closed, or report it.
