# coolports

A *simple*, *auditable*, *source based*, package system with an optional
*self hostable* binary cache to accelerate package builds.

Key features:

-  Every precompiled binary it depends on can be reproduced exactly via the package tree itself allowing total auditability.
- All source code and bootstrap binaries are also hosted on ipfs for resilience (with primary sources listed too).


## Getting started

Install the dependencies:

- [bwrap](https://github.com/containers/bubblewrap) to run the build sandbox.
- [redo](https://github.com/apenwarr/redo)[1] to run build rules.
- [curl](https://curl.se/) to download source tarballs.
- [recutils](https://www.gnu.org/software/recutils) used for the mirror databases.


[1] We provide ./bin/do as a pure shell version that lacks incremental builds, but will work for building a single packages.

## Running packages in a venv

We support running packages in a container called a venv:

```
$ ./bin/venv ./pkg/{make,oksh,gnu-base}
$ ./venv/bin/venv-run make --version
GNU Make 4.2
```

The requested process is run in a linux user container with top level directories substituted for those
in the requested packages, this allows very lightweight use of package environments.

## Building a package

```
$ redo-ifchange ./pkg/make/.pkg.tar.gz
...

# View package runtime dependencies
$ cat ./pkg/make/.closure
./pkg/libc-rt/.pkg.tar.gz
```

## Mirroring the repository

If you want to help our project and mirror all our source depdendencies, install and configure an ipfs daemon, then run `./bin/ipfs-pin-all-fetch-files`.

Alternatively you read the cids listed in ./mirrors/ipfs and decide which ones you
want to mirror.


## How it works

See the [technical documentation](./doc/TECHNICAL.md).