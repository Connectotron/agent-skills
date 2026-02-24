---
name: ralph-orchestrator
description: Autonomous programming task execution with cost control and quality gates. Kicks off TDD implementation, bug fixes, feature development, and refactoring using event-driven loop system with multi-hat coordination and external verification (tests/linters/type checks). Includes spending limits, model selection (Kiro 83% cheaper than Claude), iteration caps, and real-time cost tracking. Use when you need: (1) Cost-controlled iteration-to-perfection (set spending limits, use cheaper models), (2) Complex features with TDD workflow (RED → GREEN → REFACTOR), (3) Bug fixes with reproduction and verification, (4) Spec-driven development from PDD output, (5) Tasks where external verification gates critical. Best practices: write specific acceptance criteria (reduces iterations), use PDD for complex tasks (better scoping), specify what NOT to build (YAGNI). NOT for simple one-liner fixes, exploratory code reading, or tasks requiring human judgment at each step.
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

### Simple Task (Cost-Conscious)

```bash
cd ~/my-project
ralph init --preset code-assist

# Edit ralph.yml to use cheaper model
sed -i 's/backend: "kiro"/backend: "kiro"/' ralph.yml  # Already default

cat > PROMPT.md << 'EOF'
Add a --verbose flag to the CLI that enables debug logging

Acceptance criteria:
- -v and --verbose flags both work
- When enabled, shows detailed output
- When disabled (default), shows minimal output
- Tests verify verbose vs. normal mode
- Manual test: ./cli --verbose command shows debug output
EOF

ralph run --max-spend 0.50  # Hard cap at $0.50
```

**Expected:** 2-3 iterations, ~$0.03-0.06 with Kiro (vs. $0.15-0.30 with Claude)

**Cost control applied:**
- Cheaper model (Kiro)
- Spending limit ($0.50)
- Clear acceptance criteria (reduces iterations)

### Complex Feature with TDD (Balanced Cost + Quality)

```bash
ralph init --preset code-assist

# Iterate with Kiro (cheap)
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

ralph run --tui --max-iterations 30 --max-spend 2.00
```

**Expected:** 8-12 iterations, ~$0.20-0.36 with Kiro (vs. $1.20-1.80 with Claude)

**Cost control + planning applied:**
- Kiro model (80% savings)
- Spending limit ($2.00)
- Iteration cap (30)
- Specific acceptance criteria with E2E scenarios
- Clear YAGNI guidance (what NOT to build)
- Manual test scenarios for Validator

**Optional final validation with Claude:**
```bash
sed -i 's/kiro/claude/' ralph.yml
ralph run --max-iterations 5  # Quick quality check
```

**Total cost:** $0.36 (Kiro) + $0.75 (Claude final) = **$1.11** (vs. $1.80 all-Claude)

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

### Model Selection (80% Cost Savings)

```yaml
# ralph.yml
cli:
  backend: "kiro"        # $0.02-0.03 per iteration (recommended)
  # backend: "opencode"  # Free (with Zen models)
  # backend: "claude"    # $0.12-0.18 per iteration (highest quality)
```

**Strategy:** Use cheaper models for iteration, expensive models for final validation.

**Example workflow:**
```bash
# Iterate with Kiro (cheap, fast)
ralph run --config ralph.yml  # Uses kiro

# Final validation with Claude (expensive, thorough)
sed -i 's/kiro/claude/' ralph.yml
ralph run --max-iterations 5  # Only final validation passes
```

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

### Cost Comparison: Model Selection Impact

| Task | Kiro | Claude Sonnet | Savings |
|------|------|---------------|---------|
| Simple (3 iterations) | $0.06 | $0.30 | 80% |
| Medium (12 iterations) | $0.30 | $1.80 | 83% |
| Complex (50 iterations) | $1.50 | $9.00 | 83% |

See [references/examples.md](references/examples.md) for detailed cost breakdowns.

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

**Cost impact:**
- Vague prompt: 15-20 iterations, $2.25-3.00 (Claude) or $0.45-0.60 (Kiro)
- Specific criteria: 10-12 iterations, $1.50-1.80 (Claude) or $0.30-0.36 (Kiro)
- **Best ROI:** 5 min planning saves $0.75-1.50 per task

See [references/cost-and-planning.md](references/cost-and-planning.md) for detailed examples.

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
| **Cost control critical** (spending limits, model selection) | OpenClaw session tracking sufficient |
| Task may need 5-15 iterations to get right | Task complexity well-understood upfront |
| **Want to minimize cost** (use Kiro, set limits) | Cost not a primary concern |

**Recommendation:** Use ralph for complex features where quality gates or cost control are critical. Use OpenClaw sub-agents for multi-task workflows where each task is independent.

**Cost consideration:** Ralph with Kiro costs ~83% less than OpenClaw with Claude for equivalent work. Use ralph + spending limits for budget-constrained projects.

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

## Cost Control + Planning: Combined Strategy

**Maximum savings (70-87%)** come from combining model selection with effective planning.

**Quick wins:**
1. Use Kiro instead of Claude (80% cheaper)
2. Write specific acceptance criteria (3-5 fewer iterations)
3. Set spending limits to prevent runaway costs

**Strategy matrix:**
- **Simple tasks:** Kiro + 2 min planning → $0.03-0.06
- **Medium tasks:** Kiro + 5 min planning → $0.20-0.36 (vs. $2.70 default)
- **Complex tasks:** Kiro + 10 min PDD → $1.50-3.00 (vs. $9.00+ default)

**Rule of thumb:** Spend 10% of estimated cost on planning. $1 task → 6 min planning. $10 task → 1 hour planning.

See [references/cost-and-planning.md](references/cost-and-planning.md) for detailed strategies, ROI calculations, and real-world examples.

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
