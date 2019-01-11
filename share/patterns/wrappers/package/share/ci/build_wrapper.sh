
#!/bin/bash

# build the site
cd build && version=$1 cmake --build . --target build && cd ..
