# CakePHP 2.0 + Git starter script

A small shell script to bake a new CakePHP project, initialize it as a git repository, and install the cake core as its submodule.

## Download

https://github.com/tkyk/cakephp-git-starter


## Requirements
-  CakePHP 2.x
-  Git >= 1.5.3
-  *NIX environment (which, wget, sed, etc.)


## Usage

    $ ./cakephp_git_starter.sh /path/to/new_project 2.0.6
    
    # This will build the following directory structure:
    # /path/to/new_project
    #     + app
    #           + Controller
    #           + Model
    #           + ...
    #     + cakephp (managed as a submodule and refering to 2.0.6)
    #           + lib
    #           + app
    #           + vendors
    #           + ...


The newly created directory has been initialized as a git repository, so you are ready to make a first commit to it.

    $ cd /path/to/new_project
    $ git status
    $ git commit -m 'Initial commit'

A shortcut script to the cake shell is created in bin/.

    $ ./bin/cake bake database

If you want to switch the cake core versions, checkout the appropriate tag in the submodule.

    $ cd /path/to/new_project/cakephp
    $ git checkout 2.1.0-beta


## Internals

This script runs as follows:

1.  Clones the official cakephp repository into ~/.submodule-cakephp
2.  Checks out the specified tag in (1)
3.  Invokes `bake project $project_path/app`
4.  Initializes $project_path as a git repository
5.  Adds the official cakephp repository as a submodule located in $project_path/cakephp
6.  Checks out the specified tag in (5)
7.  Updates app/webroot/{index,test}.php to correct CAKE_CORE_INCLUDE_PATH
8.  Adds empty files so that git can hold the app/ directory structure
9.  Creates .gitignore, bin/cake, etc.

At the second time or later, it skips the (1) step and executes `git pull` instead.
