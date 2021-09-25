#!/bin/sh
set -eux

out=$(realpath $3)

tarballs="
../gcc/.pkg.tar.gz
../oksh/.pkg.tar.gz
../gnu-base/.pkg.tar.gz
../xz/.pkg.tar.gz
../make/.pkg.tar.gz
../gcc/.pkg.tar.gz
../binutils/.pkg.tar.gz
../musl/.pkg.tar.gz
../linux-headers/.pkg.tar.gz
"

redo-ifchange $tarballs

if test -e ./seed-out.tmp
then
  chmod -R 700 ./seed-out.tmp
  rm -rf ./seed-out.tmp
fi

mkdir seed-out.tmp

for t in $tarballs
do
  tar -C ./seed-out.tmp -xzf $t
  # XXX this should not be needed.
  chmod -R +rwX ./seed-out.tmp
done

cd ./seed-out.tmp
find . -print0 \
  | sort -z \
  | tar -czf - \
        --format=posix \
        --numeric-owner \
        --owner=0 \
        --group=0 \
        --mtime='2021-01-01' \
        --no-recursion \
        --null \
        --files-from -
cd ..
chmod -R 700 ./seed-out.tmp/
rm -rf ./seed-out.tmp