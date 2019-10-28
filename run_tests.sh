#!/bin/bash

SOURCE=`pwd`
echo $SOURCE

# добавить лоад конфига ?????

echo "-------"
echo "start mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh start"
./starting.sh start
sleep 1s

# run tests
prove t/*/*.t

echo "-------"
echo "stop mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh stop"
./starting.sh stop
sleep 1s