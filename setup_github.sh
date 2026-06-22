#!/bin/bash

# GitHub Repository Setup Script
# This script initializes the Git repository and pushes to GitHub

echo "=================================================="
echo "GitHub Repository Setup"
echo "=================================================="
echo ""

REPO_NAME="SandboxieCTF-Modify"
GITHUB_USERNAME=""

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    echo "[*] GitHub CLI detected"
    GITHUB_USERNAME=$(gh api user -q .login 2>/dev/null)
    if [ -n "$GITHUB_USERNAME" ]; then
        echo "[+] Authenticated as: $GITHUB_USERNAME"
    fi
else
    echo "[!] GitHub CLI not found. Please install: brew install gh"
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    echo "[*] Initializing Git repository..."
    git init
    echo "[+] Git initialized"
else
    echo "[+] Git repository already initialized"
fi

# Copy GitHub-specific README
if [ -f "GITHUB_README.md" ]; then
    echo "[*] Using GitHub-specific README..."
    cp GITHUB_README.md README_GITHUB.md
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "[*] .gitignore already exists"
fi

# Add all files
echo "[*] Staging files..."
git add -A

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "[!] No changes to commit"
else
    # Commit
    echo "[*] Creating initial commit..."
    git commit -m "Initial commit: Sandboxie-Plus CTF bypass solution

- Complete certificate bypass patches
- Automated build scripts for Windows
- GitHub Actions CI/CD pipeline
- Comprehensive documentation
- All premium features unlocked

Features:
✅ Security Enhanced (opt_sec)
✅ Encrypted Sandbox (opt_enc)
✅ Advanced Network (opt_net)
✅ Desktop Isolation (opt_desk)

For educational/CTF purposes only."

    echo "[+] Commit created"
fi

# Create GitHub repository
if [ -n "$GITHUB_USERNAME" ]; then
    echo ""
    echo "[*] Creating GitHub repository..."

    if gh repo create "$REPO_NAME" --public --description "CTF Challenge: Sandboxie-Plus Certificate Bypass - All Premium Features Unlocked" --source=. --remote=origin --push; then
        echo "[+] Repository created and pushed!"
        echo ""
        echo "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        echo ""
        echo "Next steps:"
        echo "  1. Visit https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        echo "  2. Go to Actions tab to see the build"
        echo "  3. Download artifacts after build completes"
    else
        echo "[!] Failed to create repository"
        echo ""
        echo "Manual setup:"
        echo "  1. Create repository manually at: https://github.com/new"
        echo "  2. Repository name: $REPO_NAME"
        echo "  3. Then run:"
        echo "     git remote add origin git@github.com:YOUR_USERNAME/$REPO_NAME.git"
        echo "     git branch -M main"
        echo "     git push -u origin main"
    fi
else
    echo ""
    echo "Manual GitHub Setup Required:"
    echo "================================"
    echo ""
    echo "1. Create a new repository on GitHub:"
    echo "   URL: https://github.com/new"
    echo "   Name: $REPO_NAME"
    echo "   Description: CTF Challenge: Sandboxie-Plus Certificate Bypass"
    echo "   Visibility: Public"
    echo ""
    echo "2. Connect and push:"
    echo "   git remote add origin git@github.com:YOUR_USERNAME/$REPO_NAME.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "3. GitHub Actions will automatically run on push"
    echo ""
fi

echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
echo "GitHub Actions will:"
echo "  - Build on every push"
echo "  - Run on Windows Server 2022"
echo "  - Upload artifacts (kept for 30 days)"
echo "  - Verify patches before building"
echo ""
echo "To trigger a manual build:"
echo "  1. Go to Actions tab"
echo "  2. Select 'Build Sandboxie-Plus (Patched)'"
echo "  3. Click 'Run workflow'"
echo ""
