#!/bin/sh

# Compute a deterministic cryptographic hash id for the given package.
# The hash is based on the full depdenency tree and can be 
# used for build caching.

set -eux

out="$(realpath $3)"
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

redo-ifchange run-deps build-deps

rundephashes=$(cat run-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
builddephashes=$(cat build-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)

redo-ifchange $rundephashes $builddephashes

(
  echo sums
  test -s sha256sums && cat sha256sums
  echo files
  if test -e files
  then
    # XXX we need some normalized tar format
    # guaranteed to be the same for everyone.
    find ./files -print0 \
    | sort -z \
    | tar -cf - \
          --format=posix \
          --numeric-owner \
          --owner=0 \
          --group=0 \
          --mode="go-rwx,u-rw" \
          --mtime='1970-01-01' \
          --no-recursion \
          --null \
          --files-from -
  fi
  echo run-deps
  for f in $rundephashes
  do
    cat $f
  done
  echo build-deps
  for f in $builddephashes
  do
    cat $f
  done
  echo $builddephashes
) | sha256sum | cut -c -64 > $out

redo-stamp < $out