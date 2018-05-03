#!/bin/bash

cd build

#first time configuring with tests and examples enabled
cmake -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON -DADDITIONNAL_DEBUG_INFO=OFF -DBUILD_AND_RUN_TESTS=ON -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=ON -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=OFF -DGENERATE_INSTALLER=OFF -DWORKSPACE_DIR="../binaries/pid-workspace" ..

# always generating the dependencies file of the package
cmake --build . --target list_dependencies -- write_file=true

cd ..
