#!/bin/sh

# dir0-workflow.sh - Automate dir0-branch workflow
# Usage: ./dir0-workflow.sh [commit-message]

set -e  # Exit on any error

# Configuration
WORK_BRANCH="auto"
TARGET_DIR="couldron"
MAIN_BRANCH="master"

# Default commit message if none provided
echo "🚀 Starting dir0 workflow..."

# Function to check if branch exists
# Step 1: Ensure we're on master and up to date
echo "🔄 Switching to $MAIN_BRANCH..."
git checkout $MAIN_BRANCH

# Step 2: Create dir0-branch if it doesn't exist
if ! branch_exists $WORK_BRANCH; then
	create_dir0_branch
	git checkout $MAIN_BRANCH
fi

# Step 3: Switch to work branch and pull any updates
echo "🔄 Switching to $WORK_BRANCH..."
git checkout $WORK_BRANCH

# Step 4: Open interactive shell for making changes
echo ""
echo "🛠️  You are now on $WORK_BRANCH"
echo "   Make your changes in the $TARGET_DIR/ directory"
echo "   When done, type 'exit' to continue with the merge process"
echo ""

# Start a subshell for interactive work
bash -c "
echo 'Working in: $(pwd)'
echo 'Current branch: $(git branch --show-current)'
echo 'Files in $TARGET_DIR: '
ls -la $TARGET_DIR/ 2>/dev/null || echo '  (directory empty or doesn'\''t exist)'
echo ''
echo 'Make your changes, then type \"exit\" when ready to merge...'
exec bash
"

# Step 5: Check if there are changes to commit
if ! git diff --quiet || ! git diff --cached --quiet; then
	echo "📝 Committing changes in $WORK_BRANCH..."
	git add .
	git commit -m "Work in progress: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
else
	echo "ℹ️  No changes detected in $WORK_BRANCH"
fi

# Step 6: Switch back to master and merge
echo "🔄 Switching back to $MAIN_BRANCH..."
git checkout $MAIN_BRANCH

echo "🔀 Merging $WORK_BRANCH into $MAIN_BRANCH (work branch files will overwrite)..."

# Use theirs strategy to prefer work branch files in conflicts
if git merge --allow-unrelated-histories --strategy-option=theirs $WORK_BRANCH; then
	echo "✅ Merge completed successfully"
else
	echo "⚠️  Merge had conflicts - resolving in favor of $WORK_BRANCH..."

    # In case of conflicts, accept all changes from work branch
    git checkout --theirs .
    git add .
    git commit --no-edit

    echo "✅ Conflicts resolved - $WORK_BRANCH files took precedence"
fi

# Step 6: Show the result
echo ""
echo "✅ Merge completed!"
echo "📁 Contents of $TARGET_DIR in $MAIN_BRANCH:"
ls -la $TARGET_DIR/ 2>/dev/null || echo "  (directory not found)"

echo ""
echo "🎉 Workflow complete!"
echo "   - $WORK_BRANCH has been preserved for future use"
echo "   - Changes merged into $MAIN_BRANCH"
echo "   - $TARGET_DIR directory updated in $MAIN_BRANCH"

# HAHA
