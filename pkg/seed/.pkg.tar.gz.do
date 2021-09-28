#!/bin/sh
set -eu
redo-ifchange .pkghash
../../bin/do-fetch fetch
ln .fetch/seed.tar.gz $3