
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

# 2) set the current profile if required

#getting the current platform and instance (if any) of the current runner
platform=$1

# 1 extract target platform information from runner tags
platform=${platform//"["/""}
platform=${platform//"]"/""}
platform=${platform//" "/""}
platform=${platform/pid/""}
platform=${platform/site/""}
platform=${platform//","/" "}
platform=${platform//"  "/" "}

# 2 separate platform and environment names
instance=""

reg_expr_job="^build_wrapper_(.+)__(.+)__$"

if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
    instance_job=${BASH_REMATCH[3]}
    platform_job=${BASH_REMATCH[2]}
    platform_job=${platform_job//plusplus/"++"}

    IFS=' ' read -ra my_array <<< $platform
    found=""
    expr="$platform_job__$instance_job__"
    #among all tags of the runner
    for i in "${my_array[@]}"
    do
      if [[ $i =~ "$expr" ]]; then
          instance=$instance_job
          platform=$platform_job
          found="1"
          break
      fi
    done

    if [[ $found == "" ]]; then
      echo "runner not capable of running job for platform $platform_job with instance $instance_job"
      exit 1
    fi
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
    echo "----[PID] CI : configuring workspace: FAIL (set profile) -----"
    echo "--------------------------------------------------------------"
    exit $CONFIGURE_RES
  fi
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : configuring workspace: SUCCESS ----------------"
echo "--------------------------------------------------------------"
