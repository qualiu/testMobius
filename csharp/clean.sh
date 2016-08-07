#!/bin/bash
ShellDir=$(dirname $0)
for g in $(find $ShellDir -type d -name bin); do
  rm -rf "$g"
done

for g in $(find $ShellDir -type d -name obj); do
  rm -rf "$g"
done

