#!/bin/sh
set -eu
redo-ifchange .pkghash
../../bin/do-fetch fetch
ln -f .fetch/seed.tar.gz "$3"
