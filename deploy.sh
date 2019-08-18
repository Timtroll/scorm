#!/bin/bash

SOURCE=`pwd`
echo $SOURCE

echo "-------"
echo "git checkout master"
git checkout master

echo "-------"
echo "git checkout master"
git status

echo "-------"
echo "git pull"
git pull

echo "-------"
echo "cd $SOURCE/client/admin"
cd $SOURCE/client/admin

echo "-------"
echo "delete folder $SOURCE/client/admin/dist"
rm -rf $SOURCE/client/admin/dist

echo "-------"
echo "yarn run build"
yarn run build

echo "-------"
echo "delete content of public"
rm -rf $SOURCE/public/*

echo "-------"
echo "yarn run build"
cp -a $SOURCE/client/admin/dist/. $SOURCE/public

echo "-------"
echo "stop and start mojo daemon"
cd $SOURCE
$SOURCE/starting.sh stop
./starting.sh start

echo "Finish"
# if [ "$?" != "0" ] ; then
#     echo
#     echo "ERROR: Execution failed."
#     exit 2
# fi
