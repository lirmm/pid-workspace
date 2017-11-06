#!/bin/sh

# wait until the file is created
while [ ! -f $1 ]
do
  sleep 1
done

#
exec rc -J $1
