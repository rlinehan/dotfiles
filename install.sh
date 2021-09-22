#!/bin/bash
set -e

# Currently for use with github codespaces

echo ""
echo "=========================================================="
echo "* Install packages:"
echo "----------------------------------------------------------"

brew_prefix="/home/linuxbrew/.linuxbrew"
"$brew_prefix/bin/brew" install fzf ripgrep tree
"$brew_prefix/opt/fzf/install" --all

# remove existing .gitconfig
if [ -f "$HOME/.gitconfig" ]
then
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
fi

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
