# Contributing to Connectotron Agent Skills

Thank you for your interest in contributing! This document outlines the process for adding new skills to this repository.

## Development Workflow

We use a **UAT → Main** branching strategy:

1. **Development:** Make changes in `uat` branch
2. **Testing:** Validate skills work correctly
3. **Merge:** PR from `uat` → `main` when ready for release
4. **Publish:** Skills are published to ClawHub from `main`

---

## Release Process

We use **automated releases** powered by [release-me](https://github.com/dev-build-deploy/release-me) with integrated ClawHub publishing. Every commit to `main` can trigger a release, depending on commit message format.

### How It Works

```
Commit to main → release-me analyzes commits → Creates GitHub Release → Publishes to ClawHub
```

**Automated:**
- Version increments based on [Conventional Commits](https://www.conventionalcommits.org/)
- Changelog auto-generated and categorized
- GitHub Release created with tag
- Skill(s) automatically published to ClawHub

---

### Method 1: Automated Release (Recommended)

Use **conventional commit messages** when merging to `main`:

#### Version Bumps

| Commit Type | Version Change | Example |
|-------------|----------------|---------|
| `fix:` | Patch (1.0.0 → 1.0.1) | Bug fixes |
| `feat:` | Minor (1.0.0 → 1.1.0) | New features |
| `feat!:` or `BREAKING CHANGE:` | Major (1.0.0 → 2.0.0) | Breaking changes |

#### Conventional Commit Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Examples:**

```bash
# New skill (minor bump)
git commit -m "feat(skill-evaluator): initial release"

# Bug fix (patch bump)
git commit -m "fix(skill-evaluator): correct directory-level commit analysis"

# Breaking change (major bump)
git commit -m "feat(skill-evaluator)!: redesign evaluation criteria

BREAKING CHANGE: Evaluation now requires GitHub token for API access"

# Documentation (no version bump)
git commit -m "docs(skill-evaluator): add usage examples"

# Chore (no version bump)
git commit -m "chore: update dependencies"
```

#### Commit Types

**Trigger releases:**
- `feat:` — New feature (minor bump)
- `fix:` — Bug fix (patch bump)
- `feat!:` — Breaking change (major bump)
- `BREAKING CHANGE:` in footer — Breaking change (major bump)

**Changelog only (no version bump):**
- `docs:` — Documentation changes
- `chore:` — Maintenance tasks
- `refactor:` — Code refactoring
- `test:` — Test updates
- `ci:` — CI/CD changes

#### Workflow

```bash
# 1. Make changes in uat branch
git checkout uat
git add skills/your-skill/
git commit -m "feat(your-skill): add new feature"
git push origin uat

# 2. Create PR: uat → main
gh pr create --base main --head uat --title "feat(your-skill): add new feature"

# 3. Merge PR (or admin merge)
gh pr merge <PR#> --squash

# 4. Automatic release triggers!
# - GitHub Release created (e.g., v1.1.0)
# - Changelog auto-generated
# - Skill published to ClawHub
```

**Result:** GitHub release created, skill published to ClawHub, changelog updated.

---

### Method 2: Manual Workflow Dispatch

For custom version control or specific skill releases:

1. Go to [Actions → Release](../../actions/workflows/release.yml)
2. Click **"Run workflow"**
3. Fill in:
   - **Skill name:** `skill-evaluator` (required)
   - **Version:** `1.0.0` (optional; auto-increments if blank)
4. Click **"Run workflow"**

**Result:** GitHub release + ClawHub publish with your specified version.

---

### Method 3: Direct Tag (Legacy)

For ClawHub-only publishing without GitHub release:

```bash
git tag skill-evaluator-v1.0.0
git push origin skill-evaluator-v1.0.0
```

**Result:** Publishes to ClawHub only (no GitHub release).

---

### Release Checklist

Before triggering a release:

- [ ] All changes merged to `main`
- [ ] Skill validated: `./tools/validate-skill.sh skills/your-skill/`
- [ ] Changelog-worthy changes documented in commit messages
- [ ] Breaking changes clearly marked with `!` or `BREAKING CHANGE:`
- [ ] Version follows [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`

---

### Monitoring Releases

**GitHub Releases:**
- View: [Releases](../../releases)
- Each release includes auto-generated changelog

**ClawHub:**
- View: [clawhub.com/@robottwo](https://clawhub.com/@robottwo)
- Check publication status: `clawhub list`

**GitHub Actions:**
- View workflow runs: [Actions](../../actions)
- Check logs if release fails

---

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
