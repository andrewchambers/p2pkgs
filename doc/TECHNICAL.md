# How it works

The package tree is a *just* redo based build system, this means it is simple and flexible. To build anything in the package tree, you run `redo $path` without exception.

## Package files

- ./pkg/$name/build-deps
  - A list of build dependencies.
- ./pkg/$name/run-deps
  - A list of runtime dependencies.
- ./pkg/$name/build
  - The build/install script executed in the build sandbox.
- ./pkg/$name/fetch
  - rectools database of build artifacts.
- ./pkg/$name/files
  - An optional directory of files added to the build directory.

## Computed files

Each package has has a few computed targets you can build manually:

- ./pkg/$name/.pkghash
  - A cryptographic hash representing this package, computed by hashing the *full* dependency graph.
- ./pkg/$name/.closure
  - A computed list containing the transitive runtime dependencies of this package.
- ./pkg/$name/.bclosure
  - A computed list of all the transitive build time dependencies of this package.
- ./pkg/$name/.pkg.tar.gz
  - The actual package contents once build.

## Package caching

Because we have a .pkghash uniquely representing each package, we can simply skip
package builds if $PKG_CACHE_URL/$HASH.tar.gz exists.

## P2P mirrors

We support ipfs p2p mirrors for everything we depend on. The mirror database 
is maintained in `./mirrors/ipfs` and can be populated automatically with scripts
in `./bin`.
