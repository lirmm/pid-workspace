#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : building static site --------------------------"
echo "--------------------------------------------------------------"

# updating binaries
git lfs pull origin master

# setting the adequate path to the workspace and configuring
cd build
cmake -DWORKSPACE_DIR="../binaries/pid-workspace" ..
CONFIGURE_RES=$?
if [ $CONFIGURE_RES != 0 ]; then
  cd ..
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building static site: FAIL (configuration) ----"
  echo "--------------------------------------------------------------"
  exit $CONFIGURE_RES
fi

# build the site
cmake --build . --target build
BUILD_RES=$?
cd ..
if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building static site: FAIL --------------------"
  echo "--------------------------------------------------------------"
  exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building static site: SUCCESS -----------------"
echo "--------------------------------------------------------------"
