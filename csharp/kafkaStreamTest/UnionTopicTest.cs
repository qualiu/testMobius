using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonTestUtils;
using Microsoft.Spark.CSharp.Core;
using Microsoft.Spark.CSharp.Streaming;
using PowerArgs;

namespace kafkaStreamTest
{
    [Serializable]
    [ArgExceptionBehavior(ArgExceptionPolicy.StandardExceptionHandling)]
    public class UnionTopicTestOptions : ArgOptions
    {
        [ArgDefaultValue(""), ArgDescription("Kafka topic name, row content = " + nameof(RowIdCountTime)), ArgRequired(), ArgRegex(@"^\S+")]
        public string Topic1 { get; set; }

        [ArgDefaultValue(""), ArgDescription("Kafka topic name, row content = " + nameof(RowIdCountTime)), ArgRequired(), ArgRegex(@"^\S+")]
        public string Topic2 { get; set; }

        [ArgDefaultValue("30"), ArgDescription("Print final count")]
        public int PrintCount { get; set; }

        [ArgDefaultValue(0), ArgDescription("Stream repartition : 0 -> no test.")]
        public int RePartition { get; set; }
    }

    [Serializable]
    class UnionTopicTest : TestKafkaBase<UnionTopicTest, UnionTopicTestOptions>
    {
        public override void Run(String[] args, Lazy<SparkContext> sparkContext)
        {
            if (!ParseArgs(args))
            {
                return;
            }

            PrepareToRun();

            var options = Options as UnionTopicTestOptions;

            var streamingContext = StreamingContext.GetOrCreate(options.CheckPointDirectory,
                () =>
                {
                    Logger.LogDebug($"sparkContext.Value = {sparkContext.Value}");
                    var ssc = new StreamingContext(sparkContext.Value, options.BatchSeconds * 1000L);
                    ssc.Checkpoint(options.CheckPointDirectory);

                    var stream1 = KafkaUtils.CreateDirectStream(ssc, new List<string> { options.Topic1 }, kafkaParams, offsetsRange)
                        .Map(line => new RowIdCountTime().Deserialize(line.Value));
                    var stream2 = KafkaUtils.CreateDirectStream(ssc, new List<string> { options.Topic2 }, kafkaParams, offsetsRange)
                        .Map(line => new RowIdCountTime().Deserialize(line.Value));
                    var stream = stream1.Union(stream2);
                    //var count = stream.Count();
                    //Logger.LogInfo("Will print count : ");
                    //count.Print(options.PrintCount);
                    if (options.RePartition > 0)
                    {
                        stream = stream.Repartition(options.RePartition);
                    }

                    stream.ForeachRDD(rdd =>
                    {
                        rdd.Foreach(idCount =>
                        {
                            Console.WriteLine($"{NowMilli} {this.GetType().Name} : {idCount.ToString()}");
                        });
                    });

                    SaveStreamToFile(stream.Map(it => it.ToString()));
                    return ssc;
                });

            streamingContext.Start();

            WaitTerminationOrTimeout(streamingContext);
        }

        [Serializable]
        class UidCountStreamHelper
        {

        }
    }
}
