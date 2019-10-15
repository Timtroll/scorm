#!/bin/bash

SOURCE=`pwd`
echo $SOURCE

# echo "-------"
# echo "stop mojo daemon:"
# echo "cd $SOURCE"
# cd $SOURCE
# echo "./starting.sh stop"
# ./starting.sh stop

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
echo "yarn run build"
yarn run build

echo "-------"
echo "delete content of public (exclude dir 'forum'):"
echo "rm -rf $SOURCE/public/*"
find /home/troll/workspace/scorm/master/public/ -maxdepth 1 -mindepth 1 -not -name forum -exec rm -rf {} \;

echo "-------"
echo "copy dist to public:"
echo "cp -a $SOURCE/client/admin/dist/. $SOURCE/public"
cp -a $SOURCE/client/admin/dist/. $SOURCE/public

echo "-------"
echo "remove .lock:"
echo "rm $SOURCE/log/deploy.lock"
rm $SOURCE/log/deploy.lock

echo "Finish"

# echo "-------"
# echo "restart mojo daemon:"
# echo "cd $SOURCE"
# cd $SOURCE
# echo "./starting.sh restart"
# ./starting.sh start



# if [ "$?" != "0" ] ; then
#     echo
#     echo "ERROR: Execution failed."
#     exit 2
# fi
