#!/bin/sh
set -eux
../../bin/do-fetch fetch
ln .fetch/seed.tar.gz $3