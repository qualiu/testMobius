ShellDir=$(cd $(dirname $0) && pwd)
$ShellDir/csharp/build.sh
if [ $? -gt 0 ]; then
    exit
fi
cd $ShellDir/scala/ && mvn package
