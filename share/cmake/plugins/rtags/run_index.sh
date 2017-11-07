#!/bin/sh

# make sure to remove any previously created file to index the new one
rm $1

# wait until the file is created
while [ ! -f $1 ]
do
  sleep 1
done

#
exec rc -J $1
