#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : deploying the project -------------------------"
echo "--------------------------------------------------------------"

#getting the current platform of the current runner
platform=$2
platform=${platform/pid/""}
platform=${platform/","/""}
platform=${platform/" "/""}
platform=${platform/site/""}
platform=${platform/","/""}
platform=${platform/" "/""}

runner_only_binaries="true"
if [ "$platform" = "$PACKAGE_MAIN_PLATFORM" ]; then
  # the current runner is in charge of generating the static site
  runner_only_binaries="false"
elif [ "$PACKAGE_BINARIES_PUBLISHED" != true ]; then
  # the current runner may be only used to publish binaries but it does not do that
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : deploying the project: SKIPPED ----------------"
  echo "--------------------------------------------------------------"
  exit 0
fi

#now generate the site
SITE_RES=0
if [ "$PACKAGE_HAS_SITE" = true ] ; then
  only_binaries=$runner_only_binaries version=$1 cmake --build . --target site
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
