#!/bin/sh
set -eux
curl \
  -L \
  -o $3 \
  https://github.com/andrewchambers/hpkgs-seeds/blob/master/linux-x86_64-seed.tar.gz?raw=true