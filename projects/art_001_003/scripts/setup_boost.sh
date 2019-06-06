#!/bin/bash

# 2019-06-2
# Jaime O. Rios
# Script maintained at https://gist.github.com/AhiyaHiya/5c267b61e67e5c5637e4a209b1cd2ee8
# Inspired by
# https://github.com/mgrebenets/boost-xcode5-iosx/blob/master/boost.sh

set -o errexit
set -o pipefail
set -o nounset

download_boost() {
    printf "*********************************\\n%s\\n" "${FUNCNAME[0]}"
    if [ ! -s "$BOOST_TARBALL" ]; then
        echo "Downloading boost $BOOST_TARBALL..."
        curl -L -o "$BOOST_TARBALL" http://sourceforge.net/projects/boost/files/boost/$VERSION/$BOOST_TARBALL/download
    fi

    tar xfj "$BOOST_TARBALL"
}

build_boost() {
    printf "*********************************\\n%s\\n" "${FUNCNAME[0]}"
    cd "$TARBALLDIR/boost_$BOOST_VERSION_FILE/tools/build"
    ./bootstrap.sh

    cd ../..
    BOOST_LIBS="--with-date_time --with-filesystem --with-program_options --with-random --with-system --with-locale --with-wave"

    local core_count
    core_count=$(getconf _NPROCESSORS_ONLN)

    # PRODUCES FULL NAMES
    ./tools/build/b2 \
        -j${core_count} \
        $BOOST_LIBS \
        --toolset=clang --layout=versioned \
        --stagedir=stage/intel/a \
        link=static address-model=64 \
        debug release \
        cxxflags="-arch x86_64 -std=gnu++17 -stdlib=libc++" \
        linkflags="-arch x86_64 -stdlib=libc++ -compatibility_version $VERSION -current_version $VERSION"
}

prebuild_boost() {
    printf "*********************************\\n%s\\n" "${FUNCNAME[0]}"

    if [[ ! -d "$TARBALLDIR" ]]; then
        mkdir -p "$TARBALLDIR"
    fi
    cd "$TARBALLDIR"
    if [[ -d "./boost_${BOOST_VERSION_FILE}" ]]; then
        rm -R "./boost_${BOOST_VERSION_FILE}"
    fi
}

postbuild_boost() {
    printf "*********************************\\n%s\\n" "${FUNCNAME[0]}"

    cd "$LIB_PATH/boost"

    mv -fv "$TARBALLDIR/boost_${BOOST_VERSION_FILE}/boost" ./boost

    if [[ ! -d "$LIB_PATH/boost/lib/mac/intel/a" ]]; then
        mkdir -p "$LIB_PATH/boost/lib/mac/intel/a"
    fi

    mv -fv "$TARBALLDIR/boost_${BOOST_VERSION_FILE}/stage/intel/a/lib/" "$LIB_PATH/boost/lib/mac/intel/a/"
    rm -R "$TARBALLDIR"
}

main() {
    printf "*********************************\\n%s\\n" "${FUNCNAME[0]}"
    if [[ ! -d "$LIB_PATH/boost" ]]; then
        printf "boost folder missing; attempting to create"
        mkdir -p "$LIB_PATH/boost"
    fi
    prebuild_boost
    download_boost
    build_boost
    postbuild_boost
}

readonly CURRENT_PATH=$PWD
readonly LIB_PATH=$CURRENT_PATH/lib
readonly TARBALLDIR=$LIB_PATH/boost/tmp_build
readonly VERSION=1.69.0
readonly BOOST_VERSION_FILE=1_69_0
readonly BOOST_TARBALL=boost_$BOOST_VERSION_FILE.tar.gz

main