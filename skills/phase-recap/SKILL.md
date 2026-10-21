---
name: phase-recap
description: Write the end-of-phase recap — what changed (behaviours, commit hashes per repository), how it was verified, and what the user should test by hand. Use when a phase or a plan's last phase is finished and committed.
---

# phase-recap

Run after the phase is committed. The recap is the turn's last output; nothing is done after it.

## 1. Collect the commits

The commits this session made, in the root repository and in each submodule it moved:

```bash
cd "$(git rev-parse --show-toplevel)"
git log --format='%h %s' --since='<when the phase started>' --author="$(git config user.name)"
git submodule foreach --quiet 'git log --format="$sm_path %h %s" --since="<same>" 2>/dev/null' 2>/dev/null
git status --short
```

Uncommitted changes this session made: say so in the recap; never hide them. Uncommitted changes that are not
this session's: leave them, and list them under *Not mine*.

## 2. Write it

```markdown
Phase <N> is done. <one sentence: what the user can now do or what changed, and what was run to check it>.

**Changed**

| Repository | Commit | What |
|---|---|---|
| `<repo or module>` | `<hash>` | <behaviour, not a file list> |

- **<Behaviour>:** <what it does now, with `path:line` where useful>.
- **Verified:** <exact build and test commands and their result; a skipped check is said, with why>.
- **Left open:** <review findings not fixed, follow-ups>.
- **Not mine:** <dirty files left alone>.

**To test**
- <the steps to see the change by hand: command, click path, input>.
- <what no manual step can reach, and how to reach it instead>.
```

Rules:

- Hashes are short (`%h`), one row per commit.
- Behaviours, not diffs: say what changed for the user, then where.
- Report failures and skipped steps plainly, with the decisive output line.
- The last phase of a plan restates both lists for the whole plan.
- When a next phase follows, end with a line the user pastes before saying proceed. Every call re-reads the
  whole conversation, so the next phase starts cheaper on a compacted one:

  ```
  Before the next phase: /compact Keep: plan <plan file>, phase <N> done (<commit hashes>), decisions and owed checks above; next is phase <N+1> — <title>.
  ```

  The last phase of a plan has no such line.
