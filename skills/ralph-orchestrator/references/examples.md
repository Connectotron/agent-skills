# Ralph Orchestrator Examples

Detailed workflow breakdowns with expected iteration counts and costs.

## Table of Contents

1. [Simple Task: Add Verbose Flag](#simple-task-add-verbose-flag)
2. [TDD Workflow: User Authentication](#tdd-workflow-user-authentication)
3. [Bug Fix: Rate Limiting](#bug-fix-rate-limiting)
4. [Refactoring: Extract Service](#refactoring-extract-service)
5. [Full Pipeline: Blog Search Feature](#full-pipeline-blog-search-feature)

---

## Simple Task: Add Verbose Flag

**Goal:** Add a `--verbose` flag to enable debug logging

**Complexity:** Low  
**Expected iterations:** 2-3  
**Expected cost:** ~$0.15-0.30 (Claude Sonnet)

### Setup

```bash
cd ~/my-cli-project
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Add a --verbose flag to the CLI that enables debug logging

Acceptance criteria:
- -v and --verbose flags both work
- When enabled, shows detailed output
- When disabled (default), shows minimal output
- Tests verify verbose vs. normal mode
EOF
```

### Run

```bash
ralph run
```

### Expected Workflow

**Iteration 1:**
1. **Planner** detects rough description input, derives task name `add-verbose-flag`
2. **Builder** explores codebase:
   - Searches for existing flag implementations
   - Identifies CLI argument parser (e.g., `argparse`, `commander`, `clap`)
   - Notes existing logging patterns
3. **Builder** writes failing tests (RED):
   ```python
   def test_verbose_flag_enables_debug():
       result = run_cli("--verbose", "command")
       assert "DEBUG:" in result.output
   
   def test_no_verbose_flag_hides_debug():
       result = run_cli("command")
       assert "DEBUG:" not in result.output
   ```
4. **Builder** runs tests → FAIL (expected)
5. **Builder** implements minimal code (GREEN):
   - Adds `--verbose` flag to argument parser
   - Adds conditional logging based on verbose flag
6. **Builder** runs tests → PASS
7. **Builder** publishes `implementation.ready`

**Iteration 2:**
1. **Validator** receives `implementation.ready`
2. **Validator** runs full test suite → PASS
3. **Validator** runs linter → PASS
4. **Validator** runs type checker → PASS
5. **Validator** performs YAGNI check:
   - No extra log levels (INFO, WARNING, ERROR) added (good)
   - No config file support added (good)
   - Only verbose flag implemented (good)
6. **Validator** performs KISS check:
   - Simple boolean flag (good)
   - No complex logging framework (good)
7. **Validator** publishes `validation.passed`

**Iteration 3:**
1. **Committer** receives `validation.passed`
2. **Committer** runs `git status`, `git diff`
3. **Committer** stages files: `src/cli.py`, `tests/test_cli.py`
4. **Committer** creates commit:
   ```
   feat(cli): add verbose flag for debug logging
   
   Implement --verbose/-v flag that enables detailed debug output
   during command execution. Useful for troubleshooting.
   
   🤖 Assisted by ralph-orchestrator
   ```
5. **Committer** publishes `commit.complete` → Loop ends

### Cost Breakdown

- **Iteration 1:** ~$0.10 (exploration + testing + implementation)
- **Iteration 2:** ~$0.05 (validation checks)
- **Iteration 3:** ~$0.02 (commit creation)
- **Total:** ~$0.17

---

## TDD Workflow: User Authentication

**Goal:** Implement user authentication with email/password login, JWT tokens, password hashing, and rate limiting

**Complexity:** High  
**Expected iterations:** 8-12  
**Expected cost:** ~$1.20-1.80 (Claude Sonnet)

### Setup

```bash
cd ~/my-api-project
ralph init --preset code-assist

cat > PROMPT.md << 'EOF'
Implement user authentication:
- Email/password login endpoint POST /auth/login
- JWT token generation with 24-hour expiry
- Password hashing with bcrypt (12 rounds)
- Rate limiting: 5 login attempts per 15 minutes per IP
- Tests for all edge cases

Success criteria:
- All tests pass (unit + integration)
- No TypeScript errors
- ESLint passes
- Manual E2E test: successful login returns valid JWT
- Manual E2E test: invalid credentials return 401
- Manual E2E test: rate limit enforced after 5 attempts
EOF

ralph run --tui --max-iterations 30
```

### Expected Workflow

**Iterations 1-2: Login endpoint skeleton**
1. **Builder** explores existing auth patterns
2. **Builder** writes failing tests for POST /auth/login endpoint
3. **Builder** implements minimal endpoint (no JWT, no hashing yet)
4. **Validator** fails: JWT generation missing

**Iterations 3-4: JWT token generation**
1. **Builder** writes tests for JWT generation
2. **Builder** implements JWT signing with 24-hour expiry
3. **Validator** fails: Password not hashed

**Iterations 5-6: Password hashing**
1. **Builder** writes tests for bcrypt hashing
2. **Builder** implements password verification with bcrypt
3. **Validator** fails: Rate limiting missing

**Iterations 7-9: Rate limiting**
1. **Builder** writes tests for rate limiting (5 attempts per 15 min)
2. **Builder** implements rate limiting middleware (in-memory or Redis)
3. **Validator** passes unit tests but fails manual E2E test

**Iteration 10: Fix E2E issues**
1. **Builder** reviews E2E test failure logs
2. **Builder** fixes timing issues in rate limiting
3. **Validator** passes all checks

**Iteration 11: Final validation**
1. **Validator** runs full test suite → PASS
2. **Validator** runs linters → PASS
3. **Validator** performs YAGNI check:
   - No OAuth support added (good)
   - No password reset flow added (good)
   - Only login endpoint implemented (good)
4. **Validator** performs manual E2E tests:
   - Successful login returns valid JWT → PASS
   - Invalid credentials return 401 → PASS
   - Rate limit enforced after 5 attempts → PASS
5. **Validator** publishes `validation.passed`

**Iteration 12: Commit**
1. **Committer** creates commit:
   ```
   feat(auth): implement user authentication with rate limiting
   
   - Add POST /auth/login endpoint with email/password
   - Generate JWT tokens with 24-hour expiry
   - Hash passwords with bcrypt (12 rounds)
   - Enforce rate limiting: 5 attempts per 15 minutes per IP
   
   All acceptance criteria verified via tests and manual E2E testing.
   
   🤖 Assisted by ralph-orchestrator
   ```

### Cost Breakdown (Claude Sonnet)

- **Iterations 1-2:** ~$0.20 (exploration + endpoint)
- **Iterations 3-4:** ~$0.20 (JWT implementation)
- **Iterations 5-6:** ~$0.20 (password hashing)
- **Iterations 7-9:** ~$0.30 (rate limiting + fixes)
- **Iteration 10:** ~$0.15 (E2E fix)
- **Iteration 11:** ~$0.10 (final validation)
- **Iteration 12:** ~$0.05 (commit)
- **Total:** ~$1.20

### If Using Kiro (Cheaper)

- **Total:** ~$0.20-0.30 (same iterations, 80% cheaper)

---

## Bug Fix: Rate Limiting

**Goal:** Fix bug where rate limiting is not enforced per IP, only globally

**Complexity:** Medium  
**Expected iterations:** 4-6  
**Expected cost:** ~$0.40-0.60 (Claude Sonnet)

### Setup

```bash
cd ~/my-api-project
git checkout feature/auth  # Branch with buggy rate limiting
ralph init --preset bugfix

cat > PROMPT.md << 'EOF'
Bug: Rate limiting applies globally, not per IP
Expected: Each IP should have independent 5 attempts per 15 minutes
Current behavior: All IPs share same 5-attempt limit

Steps to reproduce:
1. Login from IP A 5 times (gets rate limited)
2. Login from IP B immediately (also rate limited - WRONG)

Expected: IP B should NOT be rate limited
EOF

ralph run
```

### Expected Workflow

**Iteration 1:**
1. **Bug Hunter** reads bug description
2. **Bug Hunter** explores rate limiting code:
   - Finds: `rateLimitStore.increment("global")` (bug)
   - Should be: `rateLimitStore.increment(req.ip)`
3. **Bug Hunter** writes failing test reproducing bug:
   ```typescript
   it('should rate limit per IP independently', async () => {
     // 5 attempts from IP A
     for (let i = 0; i < 5; i++) {
       await request(app).post('/auth/login').set('X-Forwarded-For', '1.2.3.4');
     }
     
     // 6th attempt from IP A should fail
     const resultA = await request(app).post('/auth/login').set('X-Forwarded-For', '1.2.3.4');
     expect(resultA.status).toBe(429);
     
     // 1st attempt from IP B should succeed (independent limit)
     const resultB = await request(app).post('/auth/login').set('X-Forwarded-For', '5.6.7.8');
     expect(resultB.status).not.toBe(429);  // FAILS (bug reproduced)
   });
   ```
4. **Bug Hunter** runs test → FAIL (bug confirmed)
5. **Bug Hunter** publishes `bug.reproduced`

**Iteration 2:**
1. **Fixer** receives `bug.reproduced`
2. **Fixer** reviews failing test
3. **Fixer** implements minimal fix:
   ```typescript
   // Before (buggy)
   const count = rateLimitStore.increment("global");
   
   // After (fixed)
   const clientIP = req.ip || req.socket.remoteAddress;
   const count = rateLimitStore.increment(`rate_limit:${clientIP}`);
   ```
4. **Fixer** runs tests → PASS
5. **Fixer** publishes `fix.ready`

**Iteration 3:**
1. **Verifier** receives `fix.ready`
2. **Verifier** runs full test suite → PASS
3. **Verifier** checks for regressions:
   - Global rate limiting still works: PASS
   - Per-IP rate limiting now works: PASS
4. **Verifier** performs manual E2E test:
   - Login from IP A 5 times → 6th attempt rate limited
   - Login from IP B immediately → Succeeds (independent limit)
5. **Verifier** publishes `verification.passed`

**Iteration 4:**
1. **Committer** creates commit:
   ```
   fix(auth): enforce rate limiting per IP instead of globally
   
   Bug: Rate limiting was applied globally across all IPs. Once any
   IP hit the 5-attempt limit, all subsequent login attempts from any
   IP were rate limited.
   
   Fix: Changed rate limit key from "global" to include client IP
   address. Each IP now has independent 5 attempts per 15 minutes.
   
   Verified with tests and manual E2E testing.
   
   🤖 Assisted by ralph-orchestrator
   ```

### Cost Breakdown

- **Iteration 1:** ~$0.15 (bug reproduction)
- **Iteration 2:** ~$0.10 (fix implementation)
- **Iteration 3:** ~$0.10 (verification)
- **Iteration 4:** ~$0.05 (commit)
- **Total:** ~$0.40

---

## Refactoring: Extract Service

**Goal:** Extract email validation logic from UserController into separate EmailValidator service

**Complexity:** Medium  
**Expected iterations:** 3-5  
**Expected cost:** ~$0.30-0.50 (Claude Sonnet)

### Setup

```bash
cd ~/my-api-project
ralph init --preset refactor

cat > PROMPT.md << 'EOF'
Refactor: Extract email validation from UserController into EmailValidator service

Current state: Email validation logic scattered across UserController methods
Desired state: Single EmailValidator service with clear responsibilities

Constraints:
- All existing tests must still pass
- No behavior changes (refactor only)
- Follow existing service patterns in codebase
EOF

ralph run
```

### Expected Workflow

**Iteration 1:**
1. **Analyzer** examines UserController
2. **Analyzer** identifies email validation code smell:
   - Regex pattern duplicated in 3 places
   - Domain blocklist check duplicated
   - No single source of truth
3. **Analyzer** proposes refactoring:
   - Create `src/services/EmailValidator.ts`
   - Extract all email validation logic
   - Replace duplicated code with service calls
4. **Analyzer** publishes `analysis.complete`

**Iteration 2:**
1. **Refactorer** receives `analysis.complete`
2. **Refactorer** creates EmailValidator service:
   ```typescript
   export class EmailValidator {
     validate(email: string): boolean {
       return this.isValidFormat(email) && !this.isBlockedDomain(email);
     }
     
     private isValidFormat(email: string): boolean {
       return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
     }
     
     private isBlockedDomain(email: string): boolean {
       const domain = email.split('@')[1];
       return BLOCKED_DOMAINS.includes(domain);
     }
   }
   ```
3. **Refactorer** replaces duplicated code in UserController
4. **Refactorer** runs tests → PASS (behavior preserved)
5. **Refactorer** publishes `refactor.ready`

**Iteration 3:**
1. **Validator** receives `refactor.ready`
2. **Validator** runs full test suite → PASS
3. **Validator** verifies behavior unchanged:
   - All existing tests still pass
   - No new tests needed (refactor only)
4. **Validator** checks complexity metrics:
   - UserController: 150 lines → 120 lines (reduced)
   - EmailValidator: 0 lines → 30 lines (new)
   - Cyclomatic complexity decreased (good)
5. **Validator** publishes `validation.passed`

**Iteration 4:**
1. **Committer** creates commit:
   ```
   refactor(users): extract email validation into EmailValidator service
   
   Extracted email validation logic from UserController into dedicated
   EmailValidator service. Reduces duplication (validation logic was
   repeated in 3 methods) and improves testability.
   
   No behavior changes. All existing tests pass.
   
   🤖 Assisted by ralph-orchestrator
   ```

### Cost Breakdown

- **Iteration 1:** ~$0.10 (analysis)
- **Iteration 2:** ~$0.15 (refactoring)
- **Iteration 3:** ~$0.05 (validation)
- **Iteration 4:** ~$0.05 (commit)
- **Total:** ~$0.35

---

## Full Pipeline: Blog Search Feature

**Goal:** From high-level idea to working code, fully autonomous

**Complexity:** Very High  
**Expected iterations:** 30-60  
**Expected cost:** ~$4.50-9.00 (Claude Sonnet)

### Setup

```bash
cd ~/my-blog-project
ralph init --preset pdd-to-code-assist

cat > PROMPT.md << 'EOF'
I want to add a search feature to the blog that supports:
- Full-text search across post titles and content
- Filtering by tags (multiple tags with AND/OR logic)
- Sorting by relevance (default) or date (newest/oldest)
- Pagination (20 results per page)
- Search suggestions as user types (debounced)
EOF

ralph run --tui --max-iterations 100 --max-runtime-seconds 14400  # 4 hours max
```

### Expected Workflow

**Phase 1: Planning (PDD) — Iterations 1-10**

**Iteration 1-3: Requirements Analysis**
1. **Chief of Staff** breaks down idea:
   - Frontend: Search UI component
   - Backend: Search API endpoint
   - Database: Full-text search index
   - Testing: E2E search scenarios
2. **Chief of Staff** creates design doc: `.ralph/specs/search-feature/design.md`

**Iteration 4-8: Task Generation**
1. **Planner** generates code tasks:
   - Task 1: Add full-text search index to database
   - Task 2: Implement search API endpoint
   - Task 3: Add tag filtering with AND/OR logic
   - Task 4: Implement sorting (relevance/date)
   - Task 5: Add pagination
   - Task 6: Build frontend search UI
   - Task 7: Implement search suggestions (debounced)
   - Task 8: Integration tests
2. **Planner** saves tasks: `.ralph/specs/search-feature/tasks/*.code-task.md`

**Iteration 9-10: E2E Test Plan**
1. **Planner** creates test plan: `.ralph/specs/search-feature/plan.md`
2. **Planner** publishes `tasks.ready`

**Phase 2: Implementation (Code-Assist) — Iterations 11-50**

**Iterations 11-15: Task 1 (Search Index)**
1. **Builder** reads Task 1
2. **Builder** writes tests for search index
3. **Builder** implements search index (e.g., PostgreSQL full-text, Elasticsearch)
4. **Validator** verifies tests pass, marks task complete

**Iterations 16-20: Task 2 (Search API)**
1. **Builder** reads Task 2
2. **Builder** writes tests for GET /api/search endpoint
3. **Builder** implements endpoint with query parsing
4. **Validator** verifies tests pass, marks task complete

**Iterations 21-25: Task 3 (Tag Filtering)**
1. **Builder** reads Task 3
2. **Builder** writes tests for AND/OR tag logic
3. **Builder** implements tag filtering
4. **Validator** verifies tests pass, marks task complete

**Iterations 26-30: Task 4 (Sorting)**
1. **Builder** reads Task 4
2. **Builder** writes tests for relevance/date sorting
3. **Builder** implements sorting algorithms
4. **Validator** verifies tests pass, marks task complete

**Iterations 31-35: Task 5 (Pagination)**
1. **Builder** reads Task 5
2. **Builder** writes tests for pagination
3. **Builder** implements cursor-based pagination
4. **Validator** verifies tests pass, marks task complete

**Iterations 36-42: Task 6 (Frontend UI)**
1. **Builder** reads Task 6
2. **Builder** writes component tests
3. **Builder** implements SearchBar, SearchResults components
4. **Validator** verifies tests pass, marks task complete

**Iterations 43-47: Task 7 (Search Suggestions)**
1. **Builder** reads Task 7
2. **Builder** writes tests for debounced suggestions
3. **Builder** implements autocomplete with debouncing
4. **Validator** verifies tests pass, marks task complete

**Iterations 48-50: Task 8 (Integration Tests)**
1. **Builder** reads Task 8
2. **Builder** writes E2E tests
3. **Validator** verifies all E2E scenarios pass

**Phase 3: Final Validation — Iterations 51-55**

**Iteration 51-53: Full E2E Test Plan**
1. **Validator** runs manual E2E test plan:
   - Search for "authentication" → Returns relevant posts
   - Filter by tags ["tutorial", "security"] with AND logic → Correct subset
   - Sort by date (newest first) → Chronological order
   - Pagination works → 20 results per page
   - Search suggestions appear as user types → Debounced correctly
2. **Validator** verifies all scenarios: PASS

**Iteration 54: Final Quality Checks**
1. **Validator** runs full test suite → PASS
2. **Validator** runs linters → PASS
3. **Validator** performs YAGNI check:
   - No advanced search operators added (good)
   - No saved searches feature added (good)
   - Only requested features implemented (good)

**Iteration 55: Commit**
1. **Committer** creates commits (one per task):
   ```
   feat(search): add full-text search index
   feat(search): implement search API endpoint
   feat(search): add tag filtering with AND/OR logic
   feat(search): implement relevance and date sorting
   feat(search): add cursor-based pagination
   feat(search): build frontend search UI
   feat(search): implement debounced search suggestions
   test(search): add E2E integration tests
   
   🤖 Assisted by ralph-orchestrator
   ```

### Cost Breakdown (Claude Sonnet)

- **Phase 1 (Planning):** ~$1.50 (10 iterations, spec generation)
- **Phase 2 (Implementation):** ~$6.00 (40 iterations, 8 tasks × 5 iterations each)
- **Phase 3 (Validation):** ~$0.75 (5 iterations, E2E testing)
- **Total:** ~$8.25

### If Using Kiro (80% cheaper)

- **Total:** ~$1.65

### Runtime

- **With TUI:** 2-3 hours (depends on test suite speed)
- **Overnight run:** Set `--max-runtime-seconds 28800` (8 hours) and walk away

---

## Cost Comparison Summary

| Task Complexity | Iterations | Claude Sonnet | Kiro | Runtime |
|-----------------|-----------|---------------|------|---------|
| Simple (verbose flag) | 2-3 | $0.15-0.30 | $0.03-0.06 | 5-10 min |
| Medium (auth feature) | 8-12 | $1.20-1.80 | $0.20-0.30 | 20-30 min |
| Bug fix | 4-6 | $0.40-0.60 | $0.08-0.12 | 10-15 min |
| Refactoring | 3-5 | $0.30-0.50 | $0.06-0.10 | 10-15 min |
| Complex (full pipeline) | 30-60 | $4.50-9.00 | $0.90-1.80 | 2-4 hours |

**Recommendation:** Use Kiro for experimentation and iteration. Switch to Claude Sonnet for final production runs when quality is critical.
