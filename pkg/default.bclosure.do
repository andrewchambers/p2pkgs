#!/bin/sh

# Compute the runtime closure of the build dependencies of a package.

set -eu

out=$(realpath $3)
pkgdir=$(dirname $(realpath $1))
cd $pkgdir

builddepclosures=$((test -e build-deps && cat build-deps) | sed -e 's,$,/.closure,' | xargs -r realpath)
redo-ifchange .pkghash $builddepclosures

(
  set -e
  (test -e build-deps && cat build-deps) | sed -e 's,$,/.pkg.tar.gz,' | xargs -r realpath
  cat $builddepclosures < /dev/null
) | sort -u > $out
redo-stamp < $out