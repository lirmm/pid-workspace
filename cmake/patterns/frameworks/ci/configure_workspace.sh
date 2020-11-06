#!/bin/bash

#first step is initializing the workspace
echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace  ...    -----------------"
echo "--------------------------------------------------------------"

# 1) first time configuration
cd binaries/pid-workspace/build
cmake -DIN_CI_PROCESS=ON -DFORCE_CONTRIBUTION_SPACES="$FRAMEWORK_CONTRIBUTION_SPACES"  ..
CONFIGURE_RES=$?
cd ../../..
if [ $CONFIGURE_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : configuring workspace: FAIL -------------------"
  echo "--------------------------------------------------------------"
  exit $CONFIGURE_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace: SUCCESS ----------------"
echo "--------------------------------------------------------------"
