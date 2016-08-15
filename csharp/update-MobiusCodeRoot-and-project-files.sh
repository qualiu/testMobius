echo "Will set MobiusCodeRoot=$1 , current=$MobiusCodeRoot : root directory of source code that cloned from Mobius github, and update the settings in project files."
if [ -z "$1" ]; then
	echo "Usage   : $0  MobiusCodeRoot"
	echo "Example : $0  /diskExt/msgit/Mobius-1.6.200-PREVIEW-1"
	exit 5
fi

ShellDir=$(cd $(dirname $0) && pwd)
export MobiusCodeRoot=$1
cd $MobiusCodeRoot && export MobiusCodeRoot=$PWD
cd $ShellDir

$ShellDir/../set-shell-executable.sh
source ~/.bashrc

replacedCount=0
lzmw -p $ShellDir/allSubmitingTest.sln -it "(?<=\")\S+([\\\\/]+csharp[\\\\/]+(?:Adapter|Worker)[\\\\/]+Microsoft)" -o '$MobiusCodeRoot$1' -R -c
replacedCount=$(($replacedCount + $?))


lzmw -rp $ShellDir -f "\.csproj$|allSubmitingTest.sln$" -it "[^<>]*(</MobiusCodeRoot>)" -o '\$MobiusCodeRoot$1' -R -c
replacedCount=$(($replacedCount + $?))

lzmw -p $ShellDir/allSubmitingTest.sln -ix '$MobiusCodeRoot' -o "$MobiusCodeRoot" -R -c
replacedCount=$(($replacedCount + $?))

lzmw -rp $ShellDir -f "\.csproj$" -it "(?<=\")\S+([\\\\/]+csharp[\\\\/]+(?:Adapter|Worker)[\\\\/]+Microsoft)" -o '\$(MobiusCodeRoot)$1' -R -c
replacedCount=$(($replacedCount + $?))

lzmw -rp $ShellDir -f "\.csproj$" -it '\$MobiusCodeRoot</MobiusCodeRoot>' -o "$MobiusCodeRoot</MobiusCodeRoot>" -R -c
replacedCount=$(($replacedCount + $?))

lzmw -rp $ShellDir -f "\.csproj$" -ix '<ProjectReference Include="$(MobiusCodeRoot)' -o "<ProjectReference Include=\"$MobiusCodeRoot" -R -c
replacedCount=$(($replacedCount + $?))

echo "replacedCount=$replacedCount"
if [ $replacedCount -gt 0 ]; then
    lzmw -rp $ShellDir -f "\.csproj$|allSubmitingTest.sln$" -it "$MobiusCodeRoot|\$\(MobiusCodeRoot\)|[^<>]*(</MobiusCodeRoot>)|(?<=\")\S+(?=[\\\\/]+csharp[\\\\/]+(?:Adapter|Worker)[\\\\/]+Microsoft)" -e "^<MobiusCodeRoot\s*\w*"
fi
