---
name: ralph-orchestrator
description: Autonomous programming task execution with CLI agent rotation and quality gates. Kicks off TDD implementation, bug fixes, feature development, and refactoring using event-driven loop system with multi-hat coordination and external verification (tests/linters/type checks). Supports multiple CLI agents (Claude Code, GitHub Copilot, OpenCode Zen, Gemini CLI) with automatic rotation for quota management and getting unstuck. Use when you need: (1) Quota-managed iteration-to-perfection (rotate agents, never hit limits), (2) Complex features with TDD workflow (RED → GREEN → REFACTOR), (3) Getting unstuck (switch agents when stuck 3+ iterations), (4) Bug fixes with reproduction and verification, (5) Spec-driven development from PDD output. Best practices: maintain 2+ agent subscriptions (quota resilience), write specific acceptance criteria (reduces iterations), use coding-plan-first preference (primary agent for quality, secondary for TDD), rotate agents when stuck (fresh perspective), use PDD for complex tasks (better scoping). NOT for simple one-liner fixes, exploratory code reading, or tasks requiring human judgment at each step.
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

### Simple Task (Quota-Conscious)

```bash
cd ~/my-project
ralph init --preset code-assist

# Use primary agent from your plan
cat > PROMPT.md << 'EOF'
Add a --verbose flag to the CLI that enables debug logging

Acceptance criteria:
- -v and --verbose flags both work
- When enabled, shows detailed output
- When disabled (default), shows minimal output
- Tests verify verbose vs. normal mode
- Manual test: ./cli --verbose command shows debug output
EOF

ralph run --backend copilot --max-iterations 10
```

**Expected:** 2-3 iterations

**Quota management applied:**
- Use secondary agent (Copilot) to save primary (Claude) for complex tasks
- Clear acceptance criteria (reduces iterations)
- Iteration cap prevents runaway usage

**If quota exceeded:** Switch to another agent (`--backend claude` or `--backend gemini`)

### Complex Feature with TDD (Agent Rotation)

```bash
ralph init --preset code-assist

# Use primary agent (best quality)
cat > PROMPT.md << 'EOF'
Implement user authentication:
- Email/password login endpoint POST /auth/login
- JWT token generation (24-hour expiry, HS256 algorithm)
- Password hashing with bcrypt (12 rounds)
- Rate limiting: 5 attempts per 15 minutes per IP (in-memory or Redis)

Success criteria (testable):
- All unit tests pass
- Integration tests verify auth flow
- No TypeScript errors
- ESLint passes
- Manual E2E test scenarios:
  1. Valid credentials → Returns JWT with 24-hour expiry
  2. Invalid credentials → Returns 401
  3. 5 failed attempts from IP A → 6th attempt returns 429
  4. Request from IP B succeeds (independent limits)

DO NOT implement:
- OAuth/SSO (out of scope)
- Password reset flow (separate task)
- Email verification (separate task)
EOF

ralph run --backend claude --tui --max-iterations 30
```

**Expected:** 8-12 iterations

**Quota management + planning applied:**
- Claude agent (best quality, use for important features)
- Iteration cap (30) prevents runaway usage
- Specific acceptance criteria with E2E scenarios
- Clear YAGNI guidance (what NOT to build)
- Manual test scenarios for Validator

**If Claude quota running low, use agent rotation:**
```bash
# Start with secondary agent
ralph run --backend copilot --max-iterations 20

# If stuck, escalate to Claude for breakthrough
ralph run --backend claude --max-iterations 10

# Resume with Copilot after breakthrough
ralph run --backend copilot --max-iterations 10
```

**Quota savings:** Rotating agents spreads load across multiple quotas, maximizing availability.

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

## Cost Control Strategies

Ralph provides multiple levers for controlling costs while maintaining quality.

### Spending Limits (Hard Caps)

```bash
ralph run --max-spend 5.00  # Stop if cost exceeds $5
ralph run --max-spend 10.00 --max-iterations 50  # Combined limits
```

**When to use:**
- Experimentation (unknown task complexity)
- Budget constraints
- Preventing runaway costs on open-ended tasks

### CLI Agent Rotation (Quota Management + Getting Unstuck)

```yaml
# ralph.yml
cli:
  backend: "claude"      # Claude Code (included in Pro plan)
  # backend: "copilot"   # GitHub Copilot (Pro plan)
  # backend: "opencode"  # OpenCode Zen (curated models)
  # backend: "gemini"    # Gemini CLI (free tier available)
```

**Strategy:** Rotate across multiple CLI agents to manage quotas and break through when stuck.

**Coding-plan-first workflow:**
```bash
# Primary agent (best quality, generous quota)
ralph run --backend claude --max-iterations 15

# If quota hit, switch to secondary agent
ralph run --backend copilot --max-iterations 15

# Free tier overflow if both at quota
ralph run --backend gemini --max-iterations 15
```

**Benefits:**
1. **Quota resilience:** Multiple agents = never blocked by single quota limit
2. **Getting unstuck:** Different agent brings fresh perspective
3. **Agent strengths:** Match task type to best agent

**Getting unstuck (escalation):**

If agent stuck after 10-15 iterations (validation keeps rejecting):

```bash
# Watch for stuck signals:
# - Same validation error 3+ times
# - No validation passes after 10-15 iterations

# Switch to different agent (fresh model perspective)
ralph run --backend claude --max-iterations 10  # Breaks through differently

# Resume with original agent after breakthrough
ralph run --backend copilot --max-iterations 10
```

**Agent quotas (typical):**
- **Claude Code:** ~350 requests/12h (Claude Pro $20/mo)
- **GitHub Copilot:** 300 premium requests/month (Copilot Pro $10/mo)
- **OpenCode Zen:** Varies by plan (~$20/mo)
- **Gemini CLI:** Free tier available

**Recommended setup:** 2+ agents for quota overflow + getting unstuck capability.

See [references/cli-agent-rotation.md](references/cli-agent-rotation.md) for detailed rotation strategies.

### Iteration Caps (Scope Control)

```yaml
event_loop:
  max_iterations: 30  # Prevent infinite loops
```

**Guideline:**
- Simple tasks: 10-15 iterations
- Medium tasks: 20-30 iterations
- Complex tasks: 50-100 iterations

**If hitting cap frequently:** Task is poorly scoped or impossible.

### Token Tracking (Real-Time Monitoring)

```bash
ralph run --tui  # Live cost tracking
```

TUI shows:
- Tokens consumed (current iteration + total)
- Cost so far / spending limit
- Projected final cost based on iteration trend
- Cache hit rate (for providers supporting prompt caching)

**Early warning:** If cost/iteration increases over time, context window filling up (reduce max_iterations).

### Agent Rotation Benefits

| Benefit | Impact |
|---------|--------|
| **Quota resilience** | Multiple agents = never blocked by single quota |
| **Getting unstuck** | Different agent = fresh perspective on stuck tasks |
| **Agent strengths** | Match task type to best agent (Claude for complex, Copilot for TDD) |
| **Cost distribution** | Spread usage across multiple all-inclusive plans |

See [references/cli-agent-rotation.md](references/cli-agent-rotation.md) for detailed rotation strategies.

## Coding Plan Best Practices

Effective planning reduces iteration count by 30-50%. Five key practices:

**1. Write specific, testable acceptance criteria**
```markdown
✗ Bad: "Add user authentication"
✓ Good: "POST /auth/login endpoint returns JWT (24-hour expiry) on success, 401 on invalid credentials, 429 after 5 attempts per IP per 15 min. Tests verify all edge cases. Manual test: [curl command]"
```
Impact: 3-5 fewer iterations

**2. Specify what NOT to build (YAGNI)**
```markdown
Features to include: Add/remove/update cart items
DO NOT implement: Saved carts, cart sharing, wish lists
```
Impact: Prevents speculative features Validator will reject

**3. Reference existing patterns**
```markdown
Follow patterns from: auth.ts (middleware), users/controller.ts (errors), utils/validate.ts (validation)
```
Impact: Builder writes idiomatic code faster

**4. Provide E2E test scenarios**
```markdown
Manual tests: 1) 5 requests from IP A succeed, 2) 6th returns 429, 3) Request from IP B succeeds (independent limit)
```
Impact: Validator knows exactly what to verify

**5. Break down complex tasks (use PDD)**

For tasks >30 iterations, use `pdd-to-code-assist` preset to auto-generate task breakdown.

**Quota impact:**
- Vague prompt: 15-20 iterations (wastes quota)
- Specific criteria: 10-12 iterations (30-40% quota savings)
- **Best ROI:** 5 min planning preserves quota for next tasks

See [references/quota-and-planning.md](references/quota-and-planning.md) for detailed examples.

## Key Features

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
| **Quota management critical** (rotate agents, never blocked) | Single agent sufficient |
| Task may need 5-15 iterations to get right | Task complexity well-understood upfront |
| **Getting unstuck important** (switch agents for fresh perspective) | Agent rarely gets stuck |

**Recommendation:** Use ralph for complex features where quality gates or quota management are critical. Use OpenClaw sub-agents for multi-task workflows where each task is independent.

**Quota consideration:** Ralph with agent rotation spreads load across multiple quotas, maximizing availability and resilience. Use ralph with 2+ agents for production work.

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

## Quota Management + Planning: Combined Strategy

**Maximum efficiency** comes from combining agent rotation with effective planning.

**Quick wins:**
1. Rotate across 2+ CLI agents (quota resilience)
2. Write specific acceptance criteria (3-5 fewer iterations = less quota usage)
3. Set iteration caps to prevent quota exhaustion

**Strategy matrix:**
- **Simple tasks:** Secondary agent (Copilot) + 2 min planning → 2-3 iterations
- **Medium tasks:** Primary agent (Claude) + 5 min planning → 8-12 iterations
- **Complex tasks:** Agent rotation + 10 min PDD → 30-50 iterations (spread across quotas)

**Recommended agent setup:**
- **Primary (best quality):** Claude Code or OpenCode Zen
- **Secondary (fast TDD):** GitHub Copilot
- **Tertiary (free overflow):** Gemini CLI

**Rule of thumb:** Use secondary agent by default, escalate to primary when stuck or for critical tasks.

See [references/cli-agent-rotation.md](references/cli-agent-rotation.md) for detailed rotation strategies and [references/quota-and-planning.md](references/quota-and-planning.md) for quota management + planning best practices.

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
