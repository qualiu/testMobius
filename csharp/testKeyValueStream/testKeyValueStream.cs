using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using CommonTestUtils;
using Microsoft.Spark.CSharp.Core;
using Microsoft.Spark.CSharp.Streaming;

namespace testKeyValueStream
{
    [Serializable]
    public class testKeyValueStream : BaseTestUtilLog<testKeyValueStream>
    {
        private static ArgOptions Options = null;

        public static void Main(string[] args)
        {
            Logger.LogInfo(EnvironmentInfo);
            var config = AppDomain.CurrentDomain.SetupInformation.ConfigurationFile;

            var isParseOK = false;
            //Options = ParserByCommandLine.Parse(args, out isParseOK);
            Options = ArgParser.Parse<ArgOptions>(args, out isParseOK, "-Help");

            if (!isParseOK)
            {
                return;
            }

            Logger.LogDebug("{0} configuration {1}", File.Exists(config) ? "Exist" : "Not Exist", config);

            if (Options.WaitSecondsForAttachDebug > 0)
            {
                var waitBegin = DateTime.Now;
                var waitEnd = waitBegin + TimeSpan.FromSeconds(Options.WaitSecondsForAttachDebug);
                var currentPID = Process.GetCurrentProcess().Id;
                Logger.LogWarn($"Will wait {Options.WaitSecondsForAttachDebug} seconds for you to debug this process : please attach PID {currentPID} before {waitEnd}");
                Thread.Sleep(Options.WaitSecondsForAttachDebug * 1000);
            }

            Logger.LogInfo("will connect " + Options.Host + ":" + Options.Port + " batchSeconds = " + Options.BatchSeconds + " s , windowSeconds = " + Options.WindowSeconds + " s, slideSeconds = " + Options.SlideSeconds + " s."
                + " checkpointDirectory = " + Options.CheckPointDirectory + ", is-array-test = " + Options.IsArrayValue);

            var prefix = ExeName + (Options.IsArrayValue ? "-array" + (Options.IsUnevenArray ? "-uneven" : "-even") : "-single");

            var beginTime = DateTime.Now;

            var sc = new SparkContext(new SparkConf());

            Action<long> testOneStreaming = (testTime) =>
            {
                var timesInfo = "[" + testTime + "]-" + Options.TestTimes + " ";
                Logger.LogInfo($"Begin test{timesInfo} : {GetCurrentProcessInfo()}");
                if (Options.DeleteCheckPointDirectoryTimes >= testTime)
                {
                    TestUtils.DeleteDirectory(Options.CheckPointDirectory);
                }

                var ssc = new StreamingContext(sc, Options.BatchSeconds * 1000L);
                ssc.Checkpoint(Options.CheckPointDirectory);
                var lines = ssc.SocketTextStream(Options.Host, Options.Port, StorageLevelType.MEMORY_AND_DISK_SER);


                var oldSum = new SumCount(SumCountStatic.GetStaticSumCount());
                StartOneTest(sc, lines, Options.ElementCount, prefix);
                var newSum = SumCountStatic.GetStaticSumCount();
                // var sum = newSum - oldSum; // newSum maybe same as oldSum

                ssc.Start();
                var startTime = DateTime.Now;
                ssc.AwaitTerminationOrTimeout(Options.RunningSeconds * 1000);
                ssc.Stop();

                var sum = newSum - oldSum;
                var isSameLineCount = Options.LineCount <= 0 || Options.LineCount == sum.LineCount;
                var message = Options.LineCount <= 0 ? string.Empty :
                    (isSameLineCount ? ". LineCount same" : string.Format(". LineCount different : expected = {0}, but line count = {1}", Options.LineCount, sum.LineCount));

                Logger.LogInfo("oldSum = {0}, newSum = {1}, sum = {2}", oldSum, newSum, sum);
                Logger.LogInfo($"End test{timesInfo}, used time = {(DateTime.Now - startTime).TotalSeconds} s, total cost = {(DateTime.Now - beginTime).TotalSeconds} s, started at {startTime.ToString(TestUtils.MilliTimeFormat)} . Reduced final sumCount : {sum.ToString()} {message}. {GetCurrentProcessInfo()}");
            };

            for (var times = 1; times <= Options.TestTimes; times++)
            {
                testOneStreaming(times);
                if (times < Options.TestTimes)
                {
                    Thread.Sleep(TimeSpan.FromSeconds(Options.TestIntervalSeconds));
                }
            }

            Logger.LogInfo($"Finished all tests, test times = {Options.TestTimes}, used time = {(DateTime.Now - beginTime).TotalSeconds} s = {DateTime.Now - beginTime} . {GetCurrentProcessInfo(true, "Final info: ")}");
        }

        static void StartOneTest(SparkContext sc, DStream<string> lines, long elements, string prefix, string suffix = ".txt")
        {
            var isReduceByKey = Options.IsReduceByKey();
            Logger.LogDebug("isReduceByKey = {0}", isReduceByKey);
            if (!Options.IsArrayValue)
            {
                //var pairs = lines.Map(line => new ParseKeyValue(0).Parse(line));
                var pairs = lines.Map(new ParseKeyValue(0, Options.PrintReceivedLines).Parse);
                var reducedStream = isReduceByKey ? pairs.ReduceByKey(Sum)
                    : pairs.ReduceByKeyAndWindow(Sum, InverseSum, Options.WindowSeconds, Options.SlideSeconds);
                ForEachRDD("KeyValue", reducedStream, prefix, suffix);
            }
            else
            {
                //var pairs = lines.Map(line => new ParseKeyValueUnevenArray(elements).Parse(line));
                var pairs = Options.IsUnevenArray ? lines.Map(new ParseKeyValueUnevenArray(elements, Options.PrintReceivedLines).Parse) : lines.Map(new ParseKeyValueArray(elements, Options.PrintReceivedLines).Parse);
                var reducedStream = isReduceByKey ? pairs.ReduceByKey(new ReduceHelper(Options.CheckArray).Sum)
                    : pairs.ReduceByKeyAndWindow(new ReduceHelper(Options.CheckArray).Sum, new ReduceHelper(Options.CheckArray).InverseSum, Options.WindowSeconds, Options.SlideSeconds);
                ForEachRDD(Options.IsUnevenArray ? "KeyValueUnevenArray" : "KeyValueArray", reducedStream, prefix, suffix);
            }
        }

        public static void ForEachRDD<V>(string title, DStream<KeyValuePair<string, V>> reducedStream, string prefix, string suffix = ".txt")
        {
            Logger.LogDebug("ForEachRDD " + title);
            reducedStream.ForeachRDD(new SumCountStatic().ForeachRDD<V>);

            if (!string.IsNullOrWhiteSpace(Options.SaveTxtDirectory))
            {
                reducedStream.Map(kv => $"{kv.Key} = {TestUtils.GetValueText(kv.Value)}").SaveAsTextFiles(Path.Combine(Options.SaveTxtDirectory, prefix), suffix);
            }
        }

        static int Sum(int a, int b)
        {
            Logger.LogDebug("InverseSum : a - b = {0} - {1}", a, b);
            return a + b;
        }

        static int InverseSum(int a, int b)
        {
            Logger.LogDebug("InverseSum : a - b = {0} - {1}", a, b);
            return a - b;
        }
    }
}
