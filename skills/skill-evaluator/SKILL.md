---
name: skill-evaluator
description: Systematically evaluate and compare AgentSkills using objective data (GitHub metrics, activity history, directory-level analysis) rather than assumptions. Use when the user needs to find, compare, or select the best AgentSkill for a specific task. Covers discovery, metrics gathering, quality assessment, and evidence-based recommendations.
metadata:
  version: 1.0.0
---

# AgentSkill Quality Evaluator

You are an expert at evaluating AgentSkill quality using objective data rather than subjective assumptions. Your goal is to help users find the best skills for their needs through systematic analysis.

## Core Principle

**Never make assumptions based on skill names, version numbers, or repository descriptions alone.**

Quality assessment requires:
1. Objective metrics (GitHub stars, forks, activity)
2. Directory-level analysis (for embedded skills)
3. Functionality comparison (competing vs. complementary)
4. Evidence-based recommendations

---

## Step 1: Discovery

### Search Multiple Sources

**Primary sources:**
1. **ClawHub** — `clawhub search "<topic>"`
2. **GitHub topic search** — `gh search repos "<topic>" topic:claude-skills --limit 20`
3. **Web search** — Look for curated lists, "awesome" repos, official collections

**Search strategies:**
- Topic-based: `"marketing" topic:claude-skills`
- Name-based: `"SEO skill" OR "content marketing skill"`
- Catalog search: Check VoltAgent/awesome-agent-skills, ComposioHQ/awesome-claude-skills

**Output:** List of 10-30 candidate repositories

---

## Step 2: Gather Repository-Level Metrics

For each candidate repository, gather objective data:

```bash
gh repo view <owner>/<repo> --json stargazerCount,forkCount,createdAt,pushedAt,issues,pullRequests,watchers
```

**Key metrics to capture:**
- ⭐ **Stars** — Community validation strength
- 🍴 **Forks** — Adoption/customization level  
- 👀 **Watchers** — Sustained interest
- 📅 **Created date** — Age of project
- 🔄 **Last push** — Recent activity (days ago)
- 🐛 **Open issues** — Unresolved problems
- 🔀 **Pull requests** — Community contributions

**Quality signals:**

| Metric | Excellent | Good | Warning | Red Flag |
|--------|-----------|------|---------|----------|
| Stars | 1,000+ | 100-1,000 | 10-100 | <10 |
| Activity | Updated today/week | Updated month | Updated 1-3 months | >3 months abandoned |
| Issues | <5% open, responsive | 5-15% open | 15-30% open | 30%+ open, ignored |
| Community | Multiple contributors | Some PRs | Solo dev | No contributions |

---

## Step 3: Check for Embedded Skills (Critical!)

**Problem:** High repository stars don't mean individual skills are quality.

**Example:**
- ComposioHQ/awesome-claude-skills has 36,874 stars
- But individual skills inside may be abandoned (added once, never maintained)

**Solution: Directory-level activity analysis**

For embedded skills, check specific directory commit history:

```bash
gh api "repos/<owner>/<repo>/commits?path=<skill-directory>" --jq '.[0:5] | .[] | {date: .commit.author.date, message: .commit.message}'
```

**Example:**
```bash
# Check when "content-research-writer" was last updated
gh api "repos/ComposioHQ/awesome-claude-skills/commits?path=content-research-writer" --jq '.[0:3] | .[] | {date: .commit.author.date, message: .commit.message}'
```

**Quality signals:**
- ✅ **Active:** Updates in last 30 days (skill is maintained)
- ⚠️ **Stale:** Last update 1-6 months ago (may be stable or abandoned)
- ❌ **Abandoned:** Last update >6 months ago, or only "initial commit" (dead)

**Use directory-level metrics, not repository-level, for embedded skills.**

---

## Step 4: Compare Competing vs. Complementary

When multiple skills appear to solve the same problem, determine:

### A. List All Skills in Each Candidate

```bash
# For standalone skill repos
gh api repos/<owner>/<repo>/contents/skills --jq '.[].name' | sort

# For specific skill directories
gh api repos/<owner>/<repo>/contents/<category> --jq '.[].name'
```

### B. Identify Overlaps

Create comparison matrix:

| Function | Repo A Skill | Repo B Skill | Overlap? |
|----------|--------------|--------------|----------|
| SEO audit | `seo-audit` | `on-page-seo-auditor` | ✅ Competing |
| Keyword research | `keyword-research` | — | ❌ Unique to A |
| Schema markup | `schema-markup` | `schema-markup-generator` | ✅ Competing |

**Competing skills** (same function):
- ⚠️ Installing both may cause conflicts
- Requires deeper analysis to determine which is better
- Consider installing one, testing, then switching if needed

**Complementary skills** (different functions):
- ✅ Safe to install both
- Provides broader coverage
- Recommended approach

### C. Decision Matrix

**Scenario 1: No overlap**
→ Install both (complementary strengths)

**Scenario 2: Partial overlap**
→ Install repo with broader coverage + better metrics, skip the other

**Scenario 3: Complete overlap**
→ Deep-dive comparison required (read SKILL.md files, test both)

---

## Step 5: Read Actual SKILL.md Contents (When Overlapping)

**When two skills claim same functionality, don't guess—read them.**

```bash
# Clone temporarily
git clone --depth 1 <repo-url> /tmp/skill-eval

# Read SKILL.md
cat /tmp/skill-eval/<skill-path>/SKILL.md

# Compare approaches, instructions, bundled resources
```

**Evaluation criteria:**
1. **Clarity** — Are instructions clear and actionable?
2. **Depth** — Surface-level or comprehensive guidance?
3. **References** — Bundled resources (docs, examples, scripts)?
4. **Maintenance** — Up-to-date practices or outdated?
5. **Flexibility** — One-size-fits-all or customizable?

---

## Step 6: Issue & PR Analysis

Check for red flags:

```bash
# List recent issues
gh issue list --repo <owner>/<repo> --limit 10 --state all

# List recent PRs
gh pr list --repo <owner>/<repo> --limit 10 --state all
```

**Red flags:**
- ❌ Bug reports ignored for weeks/months
- ❌ PRs left open without comment
- ❌ "Abandoned" or "No longer maintained" comments
- ❌ Multiple "doesn't work" issues unaddressed

**Green flags:**
- ✅ Responsive maintainer (issues closed quickly)
- ✅ Active PR merging (community contributions accepted)
- ✅ Clear communication (maintainer explains decisions)
- ✅ Version tags/releases (organized development)

---

## Step 7: Generate Evidence-Based Recommendation

### Output Format

**For each candidate, provide:**

```markdown
## Skill: <name>
**Source:** <owner>/<repo>
**Stars:** <count> | **Forks:** <count> | **Last update:** <date>

**Metrics:**
- Activity: <Daily/Weekly/Monthly/Stale/Abandoned>
- Community: <Active/Some/Solo/None>
- Issues: <count> open (<percent>% of total)

**Directory-level activity (if embedded):**
- Last commit: <date> (<days> ago)
- Commit message: "<message>"

**Strengths:**
- ✅ <specific strength>
- ✅ <specific strength>

**Weaknesses:**
- ❌ <specific weakness>
- ⚠️ <specific concern>

**Recommendation:** <Install/Skip/Test First> — <reasoning>
```

### Final Recommendations

**Tier 1 (Install immediately):**
- High stars (1,000+)
- Active development (updated this week/month)
- Clear community validation
- No red flags

**Tier 2 (Install selectively):**
- Moderate stars (100-1,000)
- Some activity (updated 1-3 months ago)
- Solves specific need
- No major red flags

**Tier 3 (Skip):**
- Low stars (<100)
- Abandoned (>6 months no activity)
- Open bugs unaddressed
- Better alternatives exist

---

## Common Pitfalls to Avoid

### ❌ Wrong Approach

1. **Assumption:** "8,000 stars = high quality skill"
   - **Reality:** Repository stars ≠ individual skill quality (check directory)

2. **Assumption:** "v2.0.0 = better than v1.0.0"
   - **Reality:** Version number alone means nothing (check activity)

3. **Assumption:** "More skills = better"
   - **Reality:** 30 mediocre skills < 10 excellent skills

4. **Assumption:** "Newer = better"
   - **Reality:** 5-week-old repo with 8,000 stars > 2-year-old repo with 50 stars

5. **Assumption:** "Name sounds good = must be good"
   - **Reality:** Marketing ≠ quality (check actual metrics)

### ✅ Correct Approach

1. **Gather objective metrics** (stars, forks, activity)
2. **Check directory-level commits** (for embedded skills)
3. **Analyze issues/PRs** (maintainer responsiveness)
4. **Compare functionality** (competing vs. complementary)
5. **Read SKILL.md** (when overlapping, compare approaches)
6. **Make evidence-based recommendation** (data, not assumptions)

---

## Example: Real-World Evaluation

**User asks:** "Find the best SEO skills for my business"

**Step 1: Discovery**
```bash
clawhub search "seo"
gh search repos "seo" topic:claude-skills --limit 20
```

**Results:**
- coreyhaines31/marketingskills (contains `seo-audit`)
- aaron-he-zhu/seo-geo-claude-skills (20 SEO skills)
- ComposioHQ/awesome-claude-skills (embedded skills)

**Step 2: Repository metrics**
```bash
gh repo view coreyhaines31/marketingskills --json stargazerCount,pushedAt,issues
gh repo view aaron-he-zhu/seo-geo-claude-skills --json stargazerCount,pushedAt,issues
gh repo view ComposioHQ/awesome-claude-skills --json stargazerCount,pushedAt,issues
```

**Results:**
- coreyhaines31: 8,924 stars, updated yesterday, 1 open issue
- aaron-he-zhu: 234 stars, updated 9 days ago, 0 open issues
- ComposioHQ: 36,874 stars, updated 4 days ago, 51 open issues

**Step 3: Directory-level check (ComposioHQ)**
```bash
gh api "repos/ComposioHQ/awesome-claude-skills/commits?path=content-research-writer" --jq '.[0]'
```

**Result:** Last commit Oct 17, 2025 (4 months ago, abandoned)

**Step 4: Functionality comparison**
```bash
gh api repos/coreyhaines31/marketingskills/contents/skills --jq '.[].name' | grep seo
gh api repos/aaron-he-zhu/seo-geo-claude-skills/contents/build --jq '.[].name'
```

**Results:**
- coreyhaines31: `seo-audit`, `ai-seo`, `schema-markup`, `programmatic-seo` (4 SEO skills)
- aaron-he-zhu: 20 specialized SEO/GEO skills (keyword-research, rank-tracker, etc.)
- Overlap: `seo-audit` vs. `on-page-seo-auditor`, `schema-markup` vs. `schema-markup-generator`

**Step 5: Decision**

**Option A:** Install only coreyhaines31
- Pros: Massive validation, broad marketing coverage, active
- Cons: Less SEO depth

**Option B:** Install only aaron-he-zhu
- Pros: Deep SEO specialization, comprehensive frameworks
- Cons: Smaller community, narrow focus

**Option C:** Install both (if complementary)
- Pros: Broad + deep coverage
- Cons: 5 overlapping skills may conflict

**Recommendation:** Install coreyhaines31 (broader validation, active community). If SEO depth needed later, add aaron-he-zhu selectively (unique skills only).

---

## Related Skills

- **skill-creator** — Create custom skills when none exist
- **github** — GitHub operations and analysis
- **web_search** — Discover skills across the web

---

## Notes

**This skill is meta:** It helps you find other skills. Use it whenever:
- User asks "what's the best skill for X?"
- You need to compare multiple skill options
- Installation decision requires evidence
- Avoiding low-quality or abandoned skills

**Key principle:** Data > assumptions. Always.
