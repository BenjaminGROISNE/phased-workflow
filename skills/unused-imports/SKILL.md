---
name: unused-imports
description: Remove, in one pass, the unused and repeated imports of the Java files a phase changed — once per phase, after the build is green and before /code-review, instead of fixing imports file by file while working. Use when a phase reaches its import step, or when asked to clean Java imports.
---

# unused-imports

Java only. While a phase is under way, leave imports alone: an import that turns unused mid-phase is removed
here, once. The compiler does not report them, so nothing else catches them.

## 1. List them

The script `unused-imports.sh` lies beside this file (this skill's base directory).

```bash
cd "$(git rev-parse --show-toplevel)"
bash <skill base directory>/unused-imports.sh            # every uncommitted .java file, repo and submodules
```

Other scopes: `bash …/unused-imports.sh <file>…`, or `bash …/unused-imports.sh --since <ref>` for what the
current repository changed since a commit. Each line is `path:line: import …;`, with `(repeated)` for a
second copy. Exit 0 and no output: nothing to do, go on to the review.

## 2. Keep only this phase's

A listed file the phase did not touch is not this phase's: leave it and say so in the recap. Clean only the
files the phase changed.

## 3. Remove them

`Edit` each listed line out, with the line break after it; never `sed -i`. Several in one file: one `Edit` per
line, or one over the import block. Keep the blank lines between import groups as the file had them; an import
group left empty loses its blank line too.

The check keeps an import whose name only a comment or javadoc mentions (`{@link X}` needs it): leave those.

## 4. Check

Run the script again: no output. Then compile the touched modules (`/quick-check`): a wrong removal fails the
compile, not the script.
