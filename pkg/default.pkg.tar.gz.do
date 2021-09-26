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
redo-ifchange $(cat .closure) $(cat .bclosure)

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
 -czf $out \
 --format=posix \
 --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime,delete=mtime \
 --mtime='2021-01-01 00:00:00Z' \
 --sort=name \
 --numeric-owner \
 --owner=0 \
 --group=0 \
 .

chmod -R 700 .build
rm -rf .build

redo-stamp < $out