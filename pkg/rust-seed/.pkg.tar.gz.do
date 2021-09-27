#!/bin/sh
set -eu
../../bin/do-fetch fetch
ln .fetch/rust-seed.tar.gz $3