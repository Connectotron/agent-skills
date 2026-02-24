# Quota Management + Planning Strategies

Maximize agent availability and minimize wasted iterations using CLI agent rotation and effective planning.

## Table of Contents

1. [Quota Management Strategy](#quota-management-strategy)
2. [Planning Best Practices](#planning-best-practices)
3. [Combined Approach](#combined-approach)
4. [Real-World Examples](#real-world-examples)

---

## Quota Management Strategy

### The Problem

Single CLI agent has rate limits/quotas:
- **Claude Code:** ~350 requests/12h
- **GitHub Copilot:** 300 premium requests/month  
- **OpenCode Zen:** Varies by plan

**Risk:** Hit quota mid-task → blocked → cannot complete work

### The Solution: Agent Rotation

Maintain 2+ CLI agent subscriptions and rotate between them.

**Benefits:**
1. **Quota resilience:** Never blocked by single agent limit
2. **Getting unstuck:** Fresh agent perspective when stuck
3. **Load distribution:** Spread usage across multiple quotas

### Recommended Agent Setup

| Tier | Agent | Purpose | Monthly Cost |
|------|-------|---------|--------------|
| **Primary** | Claude Code or OpenCode Zen | Best quality, complex features | $20 |
| **Secondary** | GitHub Copilot Pro | Fast TDD, standard features | $10 |
| **Tertiary** | Gemini CLI | Free overflow, exploration | Free |

**Total investment:** $30/month for quota resilience + getting unstuck capability

---

## Planning Best Practices

Effective planning reduces iteration count by 30-50%, preserving quota.

### 1. Write Specific, Testable Acceptance Criteria

**Bad (vague):**
```markdown
Add user authentication
```
**Result:** Agent guesses requirements → 15-20 iterations wasted

**Good (testable):**
```markdown
Add user authentication

Acceptance criteria (testable):
- POST /auth/login endpoint accepts {email, password}
- Returns JWT token (HS256, 24-hour expiry) on success
- Returns 401 with error message on invalid credentials
- Password hashed with bcrypt (12 rounds)
- Rate limiting: 5 attempts per 15 minutes per IP
- Unit tests verify token generation, expiry, validation
- Integration tests verify login flow end-to-end

Manual E2E test:
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
Expected: Returns JWT with 24-hour expiry
```

**Impact:** 3-5 fewer iterations (saves 10-17% of quota)

---

### 2. Specify What NOT to Build (YAGNI)

**Purpose:** Prevent agent from adding speculative features

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

**Impact:** Validator's YAGNI check passes first time (saves 1-2 iterations per speculative feature = 5-10% quota)

---

### 3. Reference Existing Patterns

**Purpose:** Help agent write idiomatic code faster

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

**Impact:** Agent explores codebase first, writes code matching style (saves 2-3 iterations = 10-15% quota)

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

**Impact:** Validator knows exactly what to test (saves 1-2 iterations = 5-10% quota)

---

### 5. Break Down Complex Tasks (Use PDD)

**When:** Task estimated >30 iterations

**How:** Use `pdd-to-code-assist` preset

```bash
ralph init --preset pdd-to-code-assist

cat > PROMPT.md << 'EOF'
High-level idea: Add blog search feature

Requirements:
- Full-text search across posts
- Filter by tags (AND/OR logic)
- Sort by relevance or date
- Pagination (20 results per page)
EOF

ralph run --max-iterations 100
```

**What PDD does:**
1. **Planning phase:** Breaks idea into 5-10 tasks
2. **Implementation phase:** Tackles ONE task at a time
3. **Validation phase:** Full E2E test plan

**Impact:** Better scoping = 20-30% fewer iterations

---

## Combined Approach

Maximum efficiency comes from combining agent rotation with planning.

### Strategy Matrix

| Task Complexity | Agent | Planning Time | Expected Iterations | Quota Usage |
|-----------------|-------|---------------|-------------------|-------------|
| **Simple** | Secondary (Copilot) | 2 min (clear criteria) | 2-3 | Minimal |
| **Medium** | Primary (Claude) | 5 min (criteria + YAGNI) | 8-12 | Moderate |
| **Complex** | Rotation (spread load) | 10 min (PDD) | 30-50 | Distributed |

### Example: Medium Task (Quota-Optimized)

**Default approach (no planning, single agent):**
```markdown
Implement user authentication
```
- Vague criteria → Agent guesses → 15-20 iterations
- Single agent quota: 15-20 requests consumed
- **Risk:** If quota low, may hit limit mid-task

**Optimized approach (5 min planning, agent rotation):**
```markdown
Implement user authentication with specific acceptance criteria:
- POST /auth/login endpoint (email + password)
- JWT with 24-hour expiry
- Bcrypt hashing (12 rounds)
- Rate limiting (5/15min per IP)
- Tests + E2E scenarios
- NO OAuth, password reset, email verification
```
- Clear criteria → Agent focused → 10-12 iterations
- Agent rotation: 10 requests with Copilot, 2 final validation with Claude
- **Quota spread:** Copilot quota: 10, Claude quota: 2
- **Result:** Both agents still have quota available for next tasks

**Savings:** 33% fewer iterations + load distributed across quotas

---

### ROI: Planning Time Investment

**Rule of thumb:** Spend 5-10 minutes planning for medium+ tasks

**Example task:** User authentication (medium complexity)

**No planning:**
- Iterations: 15-20
- Quota used: 15-20 (single agent)
- Risk: May hit quota limit

**5 min planning:**
- Iterations: 10-12
- Quota used: 10-12 (distributed across agents)
- **Savings:** 25-40% quota preserved

**ROI calculation:**
- Time invested: 5 minutes
- Quota saved: 5-8 requests
- **If quota precious** (e.g., Claude Code near limit): Preserves quota for next task

---

## Real-World Examples

### Example 1: Authentication Feature (Quota-Distributed)

**Scenario:** Team has Claude Pro + Copilot Pro

**Approach:**
```bash
# Step 1: TDD iterations with Copilot (fast, saves Claude quota)
ralph run --backend copilot --max-iterations 15  # Uses 12 iterations

# Step 2: Final validation with Claude (best quality)
ralph run --backend claude --max-iterations 5  # Uses 3 iterations
```

**Quota impact:**
- Copilot: 12/300 monthly quota used (4% of quota)
- Claude: 3/~350 daily quota used (minimal)
- **Both agents still available** for next tasks

---

### Example 2: Bug Fix (Secondary Agent Preferred)

**Scenario:** Simple rate limiting bug

**Approach:**
```bash
# Use secondary agent (saves primary quota for complex features)
ralph run --backend copilot --max-iterations 10

# Bug fixes usually converge fast
# Result: 4 iterations, done
```

**Quota strategy:**
- Reserve Claude for complex features
- Use Copilot for standard bug fixes
- **Maximize primary agent availability**

---

### Example 3: Complex Pipeline (Agent Rotation)

**Scenario:** Blog search feature (high complexity)

**Approach:**
```bash
# Step 1: Planning with Claude (best for breaking down complex ideas)
ralph run --backend claude --preset pdd-to-code-assist --max-iterations 15

# Step 2: Implementation tasks with Copilot (fast TDD)
ralph run --backend copilot --max-iterations 25

# Step 3: If Copilot quota running low, rotate to OpenCode
ralph run --backend opencode --max-iterations 20

# Step 4: Final E2E validation with Claude
ralph run --backend claude --max-iterations 10
```

**Quota impact:**
- Claude: 15 (planning) + 10 (final) = 25 requests
- Copilot: 25 requests
- OpenCode: 20 requests
- **Total: 70 iterations distributed** across 3 quotas

**vs. Single agent:**
- Claude only: 70/350 daily quota (20% consumed in one task)
- **Risk:** Little quota left for rest of day

**With rotation:**
- Each agent has plenty of quota remaining
- **Result:** Can continue working for rest of day

---

## Quota Optimization Checklist

Before running `ralph run`, verify:

**Agent Rotation:**
- [ ] Do I have 2+ CLI agents available?
- [ ] Which agent should I use for this task type?
- [ ] Is my primary agent quota running low? (use secondary if yes)
- [ ] Am I ready to switch agents if this one gets stuck?

**Planning:**
- [ ] Have I written specific, testable acceptance criteria?
- [ ] Have I specified what NOT to build (YAGNI)?
- [ ] Have I provided E2E test scenarios?
- [ ] If complex (>30 iterations), should I use PDD preset?

**Iteration Management:**
- [ ] Have I set an iteration cap (`--max-iterations`)?
- [ ] Am I monitoring iteration count (use `--tui`)?
- [ ] Do I have a plan to switch agents if stuck after 10-15 iterations?

**If yes to all:** Run with confidence. Quota is protected and task will converge.

---

## Quota Tracking

Simple daily usage tracking:

```bash
# Track usage per agent
echo "$(date '+%Y-%m-%d'),claude,12" >> ~/.ralph-usage.csv
echo "$(date '+%Y-%m-%d'),copilot,8" >> ~/.ralph-usage.csv

# Check daily usage
TODAY=$(date '+%Y-%m-%d')
echo "Usage for $TODAY:"
grep "^$TODAY" ~/.ralph-usage.csv | awk -F',' '{sum[$2]+=$3} END {for (i in sum) print i": "sum[i]}'
```

**Output:**
```
Usage for 2026-02-24:
claude: 45 / ~350 daily (13% used)
copilot: 28 / 300 monthly (9% used)
```

**Quota warnings:**
- Claude >300/day: Switch to Copilot for next task
- Copilot >280/month: Use OpenCode or Gemini for remainder

---

## Summary

**Key takeaways:**
1. **Agent rotation = quota resilience** — Never blocked by single quota
2. **Planning = iteration reduction** — 30-50% fewer iterations preserves quota
3. **Coding-plan-first** — Use secondary agent by default, primary for critical tasks
4. **Distribute load** — Spread work across multiple agents to maximize availability
5. **Track usage** — Monitor daily to avoid hitting quotas unexpectedly

**Recommended workflow:**
- **Simple tasks:** Secondary agent (Copilot) + 2 min planning
- **Medium tasks:** Primary agent (Claude) + 5 min planning
- **Complex tasks:** Agent rotation (distribute load) + 10 min PDD planning

**Result:** Quota-efficient, resilient coding loop that never blocks and converges faster.
