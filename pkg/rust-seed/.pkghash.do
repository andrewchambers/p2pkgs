#!/bin/sh
set -eu
redo-ifchange .pkg.tar.gz
(
  set -e
  echo chash # Content hash tag.
  sha256sum .pkg.tar.gz
) | cut -c -64 > $3
redo-stamp < $3