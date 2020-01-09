
#!/bin/bash

# build the site
echo "--------------------------------------------------------------"
echo "----[PID] CI : building the project --------------------------"
echo "--------------------------------------------------------------"

if [ "$PACKAGE_BINARIES_PUBLISHED" = true ]; then
  # if wrapper publishes binaries then we need to specifically configure archives generation during the build
  version=$1 archive=true cmake --build . --target build
else
  version=$1 cmake --build . --target build
fi
BUILD_RES=$?

if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building the project: FAIL --------------------"
  echo "--------------------------------------------------------------"
	exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building the project: DONE --------------------"
echo "--------------------------------------------------------------"
