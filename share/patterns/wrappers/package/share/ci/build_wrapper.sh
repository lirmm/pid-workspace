
#!/bin/bash

# build the site
cd build && cmake --build . --target build version="$1" && cd ..
