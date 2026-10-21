---
name: test
description: Run one module's tests, or one test class or method, with the project's own build tool, and report only the totals and each failure's decisive line. Use when asked to test a module or a test (`/test api`, `/test core UserServiceTest#login`), after a change, or before a commit.
---

# test

`/test [module] [Class[#method]]`. No module: the project root.

## 1. The command

A test command in the project's CLAUDE.md wins. Otherwise, by the build file at the root:

| Build file | Whole module | One test |
|---|---|---|
| `pom.xml` | `mvn -B -pl <module> test` | add `-Dtest='Class#method' -Dsurefire.failIfNoSpecifiedTests=false` |
| `build.gradle*` | `./gradlew <:module>:test` | add `--tests 'pkg.Class.method'` |
| `package.json` | `npm test --workspace <module>` (or `npm test`) | add `-- -t '<name>'` (jest/vitest) |
| `Cargo.toml` | `cargo test -p <crate>` | add `<name filter>` |
| `go.mod` | `go test ./<pkg>/...` | add `-run '<Regex>'` |
| `pyproject.toml` | `pytest <path>` | `pytest <path>::Class::method` |

A module that tests against its upstreams' installed builds (Maven `~/.m2`, a local registry) needs those
rebuilt first when this session changed them: `mvn -B -q -pl <upstreams> -am install -DskipTests`, or the
tool's equivalent. Otherwise run the module alone: the fast path.

## 2. Run

Send the output to a file and read back only the decisive lines:

```bash
out="$(mktemp -d)/test.txt"
<command> >"$out" 2>&1; echo "exit $?"
grep -E 'Tests run:|FAIL|ERROR|BUILD (SUCCESS|FAILURE)|passed|failed|panicked|^---|error(\[|:)' "$out" | head -60
```

Widen the read (`grep -n -A15 '<failing test>' "$out"`) only for a failure the summary does not explain.
Never count old report directories (`target/surefire-reports`, `build/test-results`): only this run's console
output counts.

## 3. Report

1. The totals, and pass or fail.
2. Each failure as `Class.method:line — <first line of the message>`; a compile error as `path:line: message`.
3. A failure that reads the live environment rather than code (network, a missing service, the checkout's
   state): say so, and do not present it as a code bug.

Fix nothing unless asked; a failing test is reported with its output, never hidden.
