#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing wrapper ----------------------------"
echo "--------------------------------------------------------------"

#getting the current platform and instance (if any) of the current runner
reg_expr_job="^build_wrapper_(.+)__(.+)__$"
platform=""

if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
    instance_job=${BASH_REMATCH[2]}
    platform_job=${BASH_REMATCH[1]}
    platform_job=${platform_job/plus/"+"}
    platform_job=${platform_job/plus/"+"}
    platform=$platform_job"__"$instance_job"__"
else

    reg_expr_job="^build_wrapper_(.+)$"
    if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
        platform=${BASH_REMATCH[1]}
        platform=${platform/plus/"+"}
        platform=${platform/plus/"+"}
    fi
fi

runner_only_binaries="true"
if [ "$platform" = "$PACKAGE_MAIN_PLATFORM" ]; then
  # the current runner is in charge of generating the static site
  runner_only_binaries="false"
elif [ "$PACKAGE_BINARIES_PUBLISHED" != true ]; then
  # the current runner may be only used to publish binaries but it does not do that
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : publishing wrapper: SKIPPED -------------------"
  echo "--------------------------------------------------------------"
  exit 0
fi

#now generate the site
SITE_RES=0
cd build
if [ "$PACKAGE_HAS_SITE" = true ] ; then
  only_binaries=$runner_only_binaries version=$1 cmake --build . --target site
fi
SITE_RES=$?
cd ..
if [ $SITE_RES != 0 ]; then
  echo "--------------------------------------------------------------"
  echo "----[PID] CI : publishing wrapper: FAIL (static site) --------"
  echo "--------------------------------------------------------------"
  exit $SITE_RES
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing wrapper: SUCCESS -------------------"
echo "--------------------------------------------------------------"
