---
name: ralph-orchestrator
description: Autonomous programming task execution using ralph-orchestrator's event-driven loop system. Kicks off TDD implementation, bug fixes, feature development, and refactoring with multi-hat coordination, external verification gates (tests/linters/type checks), and automatic iteration until completion. Use when you need iteration-to-perfection on coding tasks: (1) Complex features requiring TDD workflow (RED → GREEN → REFACTOR), (2) Bug fixes needing reproduction and verification, (3) Spec-driven development from PDD output, (4) Refactoring with quality gates, (5) Any task where external verification (tests must pass, linters must pass, build must succeed) is critical. NOT for simple one-liner fixes, exploratory code reading, or tasks requiring human judgment at each step.
metadata:
  version: 1.0.0
  author: Connectotron
  license: MIT
  requires:
    bins: [ralph]
---

# Ralph Orchestrator

Autonomous programming task execution using ralph-orchestrator's event-driven loop system with external verification gates and iteration-to-perfection workflow.

## What Ralph Orchestrator Provides

Ralph is a Rust-based autonomous coding loop that uses an event-driven "hat" system:

- **Specialized hats** coordinate through typed events (Planner → Builder → Validator → Committer)
- **External verification gates** reject incomplete work (tests, linters, type checkers must pass)
- **Fresh context each iteration** with persistent memories across sessions
- **Token tracking & spending limits** for cost control
- **Git checkpointing** with automatic rollback on catastrophic failures

## Prerequisites

Install ralph CLI:
```bash
brew install ralph-orchestrator
```

Or via Cargo:
```bash
cargo install ralph-cli
```

Verify installation:
```bash
ralph --version
```

**Backend requirement:** At least one AI CLI tool (claude, kiro, gemini, codex, opencode) with API key configured.

## Quick Start

### Simple Task

```bash
cd ~/my-project
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Add a --verbose flag to the CLI that enables debug logging

Acceptance criteria:
- -v and --verbose flags both work
- When enabled, shows detailed output
- Tests verify verbose vs. normal mode
EOF

ralph run
```

**Expected:** 2-3 iterations, ~$0.15-0.30 with Claude Sonnet

### Complex Feature with TDD

```bash
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Implement user authentication:
- Email/password login endpoint
- JWT token generation (24-hour expiry)
- Password hashing with bcrypt
- Rate limiting: 5 attempts per 15 minutes per IP

Success criteria:
- All tests pass
- No TypeScript errors
- Manual E2E test confirms login flow works
EOF

ralph run --tui --max-iterations 30
```

**Expected:** 8-12 iterations, ~$1.20-1.80

### From PDD Output (Spec-Driven)

```bash
ralph run --preset code-assist --prompt ".ralph/specs/my-feature"
```

Ralph reads tasks from `.ralph/specs/my-feature/tasks/*.code-task.md` and implements them one at a time using TDD.

## Core Workflows (Presets)

Ralph includes 15 built-in presets. Most commonly used:

- **code-assist** — TDD implementation from specs/tasks/descriptions (default)
- **bugfix** — Bug reproduction + fix + verification
- **feature** — Feature development with integrated code review
- **refactor** — Code refactoring with quality gates
- **spec-driven** — Specification-driven development
- **pdd-to-code-assist** — Full idea-to-code pipeline (planning + implementation)

List all presets:
```bash
ralph init --list-presets
```

See [references/presets-guide.md](references/presets-guide.md) for detailed preset documentation.

## How It Works

### Event-Driven Hat System

Ralph uses specialized "hats" (personas) that subscribe to events and publish new events:

1. **📋 Planner** (`build.start` → `tasks.ready`) — Detects input type, bootstraps context
2. **⚙️ Builder** (`tasks.ready` → `implementation.ready`) — TDD implementation (RED → GREEN → REFACTOR)
3. **✅ Validator** (`implementation.ready` → `validation.passed` or `validation.failed`) — Exhaustive quality gate
4. **📦 Committer** (`validation.passed` → `commit.complete`) — Creates conventional commits

**Critical Builder constraint:** ONE TASK AT A TIME (prevents scope creep, maintains focus)

### Validation Gates (All Must Pass)

Validator runs comprehensive checks:
- All tests pass (runs full suite directly)
- Build succeeds (no warnings-as-errors)
- Linting passes (ruff, eslint, clippy, etc.)
- Type checking passes (pyright, tsc, etc.)
- YAGNI check (no speculative code)
- KISS check (simplest solution)
- Manual E2E test (from plan.md if available)

**If any gate fails:** Builder retries with fresh context and Validator feedback.

### Confidence Protocol (Never Blocks on Human)

Builder uses confidence scoring for decisions:
- **>80:** Proceed autonomously
- **50-80:** Proceed + document in `.ralph/agent/decisions.md`
- **<50:** Choose safe default + document

**Safe defaults:**
- Prefer reversible over irreversible
- Prefer additive over destructive
- Prefer narrow scope over broad changes
- Prefer existing patterns over novel approaches

**Result:** Loop never blocks waiting for human input on implementation decisions.

## Key Features

### Token Tracking & Spending Limits

```bash
ralph run --max-spend 5.00  # Stop if cost exceeds $5
```

TUI shows real-time:
- Tokens consumed (current iteration + total)
- Cost so far / limit
- Projected final cost

### Git Checkpointing

Auto-commits after each iteration:
```bash
ralph checkpoint list           # Show all checkpoints
ralph checkpoint restore 5      # Rollback to iteration 5
```

**Recovery:** If iteration fails catastrophically, rollback to last good state.

### Memories & Tasks

Persistent learning across sessions:
- **Memories:** `.ralph/agent/memories/` — Lessons learned, gotchas, design decisions
- **Tasks:** `.ralph/tasks.json` — Runtime work tracking

Agent doesn't forget across sessions; resumes long-running work after restarts.

### Monitoring Options

**Terminal UI:**
```bash
ralph run --tui
```

Real-time monitoring with live logs, iteration counter, token usage graph, cost tracker.

**Telegram Integration:**
```bash
ralph bot init                  # Setup via BotFather
ralph bot token set <TOKEN>     
ralph bot subscribe <CHAT_ID>   
ralph run --telegram            # Enable notifications
```

Remote monitoring with `/status`, `/tasks`, `/restart` commands.

## When to Use Ralph vs. OpenClaw Sub-Agents

| Use Ralph When | Use OpenClaw Sub-Agents When |
|----------------|------------------------------|
| Single feature needs iteration-to-perfection | Multi-step workflow (N independent tasks) |
| TDD workflow critical (RED → GREEN → REFACTOR) | Each task usually succeeds first try |
| External verification gates needed | Manual verification acceptable |
| Cost tracking important (spending limits) | OpenClaw session tracking sufficient |
| Task may need 5-15 iterations to get right | Task complexity well-understood upfront |

**Recommendation:** Use ralph for complex features where quality gates are critical. Use OpenClaw sub-agents for multi-task workflows where each task is independent.

## Configuration

Ralph uses `ralph.yml` for configuration. Generated by `ralph init --preset <name>`.

Key settings:
```yaml
event_loop:
  max_iterations: 100              # Stop after N iterations
  max_runtime_seconds: 14400       # 4 hours max
  checkpoint_interval: 5           # Checkpoint every N iterations
  completion_promise: "LOOP_COMPLETE"

cli:
  backend: "kiro"                  # claude, gemini, codex, opencode
  prompt_mode: "arg"

core:
  guardrails:
    - "Fresh context each iteration"
    - "Verification is mandatory"
    - "YAGNI ruthlessly"
    - "KISS always"
```

## Troubleshooting

**Loop never ends:**
- Weak completion criteria in prompt
- Task impossible (tests can't pass)
- Missing dependencies or environment issues

**Solution:** Add specific acceptance criteria to PROMPT.md. Verify tests pass manually first.

**Loop ends too early:**
- Completion promise triggered prematurely
- External verification too lenient

**Solution:** Strengthen validation gates in preset configuration.

**High cost:**
- Too many iterations (poorly scoped task)
- Expensive model (Claude Sonnet vs. Kiro)

**Solution:** Set `--max-spend` limit. Consider cheaper backend for experimentation.

See [references/troubleshooting.md](references/troubleshooting.md) for detailed solutions.

## Examples

### Example 1: Add Verbose Flag

```bash
cd ~/my-cli-project
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Add --verbose flag for debug logging
EOF

ralph run
```

**Iterations:** 2-3  
**Cost:** ~$0.15-0.30

### Example 2: User Authentication (TDD)

```bash
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Implement user authentication with email/password, JWT tokens, bcrypt hashing, and rate limiting
EOF

ralph run --tui --max-iterations 30
```

**Iterations:** 8-12  
**Cost:** ~$1.20-1.80

### Example 3: Full Idea-to-Code (PDD Pipeline)

```bash
ralph init --preset pdd-to-code-assist

cat > PROMPT.md << 'EOF'
Add blog search feature: full-text search, tag filtering, sorting by relevance/date
EOF

ralph run --tui --max-iterations 100 --max-runtime-seconds 14400
```

**Iterations:** 30-60  
**Cost:** ~$4.50-9.00

See [references/examples.md](references/examples.md) for detailed workflow breakdowns.

## Advanced Usage

### Parallel Loops with Worktrees

```bash
# Create worktrees for parallel tasks
git worktree add /tmp/task-a -b feature/task-a uat
git worktree add /tmp/task-b -b feature/task-b uat

# Run ralph in each worktree
cd /tmp/task-a && ralph run --prompt "Implement Task A" &
cd /tmp/task-b && ralph run --prompt "Implement Task B" &

# Merge sequentially after completion
cd ~/repo && git checkout uat
git merge feature/task-a
git merge feature/task-b
```

### Custom Presets

Create `my-preset.yml` with custom hat configurations:
```bash
ralph run --config my-preset.yml
```

### Web Dashboard (Experimental)

```bash
ralph web               # Auto-opens browser
ralph web --no-open     # Skip auto-open
```

Real-time monitoring of loop activity, event history, and hat coordination.

## Related Skills

- **coding-agent** — Simpler coding delegation (good for exploratory work, one-shot tasks)
- **github** — GitHub operations and PR management (use after ralph commits)
- **skill-creator** — Create custom AgentSkills (if ralph-orchestrator doesn't fit your needs)

## References

For detailed documentation:
- [Preset Guide](references/presets-guide.md) — All 15 built-in presets explained
- [Troubleshooting](references/troubleshooting.md) — Common issues and solutions
- [Examples](references/examples.md) — Detailed workflow breakdowns with expected costs

Upstream documentation: https://mikeyobrien.github.io/ralph-orchestrator/
