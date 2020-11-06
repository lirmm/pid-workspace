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
  cd binaries && git clone git@gite.lirmm.fr:pid/pid-workspace.git && cd ..
else
  cd binaries/pid-workspace && git pull -f official master && cd ../..
fi

# symlinking all CI scripts from the workspace
chmod 700 binaries/pid-workspace/cmake/patterns/frameworks/ci/configure_workspace.sh
ln -s binaries/pid-workspace/cmake/patterns/frameworks/ci/configure_workspace.sh ./configure_workspace.sh
chmod 700 binaries/pid-workspace/cmake/patterns/frameworks/ci/build_framework.sh
ln -s binaries/pid-workspace/cmake/patterns/frameworks/ci/build_framework.sh ./build_framework.sh
chmod 700 binaries/pid-workspace/cmake/patterns/frameworks/ci/publish_framework.sh
ln -s binaries/pid-workspace/cmake/patterns/frameworks/ci/publish_framework.sh ./publish_framework.sh

# previous to an execution we need to set a link into the workspace that point to the current package
dir_name=${dir_name/"-site"/""}
dir_name=${dir_name/"-pages"/""}
dir_name=${dir_name/"-framework"/""}
cd binaries/pid-workspace/sites/frameworks && ln -s $dir_path $dir_name && cd ../../../..
