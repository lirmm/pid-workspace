#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing package ----------------------------"
echo "--------------------------------------------------------------"
cd build
if [ -d "./release/share/developper_info" ] ; then
  rm -Rf ./release/share/developper_info
fi

#preparing the final archive to upload as artifact
mkdir ./release/share/developper_info
cp ./release/share/dependencies.txt ./release/share/developper_info
cmake --build . --target staticchecks && cd release/share && cmake -E tar cvfz staticchecks.tgz static_checks_report/ && mv staticchecks.tgz developper_info && cd ../..
STAT_CHK_RES=$?
if [ $STAT_CHK_RES != 0 ]; then
  cd ..
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : publishing package: FAIL (static checks) ------"
  echo "--------------------------------------------------------------"
  exit $STAT_CHK_RES
fi

if [ "$PACKAGE_HAS_LIBRARIES" = true ] && [ "$PACKAGE_HAS_TESTS" = true ] ; then
  # generating the coverage report of the package if there are tests on libraries
  cd debug/share
  cmake -E tar cvfz coverage.tgz coverage_report/ && mv coverage.tgz ../../release/share/developper_info
  COV_RES=$?
  cd ../..
  if [ $COV_RES != 0 ]; then
    cd ..
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : publishing package: FAIL (coverage) -----------"
    echo "--------------------------------------------------------------"
    exit $COV_RES
  fi
fi
#creating the final archive to upload as artifact and put it in build folder

cd ./release/share && cmake -E tar cvfz developper_info.tgz developper_info/ && mv developper_info.tgz ../../.. && cd ../..
echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing package: SUCCESS -------------------"
echo "--------------------------------------------------------------"
cd ..
