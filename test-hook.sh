#!/bin/sh

# Copyright thomas dot braun aeht virtuell minus zuhause dot de,  2013
#
# test suite for hook

cp pre-commit .git/hooks
chmod a+x .git/hooks

git config --replace-all hooks.enforcecompatiblefilenames true
commit=$(git rev-parse HEAD)

counter=0

checkname ()
{
  
  filename="$1"
  counter=$(expr $counter \+ 1)
  touch "$filename" &&
  git add "$filename" &&
  GIT_TRACE=1 
  git commit -m "my message"
  ret=$?
  echo $ret
  git reset --hard $commit > /dev/null

  if test $ret -eq 1
  then
    echo "Failed"
    exit 1
  else
    echo "Test $counter passed"
    exit 0
  fi
}

echo "###absolute path too long###"
path="1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890/1234567890"

mkdir -p $path
validfile="a.txt"

checkname "$path/$validfile"