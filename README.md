# coolports

A simple, auditable, source based, package system with an optional
precompiled package cache and optional p2p mirroring.

## Key features

- Everything is built from source except a small set of well defined bootstrap packages.

- Every bootstrap package can be reproduced exactly via the package tree itself.

- Every download can be mirrored over p2p networks and self hosted, there is no central server that can prevent packages from compiling.

- Packages can easily be exported to virtual environments, tarballs, docker containers and anything else you need.

## Getting started

Install the dependencies:

- [bwrap](https://github.com/containers/bubblewrap) to run the build sandbox.
- [redo](https://github.com/apenwarr/redo)[1] to run build rules.
- [curl](https://curl.se/) to download source tarballs.
- [recutils](https://www.gnu.org/software/recutils) used for the mirror databases.

Optional dependencies:

- [ipfs](https://ipfs.io) used for peer to peer package caches and source mirrors.


[1] We provide ./bin/do as an included version that lacks incremental builds, but will work for building single packages.

## Building a package

```
./bin/build-packages-ifchange ./pkg/{make,oksh}
```

or:

```
$ redo -j $(nproc) ./pkg/make/.pkg.tar.gz
```

## Running packages in a venv

We support running packages in a container called a venv:

```
$ ./bin/venv -j $(nproc) ./pkg/{make,oksh,gnu-base}
$ ./venv/bin/venv-run make --version
GNU Make 4.2
```

The requested process is run in a linux user container with top level directories substituted for those
in the requested packages, this allows very lightweight use of package environments.

## Setting up a binary cache

Some packages take a long time to build, you can avoid rebuilding it by
creating a binary cache.

### HTTP(s) binary cache

Generate the package tarballs and serve them over http:

```
$ ./bin/add-to-package-cache -o /path/to/cache-dir ./pkg/{gcc,binutils,musl}
$ cd /path/to/cache-dir
$ python3 -m http.server --bind 127.0.0.1
Serving HTTP on 127.0.0.1 port 8000 (http://127.0.0.1:8000/)
```

Use the binary cache:

```
$ export PACKAGE_CACHE_URL="http://127.0.0.1:8000"
$ redo ./pkg/gcc/.pkg.tar.gz
```

### IPFS binary cache

We support peer to peer binary caches via IPFS/IPNS (requires ipfs installed):

```
$ ./bin/add-to-package-cache -o /path/to/cache-dir ./pkg/{gcc,binutils,musl}
$ cd /path/to/cache-dir
$ cid=$(ipfs add -Q -r .)
```

Use the binary cache (requires ipfs installed):

```
$ export PACKAGE_CACHE_URL="ipfs://$cid"
$ redo ./pkg/gcc/.pkg.tar.gz
```

You can use ipns too:

```
$ cid=$(ipfs add -Q -r .)
$ export PACKAGE_CACHE_URL="ipns://$(ipns name publish $cid)"
```

### Public package caches

Development package cache hosted by Andrew Chambers:

```
ipns://k51qzi5uqu5dlbmgpow9z63mgu9kita6zcipmdv63cq0nkyztwx4vzv02dyj02
```

## Mirroring package source code

If you want to help our project and mirror all our source dependencies, install and configure an ipfs daemon, then run `./bin/ipfs-pin-all-fetch-files`.

Alternatively you can read the cids listed in ./mirrors/ipfs and decide which ones you
want to mirror.


## How it works

See the [technical documentation](./doc/TECHNICAL.md).