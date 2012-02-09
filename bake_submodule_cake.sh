#!/bin/sh

CAKEPHP_REPOSITORY=${CAKEPHP_REPOSITORY:-"git://github.com/cakephp/cakephp.git"}
CAKEPHP_SHARED_PATH=${CAKEPHP_SHARED_PATH:-~/.submodule_cakephp}

if [ $# -lt 2 ]; then
  echo "$0 <project_path> <cakephp_version>"
  exit
fi

which git > /dev/null || exit 1
project_path=$1
cakephp_version=$2

mkdir -p $project_path

if [ -d $CAKEPHP_SHARED_PATH ]; then
  cd $CAKEPHP_SHARED_PATH
  git checkout master
  git pull
else
  git clone $CAKEPHP_REPOSITORY $CAKEPHP_SHARED_PATH
  cd $CAKEPHP_SHARED_PATH
fi

git checkout $cakephp_version \
  && ./lib/Cake/Console/cake bake project $project_path/app \
  || exit 1

cd $project_path
git init
git submodule add $CAKEPHP_REPOSITORY cakephp
cd $project_path/cakephp
git checkout $cakephp_version
cd $project_path

sed -i -e "s/\/*define('CAKE_CORE_INCLUDE_PATH'.*/define('CAKE_CORE_INCLUDE_PATH', ROOT . DS . 'cakephp' . DS . 'lib');/" app/webroot/{index,test}.php
git add .gitmodules cakephp app
