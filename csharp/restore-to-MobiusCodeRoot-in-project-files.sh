ShellDir=$(cd $(dirname $0) && pwd)
export MobiusCodeRoot=$1
cd $MobiusCodeRoot && export MobiusCodeRoot=$PWD
cd $ShellDir

$ShellDir/../set-shell-executable.sh
source ~/.bashrc

replacedCount=0

lzmw -rp $ShellDir -f "\.csproj$" -it "[^<>]*(</MobiusCodeRoot>)" -o '..\\..\\..$1' -R -c
replacedCount=$(($replacedCount + $?))

lzmw -rp $ShellDir -f "\.csproj$|allSubmitingTest.sln$" -it "(?<=\")\S+([\\\\/]+csharp[\\\\/]+(?:Adapter|Worker)[\\\\/]+Microsoft)" -o '\$(MobiusCodeRoot)$1' -R -c
replacedCount=$(($replacedCount + $?))


if [ $replacedCount -gt 0 ]; then
    lzmw -rp $ShellDir -f "\.csproj$|allSubmitingTest.sln$" -it "$MobiusCodeRoot|\$\(MobiusCodeRoot\)|[^<>]*(</MobiusCodeRoot>)|(?<=\")\S+(?=[\\\\/]+csharp[\\\\/]+(?:Adapter|Worker)[\\\\/]+Microsoft)" -e "^<MobiusCodeRoot\s*\w*"
fi
