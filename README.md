# phased-workflow

A Claude Code plugin for a phased, review-before-commit way of working, in any project.

| Skill | What it does |
|---|---|
| `/working-rules` | The rules: ask before planning, one phase per turn, the phase loop, plan format, editing, context cost, code style |
| `/init-rules` | Writes those rules into the current project's `CLAUDE.md`, with its build and test commands filled in |
| `/quick-check` | Compile check of the uncommitted files: the IDE's MCP tools when connected, else the build tool |
| `/test [module] [Class#method]` | One module's or one test's run (Maven, Gradle, npm, Cargo, Go, pytest); totals and failures only |
| `/unused-imports` | Lists and removes the unused or repeated imports of changed Java files (script bundled) |
| `/phase-recap` | End-of-phase recap: changed (commit hashes), verified, to test, and a `/compact` line |

The phase loop it sets up:

```
implement → /quick-check → /test → /unused-imports → /code-review medium → commit → /phase-recap → stop
```

## Install

In Claude Code:

```
/plugin marketplace add BenjaminGROISNE/phased-workflow
/plugin install phased-workflow@phased-workflow
```

The repository is private, so the machine needs GitHub access to it (`gh auth login`, or a git credential).
From a local clone instead:

```
/plugin marketplace add ~/IdeaProjects/phased-workflow
```

Then, in each project where the rules should load every session without being invoked:

```
/init-rules
```

A plugin cannot ship a `CLAUDE.md`; `/init-rules` writes the section into the project's own. The project's
`CLAUDE.md` always outranks the plugin's skills.

## Update

```
/plugin marketplace update phased-workflow
```

Bump `version` in `.claude-plugin/plugin.json` when a skill changes.
