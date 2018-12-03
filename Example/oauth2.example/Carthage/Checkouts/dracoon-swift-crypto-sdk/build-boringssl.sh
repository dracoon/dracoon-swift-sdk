#!/bin/sh
set -e

build_framework()
{
  ARCH=$1
  SYSROOT=$2

  if [ -d build ]; then
  rm -rf build
  fi
  mkdir build
  cd build
  echo "Build for architecture $ARCH"
  cmake -DCMAKE_OSX_SYSROOT=$SYSROOT -DCMAKE_OSX_ARCHITECTURES=$ARCH ..
  make
  mkdir -p ../$ARCH/openssl.framework/Headers
  libtool -no_warning_for_no_symbols -static -o ../$ARCH/openssl.framework/openssl crypto/libcrypto.a ssl/libssl.a
  cp -r ../include/openssl/* ../$ARCH/openssl.framework/Headers/
  echo "Created openssl.framework for $ARCH"
  cd ..
}

if [ -d boringssl ]; then
rm -rf boringssl
fi

git clone https://boringssl.googlesource.com/boringssl
cd boringssl
for ARCH in arm64 armv7
do
build_framework $ARCH iphoneos
done
for ARCH in x86_64 i386
do
build_framework $ARCH iphonesimulator
done
lipo -create -output "arm64/openssl.framework/openssl" "arm64/openssl.framework/openssl" "armv7/openssl.framework/openssl" "x86_64/openssl.framework/openssl" "i386/openssl.framework/openssl"
if [ -d ../output ]; then
rm -rf ../output
fi
mkdir ../output
cp -r arm64/openssl.framework ../output/
rm -rf build
cd ..
echo "Created output at "$PWD"/output/"
