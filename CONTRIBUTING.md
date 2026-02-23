# Contributing to Connectotron Agent Skills

Thank you for your interest in contributing! This document outlines the process for adding new skills to this repository.

## Development Workflow

We use a **UAT → Main** branching strategy:

1. **Development:** Make changes in `uat` branch
2. **Testing:** Validate skills work correctly
3. **Merge:** PR from `uat` → `main` when ready for release
4. **Publish:** Skills are published to ClawHub from `main`

## Adding a New Skill

### 1. Copy the Template

```bash
cp -r template/ skills/your-skill-name/
```

### 2. Edit SKILL.md

Update the frontmatter and content in `skills/your-skill-name/SKILL.md`:

```markdown
---
name: your-skill-name
description: Clear description of what your skill does. Used for discovery.
metadata:
  version: 1.0.0
  author: Your Name
  license: MIT
  tags: [tag1, tag2, tag3]
---

# Your Skill Name

[Your skill instructions here]
```

### 3. Add Supporting Files

- `references/` — Supporting documentation (loaded lazily)
- `examples/` — Usage examples and demonstrations
- `scripts/` — Optional bundled tools

### 4. Validate Your Skill

```bash
./tools/validate-skill.sh skills/your-skill-name/
```

### 5. Submit a Pull Request

1. Create branch from `uat`: `git checkout -b feature/your-skill uat`
2. Commit your skill: `git add skills/your-skill-name && git commit`
3. Push and create PR targeting `uat` branch
4. After approval, it will be merged to `uat` for testing
5. When ready, `uat` will be merged to `main` and published

## Skill Quality Guidelines

### SKILL.md Best Practices

- **Keep instructions under 500 lines** — Move detailed docs to `references/`
- **Be specific and actionable** — Clear steps, not vague descriptions
- **Include at least one example** — Show the skill in action
- **Use progressive disclosure** — Main instructions concise, details in references
- **Follow AgentSkills spec** — See [agentskills.io/specification](https://agentskills.io/specification)

### File Structure

```
skills/your-skill-name/
├── SKILL.md              # Required: Main instructions
├── references/           # Optional: Supporting docs
│   └── example-ref.md
├── examples/             # Optional: Usage examples
│   └── example-usage.md
└── scripts/              # Optional: Bundled tools
    └── helper.sh
```

### Frontmatter Requirements

- `name` — Skill identifier (lowercase-with-dashes)
- `description` — Clear, concise (used for search)
- `metadata.version` — Semantic versioning (1.0.0)
- `metadata.tags` — Relevant keywords for discovery

## Testing

Before submitting, test your skill:

1. Install locally: `cp -r skills/your-skill ~/.openclaw/skills/`
2. Start OpenClaw session
3. Trigger skill and verify it works
4. Check for errors or unclear instructions

## Code of Conduct

- Be respectful and constructive
- Follow existing patterns and conventions
- Ask questions if unsure
- Provide helpful feedback on others' PRs

## Need Help?

- Open an issue for questions
- Review existing skills for examples
- Check [AgentSkills documentation](https://agentskills.io)

Thank you for contributing!
