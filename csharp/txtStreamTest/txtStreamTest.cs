using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using CommonTestUtils;
using Microsoft.Spark.CSharp.Core;

namespace TxtStreamTest
{
    class TxtStreamTest : BaseTestUtilLog<TxtStreamTest>
    {
        static void Main(string[] args)
        {
            Logger.LogInfo(EnvironmentInfo);
            var fileType = "*.csv";
            var testTimes = 1;
            var delaySeconds = 0;

            if (args.Length < 1 || args[0] == "-h" || args[0] == "--help")
            {
                Console.WriteLine("Usage     : {0}  Data-directory  [file-type: default = {1} ]  [Test-times: 1]  [Delay-run: 0 seconds]", ExePath, fileType);
                Console.WriteLine(@"Example-1 : {0}  D:\cosmos\download-stream\tenant\csv-2015-10-01  {1}", ExePath, fileType);
                Console.WriteLine(@"Example-2 : {0}  hdfs:///common/AdsData/MUID", ExePath);
                return;
            }

            var idx = 0;
            var dir = args[idx];
            fileType = TestUtils.GetArgValue(ref idx, args, nameof(fileType), fileType);
            testTimes = TestUtils.GetArgValue(ref idx, args, nameof(testTimes), testTimes);
            delaySeconds = TestUtils.GetArgValue(ref idx, args, nameof(delaySeconds), delaySeconds);

            var pathPattern = Path.Combine(dir, fileType);
            Logger.LogDebug("Will read text stream : {0}", pathPattern);

            if(delaySeconds > 0)
            {
                var waitBegin = DateTime.Now;
                var waitEnd = waitBegin + TimeSpan.FromSeconds(delaySeconds);
                var currentPID = Process.GetCurrentProcess().Id;
                Logger.LogWarn($"Will wait {delaySeconds} seconds for you to debug this process : please attach PID {currentPID} before {waitEnd}");
                Thread.Sleep(delaySeconds * 1000);
            }

            var beginTime = DateTime.Now;
            for(var k=1; k <= testTimes; k++)
            {
                StartOneTest(pathPattern, k, testTimes);
                Logger.LogInfo($"End test[{k}]-{testTimes} : {GetCurrentProcessInfo()}");
            }

            Logger.LogInfo($"Finished all tests, testTimes = {testTimes}, used time = {(DateTime.Now - beginTime).Seconds} s = {DateTime.Now - beginTime}, read data = {pathPattern}.");
            Logger.LogInfo($"Final process info : {GetCurrentProcessInfo()}");
        }

        static void StartOneTest(string pathPattern, int times, int totalTimes)
        {
            var beginTime = DateTime.Now;
            Logger.LogInfo($"Begin test[{times}]-{totalTimes} , will read : {pathPattern}");
            var sc = new SparkContext(new SparkConf());
            var mappingRDD = sc.TextFile(pathPattern).Map<string>(line => line).Cache();

            Logger.LogInfo("RDD count = {0}", mappingRDD.Count());

            mappingRDD.Unpersist();
            var endTime = DateTime.Now;
            Logger.LogInfo($"End test[{times}]-{totalTimes} of {typeof(TxtStreamTest)}, used time = {endTime - beginTime} = {(endTime - beginTime).TotalSeconds} s. read = {pathPattern}");

            sc.Stop();
        }
    }
}
