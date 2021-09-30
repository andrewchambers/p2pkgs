# Package Caches

Some packages take a long time to build, you can avoid rebuilding it by creating a package cache.

### HTTP(s) package cache

An http package cache is just a standard http server.

First generate the package cache directory:

```
mkdir /path/to/cache-dir
$ ./bin/add-to-package-cache -j $(nproc) -o /path/to/cache-dir ./pkg/{gcc,binutils,musl}
```

Next you can serve the package cache over http:

```
$ cd /path/to/cache-dir
$ python3 -m http.server --bind 127.0.0.1
Serving HTTP on 127.0.0.1 port 8000 (http://127.0.0.1:8000/)
```

Finally, you can use the package cache:

```
$ export PKG_CACHE_URL="http://127.0.0.1:8000"
$ redo ...
```

### IPFS/IPNS package cache

An IPFS/IPNS cache is served over the ipfs network.

First generate the package cache directory:

```
mkdir /path/to/cache-dir
$ ./bin/add-to-package-cache -j $(nproc) -o /path/to/cache-dir ./pkg/{gcc,binutils,musl}
```

Next add the cache directory to ipfs

```
$ cd /path/to/cache-dir
$ cid=$(ipfs add -Q -r .)
```

Use the package cache (requires ipfs installed):

```
$ export PKG_CACHE_URL="ipfs://$cid"
$ redo ...
```

You can use IPNS too:

```
$ cid=$(ipfs add -Q -r .)
$ export PKG_CACHE_URL="ipns://$(ipns name publish $cid)"
```

### Public package caches

Development package cache hosted by Andrew Chambers:

```
ipns://k51qzi5uqu5dlbmgpow9z63mgu9kita6zcipmdv63cq0nkyztwx4vzv02dyj02
```

