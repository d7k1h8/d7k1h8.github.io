#!/bin/sh -eu

# NOTE: The script will fail if duplicate files, which means the new file
# won't overwrite the old file. I could make it the opposite, but it's fine.

# The script is as barebone as it gets, can't be simplified further

target_file="$1"
pat="$2"
target_basename="${target_file##*/}"

# Create new tree with just that file added to temp's existing files
NEW_TREE="$(git mktree <<EOF
$(git ls-tree --full-tree temp)
100644 blob $(git hash-object -w ./$target_file)	${target_basename}
EOF
)"
# Create commit and update branch
git update-ref refs/heads/temp $(git commit-tree $NEW_TREE -p temp \
	-m "Add $target_basename from auto branch")
git push "https://$pat@github.com/d7k1h8/d7k1h8.github.io.git" temp
