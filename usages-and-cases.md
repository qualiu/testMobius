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
  * Socket : `scripts\memory\local-Riosocket-test-by-socket.bat 1`
  * Kafka : `scripts\memory\local-Riosocket-kafka-test.bat 1`



