
#!/bin/bash

cd build

cmake --build . --target build -- force=true

BUILD_RES=$?

cd ..

if [ $BUILD_RES != 0 ]; then
  exit $BUILD_RES
fi
