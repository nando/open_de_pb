#!/bin/bash
def_device=/dev/ttyUSB0

device=${1:-$def_device}

for name in *+
do
  if [ "$name" != "to_compeo.sh" ]
  then  
    echo "compeowpt -d $device setroute $name"
    compeowpt -d $device setroute $name < $name
  fi
done
