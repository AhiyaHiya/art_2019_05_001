#!/usr/bin/env bash

# Jaime O. Rios
# 2019-06-2
# Script will clone, config and build OpenSSL for macOS
# Script expects to be invoked from the root project directory

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

readonly LOCAL_SSL_DIR=$PWD/lib/openssl
readonly CURRENT_DIR=$PWD

mkdir $CURRENT_DIR/tmp_openssl
cd $CURRENT_DIR/tmp_openssl
git clone -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl

cd openssl

./Configure darwin64-x86_64-cc -shared --prefix="$LOCAL_SSL_DIR" --openssldir="${LOCAL_SSL_DIR}/cnf"

readonly core_count=$(getconf _NPROCESSORS_ONLN)
make -j $core_count
make install

cd "$CURRENT_DIR" || echo "Failure"

rm -rf $CURRENT_DIR/tmp_openssl