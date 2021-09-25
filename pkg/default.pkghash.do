#!/bin/sh

# Compute a deterministic cryptographic hash id for the given package.
# The hash is based on the full depdenency tree and can be therefore
# used for transparent build caching.

set -eu

out="$(realpath $3)"
pkgdir="$(dirname $(realpath $1))"
cd $pkgdir

rundephashes=""
builddephashes=""

if test -e run-deps
then
  redo-ifchange run-deps
  rundephashes=$(cat run-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
else
  redo-ifcreate run-deps
fi

if test -e build-deps
then
  redo-ifchange build-deps
  builddephashes=$(cat build-deps | sed -e 's,$,/.pkghash,' | xargs -r realpath)
else
  redo-ifcreate build-deps
fi

redo-ifchange build $rundephashes $builddephashes

if test -e files
then
	# XXX detect creation? is it possible?
	redo-ifchange $(find files -type f)
else
	redo-ifcreate files
fi

if test -e fetch
then
  redo-ifchange fetch
else
  redo-ifcreate fetch
fi

(
  set -e
  echo rhash # Recursive hash tag, see seed/.pkghash.do for content hash.
  echo fetch
  if test -e fetch
  then
    file=""
    url=""
    OLDIFS="$IFS"; IFS=$'\n'
    for line in $(recsel -p url,file,sha256 fetch) # XXX We don't want to depend on recutils
    do
      case "$line" in
        file:*)
          file="${line#file: }"
        ;;
        url:*)
          url="${line#url: }"
        ;;
        sha256:*)
          sha256="${line#sha256: }"
          if test -z "$url"
          then
            echo "fetch missing url field" 1>&2
            exit 1
          fi
          if test -z "$sha256"
          then
            echo "fetch: url: $url missing sha256 field" 1>&2
            exit 1
          fi
          if test -z "$file"
          then
            file="$(basename $url)"
          fi

          if ! test "$file" = "$(basename $file)"
          then
            echo "fetch: file: $file must not be a directory or complex path" 1>&2
            exit 1
          fi
          # only $file and $sha256 contribute to pkghash.
          echo "$file"
          echo "$sha256"
          file=""
          url=""
          sha256=""
        ;;
        *)
          echo "unexpected line: $line" 1>&2
          exit 1
        ;;
      esac
    done
    IFS="$OLDIFS"
  fi
  echo build
  cat build
  echo files
  if test -e files
  then
    # XXX we need some canonical tar format
    # guaranteed to be the same for everyone,
    # this is currently just wrong.
    find ./files -print0 -type f \
    | sort -z \
    | tar -cf - \
          --format=posix \
          --numeric-owner \
          --owner=0 \
          --group=0 \
          --mtime='1970-01-01' \
          --no-recursion \
          --null \
          --files-from -
  fi
  echo run-deps
  cat $rundephashes < /dev/null
  echo build-deps
  cat $builddephashes < /dev/null
) | sha256sum | cut -c -64 > $out

redo-stamp < $out