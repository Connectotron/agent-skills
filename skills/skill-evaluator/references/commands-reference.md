# Command Reference

Quick reference for skill evaluation commands.

---

## Discovery Commands

### ClawHub Search
```bash
clawhub search "<topic>"
clawhub search "marketing"
clawhub search "seo" --limit 20
```

### GitHub Repository Search
```bash
# Search by topic
gh search repos "<topic>" topic:claude-skills --limit 20
gh search repos "marketing" topic:claude-skills --limit 20

# Search by name
gh search repos "SKILL.md marketing" --limit 20
```

### Web Search (via tool)
Use `web_search` tool:
```
web_search("AgentSkill marketing SEO GitHub")
web_search("site:github.com claude skills marketing")
```

---

## Metrics Gathering Commands

### Repository-Level Metrics
```bash
# Full metrics
gh repo view <owner>/<repo> --json stargazerCount,forkCount,createdAt,pushedAt,issues,pullRequests,watchers

# Examples
gh repo view coreyhaines31/marketingskills --json stargazerCount,forkCount,pushedAt
gh repo view anthropics/skills --json stargazerCount,issues,pullRequests
```

**Key fields:**
- `stargazerCount` — Total stars
- `forkCount` — Total forks
- `watchers.totalCount` — Watchers
- `createdAt` — When created
- `pushedAt` — Last push date
- `issues.totalCount` — Total issues
- `pullRequests.totalCount` — Total PRs

### Directory-Level Activity (Embedded Skills)
```bash
# Check specific skill directory commits
gh api "repos/<owner>/<repo>/commits?path=<skill-directory>" --jq '.[0:5] | .[] | {date: .commit.author.date, message: .commit.message}'

# Examples
gh api "repos/ComposioHQ/awesome-claude-skills/commits?path=content-research-writer" --jq '.[0:3] | .[] | {date: .commit.author.date, message: .commit.message}'
gh api "repos/coreyhaines31/marketingskills/commits?path=skills/seo-audit" --jq '.[0:3] | .[] | {date: .commit.author.date, message: .commit.message}'
```

**Returns:**
- Last 3-5 commits to that specific directory
- Dates show actual skill maintenance
- Messages show what changed

---

## Issue & PR Analysis Commands

### List Issues
```bash
# All recent issues
gh issue list --repo <owner>/<repo> --limit 10 --state all

# Only open issues
gh issue list --repo <owner>/<repo> --limit 10 --state open

# With details
gh issue list --repo <owner>/<repo> --limit 10 --json number,title,state,createdAt,closedAt
```

### List Pull Requests
```bash
# All recent PRs
gh pr list --repo <owner>/<repo> --limit 10 --state all

# Only merged PRs
gh pr list --repo <owner>/<repo> --limit 10 --state merged

# With details
gh pr list --repo <owner>/<repo> --limit 10 --json number,title,state,createdAt,mergedAt
```

---

## Functionality Analysis Commands

### List Repository Contents
```bash
# Top-level
gh api repos/<owner>/<repo>/contents --jq '.[].name'

# Specific directory
gh api repos/<owner>/<repo>/contents/<directory> --jq '.[].name'

# Examples
gh api repos/coreyhaines31/marketingskills/contents/skills --jq '.[].name' | sort
gh api repos/aaron-he-zhu/seo-geo-claude-skills/contents/build --jq '.[].name'
```

### List Skills and Filter
```bash
# List all skills
gh api repos/<owner>/<repo>/contents/skills --jq '.[].name'

# Filter by keyword
gh api repos/<owner>/<repo>/contents/skills --jq '.[].name' | grep seo

# Count total skills
gh api repos/<owner>/<repo>/contents/skills --jq '. | length'
```

---

## SKILL.md Reading Commands

### Download and Read
```bash
# Clone temporarily
git clone --depth 1 <repo-url> /tmp/skill-eval

# Read SKILL.md
cat /tmp/skill-eval/<skill-path>/SKILL.md

# Example
git clone --depth 1 https://github.com/coreyhaines31/marketingskills /tmp/skill-eval
cat /tmp/skill-eval/skills/seo-audit/SKILL.md
```

### Read via GitHub API
```bash
# Get file contents (base64 encoded)
gh api repos/<owner>/<repo>/contents/<skill-path>/SKILL.md --jq '.content' | base64 -d

# Example
gh api repos/coreyhaines31/marketingskills/contents/skills/seo-audit/SKILL.md --jq '.content' | base64 -d
```

---

## Installation Commands

### Install Full Repository
```bash
# Install all skills with confirmation
npx skills add <owner>/<repo>

# Install all skills without prompts
npx skills add <owner>/<repo> --yes

# Examples
npx skills add coreyhaines31/marketingskills --yes
npx skills add aaron-he-zhu/seo-geo-claude-skills --yes
```

### Install Selective Skills
```bash
# Install specific skills only
npx skills add <owner>/<repo> --skill <skill1> <skill2> <skill3>

# Examples
npx skills add coreyhaines31/marketingskills --skill seo-audit competitor-alternatives page-cro
npx skills add aaron-he-zhu/seo-geo-claude-skills -s keyword-research rank-tracker
```

---

## Comparison Workflow

### Step-by-Step Command Sequence

**1. Discover candidates:**
```bash
clawhub search "marketing"
gh search repos "marketing" topic:claude-skills --limit 20
```

**2. Get metrics for top 3-5:**
```bash
gh repo view candidate1/repo --json stargazerCount,pushedAt,issues
gh repo view candidate2/repo --json stargazerCount,pushedAt,issues
gh repo view candidate3/repo --json stargazerCount,pushedAt,issues
```

**3. Check directory activity (if embedded):**
```bash
gh api "repos/candidate1/repo/commits?path=skills/target-skill" --jq '.[0:3]'
```

**4. List skills in each:**
```bash
gh api repos/candidate1/repo/contents/skills --jq '.[].name' | sort
gh api repos/candidate2/repo/contents/skills --jq '.[].name' | sort
```

**5. Check for overlaps (manual comparison)**
Create matrix of which skills exist in which repos.

**6. Read SKILL.md for overlapping skills:**
```bash
git clone --depth 1 https://github.com/candidate1/repo /tmp/eval1
git clone --depth 1 https://github.com/candidate2/repo /tmp/eval2

cat /tmp/eval1/skills/target-skill/SKILL.md
cat /tmp/eval2/skills/target-skill/SKILL.md
```

**7. Make decision and install:**
```bash
npx skills add winner/repo --yes
```

---

## Useful Filters & Transformations

### Calculate Days Since Last Push
```bash
# Get pushed date, calculate days ago
gh repo view <owner>/<repo> --json pushedAt --jq '.pushedAt' | \
  xargs -I {} date -j -f "%Y-%m-%dT%H:%M:%SZ" {} "+%s" | \
  xargs -I {} echo $(( ($(date +%s) - {}) / 86400 )) days ago
```

### Issue Open Rate
```bash
# Get issue counts
gh repo view <owner>/<repo> --json issues --jq '.issues.totalCount'

# Calculate percentage open (manual)
# open / total * 100
```

### Sort by Stars
```bash
# Search and sort by stars
gh search repos "<topic>" topic:claude-skills --json name,owner,stargazersCount --sort stars | \
  jq -r '.[] | "\(.stargazersCount)\t\(.owner.login)/\(.name)"' | \
  sort -rn
```

---

## Emergency Troubleshooting

### Command Not Found
```bash
# Install gh CLI
brew install gh

# Authenticate
gh auth login

# Install skills CLI
npm install -g skills
```

### API Rate Limiting
```bash
# Check rate limit
gh api rate_limit

# Use authenticated requests (higher limit)
gh auth status
```

### jq Not Installed
```bash
# Install jq
brew install jq

# Alternative: use --jq flag in gh (built-in)
gh api <endpoint> --jq '<filter>'
```

---

## Pro Tips

**Batch compare multiple repos:**
```bash
for repo in "owner1/repo1" "owner2/repo2" "owner3/repo3"; do
  echo "=== $repo ==="
  gh repo view $repo --json stargazerCount,pushedAt,issues | jq
done
```

**Quick star ranking:**
```bash
gh search repos "marketing" topic:claude-skills --json name,owner,stargazersCount --limit 10 | \
  jq -r 'sort_by(-.stargazersCount) | .[] | "\(.stargazersCount) ⭐ \(.owner.login)/\(.name)"'
```

**Check if skill exists in repo:**
```bash
gh api repos/<owner>/<repo>/contents/skills | \
  jq -r '.[].name' | \
  grep -i "<keyword>"
```
