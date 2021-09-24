# coolports

A *simple*, *auditable*, *source based*, package system with an optional
*self hostable* binary cache to accelerate package builds.

A key feature of this package tree is every precompiled binary it depends on can be reproduced
exactly via the package tree itself giving you full control of your software stack.

## Getting started

You need [bwrap](https://github.com/containers/bubblewrap) to run the build sandbox and [redo](https://github.com/apenwarr/redo) to execute the build rules.

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

## How it works

See the [technical documentation](./doc/TECHNICAL.md).