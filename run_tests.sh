#!/bin/bash

SOURCE=`pwd`
echo $SOURCE

echo "-------"
echo "start mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh start"
./starting.sh start

# run tests
prove t/*/*.t

echo "-------"
echo "stop mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh stop"
./starting.sh stop