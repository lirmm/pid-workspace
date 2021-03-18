#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : building package ------------------------------"
echo "--------------------------------------------------------------"

#first time configuring with tests and examples enabled
cd build
cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DADDITIONAL_DEBUG_INFO=OFF -DBUILD_AND_RUN_TESTS=ON -DENABLE_SANITIZERS=ON -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=ON -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=OFF -DGENERATE_INSTALLER=OFF -DWORKSPACE_DIR="../binaries/pid-workspace" ..
CONF_RES=$?
if [ $CONF_RES != 0 ]; then
  cd ..
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building package: FAIL (configuration) --------"
  echo "--------------------------------------------------------------"
  exit $CONF_RES
fi

# always generating the dependencies file of the package
write_file=true cmake --build . --target list_dependencies

#put the dependencies description file directly in source folder
mv ./release/share/dependencies.txt ..
#build the code
force=true cmake --build . --target build
BUILD_RES=$?
cd ..
if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building package: FAIL ------------------------"
  echo "--------------------------------------------------------------"
  exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building package: SUCCESS ---------------------"
echo "--------------------------------------------------------------"
