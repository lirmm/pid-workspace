
#!/bin/bash

# setting the adequate path to the workspace

cd build/ && cmake -DWORKSPACE_DIR="../binaries/pid-workspace" .. && cd ..

