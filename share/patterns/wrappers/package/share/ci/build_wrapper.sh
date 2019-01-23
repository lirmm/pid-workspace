
#!/bin/bash

# build the site

echo "[PID] CI : generating the binary archive..."

cd build

if [ "$PACKAGE_BINARIES_PUBLISHED" = true ]; then
  # if wrapper publishes binaries then we need to specifically configure archives generation during the build
  version=$1 archive=true cmake --build . --target build
else
  version=$1 cmake --build . --target build
fi
BUILD_RES=$?

cd ..

if [ $BUILD_RES != 0 ]; then
	exit $BUILD_RES
fi
