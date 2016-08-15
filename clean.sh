ShellDir=$(cd $(dirname $0) && pwd)
sh $ShellDir/csharp/clean.sh
cd $ShellDir/scala/ && mvn clean
