#!/bin/sh
set -eu
redo-ifchange .pkghash
../../bin/do-fetch fetch
ln -f .fetch/rust-seed.tar.gz "$3"