ShellDir=$(dirname $0)
sh $ShellDir/csharp/build.sh
cd $ShellDir/scala/ && mvn package
