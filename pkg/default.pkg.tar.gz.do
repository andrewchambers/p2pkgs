#!/bin/sh

# Build a package's build dependencies, then build the package itself.
# Builds are performed in a sandbox containing the package
# build closure and can't access the host system or the internet.

set -eux
exec 1>&2
out=$(realpath $3)
pkgdir=$(dirname $(realpath $1))
cd $pkgdir
redo-ifchange .pkghash .bclosure
redo-ifchange $(cat .bclosure)

mkdir -p .fetch
cd .fetch
if test -s ../sha256sums
then
  if ! sha256sum -c ../sha256sums
  then
    test -s ../url && curl -LK ../url
    sha256sum -c ../sha256sums
    # TODO error on files not in list.
  fi
fi
cd ..

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
    --numeric-owner \
    --owner=0 \
    --group=0 \
    --mode="go-rwx,u-rw" \
    --null \
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
  --setenv "PATH" /bin \
  --setenv "DESTDIR" /destdir \
  -- /build

# XXX whitelist of allowed output dirs?
tar \
 -C .build/chroot/destdir \
 -czf $out . \
 --numeric-owner \
 --owner=0 \
 --group=0 \
 --mode="go-rwx,u-rw"

chmod -R 700 .build
rm -rf .build