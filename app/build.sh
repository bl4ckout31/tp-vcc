#!/bin/bash
set -xe

# Fetch Sources

BIN=/app/bin
SRC=/app/src
BUILD=/app/ffmpeg_build

mkdir -p "$BIN"
mkdir -p "$BUILD"
mkdir -p "$SRC"

cd $SRC

git clone --depth 1 git://git.videolan.org/x264.git
git clone --depth 1 git://source.ffmpeg.org/ffmpeg

# Build NASM

wget https://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.xz
tar -xvf nasm-2.14.tar.xz
cd nasm-2.14
./autogen.sh
PATH="$BIN:$PATH" ./configure --prefix="$BUILD" --bindir="$BIN"
make -j $(nproc)
make install

# Build libx264

cd "$SRC/x264"
PATH="$BIN:$PATH" PKG_CONFIG_PATH="$BUILD/lib/pkgconfig" ./configure --prefix="$BUILD" --bindir="$BIN" --enable-static --enable-pic
PATH="$BIN:$PATH" make -j $(nproc)
make install


# Build ffmpeg.

cd "$SRC/ffmpeg"
PATH="$BIN:$PATH" PKG_CONFIG_PATH="$BUILD/lib/pkgconfig" ./configure \
  --prefix="$BUILD" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$BUILD/include" \
  --extra-ldflags="-L$BUILD/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="$BIN" \
  --enable-gpl \
  --enable-libass \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libvorbis \
  --enable-libx264 \
  --enable-nonfree
PATH="$BIN:$PATH" make -j $(nproc)
make install


# Remove all tmpfile

rm -rf "$SRC" "$BUILD"
