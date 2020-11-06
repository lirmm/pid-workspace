
#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : building framework site ... -------------------"
echo "--------------------------------------------------------------"

# setting the adequate path to the workspace and configuring
cd build
cmake -DWORKSPACE_DIR="../binaries/pid-workspace" ..
CONFIGURE_RES=$?
cd ..

if [ $CONFIGURE_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building framework: FAIL (configuration) ------"
  echo "--------------------------------------------------------------"
  exit $CONFIGURE_RES
fi

# force updating binaries
git lfs pull official master

# build the site
cd build
cmake --build . --target build
BUILD_RES=$?
cd ..
if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building framework : FAIL (build site) --------"
  echo "--------------------------------------------------------------"
  exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building framework : SUCCESS ------------------"
echo "--------------------------------------------------------------"
