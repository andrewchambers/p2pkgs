# coolports

A hermetic, from source, package tree for linux with transparent build caching... isn't that cool?

## Getting started

You need [bwrap](https://github.com/containers/bubblewrap) to run the build sandbox and [redo](https://github.com/apenwarr/redo) to execute the build rules.

## Building a package

```
$ redo ./pkg/gcc/.pkg.tar.gz
```

## How it works

- The package tree is a build system.
- Each package has a few files:
  - ./pkg/$name/build-deps - A list of build dependencies.
  - ./pkg/$name/run-deps - A list of runtime dependencies.
  - ./pkg/$name/build - The script executed in the build sandbox.
  - ./pkg/$name/url - A curl script of files to download.
  - ./pkg/$name/sha256sums - Validation sums for the download.
- Each package has has a few computed targets:
  - ./pkg/$name/.pkghash - A unique hash representing this package, computed by hashing its dependency graph. Used for caching and avoiding building packages all together.
  - ./pkg/$name/.closure - A computed list of all the runtime dependencies of this package.
  - ./pkg/$name/.bclosure - A computed list of all the build time dependencies of this package.
  - ./pkg/$name/.pkg.tar.gz - The actual package contents.
