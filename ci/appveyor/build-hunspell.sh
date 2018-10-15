#!/bin/sh

ARCHIVE=v1.6.2.tar.gz

echo "OK1"
mkdir -p /c/projects/hunspell
cd /c/projects/hunspell

echo "OK2"
pwd
ls


curl -sS -O https://github.com/hunspell/hunspell/archive/$ARCHIVE

echo "OK3"
pwd
ls

tar -xzf $ARCHIVE

echo "OK4"
ls
