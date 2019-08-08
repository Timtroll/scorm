#!/bin/bash

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
echo "cd ./client/admin"
cd ./client/admin

echo "-------"
echo "delete folder /home/troll/scorm/client/admin/dist"
rm -rf /home/troll/scorm/client/admin/dist

echo "-------"
echo "yarn run build"
yarn run build

echo "-------"
echo "delete content of public"
rm -rf /home/troll/workspace/scorm/public/*

echo "-------"
echo "yarn run build"
cp -a /home/troll/scorm/client/admin/dist/. /home/troll/scorm/public


# if [ "$?" != "0" ] ; then
#     echo
#     echo "ERROR: Execution failed."
#     exit 2
# fi
