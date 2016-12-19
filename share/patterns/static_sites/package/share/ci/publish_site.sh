#!/bin/bash

#getting a clean public folder to put site into
if [ ! -d "./public" ]; then
  mkdir public
else
  cd public && rm -Rf * && cd ..
fi

cp -R ./build/generated/* public 


