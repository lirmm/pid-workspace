#!/bin/bash

#getting a clean public folder to put site into
if [ ! -d "./public" ]; then
  mkdir public
else
  cd public && rm -Rf * && cd ..
fi

cp -R ./build/generated/* ./public/

#specific cleaning action to remove generated /_site, if any
if [ -d "./public/_site" ]; then
  rm -Rf ./public/_site
fi
