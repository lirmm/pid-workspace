
#!/bin/bash

# setting the adequate path to the workspace

cmake -DWORKSPACE_DIR="../binaries/pid-workspace" ..

CONF_RES=$?

if [ $CONF_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : configuring the project: FAIL -----------------"
  echo "--------------------------------------------------------------"
  exit $CONF_RES
fi
