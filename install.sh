#!/usr/bin/env bash
set -e

REPO="https://github.com/t-code4change/nextjs-claude-skills.git"
TMP_DIR="/tmp/nextjs-claude-skills-$$"
SKILLS_DIR=".claude/skills"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Next.js Claude Skills — Installer${NC}"
echo "======================================"

# Check we're in a project directory
if [ ! -f "package.json" ] && [ ! -f "next.config.ts" ] && [ ! -f "next.config.js" ]; then
  echo "⚠️  Warning: No package.json or next.config found."
  echo "   Make sure you're running this from your project root."
  echo ""
fi

# Clone
echo "📦 Downloading skills..."
git clone --depth 1 --quiet "$REPO" "$TMP_DIR"

# Create skills directory
mkdir -p "$SKILLS_DIR"

# Copy skills
echo "📂 Installing into $SKILLS_DIR/ ..."
cp -r "$TMP_DIR/nextjs-seo-performance"       "$SKILLS_DIR/"
cp -r "$TMP_DIR/nextjs-caching"               "$SKILLS_DIR/"
cp -r "$TMP_DIR/nextjs-core"                  "$SKILLS_DIR/"
cp -r "$TMP_DIR/nextjs-react-best-practices"  "$SKILLS_DIR/"

# Clean up
rm -rf "$TMP_DIR"

echo ""
echo -e "${GREEN}✓ Skills installed successfully!${NC}"
echo ""
echo "  .claude/skills/"
echo "  ├── nextjs-seo-performance       ← SEO + Core Web Vitals"
echo "  ├── nextjs-caching               ← Next.js 16 cache patterns"
echo "  ├── nextjs-core                  ← App Router fundamentals"
echo "  └── nextjs-react-best-practices  ← 70 performance rules"
echo ""
echo "Open a new Claude Code conversation — skills are ready."
echo "Invoke manually: /nextjs-seo-performance, /nextjs-caching, etc."
echo ""
