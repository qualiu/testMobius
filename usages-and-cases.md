# Accumulating cases and usages
* Assume `{testMobius}` = [testMobius](https://github.com/qualiu/testMobius) source code directory you cloned from here.
* Assume `{Mobius}` = [Mobius source code](https://github.com/Microsoft/Mobius) directory.

Tips :
- Add to %PATH% to use some nice tools with one of following commands:
 * `{testMobius}\tools\check-set-tool-path.bat` 
 * `SET PATH=%PATH%;{testMobius}\tools`

## Tool usage example :
1. Common usage :
 * Find process (like txtStreamTest.exe and java.exe ): `psall -it "txt\w+Test.exe|java.exe\s+.*streamTest" `
 * Kill process (like txtStreamTest.exe and java.exe ): `pskill -it "txt\w+Test.exe|java.exe\s+.*streamTest" `
 * File content searching/replacing : (almost in all scripts in fact)
   - `update-MobiusCodeRoot-and-project-files.bat`
    - `set-bat-windows-line-ending.bat`
    - `check-bat-echo-on.bat`
 * Git operation assitance:
   - `reset-ignore-files.bat`
    - `get-changed-files.bat`
  
2. Get Yarn apllication time cost
  ```
  /cygdrive/d/msgit/testMobius/scripts/shell/get-yarn-app-time-cost.sh 248 249
  
  application_1469835824077_0248 SUCCEEDED 674s no-buf-perf-run-10__-ne-100_-ec-28_-em-30G_-dm-32G_ : http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0248
  application_1469835824077_0249 SUCCEEDED 673s no-buf-perf-run-10__-ne-100_-ec-28_-em-30G_-dm-32G_ : http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0249
```
3. Collect logs : one command to get all log pathes on different machines to run on one AP machine
   ```
   /cygdrive/d/msgit/testMobius/scripts/shell/get-yarn-app-log-path.sh 248 249
   
  robocopy \\BN2SCH040451519\data\yarn\nm-log-dir\application_1469835824077_0248 d:\perfBenchLogs\application_1469835824077_0248--BN2SCH040451519 /E /NJH /NJS /NDL /XO
  robocopy \\BN2SCH050531724\data\yarn\nm-log-dir\application_1469835824077_0249 d:\perfBenchLogs\application_1469835824077_0249--BN2SCH050531724 /E /NJH /NJS /NDL /XO
  ``` 
 
4. Extract logs:
 ```
 d:\msgit\testMobius\scripts\bat\extract-perf-test-results.bat D:\mobius\perfBenchLogs Median
 
 application_1469835824077_0248  RunRDDMaxDeletionsByUser = 11   RunRDDLineCount = 5     RunDFMaxDeletionsByUser = 29    RunDFLineCount = 12
 application_1469835824077_0249  RunRDDMaxDeletionsByUser = 11   RunRDDLineCount = 4     RunDFMaxDeletionsByUser = 29    RunDFLineCount = 13
 application_1469835824077_0251  RunRDDMaxDeletionsByUser = 161  RunRDDLineCount = 32    RunDFMaxDeletionsByUser = 589   RunDFLineCount = 264
 application_1469835824077_0252  RunRDDMaxDeletionsByUser = 166  RunRDDLineCount = 34    RunDFMaxDeletionsByUser = 594   RunDFLineCount = 266
```

## A Full Process example : Pull code, Build, Test on local or cluster
### 1.Pull source and build {Mobius} 
* Pull source code from master or git pull request, Assume `d:\msgit\revMobius` as your local Moibius direcotry.
* Build {Mobius}
```
d:\msgit\revMobius>
git checkout master
git pull upstream master
git pull --squash https://github.com/hebinhuang/Mobius SocketOptim
build\Build.cmd

```
### 2.Build {testMobius}
* Use the above Mobius code directory(`d:\msgit\revMobius`)
* You can only build "release" 
```
d:\msgit\testMobius>
csharp\update-MobiusCodeRoot-and-project-files.bat d:\msgit\revMobius
csharp\Build.cmd release
```
### 3.Use {testMobius} to validate or test
* Just run the test tool (such as `test.bat`) without parameters will show you the usage/example/instruction.
* You can set variables like `%SparkOptions%`, `%MobiusTestArgs%` in advance, so that needless to modify the `test.bat`.

#### 1.Validate on local
* Just run test like following, if you have just build it and stay on the same cmd window (so environments kept):
```
d:\msgit\testMobius\csharp\txtStreamTest\test.bat d:\csv-directory
d:\msgit\testMobius\scripts\memory\local-Riosocket-test-by-socket.bat 1
```
* Set environment before test, with one of following if no `%MobiusCodeRoot%` or `%SPARK_XXX%`
 * `set MobiusCodeRoot={Mobius}`
 * `d:\msgit\testMobius\csharp\update-MobiusCodeRoot-and-project-files.bat d:\msgit\revMobius`

#### 2. Validate on cluster
* In your local Spark client (Assume `d:\mobius\Spark0725`) , initialize environment (assume `start.bat`)
* Set Spark submit parameters `SparkOptions` , a {testMobius} common variable used in many scripts such as `csharp\txtStreamTest\test.bat`
```
d:\mobius\Spark0725>
start.bat
set SparkOptions=--master yarn-cluster --conf spark.mobius.CSharp.socketType=Rio --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 

d:\msgit\testMobius\csharp\txtStreamTest\test.bat hdfs:///common/AdsData/MUID
```

## Usage-Example/History-Cases 
1. sparkclr-submit passing arguments to spark-submit
 - Issue items : (failed at submiting)
   * Arguments contain special characters will be cut.
    * Spark-2.0 add addtional quotes cause additional double qutoes error.
 - Repro/Validate :
   * ```csharp\testArgsQuotes\test.bat Pi* d:\tmp```
    * ```csharp\testArgsQuotes\test.bat "jdbc:mysql://localhost:3306/lzdb?user=guest&password=abc123" tb1```

2. Streaming exception : "System.Exception: unexpected valueLength: -1"   
 - Issue occur condition :  WindowDuration >= 5 * SlideDuration
 - Repro/Validate:
  ```
  csharp\testKeyValueStream\test-by-starting-socket.bat -p 9112 -d 1 -w 5 -s 1
  ```
  
3. Performance issue :
  ```
  set SparkOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20  --conf spark.mobius.streaming.kafka.CSharpReader.enabled=true
  csharp\txtStreamTest\test.bat hdfs:///common/AdsData/MUID
  ```

4. Performance benchmark comparison on Yarn cluster
  ```
  scripts\bat\submit-perf-test-comparison.bat
  ```
5. RIOSocket test and with memory test
  - You can set SparkOptions=*** (following scripts will show you) with/without : `--conf spark.mobius.CSharp.socketType=Rio`
  - You can clean and build specified type : `csharp\Clean.cmd & csharp\Build.cmd Release x64`
  - You can `set TestExePath=xxxx\bin\Release` or `set TestExePath=xxxx\bin\x64\Release`
  * Start Socket and submit test: [`scripts\memory\local-Riosocket-test-by-socket.bat 1`](https://github.com/qualiu/testMobius/blob/master/scripts/memory/local-Riosocket-test-by-socket.bat)
  * Download/init/start Kafka and submit test: [`scripts\memory\local-Riosocket-kafka-test.bat 1`](https://github.com/qualiu/testMobius/blob/master/scripts/memory/local-Riosocket-kafka-test.bat)
  - You can also directly use the exe with wrapper(.bat) and see the usage (just run without parameters):
    * [csharp\kafkaStreamTest\test.bat as wrapper of kafkaStreamTest.exe to submit on local or cluster ](https://github.com/qualiu/testMobius/blob/master/csharp/kafkaStreamTest/test.bat)
    * [kafkaStreamTest.exe UnionTopicTest](https://github.com/qualiu/testMobius/blob/master/csharp/kafkaStreamTest/UnionTopicTest.cs)
    * [kafkaStreamTest.exe WindowSlideTest](https://github.com/qualiu/testMobius/blob/master/csharp/kafkaStreamTest/WindowSlideTest.cs)
    * [csharp\testKeyValueStream\test.bat as wrapper of testKeyValueStream.exe to submit on local or cluster](https://github.com/qualiu/testMobius/blob/master/csharp/testKeyValueStream/test.bat)
    * [testKeyValueStream.exe](https://github.com/qualiu/testMobius/blob/master/csharp/testKeyValueStream/ArgOptions.cs)
    * [SourceLinesSocket.exe as Socket source](https://github.com/qualiu/testMobius/blob/master/csharp/SourceLinesSocket/PowerArgOptions.cs)
    
6. Local debug mode experience example with RIOSocket test in Visual Studio
  * Assume that you've build {Mobius} source
  * Now build {testMobius}, start socket source, submit test, and experience debug mode in Visual Studio :
  ```
  csharp\update-MobiusCodeRoot-and-project-files.bat {Mobius}
  csharp\Clean.cmd
  csharp\Build.cmd Debug
  
  csharp\SourceLinesSocket\bin\Debug\SourceLinesSocket.exe -Port 9112 -RunningSeconds 900
  
  set SparkOptions=--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g --conf spark.mobius.CSharp.socketType=Rio
  
  scripts\xtra\local-mode-debug-testKeyValue-socket.bat -p 9112
  ```
  * Open csharp\allSubmitingTest.sln In Visual Studio :
    - Set as StartUp Project : testKeyValueStream.csproj
     - Menu "Project" -> "testKeyValueStream properties" -> Debug -> Command line args : -p 9112 
  * Notes: 
    - You can add and change the parameters, read the usages just run without parameters : `SourceLinesSocket.exe`  or `csharp\testKeyValueStream\bin\Debug\testKeyValueStream.exe` or `csharp\testKeyValueStream\test.bat`
    - In fact, there's a tool : [scripts\tool\set-debug-mode-path-port.bat](https://github.com/qualiu/testMobius/blob/master/scripts/tool/set-debug-mode-path-port.bat) to Add/Change/Uncomment path and port settings. You can use it then submit your job, start Visual Studio.
