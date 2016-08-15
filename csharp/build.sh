#!/bin/bash
ShellDir=$(cd $(dirname $0) && pwd)
cd $ShellDir

CppDll=NoCpp
XBUILDOPT=/verbosity:minimal

if [ -z $builduri ]; then
  builduri=build.sh
fi

PROJ_NAME=allSubmitingTest
PROJ=$PROJ_NAME.sln

echo "===== Building $PROJ ====="

function error_exit() {
  if [ -z $STEP ]; then
    STEP=$CONFIGURATION 
  fi
  echo "===== Build FAILED for $PROJ -- $STEP with error $RC - CANNOT CONTINUE ====="
  exit 1
}

echo "Restore NuGet packages ==================="
STEP=NuGet-Restore

nuget restore

RC=$? && [ $RC -ne 0 ] && error_exit

echo "Build Debug =============================="
STEP=Debug

CONFIGURATION=$STEP

STEP=$CONFIGURATION

xbuild "/p:Configuration=$CONFIGURATION;AllowUnsafeBlocks=true" $XBUILDOPT $PROJ
RC=$? && [ $RC -ne 0 ] && error_exit
echo "BUILD ok for $CONFIGURATION $PROJ"

echo "Build Release ============================"
STEP=Release

CONFIGURATION=$STEP

xbuild "/p:Configuration=$CONFIGURATION;AllowUnsafeBlocks=true" $XBUILDOPT $PROJ
RC=$? && [ $RC -ne 0 ] && error_exit
echo "BUILD ok for $CONFIGURATION $PROJ"

#
# The plan is to build SparkCLR nuget package in AppVeyor (Windows). 
# Comment out this step for TravisCI (Linux) for now.
#
# if [ -f "$PROJ_NAME.nuspec" ];
# then
#   echo "===== Build NuGet package for $PROJ ====="
#   STEP=NuGet-Pack
# 
#   nuget pack "$PROJ_NAME.nuspec"
#   RC=$? && [ $RC -ne 0 ] && error_exit
#   echo "NuGet package ok for $PROJ"
# fi

echo "===== Build succeeded for $PROJ ====="
