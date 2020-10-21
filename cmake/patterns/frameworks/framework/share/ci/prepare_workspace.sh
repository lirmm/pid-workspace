#!/bin/bash

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
  cd binaries && git clone git@gite.lirmm.fr:pid/pid-workspace.git && cd pid-workspace/build && cmake .. && cd ../../..
else
  cd binaries/pid-workspace/build && git pull -f official master && cmake -DFORCE_CONTRIBUTION_SPACE="$FRAMEWORK_CONTRIBUTION_SPACES" .. && cd ../../..
fi

# previous to an execution we need to set a link into the workspace that point to the current package
cd binaries/pid-workspace/sites/frameworks && ln -s $dir_path $dir_name && cd ../../../..
