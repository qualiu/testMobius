using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using CommonTestUtils;
using log4net;
using Microsoft.Spark.CSharp.Core;
using Microsoft.Spark.CSharp.Services;
using Microsoft.Spark.CSharp.Streaming;

namespace kafkaStreamTest
{
    public interface ITestKafkaBase
    {
        /// <summary>
        /// Parse test times and interval from arguments.
        /// </summary>
        /// <param name="args">command line arguments</param>
        /// <returns>if failed to parse return -1 to not run test.</returns>
        Tuple<int, int> GetTestTimesAndInterval(string[] args);

        void Run(Lazy<SparkContext> sparkContext, int currentTimes, int totalTimes);
    }

    [Serializable]
    public abstract class TestKafkaBase<ClassName, ArgClass> : BaseTestUtilLog<ClassName>, ITestKafkaBase
        where ArgClass : class, new()
    {
        public abstract void Run(Lazy<SparkContext> sparkContext, int currentTimes, int totalTimes);

        protected dynamic Options;

        protected Dictionary<string, string> kafkaParams;

        protected Dictionary<string, long> offsetsRange;

        protected int runTimes = 1;

        public virtual Tuple<int, int> GetTestTimesAndInterval(string[] args)
        {
            var parsedOK = false;
            Options = ArgParser.Parse<ArgClass>(args, out parsedOK);

            // Add wait checking here as this method is definitely called by all derived classes.
            if (parsedOK && Options.WaitSecondsForAttachDebug > 0)
            {
                var waitBegin = DateTime.Now;
                var waitEnd = waitBegin + TimeSpan.FromSeconds(Options.WaitSecondsForAttachDebug);
                var currentPID = Process.GetCurrentProcess().Id;
                Logger.LogWarn($"Will wait {Options.WaitSecondsForAttachDebug} seconds for you to debug this process : please attach PID {currentPID} before {waitEnd}");
                Thread.Sleep(Options.WaitSecondsForAttachDebug * 1000);
            }

            return parsedOK ? new Tuple<int, int>(Options.TestTimes, Options.TestIntervalSeconds) : new Tuple<int, int>(-1, 0);
        }

        protected void ParseKafkaParameters()
        {
            kafkaParams = GetKafkaParameters(Options);
            Logger.LogInfo($"kafkaParams[{kafkaParams.Count}] = {string.Join(", ", kafkaParams.Select(kv => $"{kv.Key} = {kv.Value}")) } ");

            offsetsRange = GetOffsetRanges(Options);
            Logger.LogInfo($"offsetsRange[{offsetsRange.Count}] = {string.Join(", ", offsetsRange.Select(kv => $"{kv.Key} = {kv.Value}")) } ");
        }

        /// <summary>
        /// Check and delete checkpoint directory
        /// </summary>
        /// <param name="currentTimes">current test time number</param>
        protected void DeleteCheckPointDirectory(int currentTimes)
        {
            if (Options.DeleteCheckPointDirectoryTimes >= currentTimes && !string.IsNullOrWhiteSpace(Options.CheckPointDirectory))
            {
                TestUtils.DeleteDirectory(Options.CheckPointDirectory);
            }
        }

        protected virtual Dictionary<string, long> GetOffsetRanges(ArgOptions options)
        {
            var offsetsRange = new Dictionary<string, long>();
            if (options.FromOffset >= 0)
            {
                offsetsRange.Add("fromOffset", options.FromOffset);
            }

            if (options.UntilOffset >= 0)
            {
                offsetsRange.Add("untilOffset", options.UntilOffset);
            }

            return offsetsRange;
        }

        protected virtual Dictionary<string, string> GetKafkaParameters(ArgOptions options)
        {
            var config = (System.Collections.IDictionary)ConfigurationManager.GetSection("kafkaParameters");
            var map = new Dictionary<string, string>();
            if (config != null)
            {
                var it = config.GetEnumerator();
                while (it.MoveNext())
                {
                    map[it.Key as string] = it.Value as string;
                }

            }

            map["group.id"] = options.GroupId.ToString();
            map["metadata.broker.list"] = options.BrokerList.ToString();
            map["auto.offset.reset"] = options.AutoOffset.ToString();
            map["zookeeper.connect"] = options.Zookeeper.ToString();
            //map["zookeeper.connection.timeout.ms"] = "1000";
            //map["zookeeper.session.timeout.ms"] = "200";
            //map["zookeeper.sync.time.ms"] = "6000";
            //map["auto.commit.interval.ms"] = "1000";
            //map["serializer.class"] = "kafka.serializer.StringEncoder";
            return map;
        }

        protected void SaveStreamToFile<U>(DStream<U> reducedStream)
        {
            if (!string.IsNullOrWhiteSpace(Options.SaveTxtDirectory))
            {
                reducedStream.SaveAsTextFiles(Path.Combine(Options.SaveTxtDirectory, typeof(ClassName).Name), ".txt");
            }
        }

        protected void WaitTerminationOrTimeout(StreamingContext streamingContext)
        {
            if (Options.RunningSeconds > 0)
            {
                streamingContext.AwaitTerminationOrTimeout(TimeSpan.FromSeconds(Options.RunningSeconds));
            }
            else
            {
                streamingContext.AwaitTermination();
            }
        }
    }
}
