#!/bin/bash

DIR=`pwd`

FILES=`ls -a | grep -v symlink | egrep -v '.git$' | egrep -v '^\.+$' | grep -v README`


for f in $FILES
do
  echo $f
  ln -s $DIR/$f $HOME/$f
done
