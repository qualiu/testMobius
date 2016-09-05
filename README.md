# Mobius Test for user scenario and integration
1. Supplement to unit test.
2. Easy to be used to construct user scenario test and test groups.
3. Fast validation for bugs and fixes.
4. Memory and performance test.
5. Discover potential defects in advance.

## Introduction : (additional [usages-and-cases.md](https://github.com/qualiu/testMobius/blob/master/usages-and-cases.md) )
- All actions (build/test/log-processing) has automation scripts.
- All scripts, tools and test-exe/jar/py has *usages* and *examples* (run them without parameters will display).
* Assume `{testMobius}` = [testMobius](https://github.com/qualiu/testMobius) source code directory you cloned from here. (May be omitted at bellow)
* Assume `{Mobius}` = [Mobius source code](https://github.com/Microsoft/Mobius) directory.

1. `{testMobius}\csharp` : C# Spark test tool and test code.
2. `{testMobius}\scala` : Scala Spark test (for comparison)* :  
3. `{testMobius}\python` : Python Spark test
4. `{testMobius}\tools` : Common/Basic tools/scripts for utility and automation.
5. `{testMobius}\scripts` : Specific/Advanced scripts : extract cluster jobs info, collect job logs, extract/statistic logs, etc.

## Build and Run
Windows use `*.cmd`,  Linux use `*.sh` to Build and Clean.
### 1. Prerequisite
* Reference [Mobius source code](https://github.com/Microsoft/Mobius) : depends on `{Mobius}` build. 
  - `{Mobius}\build\build.cmd`
  - `{testMobius}\update-MobiusCodeRoot-and-project-files.bat {Mobius}` or `SET MobiusCodeRoot={Mobius}` 
    *  if `{testMobius}` is in `{Mobius}` it will automatically use `{Mobius}` as `%MobiusCodeRoot%`if not set.
  - `{testMobius}\Build.cmd` or `{testMobius}\csharp\Build.cmd` if only build C#.


### 2. Build
Just run :  `Build.cmd` to build all (C#/Scala) or `csharp\Build.cmd` , `scala\Build.cmd`; or just build csharp Debug version : `csharp\Build.cmd Debug`
* `csharp\Build.cmd` will update C# project files like `.sln` and `.csproj`.
* You can use `csharp\restore-to-MobiusCodeRoot-in-project-files.bat` **before git committing**.
* If you have set `%MobiusCodeRoot%`,  `csharp\Build.cmd` will use `%MobiusCodeRoot%`.
* Or else if `{testMobius}` is in `{Mobius}`, build will use `{Mobius}` as `%MobiusCodeRoot%` (**but not set**).
* Or else `csharp\Build.cmd` will tell you to set `%MobiusCodeRoot%`.
* Also can use `csharp\update-MobiusCodeRoot-and-project-files.bat` then `{MobiusCodeRoot}` is defined and set.
 
### 3. Clean
 Just run :  `Clean.cmd` to clean ,  or `csharp\Clean.cmd`  , `	scala\Clean.cmd`
### 4. Run local mode test (Spark submit)
Should run  ```{Mobius\build\localmode\RunSamples.cmd``` first if run local mode tests.

## Use it for test 
* All test have automation script (*.bat/*.sh) in the test code directory. Typically they're named "test.bat/test.sh".
* All test and data generating tools (*.exe) are self-descriptive , just like test.bat , 
run them without any arguments will show you the usage (command options).
* All data generating tools are in `{CodeRoot}\csharp` , such as :
 - `SourceLinesSocket`: generate data for Socket Streaming test.
 - `ReadWriteKafka` : generate data for Kafka Streaming test.  ("Read" displays the Kafka data for a glance.)

#### 1. Data generating in advance or during runtime :
 * Call data generating tools like "`SourceLinesSocket`" and "`ReadWriteKafka`" mentioned above.
 * Example to use `ReadWriteKafka.exe` : `csharp\kafkaStreamTest\create-2-topics-for-test.bat`
 * Example to use `SourceLinesSocket.exe` : `csharp\testKeyValueStream\test-by-starting-socket.bat`

#### 2.  Single and simple test 
 * Call `test.bat` `test-***.bat` in each catagory (in `csharp\xxxx` directory)
 * Set variables by the indication of the scripts or Moidify the script.

#### 3.  Group test
 * Call the test exe with different arguments as you want.
 * Write the command calls in a file as group test.
 * Use and follow the `test.bat` as tools and examples.


## Extend and add more test
1. Add test category
   Follow examples of : 
   * Socket streaming : `csharp/testKeyValueStream`
   * Kafka streaming : `csharp/kafkaStreamTest`
2. Add test cases
  * Follow examples of WindowSlideTest and  UnionTopicTest with 
 `csharp/kafkaStreamTest/kafkaStreamTest.cs`

## Supplement
* Some scripts are optional and irrelevant to the project, like `get-changed-files.bat` , `reset-ignore-files.bat`, etc. for code commiting/checking operations etc.(git related).
* As they're just some utilities and depend tools in {CodeRoot}/tools . You can copy them to your common tool directory or create a tool directory and add to PATH, if you've interest with `psall.bat'` and `pskill.bat` , etc.
* Follow additional [usages-and-cases.md](https://github.com/qualiu/testMobius/blob/master/usages-and-cases.md) , there's a chapter "`A Full Process example : Pull code, Build, Test on local or cluster`".
