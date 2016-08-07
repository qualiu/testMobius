# Mobius Test for user scenario and integration
1. Supplement to unit test.
2. Easy to be used to construct user scenario test and test groups.
3. Fast validation for bugs and fixes.
4. Memory and performance test.
5. Discover potential defects in advance.

## Introduction
1. All build/test have automation script (*.bat) in the test code directory. Typically they're named "test.bat".
2. All test and data generating tools (*.exe) are self-descriptive , just like test.bat , 
run them without any arguments will show you the usage (command options).
2. All data generating tools are in {CodeRoot}/test/csharp , such as :
 - SourceLinesSocket: generate data for Socket Streaming test.
 - ReadWriteKafka : generate data for Kafka Streaming test.  ("Read" displays the Kafka data for a glance.)
3. Some scripts are optional and irrelevant to the project, like get-changed-files.bat , reset-ignore-files.bat, etc. 
As they're just some utilities and depend tools in {CodeRoot}/test/tools . You can copy them to your common tool directory or create a tool directory and add to PATH, if you've interest.

## Build and Run
1. Prerequisite
  - should build Mobius first for compilation:  ```{Mobius}\build\build```
  - should run Mobius samples before run this test : ```{Mobius\build\localmode\RunSamples.cmd```
  
2. Build this test project
 just run : `test\csharp\Build.cmd`
3. Clean this test project
 just run : `test\csharp\Clean.cmd`

## Use it for test 
1. Data generating in advance or during runtime :
 * Call tools like "SourceLinesSocket" and "ReadWriteKafka" mentioned above.
 * Example to use ReadWriteKafka.exe :
 `test\csharp\kafkaStreamTest\create-2-topics-for-test.bat`
2.  Single test 
 * Call test.bat in each catagory.
3.  Group test
 * Call the test exe with different arguments as you want.
 * Write the command calls in a file as group test.
 * Use and follow the test.bat as tools and examples.

## Extend and add more test
1. Add test category
   Follow examples of : 
   * Socket streaming : `test/csharp/testKeyValueStream`
   * Kafka streaming : `test/csharp/kafkaStreamTest`
2. Add test cases
  * Follow examples of WindowSlideTest and  UnionTopicTest with 
 `test/csharp/kafkaStreamTest/kafkaStreamTest.cs`
