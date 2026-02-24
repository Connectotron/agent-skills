# Ralph Orchestrator Troubleshooting Guide

Common issues and solutions when using ralph-orchestrator.

## Installation Issues

### Command Not Found After Installation

**Symptom:** `ralph: command not found` after `brew install ralph-orchestrator`

**Cause:** Binary not in PATH

**Solution:**
```bash
# Verify installation location
which ralph

# If using Homebrew, ensure /opt/homebrew/bin in PATH
echo $PATH | grep homebrew

# Add to shell profile if missing
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### No AI Agents Detected

**Symptom:** `ralph doctor` reports "No backends available"

**Cause:** No AI CLI tools installed or not in PATH

**Solution:**
```bash
# Install at least one backend
npm install -g @anthropic-ai/claude-code   # Claude
npm install -g @google/gemini-cli          # Gemini
curl -fsSL https://opencode.ai/install | bash  # OpenCode

# Verify backend available
claude --version
gemini --version
opencode --version
```

### Authentication Errors

**Symptom:** `ralph run` fails with authentication error

**Cause:** API key not set for backend

**Solution:**
```bash
# Set API key for your backend
export ANTHROPIC_API_KEY="sk-ant-..."       # Claude
export GOOGLE_API_KEY="..."                 # Gemini
export OPENAI_API_KEY="sk-..."              # OpenAI/Codex

# Add to shell profile for persistence
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
```

---

## Loop Behavior Issues

### Loop Never Ends

**Symptom:** Ralph keeps iterating indefinitely, never outputs `LOOP_COMPLETE`

**Common causes:**

**1. Weak completion criteria**
```markdown
# Bad: Vague criteria
Add user authentication
```

**Fix:** Add specific, testable criteria
```markdown
Add user authentication

Acceptance criteria:
- Email/password login endpoint returns JWT
- Password hashed with bcrypt
- Rate limiting: 5 attempts per 15 minutes
- Tests verify all edge cases
- Manual E2E test: successful login returns valid JWT
```

**2. Impossible task**

Task requires functionality not available in codebase/environment.

**Fix:** Verify task is achievable manually first. Check dependencies installed, environment configured.

**3. Flaky tests**

Tests pass sometimes, fail other times (timing issues, network dependencies).

**Fix:** Stabilize tests before using ralph. Mock external dependencies.

**4. Missing completion promise**

```yaml
# ralph.yml
event_loop:
  completion_promise: "LOOP_COMPLETE"  # Ensure this is set
```

### Loop Ends Too Early

**Symptom:** Ralph outputs `LOOP_COMPLETE` before task is actually done

**Common causes:**

**1. Overly optimistic agent**

Agent thinks task is done but validation hasn't run yet.

**Fix:** Ensure Validator hat is triggering on `implementation.ready`:
```yaml
hats:
  validator:
    triggers: ["implementation.ready"]  # Must trigger
```

**2. Weak validation gates**

Validator passing when it shouldn't.

**Fix:** Strengthen validation gates in preset:
```yaml
core:
  guardrails:
    - "Verification is mandatory — tests/typecheck/lint/audit must pass"
    - "YAGNI ruthlessly — no speculative features"
```

**3. Early completion promise**

Agent outputs "LOOP_COMPLETE" in scratchpad before work is done.

**Fix:** Change completion promise to unique string:
```yaml
event_loop:
  completion_promise: "RALPH_LOOP_FINISHED_ALL_WORK"
```

---

## Quality Issues

### Quality Degrades Over Iterations

**Symptom:** First few iterations are good, then agent starts making mistakes

**Cause:** Context window filling up with accumulated conversation

**Fix (built-in):** Ralph already implements fresh context each iteration. If still degrading:

1. **Check memories are being written:**
```bash
ls .ralph/agent/memories/
```

2. **Reduce max_iterations:**
```yaml
event_loop:
  max_iterations: 30  # Lower if quality degrades after iteration 20
```

3. **Use cheaper model for exploration, expensive for final passes:**
```yaml
cli:
  backend: "kiro"  # Cheaper for iterations 1-20
```

Then switch to Claude for final verification.

### Tests Pass Locally but Fail in Ralph

**Symptom:** `npm test` passes manually, but Validator reports failures

**Cause:** Environment differences (missing env vars, different working directory, etc.)

**Fix:**
```bash
# Run ralph from same directory as manual tests
cd ~/my-project
ralph run

# Ensure environment variables available to ralph
export NODE_ENV=test
ralph run

# Check working directory in ralph.yml
pwd  # Should match where tests expect to run
```

### YAGNI Check Keeps Failing

**Symptom:** Validator rejects code for "speculative features"

**Cause:** Builder adding features not in acceptance criteria

**Fix:** Make acceptance criteria exhaustive:
```markdown
Implement ONLY these features:
- Feature A with behavior X
- Feature B with behavior Y

DO NOT implement:
- Feature C
- Any "future-proofing" abstractions
```

---

## Cost Issues

### Unexpected High Costs

**Symptom:** Ralph loop costs more than estimated

**Common causes:**

**1. Too many iterations**

Task poorly scoped, agent can't converge.

**Fix:** Set spending limit:
```bash
ralph run --max-spend 5.00  # Stop at $5
```

Review task scope:
```markdown
# Bad: Too broad
Implement complete e-commerce system

# Good: One feature at a time
Implement shopping cart add/remove item functionality
```

**2. Expensive model**

Using Claude Sonnet for simple tasks.

**Fix:** Use cheaper backend:
```yaml
cli:
  backend: "kiro"        # Much cheaper
  # backend: "opencode"  # Free (with Zen models)
```

**3. Large codebase**

Agent loading entire codebase into context each iteration.

**Fix:** Work in subdirectory:
```bash
cd ~/my-project/src/feature-x
ralph run  # Limits scope
```

Or specify files explicitly in PROMPT.md:
```markdown
Only modify these files:
- src/auth/login.ts
- src/auth/login.test.ts
```

---

## Git Issues

### Uncommitted Changes Warning

**Symptom:** `ralph doctor` warns "Working tree has uncommitted changes"

**Cause:** Uncommitted files in working tree

**Fix (recommended):** Commit or stash changes before running:
```bash
git add .
git commit -m "WIP: before ralph run"
ralph run
```

Or stash:
```bash
git stash
ralph run
git stash pop
```

**Why it matters:** Ralph checkpoints rely on clean git state. Uncommitted changes make rollback difficult.

### Checkpoint Restore Fails

**Symptom:** `ralph checkpoint restore 5` fails with git error

**Cause:** Conflicts between checkpoint and current state

**Fix:**
```bash
# Hard reset to checkpoint (destructive)
git reset --hard ralph-checkpoint-iter-5

# Or view checkpoint first
git show ralph-checkpoint-iter-5
```

---

## Performance Issues

### Slow Iteration Times

**Symptom:** Each iteration takes 2-3 minutes

**Common causes:**

**1. Large test suite**

Full test suite runs every iteration.

**Fix:** Run only relevant tests in ralph loop:
```yaml
# In preset configuration
hats:
  validator:
    instructions: |
      Run only unit tests for modified files:
      pytest tests/test_auth.py  # Not entire suite
```

**2. Slow linters**

Heavy linters like mypy run on entire codebase.

**Fix:** Scope linting to changed files:
```bash
# Instead of: mypy .
# Use: mypy src/auth/  # Only relevant directory
```

**3. Network-dependent tests**

Tests making real HTTP requests.

**Fix:** Mock network calls in tests. Ralph should work offline.

---

## Backend-Specific Issues

### Claude Rate Limits

**Symptom:** "Rate limit exceeded" error mid-loop

**Fix:**
```bash
# Wait and retry
sleep 60
ralph run  # Resumes from checkpoint

# Or switch to cheaper tier with higher rate limits
```

### Kiro Model Unavailable

**Symptom:** "Model not found" or "quota exceeded"

**Fix:** Try fallback model:
```yaml
cli:
  backend: "claude"  # More reliable, higher cost
```

Or check Kiro status: https://kiro.dev/status

### OpenCode Zen Model Changes

**Symptom:** `opencode/kimi-k2.5-free` no longer available

**Fix:** Check current Zen models:
```bash
curl https://opencode.ai/zen/v1/models
```

Update ralph.yml with available model:
```yaml
cli:
  backend: "opencode"
  model: "opencode/glm-4.7-free"  # Update to current free model
```

---

## Debugging Techniques

### Enable Verbose Logging

```bash
ralph run --verbose
```

Shows detailed event flow, hat triggers, and decision points.

### Check Event History

```bash
ralph events
```

Lists all events published during loop (useful for debugging hat coordination).

### Inspect Memories

```bash
cat .ralph/agent/memories/$(date +%Y-%m-%d).md
```

See what agent learned during loop.

### Review Decision Log

```bash
cat .ralph/agent/decisions.md
```

See low-confidence decisions agent made (confidence < 80).

### Monitor in Real-Time

```bash
ralph run --tui
```

Live terminal UI shows:
- Current iteration
- Active hat
- Recent events
- Token usage
- Cost tracker

---

## Getting Help

If issue not covered here:

1. **Check upstream docs:** https://mikeyobrien.github.io/ralph-orchestrator/
2. **GitHub issues:** https://github.com/mikeyobrien/ralph-orchestrator/issues
3. **Discord:** https://discord.com/invite/clawd (OpenClaw community)

When reporting issues, include:
- `ralph --version` output
- `ralph doctor` output
- Relevant section of ralph.yml
- Last 10 lines of ralph output
