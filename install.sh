#!/bin/bash

# Currently for use with github codespaces

# set a different tmux prefix so it doesn't conflict with local one
tmux set-option -g prefix C-]

echo ""
echo "=========================================================="
echo "* Install packages:"
echo "----------------------------------------------------------"

apt-get update
apt-get install tree fzf ripgrep fzf

echo ""
echo "=========================================================="
echo "* Symlink dotfiles into place:"
echo "----------------------------------------------------------"

./symlink.sh
