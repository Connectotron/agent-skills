# Skill Evaluation Template

Use this template to systematically evaluate AgentSkills.

---

## Candidate: [Skill Name]

**Repository:** `<owner>/<repo>`  
**Directory:** `<path/to/skill>` (if embedded)  
**Discovered via:** [ClawHub / GitHub search / Web search / Catalog]

---

### 1. Repository-Level Metrics

**Gathered:** `gh repo view <owner>/<repo> --json stargazerCount,forkCount,createdAt,pushedAt,issues,pullRequests,watchers`

| Metric | Value | Assessment |
|--------|-------|------------|
| ⭐ Stars | <count> | Excellent / Good / Low |
| 🍴 Forks | <count> | High adoption / Moderate / Low |
| 👀 Watchers | <count> | Strong interest / Some / Minimal |
| 📅 Created | <date> | <age> old |
| 🔄 Last push | <date> | <days> ago — Active / Stale / Abandoned |
| 🐛 Issues (open/total) | <x>/<y> | <percent>% open — Healthy / Concerning / Red flag |
| 🔀 PRs (open/total) | <x>/<y> | Community active / Solo dev / None |

**Overall repository health:** ✅ Excellent / ⚠️ Concerning / ❌ Poor

---

### 2. Directory-Level Activity (If Embedded)

**Checked:** `gh api "repos/<owner>/<repo>/commits?path=<skill-directory>" --jq '.[0:3]'`

| Commit # | Date | Message | Days Ago |
|----------|------|---------|----------|
| Latest | <date> | <message> | <days> |
| Previous | <date> | <message> | <days> |
| Previous | <date> | <message> | <days> |

**Directory-level assessment:**
- ✅ Active (updated within 30 days)
- ⚠️ Stale (30-180 days)
- ❌ Abandoned (>180 days or only "initial commit")

**Use this assessment if embedded, ignore repository-level stars.**

---

### 3. Issue & PR Analysis

**Recent issues:** `gh issue list --repo <owner>/<repo> --limit 10 --state all`

| Issue # | Status | Created | Title | Days Open |
|---------|--------|---------|-------|-----------|
| <#> | OPEN/CLOSED | <date> | <title> | <days> |
| <#> | OPEN/CLOSED | <date> | <title> | <days> |

**Red flags:**
- [ ] Bug reports open >30 days without response
- [ ] Multiple "doesn't work" issues unaddressed
- [ ] "Abandoned" or "no longer maintained" comments
- [ ] PRs ignored (no comments, no merges)

**Green flags:**
- [ ] Responsive maintainer (issues closed quickly)
- [ ] Clear communication
- [ ] Active PR merging
- [ ] Version tags/releases

**Maintainer responsiveness:** ✅ Excellent / ⚠️ Slow / ❌ Non-existent

---

### 4. Skill Functionality

**Listed skills:** `gh api repos/<owner>/<repo>/contents/<skills-dir> --jq '.[].name'`

**Skills in this repository:**
- `<skill-name-1>`
- `<skill-name-2>`
- `<skill-name-3>`
- ...

**Relevant to my needs:**
- ✅ `<skill-name>` — [Primary / Secondary / Tertiary]
- ✅ `<skill-name>` — [Primary / Secondary / Tertiary]

**Not relevant:**
- ❌ `<skill-name>` — (reason)

---

### 5. Competing Skills (Overlap Analysis)

**Compare with other candidates:**

| Function | This Skill | Competitor Skill | Overlap? |
|----------|------------|------------------|----------|
| <function> | `<skill-name>` | `<competitor-skill>` | ✅ / ❌ |
| <function> | `<skill-name>` | `<competitor-skill>` | ✅ / ❌ |

**Overlap assessment:**
- **Competing:** <count> skills overlap with other candidates (conflict risk)
- **Complementary:** <count> unique skills (safe to install alongside)

**Recommended approach:**
- [ ] Install this alone (best overall)
- [ ] Install alongside <other-repo> (complementary)
- [ ] Skip (better alternative exists)
- [ ] Test both, choose best (overlapping, unclear winner)

---

### 6. SKILL.md Quality Check (If Overlapping)

**Read:** `cat /tmp/<repo>/<skill-path>/SKILL.md`

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Clarity | ⭐⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐ | Instructions clear? |
| Depth | ⭐⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐ | Comprehensive vs. surface? |
| References | ⭐⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐ | Bundled docs/examples? |
| Up-to-date | ⭐⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐ | Current practices? |
| Flexibility | ⭐⭐⭐⭐⭐ / ⭐⭐⭐ / ⭐ | Customizable? |

**Overall SKILL.md quality:** ✅ Excellent / ⚠️ Adequate / ❌ Poor

---

### 7. Strengths & Weaknesses

**Strengths:**
- ✅ <specific strength with evidence>
- ✅ <specific strength with evidence>
- ✅ <specific strength with evidence>

**Weaknesses:**
- ❌ <specific weakness with evidence>
- ⚠️ <concern with evidence>
- ⚠️ <concern with evidence>

---

### 8. Final Recommendation

**Tier:** [1 - Install immediately / 2 - Install selectively / 3 - Skip]

**Reasoning:**
<Evidence-based explanation of recommendation>

**Installation command:**
```bash
npx skills add <owner>/<repo>
# Or selective:
npx skills add <owner>/<repo> --skill <skill-name> <skill-name>
```

**Alternative considered:**
- <competitor-repo> — [Why chosen / Why rejected]

**Next steps:**
- [ ] Install and test
- [ ] Compare with <alternative> if results unsatisfactory
- [ ] Monitor for updates (set reminder)

---

**Evaluated by:** <agent-name>  
**Date:** <YYYY-MM-DD>  
**Confidence:** High / Medium / Low
