#!/bin/bash

# Script to push collected dotfiles to GitHub

REPO_NAME="linux_dotfiles"
GITHUB_USER=$(git config github.user)

if [ -z "$GITHUB_USER" ]; then
    echo "GitHub username not found in git config."
    echo "Please set your GitHub username with:"
    echo "  git config --global github.user YOUR_USERNAME"
    exit 1
fi

echo "Will push to GitHub repository: $GITHUB_USER/$REPO_NAME"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create temporary directory for the repository
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone the existing repository
git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git"
cd "$REPO_NAME"

# Copy all dotfiles to the repository
cp -r "$HOME/dotfiles_backup"/* .

# Commit and push changes
git add .
git commit -m "Update dotfiles $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "Dotfiles successfully pushed to GitHub!"
