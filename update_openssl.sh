#!/bin/sh

APP_FOLDER="`pwd`"

pushd openssl-1.0.1e || exit 1

make clean || exit 1

./Configure darwin64-x86_64-cc --prefix=$APP_FOLDER/openssl --openssldir=$APP_FOLDER/openssl/ssl || exit 1

make clean || exit 1

make || exit 1

make test || exit 1

make install
