#!/bin/bash

if [ "$PACKAGE_HAS_SITE" = true ] ; then
  cd build && cmake --build . --target site version="$1" && cd ..
fi
