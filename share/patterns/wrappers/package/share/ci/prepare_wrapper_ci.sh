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

#initializing the pid-workspace
if [ ! -d "./binaries/pid-workspace" ]; then
  cd binaries && git clone git@gite.lirmm.fr:pid/pid-workspace.git && cd pid-workspace/pid && cmake -DIN_CI_PROCESS=ON .. && cd ../../..
else
  cd binaries/pid-workspace/pid && git pull -f official master && cmake -DIN_CI_PROCESS=ON .. && cd ../../..
fi

# previous to an execution we need to set a link into the workspace that point to the current package
cd binaries/pid-workspace/wrappers && ln -s $dir_path $dir_name && cd ../../..

echo "--------------------------------------------------------------"
echo "----[PID] CI : preparing workspace: DONE ---------------------"
echo "--------------------------------------------------------------"
