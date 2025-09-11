#!/usr/bin/sh -ux

parent_dir=$PWD

dir1="auto_branch_1"
dir2="auto_branch_2"
[ -d "$dir1" ] && rm -rf "$dir1"
[ -d "$dir2" ] && rm -rf "$dir2"
git clone --branch auto --depth=1 \
	'https://github.com/d7k1h8/d7k1h8.github.io.git' "$dir1"
git clone --branch auto --depth=1 \
	'https://github.com/d7k1h8/d7k1h8.github.io.git' "$dir2"

# | awk '$1="",!seen[$1]++'
upload_file() {
	cd "$parent_dir"
	cd "$1/couldron"
	file="${2##*/}"

	# --depth=1 is bad if multiple simultaneous pushes happened
	# git will groan about conflicts
	# git fetch --depth=1 origin temp:temp
	git fetch origin temp:temp

	# Create new tree with just that file added to temp's existing files
	# printf -v files_tree '%s\n100644 blob %s\t%s\n' \
	# 	"$(git ls-tree --full-tree temp)" \
	# 	"$(git hash-object -w "$file")" "$file"
	files_tree="$({
		git ls-tree --full-tree temp
		printf "100644 blob %s\t%s\n" \
			"$(git hash-object -w "$file")" \
			"$file"
	})"

	awk '{sub(/[^\t]+\t/, ""); if (seen[$0]++) exit 1}' <<< "$files_tree" || return

	git update-ref refs/heads/temp "$(git commit-tree \
		"$(git mktree <<< "$files_tree")" \
		-p temp \
		-m "Add $file from auto branch")"
	git push "https://$PAT@github.com/d7k1h8/d7k1h8.github.io.git" temp
}

upload_file "$dir1" test1
upload_file "$dir1" kommit.sh
upload_file "$dir2" test2
upload_file "$dir2" README.md
