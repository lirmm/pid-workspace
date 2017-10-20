
#!/bin/bash

# updating binaries
git lfs pull origin master

# build the site
cd build && cmake --build . --target build && cd ..

