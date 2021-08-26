#!/bin/bash

DIR=$(pwd)

# list all files in this directory excluding the README, symlink.sh, and
# script, .git, and .config dirs
FILES=$(find -s . -maxdepth 1  ! -name "README.md" ! -name "symlink.sh" ! -name "script" ! -name ".config" ! -name ".git" ! -name "." | sed "s/\.\///")

# list files in .config/, excluding .config itself
# this is separated out because unlike .vim/ I don't want to completely clobber
# ~/.config
CONFIG_DIR_FILES=$(find -s .config -maxdepth 1 ! -name ".config" -print0)

for f in $FILES $CONFIG_DIR_FILES
do
 if [ -e "$HOME/$f" ]
 then
   echo "- $HOME/$f already exists"
 else
   ln -s "$DIR/$f" "$HOME/$f"
   echo "* symlink created from $DIR/$f to $HOME/$f"
 fi
done
