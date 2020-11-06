
#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : building wrapper ------------------------------"
echo "--------------------------------------------------------------"

# setting the adequate path to the workspace
cd build
cmake -DWORKSPACE_DIR="../binaries/pid-workspace" ..
CONF_RES=$?
if [ $CONF_RES != 0 ]; then
  cd ..
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building wrapper: FAIL (configuration) --------"
  echo "--------------------------------------------------------------"
  exit $CONF_RES
fi

#building the external project code
if [ "$PACKAGE_BINARIES_PUBLISHED" = true ]; then
  # if wrapper publishes binaries then we need to specifically configure archives generation during the build
  version=$1 archive=true cmake --build . --target build
else
  version=$1 cmake --build . --target build
fi
BUILD_RES=$?
cd ..
if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building wrapper: FAIL ------------------------"
  echo "--------------------------------------------------------------"
	exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building wrapper: SUCCESS ---------------------"
echo "--------------------------------------------------------------"
