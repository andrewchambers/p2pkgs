# Packaging

## Package Files

## build

A script run inside the build sandbox that must build the package
and install it into the staging directory $DESTDIR.

### run-deps

A file containing relative paths to runtime dependencies, one per line. Newlines are not supported in package paths.

### build-deps

A file containing relative paths to build dependencies, one per line. Newlines are not supported in package paths.

### fetch

A rec file containing urls to download and sha256 sums to verify
the downloads.

### files

A directory of files to include in the build environment in the working directory.

## The build environment

### Build sandbox

All packages are built inside a chroot/vm/container.

- Packages are built without access to the internet.
- Packages are built with the working directory at $HOME.
- Package build scripts run as a generic 'build' user.

### Env vars

```
HOME=/home/build
PKG_JOBSERVER="x,y"
MAKEFLAGS="-j --jobserver-auth=$PKG_JOBSERVER"
TMPDIR="/tmp"
PREFIX=
DESTDIR=/destdir
```

## Notes

### Static linking

Packages may be statically linked if:

- Doing so is typical for the package (e.g. busybox, go binaries, ...).
- Doing so is how the upstream developers expect the software to be built.
- Doing so does not impact packages that depend on it.

If a package has significant utility in a statically linked
context, we also accept a $pkg-static duplication of a package.

### Debug symbols

Debug symbols should be stripped if possible. We may review this
rule in the future.

### Manuals and support files

They should be included if they are not excessive, and are not scattered around the package tree. It should be easy to manually remove them with a post processing on the tarballs step if desired.

### 'Vendored' dependencies

Often upstream package includes a copy of a dependency with the intention of it being statically linked, we allow this while most other package trees do not.

The reasons are simple:

- It is likely upstream tests with this version.
- It is likely upstream understands their usage of a library
  better than we do.
- If we do not have any trust in upstream, we should not be using that software.

All that being said, if the upstream provides both options, prefer using our versions unless there is reason to do otherwise.