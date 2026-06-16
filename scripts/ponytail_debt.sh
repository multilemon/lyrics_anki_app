#!/bin/bash

# Harvest ponytail: comments from the codebase (excluding build, git, .dart_tool, etc.)
echo "🔍 Scanning codebase for Ponytail Technical Debt..."
echo "=================================================="

# Check if we are inside a git repository to use git grep (which naturally respects gitignore)
if git rev-parse --is-inside-work-tree &> /dev/null; then
    git grep -n -E "(#|//) ?ponytail:" || echo "No ponytail technical debt found!"
else
    # Fallback to standard grep
    grep -rnE '(#|//) ?ponytail:' . \
        --exclude-dir=.git \
        --exclude-dir=.dart_tool \
        --exclude-dir=build \
        --exclude-dir=.vscode \
        --exclude-dir=.idea \
        --exclude-dir=node_modules || echo "No ponytail technical debt found!"
fi

echo "=================================================="
echo "✅ Scan complete!"
