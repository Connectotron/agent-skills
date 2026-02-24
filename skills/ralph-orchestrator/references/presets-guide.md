# Ralph Orchestrator Preset Guide

Complete guide to all 15 built-in presets and when to use each.

## Table of Contents

1. [code-assist](#code-assist) — TDD implementation (most common)
2. [bugfix](#bugfix) — Bug reproduction + fix
3. [feature](#feature) — Feature development with review
4. [refactor](#refactor) — Code refactoring
5. [spec-driven](#spec-driven) — Specification-driven development
6. [pdd-to-code-assist](#pdd-to-code-assist) — Full idea-to-code pipeline
7. [debug](#debug) — Bug investigation
8. [pr-review](#pr-review) — Multi-perspective code review
9. [docs](#docs) — Documentation generation
10. [deploy](#deploy) — Deployment workflow
11. [research](#research) — Deep exploration
12. [gap-analysis](#gap-analysis) — Gap analysis and planning
13. [review](#review) — General code review
14. [merge-loop](#merge-loop) — Merge parallel loops
15. [hatless-baseline](#hatless-baseline) — Baseline for comparison

---

## code-assist

**Use for:** TDD implementation from specs, tasks, or descriptions

**Hats:** Planner, Builder, Validator, Committer

**Input types:**
- PDD output directory (`.ralph/specs/my-feature/`)
- Single code task file (`.ralph/tasks/add-flag.code-task.md`)
- Rough description ("Add verbose flag")

**Workflow:**
1. Planner detects input type and bootstraps context
2. Builder explores codebase, writes failing tests (RED)
3. Builder implements minimal code to pass tests (GREEN)
4. Builder refactors while keeping tests green (REFACTOR)
5. Validator runs all gates (tests, linters, type checks, YAGNI, KISS, E2E)
6. Committer creates conventional commit

**Max iterations:** 100  
**Max runtime:** 4 hours  
**Backend:** Kiro (change via `cli.backend` in ralph.yml)

**Example:**
```bash
ralph init --preset code-assist
cat > PROMPT.md << 'EOF'
Add --verbose flag
EOF
ralph run
```

---

## bugfix

**Use for:** Systematic bug reproduction, fix, and verification

**Hats:** Bug Hunter, Fixer, Verifier, Committer

**Workflow:**
1. Bug Hunter reproduces the bug with failing test
2. Fixer implements minimal fix to make test pass
3. Verifier confirms bug is fixed and no regressions
4. Committer creates fix commit with bug reference

**Input format:**
```markdown
Bug: API returns 500 when email missing
Expected: Should return 400 Bad Request with error message
Steps to reproduce: POST /users without email field
```

**Max iterations:** 50  
**Max runtime:** 2 hours

**Example:**
```bash
ralph init --preset bugfix
cat > PROMPT.md << 'EOF'
Bug: Login fails with special characters in password
Expected: Should handle all printable ASCII
EOF
ralph run
```

---

## feature

**Use for:** Feature development with integrated code review

**Hats:** Planner, Builder, Reviewer, Committer

**Workflow:**
1. Planner breaks down feature into implementation steps
2. Builder implements each step with TDD
3. Reviewer provides multi-perspective code review
4. Builder addresses review feedback
5. Committer creates feature commit

**Perspectives reviewed:**
- Functionality (does it work?)
- Maintainability (can we sustain it?)
- Performance (is it efficient?)
- Security (is it safe?)

**Max iterations:** 100  
**Max runtime:** 4 hours

---

## refactor

**Use for:** Code refactoring with quality gates

**Hats:** Analyzer, Refactorer, Validator, Committer

**Workflow:**
1. Analyzer identifies code smells and refactoring opportunities
2. Refactorer applies refactorings while keeping tests green
3. Validator verifies behavior unchanged (tests still pass)
4. Committer creates refactor commit

**Constraints:**
- Tests must pass before AND after
- No new features (behavior preservation only)
- Complexity metrics should improve

**Example:**
```bash
ralph init --preset refactor
cat > PROMPT.md << 'EOF'
Refactor user service: extract email validation into separate function
EOF
ralph run
```

---

## spec-driven

**Use for:** Implementation from formal specifications

**Hats:** Spec Reader, Builder, Validator, Committer

**Workflow:**
1. Spec Reader parses specification document
2. Builder implements to spec with TDD
3. Validator verifies compliance with spec
4. Committer creates implementation commit

**Spec format:** Markdown with clear acceptance criteria

**Max iterations:** 100  
**Max runtime:** 4 hours

---

## pdd-to-code-assist

**Use for:** Full idea-to-code pipeline (planning + implementation)

**Hats:** Chief of Staff, Planner, Builder, Validator, Committer

**Workflow:**

**Phase 1: Planning (PDD)**
1. Chief of Staff breaks down idea into requirements
2. Planner creates design doc (`.ralph/specs/feature/design.md`)
3. Planner generates code tasks (`.ralph/specs/feature/tasks/*.code-task.md`)
4. Planner creates E2E test plan (`.ralph/specs/feature/plan.md`)

**Phase 2: Implementation (Code-Assist)**
5. Builder implements each task one at a time with TDD
6. Validator verifies each task
7. Validator runs full E2E test plan after all tasks complete
8. Committer creates commits

**Max iterations:** 100  
**Max runtime:** 4 hours  
**Use case:** Fully autonomous overnight runs

**Example:**
```bash
ralph init --preset pdd-to-code-assist
cat > PROMPT.md << 'EOF'
Add blog search: full-text search, tag filtering, sorting
EOF
ralph run --tui --max-iterations 100 --max-runtime-seconds 14400
```

**Expected:** 30-60 iterations, ~$4.50-9.00

---

## debug

**Use for:** Bug investigation and root cause analysis

**Hats:** Investigator, Analyzer, Reporter

**Workflow:**
1. Investigator gathers evidence (logs, stack traces, reproduction steps)
2. Analyzer performs root cause analysis
3. Reporter documents findings with recommendations

**Does NOT fix the bug** (use `bugfix` preset for that)

**Output:** Investigation report in `.ralph/agent/investigation.md`

---

## pr-review

**Use for:** Multi-perspective PR code review

**Hats:** Reviewer (multiple perspectives)

**Perspectives:**
- **Functionality:** Does it work as intended?
- **Tests:** Are edge cases covered?
- **Performance:** Any bottlenecks or inefficiencies?
- **Security:** Any vulnerabilities or risks?
- **Maintainability:** Will this be easy to maintain?
- **Documentation:** Are changes documented?

**Output:** Review comments in `.ralph/agent/review.md`

**Example:**
```bash
git checkout feature/new-auth
ralph init --preset pr-review
cat > PROMPT.md << 'EOF'
Review the authentication changes in this branch
EOF
ralph run
```

---

## docs

**Use for:** Documentation generation

**Hats:** Doc Writer, Reviewer, Committer

**Workflow:**
1. Doc Writer generates documentation from code
2. Reviewer checks accuracy and completeness
3. Committer creates doc commit

**Supports:**
- API documentation
- README files
- Architecture docs
- User guides

---

## deploy

**Use for:** Deployment and release workflow

**Hats:** Deployer, Verifier, Notifier

**Workflow:**
1. Deployer prepares release (version bump, changelog)
2. Verifier runs pre-deployment checks
3. Notifier announces deployment status

**Not autonomous** (requires manual approval steps)

---

## research

**Use for:** Deep exploration and analysis tasks

**Hats:** Researcher, Analyzer, Documenter

**Workflow:**
1. Researcher gathers information from codebase/docs
2. Analyzer synthesizes findings
3. Documenter creates research report

**Output:** Research findings in `.ralph/agent/research.md`

---

## gap-analysis

**Use for:** Gap analysis and planning workflow

**Hats:** Analyst, Planner, Documenter

**Workflow:**
1. Analyst identifies gaps between current state and desired state
2. Planner proposes steps to close gaps
3. Documenter creates gap analysis report

**Output:** Gap analysis in `.ralph/agent/gaps.md`

---

## review

**Use for:** General code review workflow

**Hats:** Reviewer, Commenter

**Simpler than `pr-review` (single perspective)

**Use when:** Quick code review needed without multi-perspective analysis

---

## merge-loop

**Use for:** Merge completed parallel loop from worktree back to main branch

**Hats:** Merger, Conflict Resolver, Validator

**Workflow:**
1. Merger attempts merge
2. Conflict Resolver handles conflicts if any
3. Validator verifies tests still pass

**Use after:** Running parallel ralph loops in separate worktrees

---

## hatless-baseline

**Use for:** Baseline mode for comparison (no hat system)

**Single agent, no event-driven coordination**

**Use when:** Comparing hat-based vs. traditional loop performance

---

## Choosing the Right Preset

| Task Type | Preset | Why |
|-----------|--------|-----|
| "Add feature X" | code-assist | TDD workflow with validation |
| "Fix bug Y" | bugfix | Reproduction + fix + verification |
| "Refactor Z" | refactor | Behavior preservation with tests |
| "Build from idea" | pdd-to-code-assist | Planning + implementation pipeline |
| "Review this PR" | pr-review | Multi-perspective analysis |
| "What's wrong here?" | debug | Investigation without fixing |
| "Generate docs" | docs | Documentation from code |

**Default recommendation:** Start with `code-assist` for most tasks. It handles specs, tasks, and descriptions equally well.
