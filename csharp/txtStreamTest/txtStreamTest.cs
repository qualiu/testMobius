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
            var testIntervalSeconds = 0;
            var delaySeconds = 0;

            if (args.Length < 1 || args[0] == "-h" || args[0] == "--help")
            {
                Console.WriteLine("Usage     : {0}  Data-directory  [file-type: default = {1} ]  [Test-times: 1] [Test-interval: 0 seconds] [Delay-start: 0 seconds]", ExePath, fileType);
                Console.WriteLine(@"Example-1 : {0}  D:\cosmos\download-stream\tenant\csv-2015-10-01  {1}", ExePath, fileType);
                Console.WriteLine(@"Example-2 : {0}  hdfs:///common/AdsData/MUID", ExePath);
                return;
            }

            var idx = 0;
            var dir = args[idx];
            fileType = TestUtils.GetArgValue(ref idx, args, nameof(fileType), fileType);
            testTimes = TestUtils.GetArgValue(ref idx, args, nameof(testTimes), testTimes);
            testIntervalSeconds = Math.Max(0, TestUtils.GetArgValue(ref idx, args, nameof(testIntervalSeconds), testIntervalSeconds));
            delaySeconds = Math.Max(0, TestUtils.GetArgValue(ref idx, args, nameof(delaySeconds), delaySeconds));

            var pathPattern = Path.Combine(dir, fileType);
            Logger.LogDebug("Will read text stream : {0}", pathPattern);

            if (delaySeconds > 0)
            {
                var waitBegin = DateTime.Now;
                var waitEnd = waitBegin + TimeSpan.FromSeconds(delaySeconds);
                var currentPID = Process.GetCurrentProcess().Id;
                Logger.LogWarn($"Will wait {delaySeconds} seconds for you to debug this process : please attach PID {currentPID} before {waitEnd}");
                Thread.Sleep(TimeSpan.FromSeconds(delaySeconds));
            }

            var beginTime = DateTime.Now;
            for (var k = 1; k <= testTimes; k++)
            {
                StartOneTest(pathPattern, k, testTimes);
                if (k < testTimes)
                {
                    Thread.Sleep(TimeSpan.FromSeconds(testIntervalSeconds));
                }
            }

            Logger.LogInfo($"Finished all tests, test times = {testTimes}, used time = {(DateTime.Now - beginTime).Seconds} s = {DateTime.Now - beginTime}, read data = {pathPattern}. {GetCurrentProcessInfo(true, "Final Info: ")}");
        }

        static void StartOneTest(string pathPattern, int times, int totalTimes)
        {
            var beginTime = DateTime.Now;
            Logger.LogInfo($"Begin test[{times}]-{totalTimes} , will read : {pathPattern} . {GetCurrentProcessInfo()}");
            var sc = new SparkContext(new SparkConf());
            var mappingRDD = sc.TextFile(pathPattern).Map<string>(line => line).Cache();

            Logger.LogInfo("RDD count = {0}", mappingRDD.Count());

            mappingRDD.Unpersist();
            var endTime = DateTime.Now;
            Logger.LogInfo($"End test[{times}]-{totalTimes} of {typeof(TxtStreamTest)}, used time = {(endTime - beginTime).TotalSeconds} s = {endTime - beginTime} . read = {pathPattern} ; {GetCurrentProcessInfo()}");

            sc.Stop();
        }
    }
}
