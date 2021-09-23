#!/bin/sh
set -eux
redo-ifchange .pkg.tar.gz
(
  set -e
  echo chash # Content hash tag.
  sha256sum .
) | cut -c -64 > $3
redo-stamp < $3