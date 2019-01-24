#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : deploying the project -------------------------"
echo "--------------------------------------------------------------"

if [ "$PACKAGE_HAS_SITE" = true ] ; then
  version=$1 cmake --build . --target site
fi
SITE_RES=$?
if [ $SITE_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : deploying the project: FAIL (STATIC SITE) -----"
  echo "--------------------------------------------------------------"
  exit $SITE_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : deploying the project: DONE -------------------"
echo "--------------------------------------------------------------"
