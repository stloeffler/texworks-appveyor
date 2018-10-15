#!/bin/sh

ARCHIVE=v1.6.2.tar.gz

mkdir -p /c/projects/hunspell
cd /c/projects/hunspell
curl -sS -O https://github.com/hunspell/hunspell/archive/$ARCHIVE
tar -xvf $ARCHIVE

ls
