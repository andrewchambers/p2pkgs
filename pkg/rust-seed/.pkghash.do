#!/bin/sh
set -eu
redo-ifchange fetch
(
  set -e
  echo chash # Content hash tag.
  recsel -C -P sha256 fetch
) | sha256sum | cut -c -64 > $3
