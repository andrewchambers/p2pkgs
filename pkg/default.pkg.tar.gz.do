#!/bin/sh

# Build a package's build dependencies, then build the package itself.
# Builds are performed in a sandbox containing the package
# build closure and can't access the host system or the internet.

set -eu

startdir="$PWD"
out=$(realpath $3)
pkgdir=$(dirname $(realpath $1))
cd $pkgdir
redo-ifchange .pkghash .bclosure .closure
redo-ifchange $(cat .closure)

if test -n "${PKG_BINARY_CACHE_URL:-}"
then
  cachetar="$(cat .pkghash).tar.gz"
  if "$startdir"/../bin/.bin-cache-get "$cachetar" "$out" > /dev/null 2>&1
  then
    redo-stamp < "$out"
    exit 0
  fi
  # XXX distinguish between error and 404
  echo "binary cache lookup failed" >&2
  test -e "$out" && rm "$out"
fi

if test "${PKG_FORCE_BINARY_PACKAGES:-}" = "on"
then
  echo "PKG_FORCE_BINARY_PACKAGES is enabled and the binary cache download failed" 1>&2
  exit 1
fi

# Download failed, we do need the build closure.
redo-ifchange $(cat .bclosure)

"$startdir"/../bin/do-fetch fetch

if test -e .build
then
  chmod -R 700 .build
  rm -rf .build
fi
mkdir -p \
  .build/chroot/{bin,lib,libexec,usr,etc,share,include,var,run,tmp,home,destdir}

cp build .build
cp -r .fetch .build/chroot/home/build
if test -e files
then
  tar \
    -C files \
    -cf - \
    . \
  | tar \
    -C .build/chroot/home/build \
    -xf -
fi

for tar in $(cat .bclosure)
do
  tar -C .build/chroot -xzf $tar
  # XXX after extracting some tars it prevents us from writing...
  chmod -R +rw .build/chroot
done

chmod -R 700 .build
# XXX not what we want obviously.
# This is because we need to wrangle container perms
chmod -R 777 .build/chroot


binds=$(
  set -e
  for toplevel in $(ls .build/chroot)
  do
    echo --bind .build/chroot/$toplevel $toplevel
  done
)

env -i bwrap \
  --unshare-user \
  --unshare-net \
  --unshare-uts \
  $binds \
  --bind .build/build /build \
  --dev /dev \
  --proc /proc \
  --hostname build \
  --chdir /home/build \
  --setenv "HOME" /home/build \
  --setenv "PATH" /bin:/usr/bin \
  --setenv "DESTDIR" /destdir \
  -- /build 1>&2

# XXX whitelist of allowed output dirs?
tar \
 -C .build/chroot/destdir \
  --format=posix \
  --mtime='2021-01-01 00:00:00Z' \
  --sort=name \
  --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
  --numeric-owner \
  --owner=0 \
  --group=0 \
  -czf $out \
  .

chmod -R 700 .build
rm -rf .build

redo-stamp < "$out"