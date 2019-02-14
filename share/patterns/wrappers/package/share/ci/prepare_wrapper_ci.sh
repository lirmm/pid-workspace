#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : preparing workspace ---------------------------"
echo "--------------------------------------------------------------"

#########################
#  --  Git prepare  --  #
#########################

# Print Git version
git --version
dir_path=`pwd`
dir_name=`basename $dir_path`

############################################################################################
#  --  initializing the folder where dependencies and installed artefacts will be put  --  #
############################################################################################

#creating the folder for binaries
if [ ! -d "./binaries" ]; then
  mkdir binaries
fi

echo "[PID] CI : initializing workspace ..."
#initializing the pid-workspace
if [ ! -d "./binaries/pid-workspace" ]; then
  cd binaries && git clone git@gite.lirmm.fr:pid/pid-workspace.git && cd pid-workspace/pid && cmake -DIN_CI_PROCESS=ON .. && cd ../../..
else
  cd binaries/pid-workspace/pid && git pull -f official master && cmake -DIN_CI_PROCESS=ON .. && cd ../../..
fi

# previous to an execution we need to set a link into the workspace that point to the current package
cd binaries/pid-workspace/wrappers && ln -s $dir_path $dir_name && cd ../../..

#getting the current platform and instance (if any) of the current runner
platform=$1
# 1 extract target platform information from runner targs
platform=${platform/pid/""}
platform=${platform/","/""}
platform=${platform/" "/""}
# 2 separate platform and environment names
instance=""
if [[ $platform =~ '^(.*)__([^_]+)__$' ]]; then
    instance=${BASH_REMATCH[2]}
    platform=${BASH_REMATCH[1]}
fi

if [  "$instance" != "" ]; then
  echo "[PID] CI : configuring environment $instance on platform $platform ..."
  cd build
  environment=$instance platform=$platform cmake --build . --target configure
  cd ..
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : preparing workspace: DONE ---------------------"
echo "--------------------------------------------------------------"
