#!/bin/bash

# Script to remove all .tar.gz files from current working directory and Git history
# WARNING: This will rewrite Git history - make sure to backup your repo first!

set -e  # Exit on any error

echo "🗑️  Removing .tar.gz files from repository and Git history..."
echo "⚠️  WARNING: This will rewrite Git history!"
echo "📋 Make sure you have a backup of your repository before proceeding."
echo ""

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Check if we're in a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a Git repository"
    exit 1
fi

# Remove .tar.gz files from current working directory
echo "🧹 Removing .tar.gz files from working directory..."
find . -name "*.tar.gz" -type f -delete
echo "✅ Removed .tar.gz files from working directory"

# Stage the deletions
git add -A

# Commit the changes if there are any
if ! git diff --cached --quiet; then
    git commit -m "Remove .tar.gz files from working directory"
    echo "✅ Committed removal of .tar.gz files"
else
    echo "ℹ️  No .tar.gz files found in working directory"
fi

# Remove .tar.gz files from Git history using git filter-branch
echo "🔄 Removing .tar.gz files from Git history..."
echo "This may take a while for large repositories..."

# Use git filter-branch to remove .tar.gz files from all commits
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch **/*.tar.gz *.tar.gz' \
    --prune-empty --tag-name-filter cat -- --all

# Clean up the backup refs created by filter-branch
echo "🧹 Cleaning up backup references..."
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin

# Force garbage collection to free up space
echo "🗑️  Running garbage collection..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Add .tar.gz to .gitignore if it's not already there
if [ ! -f .gitignore ] || ! grep -q "*.tar.gz" .gitignore; then
    echo "📝 Adding *.tar.gz to .gitignore..."
    echo "*.tar.gz" >> .gitignore
    git add .gitignore
    git commit -m "Add *.tar.gz to .gitignore"
    echo "✅ Added *.tar.gz to .gitignore"
else
    echo "ℹ️  *.tar.gz already in .gitignore"
fi

echo ""
echo "🎉 Successfully removed all .tar.gz files from repository and Git history!"
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo "   • Git history has been rewritten"
echo "   • If this is a shared repository, all collaborators will need to:"
echo "     - Backup their local changes"
echo "     - Delete their local repository"
echo "     - Re-clone the repository"
echo "   • If you have already pushed to a remote, you'll need to force push:"
echo "     git push --force-with-lease origin --all"
echo "     git push --force-with-lease origin --tags"