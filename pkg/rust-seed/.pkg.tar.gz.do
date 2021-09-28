#!/bin/sh
set -eu
redo-ifchange .pkghash
../../bin/do-fetch fetch
ln .fetch/rust-seed.tar.gz "$3"
redo-stamp < "$3"