#!/bin/bash

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing static site ------------------------"
echo "--------------------------------------------------------------"

#getting a clean public folder to put site into
if [ ! -d "./public" ]; then
  mkdir public
else
  cd public && rm -Rf * && cd ..
fi
#if something generated then proceed
if [ -d "./build/generated" ]; then
  cp -R ./build/generated/* ./public/

  #specific cleaning action to remove generated /_site, if any
  if [ -d "./public/_site" ]; then
    rm -Rf ./public/_site
  fi
fi

echo "--------------------------------------------------------------"
echo "----[PID] CI : publishing static site: SUCCESS ---------------"
echo "--------------------------------------------------------------"
