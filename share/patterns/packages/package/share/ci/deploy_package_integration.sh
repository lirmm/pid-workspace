
#!/bin/bash


cd build

# build/debug/share/coverage.tgz
# build/release/share/staticchecks.tgz
if [ -d release/share/developper_info]
  cd release/share/developper_info && rm -Rf * && cd ../../..
else
  cd release/share && mkdir developper_info && cd ../..
fi

cp release/share/dependencies.txt release/share/developper_info

if [ "$PACKAGE_HAS_LIBRARIES" = true ] ; then

  if [ "$PACKAGE_HAS_TESTS" = true ] ; then
      # generating the coverage report of the package if there are tests on libraries
      cd debug/share && cmake -E tar cvz coverage.tgz coverage_report/ && mv coverage.tgz ../../release/share/developper_info && cd ../..
  fi

  cd release/share && cmake -E tar cvz staticchecks.tgz static_checks_report/ && mv staticchecks.tgz developper_info && cd ../..

fi

cd ..
