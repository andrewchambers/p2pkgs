#!/bin/sh
set -eux

redo-ifchange ../rust/.pkg.tar.gz
ln -f ../rust/.pkg.tar.gz "$3"