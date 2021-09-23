# coolports

A *simple*, *source based*, *hermetic* package system, that is *really fast* for cached packages... cool!

## Getting started

You need [bwrap](https://github.com/containers/bubblewrap) to run the build sandbox and [redo](https://github.com/apenwarr/redo) to execute the build rules.

## Building a package

```
$ redo-ifchange ./pkg/make/.pkg.tar.gz
...

# View runtime dependencies
$ redo ./pkg/make/.closure
$ cat ./pkg/make/.closure
./pkg/libc-rt/.pkg.tar.gz
```

## Running a virtual environment

```
$ ./bin/venv ./pkg/seed
$ ./venv/bin/venv-run env -i PATH=/bin gcc --version
```

## How it works

- The package tree is a redo based build system.
- Each package has a few files:
  - ./pkg/$name/build-deps
    - A list of build dependencies.
  - ./pkg/$name/run-deps
    - A list of runtime dependencies.
  - ./pkg/$name/build
    - The build/install script executed in the build sandbox.
  - ./pkg/$name/fetch
    - A curl script of files to download.
  - ./pkg/$name/sha256sums
    - Validation sums for the download.
- Each package has has a few computed targets:
  - ./pkg/$name/.pkghash
    - A cryptographic hash representing this package, computed by hashing the *full* dependency graph.
  - ./pkg/$name/.closure
    - A computed list containing the transitive runtime dependencies of this package.
  - ./pkg/$name/.bclosure
    - A computed list of all the transitive build time dependencies of this package.
  - ./pkg/$name/.pkg.tar.gz
    - The actual package contents once build.

### Build caching

WIP:

We simply check https://$cache/$pkghash.tar.gz before performing a build.

Populating the cache is a matter of just copying the built tarballs into place on any http server.

To make things even faster, we will add a client side server index that is a simple redo target.


## ./bin/do

Instead of redo, you can use the bootstrap 'do' script, which is a pure sh
implementation of redo, it does not support incremental builds, but should
be able to build one off packages.

