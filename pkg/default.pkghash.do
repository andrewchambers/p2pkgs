#!/bin/sh

# Compute a deterministic cryptographic hash id for the given package.
# The hash is based on the full depdenency tree and can be therefore
# used for transparent build caching.

set -eux

out="$(realpath $3)"
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

redo-ifchange run-deps build-deps

rundephashes=$(cat run-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
builddephashes=$(cat build-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)

redo-ifchange $rundephashes $builddephashes

# TODO we need to have invaldation when files changes.
# this might not be possible with the current system.

(
  set -e
  echo sums
  test -s sha256sums && cat sha256sums
  echo files
  if test -e files
  then
    # XXX we need some canonical tar format
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
  cat $rundephashes < /dev/null
  echo build-deps
  cat $builddephashes < /dev/null
) | sha256sum | cut -c -64 > $out

redo-stamp < $out