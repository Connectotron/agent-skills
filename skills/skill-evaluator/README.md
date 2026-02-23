# AgentSkill Quality Evaluator

**Version:** 1.0.0  
**Created:** 2026-02-23  
**Purpose:** Systematically evaluate and compare AgentSkills using objective data rather than assumptions.

---

## What This Skill Does

Helps agents find the best AgentSkills for specific tasks by:

1. **Discovering** skills across multiple sources (ClawHub, GitHub, web)
2. **Gathering objective metrics** (stars, forks, activity, issues)
3. **Checking directory-level activity** (for embedded skills in catalogs)
4. **Comparing functionality** (competing vs. complementary)
5. **Making evidence-based recommendations** (data-driven, not assumption-driven)

---

## When to Use This Skill

- User asks: "What's the best skill for X?"
- You need to compare multiple skill repositories
- Installation decision requires evidence
- Avoiding low-quality or abandoned skills
- Choosing between similar-sounding options

---

## Core Principle

**NEVER make assumptions based on:**
- ❌ Skill names or descriptions
- ❌ Version numbers (v2.0 ≠ better quality)
- ❌ Repository stars alone (catalog stars ≠ individual skill quality)
- ❌ Recency (new ≠ better)

**ALWAYS use objective data:**
- ✅ GitHub metrics (stars, forks, watchers, activity)
- ✅ Directory-level commit history (for embedded skills)
- ✅ Issue/PR responsiveness (maintainer engagement)
- ✅ Functionality comparison (overlaps, uniqueness)
- ✅ SKILL.md quality (when comparing similar skills)

---

## Key Innovation: Directory-Level Analysis

**Problem:** High-star catalogs often contain abandoned individual skills.

**Example:**
- `ComposioHQ/awesome-claude-skills` has **36,874 stars**
- But `content-research-writer` inside was **last updated 4 months ago** (abandoned)

**Solution:** Check directory-level commit history:

```bash
gh api "repos/ComposioHQ/awesome-claude-skills/commits?path=content-research-writer" \
  --jq '.[0] | {date: .commit.author.date, message: .commit.message}'
```

This reveals **actual skill maintenance**, not catalog popularity.

---

## Methodology (7 Steps)

### 1. Discovery
Search ClawHub, GitHub (topic:claude-skills), web, and curated lists.

### 2. Repository Metrics
Gather stars, forks, watchers, created/pushed dates, issues, PRs.

### 3. Directory-Level Activity
For embedded skills, check specific directory commit history.

### 4. Functionality Comparison
List skills in each repo, identify overlaps (competing vs. complementary).

### 5. SKILL.md Quality
If overlapping, read actual SKILL.md contents and compare approaches.

### 6. Issue/PR Analysis
Check for red flags (ignored bugs, abandoned PRs) or green flags (responsive maintainer).

### 7. Evidence-Based Recommendation
Tier 1 (install), Tier 2 (selective), Tier 3 (skip) with reasoning.

---

## Example Output

```markdown
## Recommendation: coreyhaines31/marketingskills

**Stars:** 8,924 | **Forks:** 1,190 | **Last push:** Yesterday
**Assessment:** ✅ Tier 1 - Install immediately

**Strengths:**
- ✅ Massive community validation (8,924 stars in 5 weeks)
- ✅ Extremely active (updated daily)
- ✅ Community contributions (multiple merged PRs this week)
- ✅ Broad coverage (30 marketing skills across SEO, CRO, content, email, social)

**Weaknesses:**
- ⚠️ Some SEO skills overlap with aaron-he-zhu/seo-geo-claude-skills

**Reason:** Strongest community validation + active development + responsive maintainer.
Clear winner for broad marketing needs.

**Installation:**
```bash
npx skills add coreyhaines31/marketingskills --yes
```

---

## Alternative: aaron-he-zhu/seo-geo-claude-skills

**Stars:** 234 | **Last push:** 9 days ago
**Assessment:** ⚠️ Tier 2 - Install selectively (if need deep SEO frameworks)

**Strengths:**
- ✅ Deep SEO specialization (20 skills)
- ✅ Unique frameworks (CORE-EEAT 80-item audit, CITE 40-item domain rating)
- ✅ Active maintenance (updated within 2 weeks)

**Weaknesses:**
- ❌ Smaller community (234 vs 8,924 stars)
- ❌ 5 overlapping skills with coreyhaines31 (may conflict)

**Reason:** Good for SEO specialists, but coreyhaines31 covers 80% of needs with broader validation.
Consider if you need CORE-EEAT/CITE frameworks specifically.
```

---

## Files in This Skill

```
skill-evaluator/
├── SKILL.md                          # Main skill instructions
├── README.md                         # This file
└── references/
    ├── evaluation-template.md        # Step-by-step evaluation template
    └── commands-reference.md         # Quick command reference
```

---

## Usage Tips

**For Users:**
- Ask: "Find the best SEO skills for my business"
- Agent will use this skill to systematically evaluate options

**For Agents:**
- Don't guess based on names
- Follow 7-step methodology
- Use directory-level analysis for embedded skills
- Provide evidence-based recommendations

**Common Pitfall:**
- Assuming high repository stars = high individual skill quality
- **Solution:** Always check directory-level commits for embedded skills

---

## Maintenance

**Created by:** 3PO (Delta Echo Three Protocol Droid)  
**Based on:** Real-world evaluation of marketing AgentSkills (Feb 2026)  
**Methodology:** Derived from coreyhaines31 vs. aaron-he-zhu vs. SpillwaveSolutions comparison

**Updates needed when:**
- GitHub API changes
- New skill discovery sources emerge
- Evaluation criteria evolve

---

## Related Skills

- **skill-creator** — Create custom skills when none exist
- **github** — GitHub operations and analysis (used internally)
- **web_search** — Discover skills across the web (used internally)

---

## License

MIT (same as parent OpenClaw project)
