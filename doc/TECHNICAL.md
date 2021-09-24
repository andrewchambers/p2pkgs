# How it works

- The package tree is a *just* redo based build system, this means it is
  simple and flexible.
- Packages are built isolated from everything except declared dependencies.
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
  - ./pkg/$name/files
    - An optional directory of files added to the build directory.
- Each package has has a few computed targets:
  - ./pkg/$name/.pkghash
    - A cryptographic hash representing this package, computed by hashing the *full* dependency graph.
  - ./pkg/$name/.closure
    - A computed list containing the transitive runtime dependencies of this package.
  - ./pkg/$name/.bclosure
    - A computed list of all the transitive build time dependencies of this package.
  - ./pkg/$name/.pkg.tar.gz
    - The actual package contents once build.

So what is the point?

Once we have a .pkghash that represents each package and encapsulates the entire dependency tree we can now use this as a cache tag and immutable id for that package. Now instead of building a package, we can simply check https://$cache/$pkghash.tar.gz for a package, and download it if it is there.
This gives us the power of a source based ports tree, and a binary package 
manager.

