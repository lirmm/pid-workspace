#!/bin/bash

#first step is initializing the workspace
echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace -------------------------"
echo "--------------------------------------------------------------"

# 1) first time configuration
cd binaries/pid-workspace/build
cmake -DIN_CI_PROCESS=ON -DFORCE_CONTRIBUTION_SPACES="$PACKAGE_CONTRIBUTION_SPACES" ..
CONFIGURE_RES=$?
cd ../../..
if [ $CONFIGURE_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : configuring workspace: FAIL -------------------"
  echo "--------------------------------------------------------------"
  exit $CONFIGURE_RES
fi

#getting the current platform and instance (if any) of the current runner
platform=$1

# 1 extract target platform information from runner tags
platform=${platform/pid/""}
platform=${platform/","/""}
platform=${platform/" "/""}
platform=${platform/site/""}
platform=${platform/","/""}
platform=${platform/" "/""}

# 2 separate platform and environment names
instance=""
reg_expr="^(.+)__(.+)__$"

if [[ $platform =~ $reg_expr ]]; then
    instance=${BASH_REMATCH[2]}
    platform=${BASH_REMATCH[1]}
fi

if [  "$instance" != "" ]; then
  using_profile=use_$instance
  echo "[PID] CI : configuring environment $instance on platform $platform ..."
  cd binaries/pid-workspace/build
  cmd=mk profile=$using_profile env=$instance instance=$instance platform=$platform cmake --build . --target profiles
  CONFIGURE_RES=$?
  cd ../../..
  if [ $CONFIGURE_RES != 0 ]; then
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : configuring workspace: FAIL (setting profile) -"
    echo "--------------------------------------------------------------"
    exit $CONFIGURE_RES
  fi
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace: SUCCESS ----------------"
echo "--------------------------------------------------------------"
