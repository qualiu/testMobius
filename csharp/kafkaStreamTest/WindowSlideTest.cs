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
    public class WindowSlideTestOptions : ArgOptions
    {
        [ArgDefaultValue("test"), ArgDescription("Kafka topic names (separated by ',' if multiple)"), ArgRequired()]
        public String Topics { get; set; }

        [ArgShortcut("a"), ArgDefaultValue(true), ArgDescription("is value type array")]
        public bool IsArrayValue { get; set; }

        [ArgShortcut("u"), ArgDefaultValue(false), ArgDescription("is uneven array value")]
        public bool IsUnevenArray { get; set; }

        [ArgShortcut("e"), ArgDefaultValue(0), ArgDescription("element count in value array. 0 means not set.")]
        public long ElementCount { get; set; }

        [ArgShortcut("k"), ArgDefaultValue(true), ArgDescription("check array before operation such as reduce.")]
        public bool CheckArrayAtFirst { get; set; }

        [ArgShortcut("v"), ArgDefaultValue(-1), ArgDescription("line count to validate with, ignore if < 0 ")]
        public Int64 ValidateCount { get; set; }

        [ArgDefaultValue(true), ArgDescription("show received lines text")]
        public bool ShowReceivedLines { get; set; }
    }

    class WindowSlideTest : TestKafkaBase<WindowSlideTest, WindowSlideTestOptions>
    {
        public override void Run(Lazy<SparkContext> sparkContext, int currentTimes, int totalTimes)
        {
            PrepareToRun(currentTimes);

            var options = Options as WindowSlideTestOptions;
            var allBeginTime = DateTime.Now;

            var topicList = new List<string>(options.Topics.Split(";,".ToArray()));

            for (var k = 0; options.TestTimes <= 0 || k < options.TestTimes; k++)
            {
                var beginTime = DateTime.Now;
                Logger.LogInfo("begin test[{0}]-{1} , sparkContext = {2}", k + 1, options.TestTimes > 0 ? options.TestTimes.ToString() : "infinite", sparkContext.Value);
                var streamingContext = StreamingContext.GetOrCreate(options.CheckPointDirectory,
                () =>
                {
                    var ssc = new StreamingContext(sparkContext.Value, options.BatchSeconds * 1000L);
                    ssc.Checkpoint(options.CheckPointDirectory);

                    var stream = KafkaUtils.CreateDirectStream(ssc, topicList, kafkaParams, offsetsRange)
                        .Map(line => Encoding.UTF8.GetString(line.Value));

                    var pairs = stream.Map(new ParseKeyValueArray(options.ElementCount, options.ShowReceivedLines).Parse);

                    var reducedStream = pairs.ReduceByKeyAndWindow(
                        new ReduceHelper(options.CheckArrayAtFirst).Sum,
                        new ReduceHelper(options.CheckArrayAtFirst).InverseSum,
                        options.WindowSeconds,
                        options.SlideSeconds
                        );

                    reducedStream.ForeachRDD(new SumCountStatic().ForeachRDD<int[]>);
                    SaveStreamToFile(reducedStream);
                    return ssc;
                });

                streamingContext.Start();
                WaitTerminationOrTimeout(streamingContext);
            }

        }
    }
}
