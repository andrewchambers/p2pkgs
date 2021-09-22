#!/bin/sh
set -eux
redo-ifchange .pkg.tar.gz
sha256sum | cut -c -64 > $3
redo-stamp < $3