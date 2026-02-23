#!/bin/bash
# Validate an AgentSkill structure

set -e

SKILL_DIR="$1"

if [ -z "$SKILL_DIR" ]; then
  echo "Usage: $0 <skill-directory>"
  exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
  echo "Error: Directory not found: $SKILL_DIR"
  exit 1
fi

echo "Validating skill: $SKILL_DIR"

# Check required files
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  echo "❌ Missing required file: SKILL.md"
  exit 1
fi

echo "✅ SKILL.md exists"

# Check for YAML frontmatter
if ! grep -q "^---$" "$SKILL_DIR/SKILL.md"; then
  echo "❌ SKILL.md missing YAML frontmatter"
  exit 1
fi

echo "✅ YAML frontmatter present"

# Check for required frontmatter fields
if ! grep -q "^name:" "$SKILL_DIR/SKILL.md"; then
  echo "❌ Missing 'name' field in frontmatter"
  exit 1
fi

if ! grep -q "^description:" "$SKILL_DIR/SKILL.md"; then
  echo "❌ Missing 'description' field in frontmatter"
  exit 1
fi

echo "✅ Required frontmatter fields present"

# Check file size (warn if >500 lines)
LINE_COUNT=$(wc -l < "$SKILL_DIR/SKILL.md")
if [ "$LINE_COUNT" -gt 500 ]; then
  echo "⚠️  SKILL.md is $LINE_COUNT lines (recommended: <500)"
  echo "   Consider moving detailed content to references/"
fi

echo "✅ Validation complete"
