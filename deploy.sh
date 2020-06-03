#!/bin/bash

if [ -n "$1" ]
then
    SOURCE=$1
    cd $SOURCE
else
 exit 0
fi

echo "-------"
echo "stop mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh stop"
./starting.sh stop

echo "-------"
echo "git checkout master:"
git checkout master

echo "-------"
echo "git status:"
git status

echo "-------"
echo "git pull:"
git pull

echo "-------"
echo "cd $SOURCE/client/admin"
cd $SOURCE/client/admin

echo "-------"
echo "delete folder:"
echo "rm -rf $SOURCE/client/admin/dist"
rm -rf $SOURCE/client/admin/dist

echo "-------"
echo "npm install"
npm install

echo "-------"
echo "npm run build"
npm run build

echo "-------"
echo "delete content of public (exclude dir 'forum'):"
echo "rm -rf $SOURCE/public/*"
find $SOURCE/public -maxdepth 1 -mindepth 1 -not -name forum -exec rm -rf {} \;

echo "-------"
echo "copy dist to public:"
echo "cp -a $SOURCE/client/admin/dist/. $SOURCE/public"
cp -a $SOURCE/client/admin/dist/. $SOURCE/public

echo "-------"
echo "remove .lock:"
echo "rm $SOURCE/log/deploy.lock"
rm $SOURCE/log/deploy.lock

echo "Finish"

echo "-------"
echo "Start mojo daemon:"
echo "cd $SOURCE"
cd $SOURCE
echo "./starting.sh start"
./starting.sh start

if [ "$?" != "0" ] ; then
    echo
    echo "ERROR: Execution failed."
    exit 2
fi
