#!/bin/bash

DIR=$(pwd)

# list all files in this directory excluding the README, symlink.sh, and
# script, .git, and .config dirs
#FILES=$(find -s . -maxdepth 1  ! -name "*.md" ! -name "symlink.sh" ! -name "script" ! -name ".config" ! -name ".git" ! -name "." | sed "s/\.\///")
FILES=`ls -a | grep -v symlink | egrep -v '^\.git$' | egrep -v '^\.+$' | egrep -v '^.*\.md$' | egrep -v '^\.config$'`

# list files in .config/, excluding .config itself
# this is separated out because unlike .vim/ I don't want to completely clobber
# ~/.config
#CONFIG_DIR_FILES=$(find -s .config -maxdepth 1 ! -name ".config" -print0)
CONFIG_DIR_FILES=`ls -a .config | egrep -v '^\.+$'`

if [ ! -d "$HOME/.config" ]
then
  echo "Creating .config directory"
  mkdir "$HOME/.config"
fi

function symlink_files () {
  prefix=""
  if [ -n "$2" ]; then
    prefix="$2/"
  fi

  for f in $1
  do
    f=$prefix$f
    if [ -e "$HOME/$f" ]
    then
      echo "- $HOME/$f already exists"
    else
      ln -s "$DIR/$f" "$HOME/$f"
      echo "* symlink created from $DIR/$f to $HOME/$f"
    fi
  done
}

symlink_files "$FILES"
symlink_files "$CONFIG_DIR_FILES" ".config"
