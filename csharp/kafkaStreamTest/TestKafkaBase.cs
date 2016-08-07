using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
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
        bool ParseArgs(string[] args);
        void Run(String[] args, Lazy<SparkContext> sparkContext);
    }

    [Serializable]
    public abstract class TestKafkaBase<ClassName, ArgClass> : BaseTestUtilLog<ClassName>, ITestKafkaBase
        where ArgClass : class, new()
    {
        protected DateTime beginTime = DateTime.UtcNow;

        protected dynamic Options;

        protected Dictionary<string, string> kafkaParams;

        protected Dictionary<string, long> offsetsRange;


        public abstract void Run(String[] args, Lazy<SparkContext> sparkContext);

        public virtual bool ParseArgs(string[] args)
        {
            var parsedOK = false;
            Options = ArgParser.Parse<ArgClass>(args, out parsedOK);
            return parsedOK;
        }

        protected void PrepareToRun()
        {
            kafkaParams = GetKafkaParameters(Options);
            Logger.LogInfo($"kafkaParams[{kafkaParams.Count}] = {string.Join(", ", kafkaParams.Select(kv => $"{kv.Key} = {kv.Value}")) } ");

            offsetsRange = GetOffsetRanges(Options);
            Logger.LogInfo($"offsetsRange[{offsetsRange.Count}] = {string.Join(", ", offsetsRange.Select(kv => $"{kv.Key} = {kv.Value}")) } ");

            beginTime = DateTime.UtcNow;
            if (Options.DeleteCheckPointDirectory)
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
                streamingContext.AwaitTerminationOrTimeout(Options.RunningSeconds * 1000);
            }
            else
            {
                streamingContext.AwaitTermination();
            }

            Logger.LogInfo($"Finished {typeof(ClassName).Name}, used time = {DateTime.UtcNow - beginTime}");
        }
    }
}
