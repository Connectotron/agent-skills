# CLI Agent Rotation Strategy

Load balancing across multiple coding agents for quota management and getting unstuck.

## Core Strategy

**Problem:** Single CLI agent has rate limits/quotas. Gets stuck on certain task types.

**Solution:** Rotate dispatches across multiple agents. Spreads load + brings fresh perspective when stuck.

## Available CLI Agents

Ralph supports multiple CLI agents. Detect which you have access to:

```bash
# Check available agents
command -v claude >/dev/null 2>&1 && echo "✓ Claude Code"
command -v copilot >/dev/null 2>&1 && echo "✓ GitHub Copilot"
command -v opencode >/dev/null 2>&1 && echo "✓ OpenCode"
command -v gemini >/dev/null 2>&1 && echo "✓ Gemini CLI"
command -v codex >/dev/null 2>&1 && echo "✓ Codex"
```

### Agent Comparison

| Agent | Included Plan | Quota/Limits | Strengths |
|-------|--------------|--------------|-----------|
| **Claude Code** | Claude Pro ($20/mo) | ~350 requests/12h | Best reasoning, complex edge cases |
| **GitHub Copilot** | Copilot Pro ($10/mo) | 300 premium requests/mo | Fast iteration, GitHub integration |
| **OpenCode Zen** | OpenCode ($20/mo) | Varies by model | Curated models, good balance |
| **Gemini CLI** | Google AI Studio (free tier) | Varies | Free option, good for exploration |

**Note:** Quotas are subject to change. Check current limits with your provider.

## Rotation Benefits

### 1. Quota Management

**Problem:** Single agent hits rate limit mid-task.

**Solution:** Spread load across multiple agents.

**Example:**
- Claude Code: 350 requests/12h ≈ 29 requests/hour
- Copilot: 300 requests/month ≈ 10 requests/day
- **Total capacity with both: 39 requests/hour**

### 2. Getting Unstuck

**Problem:** Agent stuck on same validation error 3+ times.

**Solution:** Switch to different agent. Fresh model often solves differently.

**Example:**
- Claude stuck on subtle type inference issue (10 iterations)
- Switch to Copilot → solves it differently (2 iterations)
- **Saved:** 8 wasted iterations

### 3. Agent Strengths

Different agents excel at different task types:

| Task Type | Best Agent | Why |
|-----------|-----------|-----|
| Complex logic/edge cases | Claude Code | Strongest reasoning |
| Quick iterations | GitHub Copilot | Fast, good for TDD loops |
| API integrations | OpenCode Zen | Broad model access |
| Exploratory/free tier | Gemini CLI | No cost for experimentation |

---

## Rotation Strategies

### Strategy 1: Round-Robin (Default)

**Use when:** Multiple agents available, no quota concerns

**Pattern:**
```bash
# Task 1: Use Claude
ralph run --backend claude --max-iterations 15

# Task 2: Use Copilot
ralph run --backend copilot --max-iterations 15

# Task 3: Use OpenCode
ralph run --backend opencode --max-iterations 15

# Task 4: Back to Claude
ralph run --backend claude --max-iterations 15
```

**Benefits:**
- Simple
- Evenly distributes load
- Prevents any single agent from hitting quota

---

### Strategy 2: Coding-Plan-First Preference

**Use when:** You have one primary agent with generous coding plan, backup agents for overflow

**Pattern:**
```bash
# Primary: Claude Code (best quality)
ralph run --backend claude --max-iterations 15

# If Claude hits quota, fallback to Copilot
ralph run --backend copilot --max-iterations 15

# If both hit quota, use free tier Gemini
ralph run --backend gemini --max-iterations 15
```

**Priority order:**
1. **Primary (best quality):** Claude Code or OpenCode Zen
2. **Secondary (good balance):** GitHub Copilot
3. **Tertiary (free tier):** Gemini CLI

**Benefits:**
- Maximize quality with primary agent
- Automatic overflow handling
- Never blocked by quotas

---

### Strategy 3: Escalation on Stuck

**Use when:** Agent struggling with specific task

**Pattern:**
```bash
# Start with default agent
ralph run --backend copilot --max-iterations 15

# Watch for stuck signals:
# - Same validation error 3+ times
# - No progress after 10 iterations

# If stuck, escalate to stronger agent
ralph run --backend claude --max-iterations 10  # Breaks through

# Resume with original agent after breakthrough
ralph run --backend copilot --max-iterations 10
```

**Stuck signals:**
- Same validation error 3+ consecutive times
- Iteration count >10-15 with no validation pass
- Error messages indicate subtle requirement misunderstood

**Benefits:**
- Use cheaper/quota-friendly agent by default
- Escalate to premium agent only when needed
- Resume cheaper agent after breakthrough

---

### Strategy 4: Task-Type-Based Selection

**Use when:** You know task characteristics upfront

**Routing:**
```bash
# Complex edge case handling → Claude
if [[ "$TASK_TYPE" == "complex" ]]; then
  ralph run --backend claude

# Quick TDD iteration → Copilot
elif [[ "$TASK_TYPE" == "tdd" ]]; then
  ralph run --backend copilot

# API integration → OpenCode
elif [[ "$TASK_TYPE" == "api" ]]; then
  ralph run --backend opencode

# Exploration/prototyping → Gemini (free)
elif [[ "$TASK_TYPE" == "explore" ]]; then
  ralph run --backend gemini
fi
```

**Task type indicators:**
- **Complex:** Refactoring, subtle behavioral changes, edge cases
- **TDD:** New features with clear acceptance criteria
- **API:** Third-party integrations, schema mapping
- **Explore:** Prototyping, proof-of-concept, learning

---

## Quota Tracking

Track agent usage to avoid hitting limits:

```bash
# Simple tracking script
echo "$(date '+%Y-%m-%d %H:%M:%S'),claude,15" >> ~/ralph-usage.csv
echo "$(date '+%Y-%m-%d %H:%M:%S'),copilot,12" >> ~/ralph-usage.csv

# Check daily usage
grep "$(date '+%Y-%m-%d')" ~/ralph-usage.csv | \
  awk -F',' '{sum[$2]+=$3} END {for (i in sum) print i": "sum[i]}'
```

**Output:**
```
claude: 45
copilot: 28
opencode: 12
```

**Quota warnings:**
- Claude >300/day: Consider switching to Copilot for next task
- Copilot >280/month: Use OpenCode or Gemini for remainder of month

---

## Agent-Specific Configuration

### Claude Code

```yaml
# ralph.yml
cli:
  backend: "claude"
```

**Quota:** ~350 requests/12h (soft limit, may vary)

**Best for:**
- Complex refactoring
- Subtle edge case handling
- High-quality final validation

---

### GitHub Copilot

```yaml
# ralph.yml
cli:
  backend: "copilot"
```

**Quota:** 300 premium requests/month (Pro plan)

**Best for:**
- Quick TDD iterations
- Standard CRUD operations
- GitHub workflow integration

---

### OpenCode Zen

```yaml
# ralph.yml
cli:
  backend: "opencode"
```

**Models:** Curated set optimized for coding agents

**Best for:**
- Broad model access
- API integrations
- Balanced quality/cost

---

### Gemini CLI

```yaml
# ralph.yml
cli:
  backend: "gemini"
```

**Quota:** Free tier available (check current limits)

**Best for:**
- Exploration/prototyping
- Learning/experimentation
- Overflow when other agents at quota

---

## Automated Rotation Script

```bash
#!/bin/bash
# ralph-rotate.sh - Automatically select agent based on quota availability

# Track usage (simple file-based)
USAGE_FILE=~/.ralph-usage.csv
TODAY=$(date '+%Y-%m-%d')

# Count today's usage per agent
get_usage() {
  local agent=$1
  grep "^$TODAY.*,$agent," "$USAGE_FILE" 2>/dev/null | wc -l | tr -d ' '
}

# Agent quotas (update these based on your plans)
CLAUDE_DAILY_LIMIT=300
COPILOT_DAILY_LIMIT=10
OPENCODE_DAILY_LIMIT=50

# Get current usage
CLAUDE_USAGE=$(get_usage claude)
COPILOT_USAGE=$(get_usage copilot)
OPENCODE_USAGE=$(get_usage opencode)

# Select agent (coding-plan-first preference)
if [ "$CLAUDE_USAGE" -lt "$CLAUDE_DAILY_LIMIT" ]; then
  AGENT="claude"
elif [ "$COPILOT_USAGE" -lt "$COPILOT_DAILY_LIMIT" ]; then
  AGENT="copilot"
elif [ "$OPENCODE_USAGE" -lt "$OPENCODE_DAILY_LIMIT" ]; then
  AGENT="opencode"
else
  AGENT="gemini"  # Free tier fallback
fi

echo "Selected agent: $AGENT (usage: $CLAUDE_USAGE claude, $COPILOT_USAGE copilot, $OPENCODE_USAGE opencode)"

# Log usage
echo "$TODAY $(date '+%H:%M:%S'),$AGENT,1" >> "$USAGE_FILE"

# Run ralph with selected agent
ralph run --backend "$AGENT" "$@"
```

**Usage:**
```bash
chmod +x ralph-rotate.sh
./ralph-rotate.sh --max-iterations 15
```

---

## Best Practices

### 1. Maintain Multiple Agent Subscriptions

**Recommended minimum:** 2 agents

**Why:**
- Quota overflow protection
- Getting unstuck capability
- Redundancy if one agent has outage

**Suggested combinations:**
- **Budget:** Copilot Pro ($10) + Gemini CLI (free)
- **Balanced:** Claude Pro ($20) + Copilot Pro ($10)
- **Premium:** Claude Pro + OpenCode Zen + Copilot Pro

---

### 2. Monitor Quota Usage Daily

Set up daily check:
```bash
# Add to crontab
0 18 * * * ~/bin/ralph-quota-check.sh
```

**quota-check.sh:**
```bash
#!/bin/bash
TODAY=$(date '+%Y-%m-%d')
grep "^$TODAY" ~/.ralph-usage.csv | \
  awk -F',' '{sum[$2]++} END {for (i in sum) print i": "sum[i]}' | \
  mail -s "Ralph Agent Usage $TODAY" you@example.com
```

---

### 3. Document Task-Agent Pairings

Track which agents work best for your specific codebase/patterns:

```markdown
# .ralph/agent-notes.md

## Agent Performance Notes

### Claude Code
- ✅ Excellent: Complex refactoring (user service cleanup)
- ✅ Excellent: Subtle type inference (generic constraints)
- ❌ Struggled: Simple CRUD (overkill, slower)

### GitHub Copilot
- ✅ Excellent: TDD loops (auth feature)
- ✅ Excellent: Quick iterations (verbose flag)
- ❌ Struggled: Edge case handling (rate limiting per-IP logic)

### OpenCode Zen
- ✅ Excellent: API integrations (Stripe webhook)
- ✅ Good: Balanced tasks (search endpoint)
```

**Evolve over time:** Learn which agent excels at which tasks in YOUR codebase.

---

## Troubleshooting

### Agent Not Found

**Symptom:** `ralph run --backend claude` fails with "claude not found"

**Fix:**
```bash
# Install CLI agent
npm install -g @anthropic-ai/claude-code  # Claude
npm install -g @github/copilot-cli        # Copilot
npm install -g opencode                   # OpenCode

# Verify installation
which claude
which copilot
which opencode
```

---

### Quota Exceeded Mid-Task

**Symptom:** Agent stops mid-loop with quota error

**Fix:**
```bash
# Check which agent hit quota
ralph doctor  # Shows backend status

# Switch to different agent
sed -i 's/backend: "claude"/backend: "copilot"/' ralph.yml

# Resume from checkpoint
ralph run --continue
```

---

### All Agents at Quota

**Symptom:** No agents available

**Options:**
1. **Wait:** Quotas reset (Claude: 12h, Copilot: monthly)
2. **Use free tier:** Gemini CLI or local models
3. **Upgrade plan:** Copilot Pro+ (1,500 requests vs. 300)

---

## Future: Automated Agent Selection

**If ralph adds native rotation support (check latest docs):**

```yaml
# ralph.yml (hypothetical)
cli:
  backends:
    - name: claude
      priority: 1
      quota_limit: 300/day
    - name: copilot
      priority: 2
      quota_limit: 10/day
    - name: gemini
      priority: 3
      quota_limit: unlimited
  
  rotation:
    strategy: "coding-plan-first"  # or round-robin, task-based
    stuck_threshold: 3  # Switch after 3 same errors
```

**Check ralph documentation for latest rotation features.**

---

## Summary

**Key takeaways:**
1. **Multiple agents = quota resilience** — Never blocked by single agent limit
2. **Different agents = getting unstuck** — Switch agent if stuck 3+ iterations
3. **Coding-plan-first** — Use best quality agent, overflow to others
4. **Track usage** — Monitor daily to avoid hitting quotas
5. **Learn patterns** — Document which agents work best for your tasks

**Recommended setup:**
- Primary: Claude Code or OpenCode Zen (best quality)
- Secondary: GitHub Copilot (good balance, lower cost)
- Tertiary: Gemini CLI (free tier overflow)

**Result:** Resilient, cost-effective coding loop that never blocks and gets unstuck faster.
