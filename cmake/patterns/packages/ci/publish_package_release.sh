#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing package ----------------------------"
echo "--------------------------------------------------------------"

if [ "$PACKAGE_HAS_SITE" = true ] ; then

  #getting the current platform and instance (if any) of the current runner
  reg_expr_job="^build_release_(.+)__(.+)__$"
  platform=""

  if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
      instance_job=${BASH_REMATCH[2]}
      platform_job=${BASH_REMATCH[1]}
      platform_job=${platform_job/plus/"+"}
      platform_job=${platform_job/plus/"+"}
      platform=$platform_job"__"$instance_job"__"
  else

      reg_expr_job="^build_release_(.+)$"
      if [[ $CI_JOB_NAME =~ $reg_expr_job ]]; then
          platform=${BASH_REMATCH[1]}
          platform=${platform/plus/"+"}
          platform=${platform/plus/"+"}
      fi
  fi

  site_publish_coverage=OFF
  site_publish_static_checks=OFF
  site_publish_api=OFF
  runner_only_binaries="true"
  if [ "$platform" = "$PACKAGE_MAIN_PLATFORM" ]; then
    # the current runner is in charge of generating the static site
    runner_only_binaries="false"

    # managing publication of developpers info
    if [ "$PACKAGE_DEV_INFO_PUBLISHED" = true ]; then
      site_publish_static_checks=ON
      if [ "$PACKAGE_HAS_TESTS" = true ] ; then
        site_publish_coverage=ON
      fi
    fi


    # publishing API doc as soon as there are libraries
    if [ "$PACKAGE_HAS_LIBRARIES" = true ]; then
      site_publish_api=ON
    fi
  fi

  BIN_ARCH_RES=0
  # 1) generating the binary archives (if necessary),this step is separate from following to avoid including in binary archive unecessary developper infos
  if [ "$PACKAGE_BINARIES_PUBLISHED" = true ]; then
    echo "[PID] CI : generating the binary archive..."
    cd build
    cmake -DBUILD_RELEASE_ONLY=OFF -DADDITIONAL_DEBUG_INFO=OFF -DBUILD_AND_RUN_TESTS=OFF -DENABLE_SANITIZERS=OFF -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=OFF -DBUILD_STATIC_CODE_CHECKING_REPORT=OFF -DGENERATE_INSTALLER=ON ..
    #build the package to get clean binary archives (without dev info)
    force=true cmake --build . --target build
    BIN_ARCH_RES=$?
    cd ..
  elif [ "$runner_only_binaries" = true ]; then
    #the runner does not publish pages, nor binaries !! => nothing to do
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : publishing package: SKIPPED -------------------"
    echo "--------------------------------------------------------------"
    exit 0
  fi

  # 2) configuring the package adequately to make it generate other artefacts included in the static site (API doc for instance)
  echo "[PID] CI : generating the static site..."
  cd build
  cmake -DBUILD_RELEASE_ONLY=OFF -DADDITIONAL_DEBUG_INFO=OFF -DBUILD_AND_RUN_TESTS=$site_publish_coverage -DRUN_TESTS_IN_DEBUG=$site_publish_coverage -DBUILD_COVERAGE_REPORT=$site_publish_coverage -DENABLE_PARALLEL_BUILD=ON -DBUILD_EXAMPLES=OFF -DBUILD_API_DOC=$site_publish_api -DBUILD_STATIC_CODE_CHECKING_REPORT=$site_publish_static_checks -DGENERATE_INSTALLER=OFF ..
  #build the package again to get all dev infos available
  force=true cmake --build . --target build
  BIN_FULL_INFO_RES=$?
  #build the static site
  only_binaries=$runner_only_binaries cmake --build . --target site
  SITE_RES=$?
  cd ..
  if [ $SITE_RES != 0 ]; then
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : publishing package: FAIL (static site) --------"
    echo "--------------------------------------------------------------"
  	exit $SITE_RES
  fi

  if [ $BIN_FULL_INFO_RES != 0 ]; then
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : publishing package: FAIL (dev info) -----------"
    echo "--------------------------------------------------------------"
  	exit $BIN_FULL_INFO_RES
  fi

  if [ $BIN_ARCH_RES != 0 ]; then
    echo "--------------------------------------------------------------"
    echo "----[PID] CI : publishing package: FAIL (bin archive) --------"
    echo "--------------------------------------------------------------"
    exit $BIN_ARCH_RES
  fi
fi
#Note: if no site to publish then nothing to do

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing package: SUCCESS -------------------"
echo "--------------------------------------------------------------"
