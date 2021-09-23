#!/bin/sh

# Compute a deterministic cryptographic hash id for the given package.
# The hash is based on the full depdenency tree and can be therefore
# used for transparent build caching.

set -eux

out="$(realpath $3)"
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

rundephashes=""
builddephashes=""

if test -e run-deps
then
  redo-ifchange run-deps
  rundephashes=$(cat run-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
else
  redo-ifcreate run-deps
fi

if test -e build-deps
then
  redo-ifchange build-deps
  builddephashes=$(cat build-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
else
  redo-ifcreate build-deps
fi

redo-ifchange $rundephashes $builddephashes

if test -e files
then
	# XXX detect creation? is it possible?
	redo-ifchange $(find files -type f)
else
	redo-ifcreate files
fi

(
  set -e
  echo rhash # Recursive hash tag, see seed/.pkghash.do for content hash.
  echo sums
  test -s sha256sums && cat sha256sums
  echo files
  if test -e files
  then
    # XXX we need some canonical tar format
    # guaranteed to be the same for everyone.
    find ./files -print0 -type f \
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