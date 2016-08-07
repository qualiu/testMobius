ShellDir=$(dirname $0)
sh $ShellDir/csharp/clean.sh
cd $ShellDir/scala/ && mvn clean
