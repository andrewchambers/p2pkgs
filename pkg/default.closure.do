#!/bin/sh

# Compute the runtime closure of a package.

set -eux

out=$(realpath $3)
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

redo-ifchange .pkghash
depclosures=$(cat run-deps | sed -e 's,$,/.closure,' | xargs -r realpath)
redo-ifchange $depclosures

(
  set -e
  cat $depclosures < /dev/null
  cat run-deps | sed -e 's,$,/.pkg.tar.gz,' | xargs -r realpath
) | sort -u > $out
redo-stamp < $out