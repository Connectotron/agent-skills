# Cost Control + Planning Strategies

Comprehensive guide to minimizing costs while maximizing code quality using ralph-orchestrator.

## Table of Contents

1. [Cost Control Levers](#cost-control-levers)
2. [Planning Best Practices](#planning-best-practices)
3. [Combined Strategy](#combined-strategy)
4. [Real-World Examples](#real-world-examples)

---

## Cost Control Levers

Ralph provides four primary cost control mechanisms that work independently or in combination.

### 1. Spending Limits (Hard Caps)

**Purpose:** Prevent runaway costs on unknown or open-ended tasks

**Usage:**
```bash
ralph run --max-spend 5.00  # Stop if cost exceeds $5
ralph run --max-spend 10.00 --max-iterations 50  # Combined limits
```

**When to use:**
- Experimentation (unknown task complexity)
- Budget constraints (client project with fixed budget)
- Open-ended exploration ("improve performance" without specific target)

**Downsides:**
- May stop before task complete (need to resume manually)
- Requires cost estimation upfront

---

### 2. Model Selection (80-90% Cost Savings)

**Cost per iteration:**
- **Kiro:** $0.02-0.03 (recommended for iteration)
- **OpenCode Zen:** $0.00 (free, but quality varies)
- **Claude Sonnet:** $0.12-0.18 (highest quality)

**Configuration:**
```yaml
# ralph.yml
cli:
  backend: "kiro"        # Default: cheap and fast
  # backend: "opencode"  # Free alternative
  # backend: "claude"    # Premium quality
```

**Hybrid strategy (best ROI):**
```bash
# Step 1: Iterate with Kiro (cheap exploration)
ralph run --config ralph.yml  # Uses kiro
# Cost: 10 iterations × $0.03 = $0.30

# Step 2: Final validation with Claude (expensive verification)
sed -i 's/kiro/claude/' ralph.yml
ralph run --max-iterations 5
# Cost: 3 iterations × $0.15 = $0.45

# Total: $0.75 (vs. $1.95 all-Claude = 62% savings)
```

**Escalation strategy (when Kiro gets stuck):**

If cheap model fails to converge after 10-15 iterations:

```bash
# Watch for signs of being stuck:
# - Same validation error 3+ times
# - No validation passes after 10-15 iterations
# - Error messages indicate subtle requirement misunderstood

# Step 1: Stop current loop (Ctrl+C)

# Step 2: Escalate to Claude to break through
sed -i 's/kiro/claude/' ralph.yml
ralph run --max-iterations 10  # Claude's stronger reasoning breaks through
# Cost: 5 iterations × $0.15 = $0.75

# Step 3: Resume with Kiro after breakthrough
sed -i 's/claude/kiro/' ralph.yml
ralph run --max-iterations 10  # Finish cheaper
# Cost: 5 iterations × $0.03 = $0.15

# Total with escalation: $0.30 (initial Kiro) + $0.75 (Claude breakthrough) + $0.15 (Kiro finish) = $1.20
# vs. Kiro stuck indefinitely or all-Claude $2.25
```

**Escalation decision matrix:**

| Symptom | Action | Cost Impact |
|---------|--------|-------------|
| Validation passes, then fails once | Continue with Kiro | No change |
| Same error 2 times in a row | Continue with Kiro (may be fixing) | No change |
| Same error 3+ times in a row | **Escalate to Claude** | +$0.60-0.90 |
| 10 iterations, no validation pass | **Escalate to Claude** | +$0.60-0.90 |
| 15 iterations, still stuck | **Escalate to Claude immediately** | +$0.60-0.90 |
| Subtle requirement misunderstood | **Escalate to Claude** | +$0.60-0.90 |

**When escalation is worth it:**

**Scenario 1: Kiro stuck on edge case (typical)**
- 15 Kiro iterations (stuck): $0.45
- 5 Claude iterations (breakthrough): $0.75
- 5 Kiro iterations (finish): $0.15
- **Total: $1.35** (converges)

vs. all-Kiro indefinitely: $0.60+ (never converges, wasted)
vs. all-Claude: $2.25 (converges, but expensive)

**Scenario 2: Task well-scoped (no escalation needed)**
- 12 Kiro iterations: $0.36 (converges)
- **Total: $0.36** (best case)

**Rule of thumb:** If stuck after 10-15 iterations with same error, escalate immediately. Continuing with Kiro wastes money without progress.

**When to use which model:**

| Stage | Model | Why |
|-------|-------|-----|
| Exploration (iterations 1-10) | Kiro or OpenCode | Fast iteration, acceptable quality for TDD |
| Implementation (converging) | Kiro | 80% savings, good enough for passing tests |
| **Stuck (3+ same errors)** | **Claude Sonnet** | **Stronger reasoning breaks through** |
| Final validation | Claude Sonnet | Thorough YAGNI/KISS checks, best E2E verification |
| Bug fixing (simple) | Kiro | Simple logic changes don't need premium model |
| Refactoring | Claude Sonnet | Subtle behavioral changes need careful review |

---

### 3. Iteration Caps (Scope Control)

**Purpose:** Force convergence or expose poorly-scoped tasks

**Configuration:**
```yaml
event_loop:
  max_iterations: 30  # Stop after 30 attempts
```

**Guideline by complexity:**
- Simple tasks (verbose flag, single endpoint): 10-15 iterations
- Medium tasks (auth feature, search endpoint): 20-30 iterations
- Complex tasks (full pipeline, multi-feature): 50-100 iterations

**Diagnostic:** If consistently hitting iteration cap:
- Task is poorly scoped (break into smaller tasks)
- Task is impossible (tests can't pass, environment issue)
- Completion criteria too vague (agent doesn't know when done)

**Fix:** Break task into PDD subtasks or tighten acceptance criteria

---

### 4. Real-Time Monitoring (Early Warning)

**TUI mode:**
```bash
ralph run --tui
```

**What to watch:**
- **Cost/iteration trend:** If increasing over time, context window filling up
- **Token consumption:** Rapid growth indicates inefficient prompts or large files
- **Cache hit rate:** Low rate means agent re-reading same files (inefficient)

**Early intervention:**
- If cost/iteration >$0.20 with Kiro: Switch to cheaper model or reduce max_iterations
- If token/iteration >8,000: Agent loading too much context (scope task narrower)

---

### 5. Smart Model Escalation (Break Through When Stuck)

**Purpose:** Use cheap models by default, escalate to expensive models only when stuck

**Core insight:** Kiro handles 70-80% of tasks well. For the 20-30% where it gets stuck, Claude can break through quickly.

#### Escalation Triggers

**Trigger 1: Repeated validation failures**
```
Iteration 8: Validator fails (missing rate limiting)
Iteration 9: Validator fails (missing rate limiting)
Iteration 10: Validator fails (missing rate limiting)
→ ESCALATE: Same error 3 times = Kiro doesn't understand requirement
```

**Trigger 2: No validation passes after threshold**
```
Iterations 1-15: All fail validation
→ ESCALATE: Kiro struggling with task complexity
```

**Trigger 3: Subtle requirement misunderstood**
```
Validator: "Rate limiting is per-user, not per-IP"
Kiro iterations keep implementing per-IP despite feedback
→ ESCALATE: Kiro missing nuance
```

#### Manual Escalation Workflow

**Step 1: Monitor for stuck signals**
```bash
ralph run --tui --max-iterations 20  # TUI shows iteration history
```

Watch for:
- Same validation error message appearing repeatedly
- Iteration count reaching 10-15 without progress
- Error messages indicating misunderstanding of requirement

**Step 2: Stop and escalate**
```bash
# Ctrl+C to stop current loop

# Switch to Claude
sed -i 's/backend: "kiro"/backend: "claude"/' ralph.yml

# Run limited iterations to break through
ralph run --max-iterations 10
```

**Step 3: Resume with Kiro after breakthrough**
```bash
# Once validation passes, switch back to Kiro
sed -i 's/backend: "claude"/backend: "kiro"/' ralph.yml

# Finish remaining work
ralph run --max-iterations 10
```

#### Cost Analysis: Escalation vs. Pure Strategies

**Example task:** User authentication with rate limiting (medium complexity)

**Strategy A: Kiro only (gets stuck)**
- 20+ iterations, never passes validation
- Cost: $0.60+ (wasted)
- **Outcome:** FAIL

**Strategy B: Claude only**
- 12 iterations, passes validation
- Cost: $1.80
- **Outcome:** SUCCESS

**Strategy C: Kiro → escalate → Kiro (smart)**
- 10 Kiro iterations (stuck): $0.30
- 5 Claude iterations (breakthrough): $0.75
- 5 Kiro iterations (finish): $0.15
- **Total: $1.20**
- **Outcome:** SUCCESS
- **Savings vs. Claude-only:** $0.60 (33%)

**Strategy D: Kiro → Claude final validation only (ideal, when not stuck)**
- 12 Kiro iterations (converges): $0.36
- 3 Claude iterations (final validation): $0.45
- **Total: $0.81**
- **Outcome:** SUCCESS
- **Savings vs. Claude-only:** $0.99 (55%)

#### When NOT to Escalate

**Avoid premature escalation:**
- Single validation failure (Kiro is still fixing)
- Two failures in a row (Kiro may be iterating toward solution)
- Task is simple (verbose flag, single endpoint)

**Wait for clear signals:**
- Three or more identical failures
- 10+ iterations with no validation pass
- Error messages show fundamental misunderstanding

#### Future: Automated Escalation

**If ralph supports config-based escalation (check latest docs):**

```yaml
# ralph.yml (hypothetical)
cli:
  backend: "kiro"
  escalation:
    enabled: true
    trigger_after_failures: 3       # Same error 3 times
    trigger_after_iterations: 12    # No progress after 12 iterations
    escalate_to: "claude"
    escalate_max_iterations: 10
    resume_backend: "kiro"          # Return to Kiro after breakthrough
```

**Check ralph documentation for latest escalation features.**

---

## Planning Best Practices

Effective planning reduces iteration count more than any other lever.

### 1. Write Testable Acceptance Criteria

**Bad (vague):**
```markdown
Add user authentication
```
**Problems:**
- Builder doesn't know what "authentication" means (OAuth? JWT? Session cookies?)
- Validator doesn't know when to approve (what tests must pass?)
- Agent will guess → Validator will reject → wasted iterations

**Good (testable):**
```markdown
Add user authentication

Acceptance criteria (testable):
- POST /auth/login endpoint accepts {email, password}
- Returns JWT token (HS256, 24-hour expiry) on success
- Returns 401 with error message on invalid credentials
- Password must be hashed with bcrypt (12 rounds)
- Rate limiting: 5 attempts per 15 minutes per IP
- Unit tests verify token generation, expiry, validation
- Integration tests verify login flow end-to-end
- Manual E2E test: curl command below returns valid JWT

Manual test:
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

**Impact:** 3-5 fewer iterations (saves $0.15-0.75 with Claude, $0.09-0.15 with Kiro)

---

### 2. Specify What NOT to Build (YAGNI)

**Purpose:** Prevent Builder from adding speculative features that Validator will reject

**Example:**
```markdown
Implement shopping cart

Features to include:
- Add item to cart (POST /cart/items)
- Remove item from cart (DELETE /cart/items/:id)
- Update quantity (PATCH /cart/items/:id)
- View cart contents (GET /cart)

DO NOT implement:
- Saved carts / cart persistence across sessions
- Cart sharing / send cart to friend
- Wish lists
- Product recommendations in cart
- Promo code application (separate feature)
```

**Impact:** Validator's YAGNI check passes first time (saves 1-2 iterations per speculative feature)

---

### 3. Reference Existing Patterns

**Purpose:** Help Builder write idiomatic code faster

**Example:**
```markdown
Implement user profile endpoint

Existing patterns to follow:
- Authentication middleware: src/middleware/auth.ts (use verifyToken)
- Error handling: src/utils/errors.ts (throw AppError, not generic Error)
- Validation: src/utils/validate.ts (use validateEmail, validatePhone)
- Response format: { data: {...}, meta: {...} } (see src/types/api.ts)

DO NOT invent new patterns. Follow existing conventions.
```

**Impact:** Builder explores codebase first, writes code matching style (Validator's idiomatic check passes)

---

### 4. Provide E2E Test Scenarios

**Purpose:** Give Validator clear verification steps

**Example:**
```markdown
Implement rate limiting on /auth/login

Manual E2E test scenarios (Validator must verify ALL):
1. Send 5 POST /auth/login from IP 1.2.3.4 → All return 200 or 401 (normal behavior)
2. Send 6th POST /auth/login from IP 1.2.3.4 → Returns 429 (rate limited)
3. Send POST /auth/login from IP 5.6.7.8 immediately → Returns 200 or 401 (independent limit)
4. Wait 15 minutes, send POST /auth/login from IP 1.2.3.4 → Returns 200 or 401 (limit reset)

Expected behavior:
- Rate limiting is per-IP, not global
- Limit resets after 15 minutes
- Error response includes Retry-After header
```

**Impact:** Validator knows exactly what to test (no ambiguity, faster approval)

---

### 5. Break Down Complex Tasks (Use PDD)

**When to use PDD:**
- Task estimated >30 iterations
- Task has multiple independent features
- High-level idea without implementation details

**Example:**
```bash
ralph init --preset pdd-to-code-assist

cat > PROMPT.md << 'EOF'
High-level idea: Add blog search feature

Requirements:
- Full-text search across post titles and content
- Filter by tags (multiple tags with AND/OR logic)
- Sort by relevance (default) or date (newest/oldest)
- Pagination (20 results per page)
- Search suggestions as user types (debounced)
EOF

ralph run --max-iterations 100
```

**What PDD does:**
1. **Planning phase (10 iterations):** Breaks idea into tasks
   - Task 1: Add full-text search index
   - Task 2: Implement search API endpoint
   - Task 3: Add tag filtering
   - Task 4: Implement sorting
   - Task 5: Add pagination
   - Task 6: Build frontend search UI
   - Task 7: Implement search suggestions
   - Task 8: Integration tests

2. **Implementation phase (40 iterations):** Builder tackles ONE task at a time
   - Each task has clear acceptance criteria (from planning phase)
   - Validator verifies each task before moving to next

3. **Validation phase (5 iterations):** Full E2E test plan execution

**Impact:** Better scoping = less backtracking = 20-30% fewer iterations

---

## Combined Strategy

Maximum cost savings come from combining model selection with effective planning.

### Strategy Matrix

| Task Complexity | Planning Time | Model | Expected Iterations | Expected Cost |
|-----------------|---------------|-------|-------------------|---------------|
| **Simple** | 2 min | Kiro | 2-3 | $0.03-0.06 |
| **Medium** | 5 min | Kiro | 8-12 | $0.20-0.36 |
| **Complex** | 10 min (PDD) | Kiro + Claude final | 30-50 | $1.50-3.00 |

### ROI Calculation: Medium Task

**Scenario:** Implement user authentication feature

**Default approach (no planning, Claude):**
```markdown
Implement user authentication
```
- Vague criteria → Builder guesses features → Validator rejects
- 15-20 iterations with Claude Sonnet
- Cost: 18 iterations × $0.15 = **$2.70**

**Optimized approach (5 min planning, Kiro):**
```markdown
Implement user authentication

Acceptance criteria (specific):
- POST /auth/login (email + password)
- JWT with 24-hour expiry (HS256)
- Bcrypt hashing (12 rounds)
- Rate limiting (5/15min per IP)
- Tests verify all edge cases
- Manual E2E: curl command returns valid JWT

DO NOT implement:
- OAuth / SSO
- Password reset flow
- Email verification
- Multi-factor authentication
```
- Clear criteria → Builder focused → Validator passes
- 10-12 iterations with Kiro
- Cost: 12 iterations × $0.03 = **$0.36**

**Savings:** $2.34 (87% reduction) from:
- 5 minutes of planning (clear criteria + YAGNI)
- Model selection (Kiro instead of Claude)

**Time invested:** 5 minutes planning  
**Money saved:** $2.34  
**ROI:** ~$28/hour of planning time

### When to Invest in Planning

**Always worth it (ROI >10x):**
- Tasks estimated >$1.00 with default approach
- Unfamiliar domains (Builder will explore inefficiently)
- Complex multi-step workflows (use PDD)

**Optional (ROI 2-5x):**
- Simple tasks <$0.50 (marginal savings)
- Well-understood patterns (Builder knows the codebase already)

**Rule of thumb:** If task will cost >$1.00, spend 10% of that cost in planning time.
- $10 task → 1 hour planning
- $1 task → 6 minutes planning
- $0.50 task → 3 minutes planning (optional)

---

## Real-World Examples

### Example 1: Authentication Feature (Medium Complexity)

**Default approach:**
- No planning
- Claude Sonnet
- Vague prompt: "Add user authentication"
- **Result:** 18 iterations, $2.70

**Optimized approach:**
- 5 min planning (specific criteria + YAGNI)
- Kiro for implementation
- Optional Claude final validation (3 iterations)
- **Result:** 12 iterations Kiro + 3 iterations Claude = $0.36 + $0.45 = **$0.81**

**Savings:** $1.89 (70%)

---

### Example 2: Blog Search (High Complexity)

**Default approach:**
- No planning (just high-level idea)
- Claude Sonnet
- **Result:** 60+ iterations (agent backtracks, adds unnecessary features), $9.00+

**Optimized approach:**
- 10 min PDD planning (breaks into 8 tasks)
- Kiro for implementation (40 iterations)
- Claude for final E2E validation (5 iterations)
- **Result:** 10 planning + 40 implementation + 5 validation = **55 iterations, $1.95**

**Savings:** $7.05 (78%)

---

### Example 3: Bug Fix (Low Complexity)

**Default approach:**
- Claude Sonnet
- Vague: "Fix the rate limiting bug"
- **Result:** 6 iterations (reproducing, fixing, verifying), $0.90

**Optimized approach:**
- 2 min planning (clear repro steps)
- Kiro
```markdown
Bug: Rate limiting applies globally, not per IP

Expected: Each IP should have independent 5-attempt limit
Current: All IPs share same limit

Repro steps:
1. Login from IP A 5 times → 6th attempt rate limited
2. Login from IP B immediately → Also rate limited (WRONG)

Expected: IP B should NOT be rate limited
```
- **Result:** 4 iterations, $0.12

**Savings:** $0.78 (87%)

---

## Cost Optimization Checklist

Before running `ralph run`, ask:

**Planning:**
- [ ] Have I written specific, testable acceptance criteria?
- [ ] Have I specified what NOT to build (YAGNI)?
- [ ] Have I provided E2E test scenarios?
- [ ] If complex (>30 iterations), should I use PDD preset?

**Cost Control:**
- [ ] Have I set a spending limit (`--max-spend`)?
- [ ] Am I using the cheapest viable model (Kiro for exploration)?
- [ ] Have I set an iteration cap (`--max-iterations`)?
- [ ] Do I have monitoring enabled (`--tui`) to catch cost issues early?

**If yes to all:** Run with confidence. If no, invest 5-10 minutes in planning first.

**Expected ROI:** 5-10x cost savings from planning + model selection combined.
