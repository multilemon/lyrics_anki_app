#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Production Web Build..."

# 1. Back up the development index.html
echo "📦 Backing up development index.html..."
cp web/index.html web/index.html.bak

# 2. Copy production index (with strict CSP) to index.html
echo "csp Coping production index_prod.html to index.html..."
cp web/index_prod.html web/index.html

# 3. Build for Web
# Adjust --base-href if you are deploying to a custom domain or different path
echo "sz Building Flutter Web App..."
flutter build web --release --base-href "/lyrics_anki_app/"

# 4. Restore the development index.html
echo "pw Restoring development index.html..."
mv web/index.html.bak web/index.html

echo "✅ Build Complete! Artifacts are in build/web"
