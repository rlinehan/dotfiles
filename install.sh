#!/bin/bash

# Currently for use with github codespaces

# set a different tmux prefix so it doesn't conflict with local one
tmux set-option -g prefix C-]

echo ""
echo "=========================================================="
echo "* Install packages:"
echo "----------------------------------------------------------"

apt-get update
apt-get install -y tree fzf ripgrep fzf

# remove existing .gitconfig
mv .gitconfig{,.bak}

echo ""
echo "=========================================================="
echo "* Symlink dotfiles into place:"
echo "----------------------------------------------------------"

./symlink.sh

echo ""
echo "=========================================================="
echo "* Update .gitconfig:"
echo "----------------------------------------------------------"

{
	echo '[url "https://github.com/"]'
	echo "  insteadOf = git@github.com:"
	echo "[credential]"
	echo "  helper = cache"
} >> ./.gitconfig
