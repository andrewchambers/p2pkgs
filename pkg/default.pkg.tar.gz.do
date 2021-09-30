#!/bin/sh

# Build a package's build dependencies, then build the package itself.
# Builds are performed in a sandbox containing the package
# build closure and can't access the host system or the internet.

set -eu

startdir="$PWD"
out=$(realpath $3)
pkgdir=$(dirname $(realpath $1))
cd $pkgdir

redo-ifchange .pkghash .closure
redo-ifchange $(cat .closure)

if test -n "${PACKAGE_CACHE_URL:-}"
then
  cachetar="$(cat .pkghash).tar.gz"
  set +e
  "$startdir"/../bin/.package-cache-get "$cachetar" "$out"
  rc="$?"
  set -e
  case "$rc" in
    2)
      echo "package cache miss..." >&2
    ;;
    0)
      exit 0
    ;;
    *)
      echo "package cache lookup failed, aborting" >&2
      exit 1
    ;;
  esac
fi

if test "${PKG_FORCE_BINARY_PACKAGES:-}" = "yes"
then
  echo "PKG_FORCE_BINARY_PACKAGES is 'yes' and the binary cache lookup failed" 1>&2
  exit 1
fi

# Download not possible, we now need the build closure.
redo-ifchange .bclosure
redo-ifchange $(cat .bclosure)

"$startdir"/../bin/do-fetch fetch

if test -e .build
then
  chmod -R 700 .build
  rm -rf .build
fi

mkdir -p .build/chroot
cd .build/chroot
mkdir bin lib libexec usr etc share include var run tmp home destdir
cd ../../

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
    echo --bind ".build/chroot/$toplevel" "$toplevel"
  done
)

# Only pass through job server MAKEFLAGS.
PKG_JOBSERVER=""
BUILD_MAKEFLAGS=""
if test -n "${MAKEFLAGS:-}"
then
  for flag in ${MAKEFLAGS:-}
  do
    case "$flag" in
      --jobserver-auth=*)
        PKG_JOBSERVER="${flag#--jobserver-auth=}"
        BUILD_MAKEFLAGS="-j $flag"
        break
      ;;
    esac
  done
elif test -n "${REDO_JS_FD:-}"
then
  PKG_JOBSERVER="$(echo -n $REDO_JS_FD)" # trim
  BUILD_MAKEFLAGS="-j --jobserver-auth=$(echo "$PKG_JOBSERVER")"
fi

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
  --setenv "TMPDIR" /tmp \
  --setenv "DESTDIR" /destdir \
  --setenv "PKG_JOBSERVER" "$PKG_JOBSERVER" \
  --setenv "MAKEFLAGS" "$BUILD_MAKEFLAGS" \
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
