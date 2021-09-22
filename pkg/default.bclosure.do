#!/bin/sh

# Compute the runtime closure of the build dependencies of a package.

set -eux

out=$(realpath $3)
pkgdir=$(dirname $(realpath $1))
cd $pkgdir
redo-ifchange .pkghash
(
  cat build-deps | sed -e 's,$,/.pkg.tar.gz,' | xargs -r realpath
  for f in $(cat build-deps | sed -e 's,$,/.closure,' | xargs -r realpath)
  do
    cat $f
  done
) | sort -u > $out
redo-stamp < $out