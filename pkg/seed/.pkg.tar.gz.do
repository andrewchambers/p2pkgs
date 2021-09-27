#!/bin/sh
set -eu
../../bin/do-fetch fetch
ln .fetch/seed.tar.gz $3