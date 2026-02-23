# Connectotron Agent Skills

A collection of AgentSkills for OpenClaw and other AI coding agents.

## 🎯 Skills

- **[skill-evaluator](./skills/skill-evaluator/)** - Systematically evaluate and compare AgentSkills using objective data (GitHub metrics, directory activity, issue responsiveness). Helps answer "What's the best skill for X?"

## 📦 Installation

### Via ClawHub
```bash
clawhub install skill-evaluator
```

### Via npx skills
```bash
npx skills add Connectotron/agent-skills --skill skill-evaluator
```

### Manual Installation
```bash
git clone https://github.com/Connectotron/agent-skills
cp -r agent-skills/skills/skill-evaluator ~/.openclaw/skills/
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on adding new skills.

## 📋 Skill Quality Standards

All skills in this repository follow the [AgentSkills specification](https://agentskills.io) and undergo validation before publication.

## 📄 License

MIT License - See [LICENSE](./LICENSE)

## 🔗 Links

- [AgentSkills Specification](https://agentskills.io)
- [ClawHub Marketplace](https://clawhub.ai)
- [OpenClaw Documentation](https://docs.openclaw.ai)
