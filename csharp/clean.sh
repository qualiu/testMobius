#!/bin/bash
ShellDir=$(cd $(dirname $0) && pwd)
for g in $(find $ShellDir -type d -name bin); do
  rm -rf "$g"
done

for g in $(find $ShellDir -type d -name obj); do
  rm -rf "$g"
done

