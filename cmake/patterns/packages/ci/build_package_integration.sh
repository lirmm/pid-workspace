#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : building package ------------------------------"
echo "--------------------------------------------------------------"

cd build
#NB: never building API doc nor binaries on integration, but always generating developpers reports
if [ "$PACKAGE_HAS_LIBRARIES" = true ] ; then
  if [ "$PACKAGE_HAS_TESTS" = true ] ; then
     if [ "$PACKAGE_HAS_EXAMPLES" = true ] ; then
        cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DADDITIONAL_DEBUG_INFO=ON -DBUILD_AND_RUN_TESTS=ON -DENABLE_SANITIZERS=ON -DBUILD_TESTS_IN_DEBUG=ON -DBUILD_COVERAGE_REPORT=ON -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=ON -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DWORKSPACE_DIR="../binaries/pid-workspace" ..
     else
        cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DADDITIONAL_DEBUG_INFO=ON -DBUILD_AND_RUN_TESTS=ON -DENABLE_SANITIZERS=ON -DBUILD_TESTS_IN_DEBUG=ON -DBUILD_COVERAGE_REPORT=ON -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DWORKSPACE_DIR="../binaries/pid-workspace" ..
     fi
  else
      if [ "$PACKAGE_HAS_EXAMPLES" = true ] ; then
        cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DBUILD_AND_RUN_TESTS=OFF -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=ON -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DADDITIONAL_DEBUG_INFO=ON -DWORKSPACE_DIR="../binaries/pid-workspace" ..
      else
        cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DBUILD_AND_RUN_TESTS=OFF -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DADDITIONAL_DEBUG_INFO=ON -DWORKSPACE_DIR="../binaries/pid-workspace" ..
      fi
  fi
else  # no libraries => this is a pure applicative package, no examples since no lib
    if [ "$PACKAGE_HAS_TESTS" = true ] ; then
      cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DBUILD_AND_RUN_TESTS=ON -DENABLE_SANITIZERS=ON -DBUILD_TESTS_IN_DEBUG=ON -DBUILD_COVERAGE_REPORT=ON -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DADDITIONAL_DEBUG_INFO=OFF -DWORKSPACE_DIR="../binaries/pid-workspace" ..
    else
      cmake -DBUILD_RELEASE_ONLY=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DBUILD_AND_RUN_TESTS=OFF -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=ON -DADDITIONAL_DEBUG_INFO=OFF -DWORKSPACE_DIR="../binaries/pid-workspace" ..
    fi
fi
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
#build the code
force=true cmake --build . --target build
BUILD_RES=$?
cd ..
if [ $BUILD_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : building package: FAIL --------------------"
  echo "--------------------------------------------------------------"
  exit $BUILD_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : building package: SUCCESS ---------------------"
echo "--------------------------------------------------------------"
