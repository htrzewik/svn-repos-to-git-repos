#!/bin/sh
scriptdir=`pwd`
project=$1 # take from argument 1
svnbase=${2:-`grep -m1 -v ^# default_svnbase`} # take SVNBASE from file if not given in argument 2 
workdir=${3:-`grep -m1 -v ^# default_workdir`} # take workdir from file if not given in argument 3
svn_clone_subdir=svn-clone
svn_clone_extension=.svn
git_bare_subdir=git-bare
git_bare_extension=.git
git_test_subdir=git-test-workdir

clear
echo "** START *************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"

echo "=== Arguments ==="
echo workdir = $workdir
echo project = $project
echo svnbase = $svnbase

# === Preparations ===
rm -fr $workdir/$svn_clone_subdir # will delete previous work, you may commment out!
rm -fr $workdir/$git_bare_subdir # will delete previous work, you may comment out!
rm -fr $workdir/$git_test_subdir # will delete previous work, you may comment out!
mkdir -p $workdir/$svn_clone_subdir
mkdir -p $workdir/$git_bare_subdir
mkdir -p $workdir/$git_test_subdir

echo "=== SVN clone stage ==="
cd $workdir/$svn_clone_subdir
git svn clone $svnbase/$project --no-metadata -A $scriptdir/authors $workdir/$svn_clone_subdir/$project$svn_clone_extension

echo "=== GIT bare repo init stage ==="
cd $workdir/$git_bare_subdir
git init --bare $workdir/$git_bare_subdir/$project$git_bare_extension

echo "=== Reconfig stage ==="
cd $workdir/$svn_clone_subdir/$project$svn_clone_extension
git remote add bare $workdir/$git_bare_subdir/$project$git_bare_extension
git config remote.bare.push 'refs/remotes/*:refs/heads/*'

echo "=== Push to bare repo stage ==="
cd $workdir/$svn_clone_subdir/$project$svn_clone_extension
git push bare

echo "=== Rename branch stage ==="
cd $workdir/$git_bare_subdir/$project$git_bare_extension
git branch -m git-svn master

echo "=== GIT test clone stage =="
cd $workdir/$git_test_subdir
git clone $workdir/$git_bare_subdir/$project$git_bare_extension
