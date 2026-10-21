---
name: init-rules
description: Add the working rules (planning, the one-phase-per-turn loop, editing, context, code style) to the current project's CLAUDE.md, with the project's own build, test and check commands filled in. Use when asked to set up these rules in a project, or with /init-rules.
---

# init-rules

Writes the rules of `/working-rules` into the project's CLAUDE.md as one section, `## How to work here`,
so they load in every session without invoking a skill.

## 1. Read the project

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ls; ls CLAUDE.md AGENTS.md 2>/dev/null
ls pom.xml build.gradle* settings.gradle* package.json Cargo.toml go.mod pyproject.toml Makefile 2>/dev/null
git submodule status 2>/dev/null | head
```

From these, find:

| Item | Where |
|---|---|
| build | `mvn -B -q compile`, `./gradlew build`, `npm run build`, `cargo build`, `go build ./...`, `make` |
| one module's or one test's run | the same tool's test command and its filter flag |
| lint or type check | `npm run lint`, `tsc --noEmit`, `cargo clippy`, `ruff check`, … when the project defines it |
| repositories | the root, plus submodules when `git submodule status` lists any |

An existing CLAUDE.md that already names a command wins over a guess. A command you cannot find: ask the user
with `AskUserQuestion` rather than invent one.

## 2. Write the section

Start from the block in step 4. Fill each `<…>` placeholder; drop a line whose tool the project lacks (no
Java: drop `/unused-imports`).

- **No CLAUDE.md**: create it with a one-line title and the section.
- **A CLAUDE.md with `## How to work here`**: show the user the differences and ask before replacing it.
- **A CLAUDE.md without it**: append the section at the end with `Edit`. Never reorder or reword what the file
  already says.
- A rule the file already states differently: keep the file's, drop that line from the section, and say so.

## 3. Report

The file path, whether it was created or appended, and the commands filled in. Do not commit unless asked.

## 4. The block

````markdown
## How to work here

- **Planning — ask, don't assume.** Use `AskUserQuestion` before writing a plan whenever the answer changes
  what gets built; lead with a labelled recommendation. Routine calls are yours.
- **Plan format — `## Phase <N> — <title>`**, `(ask)` in the title when the phase needs the user's decision.
- **Multi-phase work — one phase per turn.** Implement → `/quick-check` → `/test <module> [Class#method]` →
  `/unused-imports` (once, not per file) → `/code-review medium` on the phase's diff (fix what it confirms,
  list the rest in the recap) → one commit per touched repository → `/phase-recap` → stop. A phase commits on
  its targeted tests; the whole build (`<full build command>`) runs once, at the plan's end.
- **Commands.** Build: `<build command>`. Test one module or test: `<test command>`. Check: `<lint command>`.
- **Editing — `Edit`/`Write` only, never `sed -i`/perl/python heredocs on tracked files**, however
  mechanical. Bash is for reading and building. A file mostly rewritten is one `Write`.
- **Context is the cost — every call re-reads the whole conversation.** Send independent calls in one message;
  find with `grep -n` and read a range. Between phases the recap gives a `/compact` line.
- **Subagents — budget, not fan-out.** Do the work inline; spawn only when asked or when the search is wide
  and the answer small.
- **Never push unless asked.** Report failures with their decisive line; never claim an unrun check passed.
- **Code style**: type a closed set, not a bare `String` (enum with `id()` + `displayName()`, total `fromId` →
  `UNKNOWN`); a shared type owns the labels its consumers would rebuild; minimise mutable state; match the
  surrounding comment density; import a type, never write it fully qualified unless names clash.
````
