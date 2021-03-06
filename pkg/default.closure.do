#!/bin/sh

# Compute the runtime closure of a package.

set -eu

out=$(realpath $3)
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

if test -e run-deps
then
  redo-ifchange run-deps
else
  redo-ifcreate run-deps
fi

depclosures=$( (test -e run-deps && cat run-deps) | sed -e 's,$,/.closure,' | xargs -r realpath)

redo-ifchange $depclosures

(
  set -e
  cat $depclosures < /dev/null
  (test -e run-deps && cat run-deps) | sed -e 's,$,/.pkg.tar.gz,' | xargs -r realpath
) | sort -u > $out
