
#!/bin/bash

# updating binaries
git lfs fetch origin master

# build the site
cd build && cmake --build . --target build && cd ..

