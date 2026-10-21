---
name: quick-check
description: Check the files changed and not yet committed for compile errors in seconds — through the IDE's MCP tools when an IDE is connected, else the project's own build or type check on just the touched modules. Use after an edit, before /test, or when asked whether the code compiles.
---

# quick-check

`/quick-check [--warnings] [file…]`. No file: every file changed and not committed, in the repository and
its submodules. It reports; it fixes nothing unless asked.

## 1. The files

```bash
cd "$(git rev-parse --show-toplevel)"
{ git status --porcelain --untracked-files=all | awk '$1 != "D" {print $NF}'
  git submodule foreach --quiet \
    'git status --porcelain --untracked-files=all | awk -v p="$sm_path/" '"'"'$1 != "D" {print p $NF}'"'"'' 2>/dev/null
}
```

Keep source files only. None: say "nothing changed" and stop.

## 2. The IDE first

When an IDE MCP server is connected (JetBrains: `mcp__idea__*`, or another IDE's equivalent):

- For each file, its problems tool (`get_file_problems`) with the path relative to the project root and
  **errors only**.
- Then its build tool (`build_project`) limited to those files when it takes a file list.

Warnings only when asked (`--warnings`), and only those on lines this change touched: the
`git diff -U0 -- <file>` hunks (`@@ … +start,count @@`); an untracked file counts whole.

A tool that is missing or fails (IDE closed, project not open): go to step 3, and say the IDE was not used.

## 3. The build tool

Compile only what owns the files, in one run:

| Project | Command |
|---|---|
| Maven | `mvn -B -q -pl <modules> -am compile` (`test-compile` when a test changed) |
| Gradle | `./gradlew <:module>:compileJava` (`compileTestJava` when a test changed) |
| TypeScript | `npx tsc --noEmit -p <tsconfig>` |
| Rust | `cargo check -p <crate>` (`--tests` when a test changed) |
| Go | `go vet ./<pkg>/...` |
| Python | the project's type checker or linter on the files (`ruff check`, `mypy`) |

A command in the project's CLAUDE.md wins over this table.

## 4. Report

`path:line: message`, errors (then, with `--warnings`, the touched-line warnings) grouped by file. Then
`IDE build ok`, `<tool> ok`, or the first failure, and which of the two ran.
