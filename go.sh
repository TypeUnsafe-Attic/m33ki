#!/bin/sh
# ./go.sh directory mainFile.golo
# ie: ./go.sh samples/simple.react.wip simple.golo
RC=1
#trap "echo CTRL-C was pressed" 2
trap "exit 1" 2
while [ $RC -ne 0 ] ; do
   golo golo --classpath jars/*.jar --files libs/*.golo $1/app/*.golo $1/$2
   RC=$?
done
