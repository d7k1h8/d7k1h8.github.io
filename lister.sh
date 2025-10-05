#!/bin/sh

test $# -ne 1 && echo "Usage: $0 [DIR]" && exit
script_dir=${0%/*}
base_url='https://media.githubusercontent.com/media/d7k1h8/d7k1h8.github.io/refs/heads/master/docs/comp/'
find "$script_dir/docs/$1" -name '*.webp' -printf "${base_url}%f\n"
