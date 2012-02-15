#!/bin/sh
#
# The MIT License (MIT)
# 
# Copyright (c) 2012 Takayuki Miwa
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

CAKEPHP_REPOSITORY=${CAKEPHP_REPOSITORY:-"git://github.com/cakephp/cakephp.git"}
CAKEPHP_SHARED_PATH=${CAKEPHP_SHARED_PATH:-~/.submodule_cakephp}

# file template
cakeshell()
{
  cat <<'_EOT_'
#!/bin/sh
ROOT_DIR=$(cd "$(dirname $0)/../"; pwd)
$ROOT_DIR/cakephp/lib/Cake/Console/cake -app $ROOT_DIR/app "$@"
_EOT_
}

if [ $# -lt 2 ]; then
  echo "$0 <project_path> <cakephp_version>"
  exit
fi

which git > /dev/null || exit 1
project_path=$1
cakephp_version=$2
mkdir -p $project_path

error()
{
  echo "[ERROR] Failed to $1" 1>&2
  exit 1
}

init_shared_repository()
{
  if [ -d $CAKEPHP_SHARED_PATH ]; then
    cd $CAKEPHP_SHARED_PATH
    git checkout master
    git pull
  else
    git clone $CAKEPHP_REPOSITORY $CAKEPHP_SHARED_PATH
    cd $CAKEPHP_SHARED_PATH
  fi

  git checkout $cakephp_version
}

bake_a_new_project()
{
  cd $CAKEPHP_SHARED_PATH
  ./lib/Cake/Console/cake bake project $project_path/app
}

add_core_as_a_submodule()
{
  cd $project_path
  git init
  git submodule add $CAKEPHP_REPOSITORY cakephp
  cd $project_path/cakephp
  git checkout $cakephp_version
}

fix_include_path()
{
  cd $project_path
  sed -i.bak -e "s/\/*define('CAKE_CORE_INCLUDE_PATH'.*/define('CAKE_CORE_INCLUDE_PATH', ROOT . DS . 'cakephp' . DS . 'lib');/" \
    app/webroot/{index,test}.php
  rm -f app/webroot/{index,test}.php.bak
}

copy_empty_files()
{
  cd $project_path/cakephp
  empty_files=$(find app/ -name empty | xargs echo)
  for src in $empty_files; do
    dest=../$src
    mkdir -p $(dirname $dest)
    cp $src $dest
  done
}

setup_git_repository()
{
  cd $project_path
  git add .gitmodules cakephp app

  mkdir bin
  cakeshell > bin/cake
  chmod +x bin/cake

  echo '/app/tmp/*' >> .gitignore
  echo '/app/Config/database.php' >> .gitignore

  git add bin .gitignore
}

init_shared_repository || error "initialize shared repository"
bake_a_new_project || error "bake a new project"
add_core_as_a_submodule || error "add CakePHP core as a git submodule"
fix_include_path || error "modify CAKE_CORE_INCLUDE_PATH"
copy_empty_files  || error "copy 'empty' files to app/"
setup_git_repository || error "setup git repository"
