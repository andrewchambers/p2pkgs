#!/bin/sh
set -eux

redo-ifchange ../rust/.pkg.tar.gz
ln ../rust/.pkg.tar.gz "$3"