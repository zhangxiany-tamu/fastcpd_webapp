#!/bin/bash

# Upload fastcpd webapp to GitHub
echo "🚀 Preparing fastcpd web application for GitHub upload..."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    echo ""
fi

# Add files
echo "📄 Adding files to git..."
git add .
echo ""

# Show status
echo "📋 Current git status:"
git status
echo ""

# Commit
echo "💾 Creating commit..."
read -p "Enter commit message (or press Enter for default): " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="Initial commit: fastcpd web application"
fi

git commit -m "$commit_msg"
echo ""

# Add remote if not exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/zhangxiany-tamu/fastcpd_webapp.git
    echo ""
fi

# Push to GitHub
echo "⬆️ Uploading to GitHub..."
echo "Run: git push -u origin main"
echo ""
echo "✅ Ready to push to: https://github.com/zhangxiany-tamu/fastcpd_webapp"