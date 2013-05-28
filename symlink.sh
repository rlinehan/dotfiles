#!/bin/bash

DIR=`pwd`

FILES=`ls -a | grep -v symlink | egrep -v '.git$' | egrep -v '^\.+$' | grep -v README`

for f in $FILES
do
  if [ -e ~/$f ]
  then
    echo ~/$f already exists
  else
    ln -s $DIR/$f $HOME/$f
    echo symlink created from $DIR/$f to ~/$f
  fi
done
