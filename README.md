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
- redo[1] to run build rules.
- [curl](https://curl.se/) to download source tarballs.
- [recutils](https://www.gnu.org/software/recutils) used for the mirror databases.
- [gnu tar](https://www.gnu.org/software/tar/)[2] used for reproducible tarballs.


Optional dependencies:

- [ipfs](https://ipfs.io) used for peer to peer package caches and source mirrors.


[1] We support multiple redo implementations:

- cypherpunks [goredo](http://www.goredo.cypherpunks.ru).
- apenwarrs [redo](https://github.com/apenwarr/redo).
- The bundled, but very limited [./bin/do](./bin/do).

They above list is order of preference.

[2] We want help and are working on making the package tree more portable.

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

## Setting up a package cache

To avoid compiling packages from source you can configure
a package cache, which acts transparently but dramatically
increases the build speed of cached packages.

See the [package cache documentation](./doc/packagecaches.md) for
more information.

### Public package caches

Below are some public package caches, you should only use them
if you trust the cache owner.

Development package cache by Andrew Chambers:

```
export PKG_CACHE_URL=ipns://k51qzi5uqu5dlbmgpow9z63mgu9kita6zcipmdv63cq0nkyztwx4vzv02dyj02
```

## Writing packages

For more information about writing packages see the [packaging documentation](./doc/packaging.md).

## Technical overview

To see how it all works, check the [technical overview](./doc/technical.md).