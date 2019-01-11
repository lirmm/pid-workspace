#!/bin/bash

if [ "$PACKAGE_HAS_SITE" = true ] ; then
  cd build && version=$1 cmake --build . --target site && cd ..
fi
