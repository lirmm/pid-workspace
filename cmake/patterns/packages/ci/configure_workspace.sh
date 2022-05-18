#!/bin/bash

#first step is initializing the workspace
echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace -------------------------"
echo "--------------------------------------------------------------"

# 1) first time configuration
cd binaries/pid-workspace/build
cmake -DIN_CI_PROCESS=ON -DFORCE_CONTRIBUTION_SPACES="$PACKAGE_CONTRIBUTION_SPACES" -DPROFILE_EVALUATION_INFO=ON ..
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
platform=${platform/pid/" "}
platform=${platform/site/" "}
platform=${platform//","/" "}

# 2 separate platform and environment names
instance=""
reg_expr="^(.+)__(.+)__$"

reg_expr_job="^build_(release|integration)_(.+)__(.+)__$"

if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
    instance_job=${BASH_REMATCH[3]}
    platform_job=${BASH_REMATCH[2]}
    platform_job=${platform_job//plusplus/"++"}

    IFS=' ' read -ra my_array <<< "$platform"

    #among all tags of the runner
    for i in "${my_array[@]}"
    do
      if [[ $i =~ $reg_expr ]]; then

        tmp_instance=${BASH_REMATCH[2]}
        tmp_platform=${BASH_REMATCH[1]}

        if [ $platform_job = $tmp_platform ] && [ $instance_job = $tmp_instance ]; then
          instance=$tmp_instance
          platform=$tmp_platform
          break
        fi
      fi
    done
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
