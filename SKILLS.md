# Skills

Skill definitions shared by every agent on this machine. The `skills/`
directory is the source of truth: `bootstrap.sh` links it into the locations
each agent reads.

## Layout

```text
skills/
├── reviewer/                     # Original skill added here
├── aws-*/                        # Personal AWS serverless course
├── course-*/                     # Personal course tooling
├── guided-project-builder/       # Personal teaching workflow
├── pdf-to-markdown/              # Personal PDF conversion workflow
├── technical-course-factory/     # Personal course generator
└── <vendor>/                     # Third-party skills, vendored (see below)
```

Each skill is a directory with a `SKILL.md` and optional `scripts/`,
`references/`, `assets/`, or `agents/` next to it. Paths inside a skill are
relative to its directory.

## Discovery and precedence

OpenCode reads the native global directory and keeps it above the compatibility
directories, so the repo always wins:

1. `~/.config/opencode/skills` → symlink to this directory (native, preferred)
2. `~/.claude/skills` → one symlink per skill (Claude Code compatibility)
3. `~/.agents/skills` → symlink to this directory (skills CLI and Codex)

`~/.claude/skills` stays a real directory because Claude Code writes synced
claude.ai skills to `~/.claude/skills/synced/`; each repo skill is linked
individually there.

OpenCode IDs come from the directory name. Keep them lowercase kebab-case and
unique; the frontmatter `name` is only a display label. A skill without a
`description` is registered but not advertised to the model.

## Add or update a skill

- **Personal skill**: create `skills/<id>/SKILL.md` here and re-run
  `./bootstrap.sh` (or link it by hand) so the agents pick it up.
- **Third-party skill**: install it with the `skills` CLI; because
  `~/.agents/skills` points here, new files land in this repo. Review them and
  commit the result.
- **Changes** are picked up live by OpenCode and Claude Code; no restart needed.

## Vendored third-party skills

These are copied from their upstream projects so a fresh machine does not need
network access. See each upstream repository for its license.

| Skill | Upstream |
| --- | --- |
| `api-design-principles` | [wshobson/agents](https://github.com/wshobson/agents) |
| `brainstorming` | [obra/superpowers](https://github.com/obra/superpowers) |
| `create-readme` | [github/awesome-copilot](https://github.com/github/awesome-copilot) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) |
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) |
| `git-commit` | [github/awesome-copilot](https://github.com/github/awesome-copilot) |
| `microsoft-foundry` | [microsoft/azure-skills](https://github.com/microsoft/azure-skills) |
| `vercel-react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
| `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
