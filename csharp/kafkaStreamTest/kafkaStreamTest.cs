using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using CommonTestUtils;
using Microsoft.Spark.CSharp.Core;
using Microsoft.Spark.CSharp.Streaming;

namespace kafkaStreamTest
{
    class kafkaStreamTest : BaseTestUtilLog<kafkaStreamTest>
    {
        private static List<Type> TestClasses = new List<Type> {
                typeof(WindowSlideTest),
                typeof(UnionTopicTest)
            };


        static void Main(string[] args)
        {
            Logger.LogInfo(EnvironmentInfo);

            var config = AppDomain.CurrentDomain.SetupInformation.ConfigurationFile;

            if (args.Length < 1 || args[0] == "-h" || args[0] == "--help")
            {
                ShowUsage();
                return;
            }

            Logger.LogDebug("{0} configuration {1}", File.Exists(config) ? "Exist" : "Not Exist", config);

            var className = args[0];
            var type = TestClasses.Find(tp => tp.Name.Equals(className, StringComparison.OrdinalIgnoreCase));
            Logger.LogDebug($"Test class = {type}");
            if (type == null)
            {
                Logger.LogWarn($"Please use one test-name as first parameter : {string.Join(", ", TestClasses.Select(tp => tp.Name))} ");
                ShowUsage();
                return;
            }

            var kafkaTest = Activator.CreateInstance(type) as ITestKafkaBase;

            var testArgs = new List<string>(args);
            testArgs.RemoveAt(0);
            if (testArgs.Count == 0)
            {
                testArgs.Add("-h");
            }

            var testTimesAndInterval = kafkaTest.GetTestTimesAndInterval(testArgs.ToArray());
            var testTimes = testTimesAndInterval.Item1;
            var allBeginTime = DateTime.Now;
            for (var t = 1; t <= testTimes; t++)
            {
                SumCountStatic.GetStaticSumCount().Set();
                var sparkContext = new Lazy<SparkContext>(() => new SparkContext(new SparkConf()));
                var beginTime = DateTime.Now;
                Logger.LogInfo($"Begin test[{t}]-{testTimes} of {type.Name} : {GetCurrentProcessInfo()}");
                kafkaTest.Run(sparkContext, t, testTimes);
                var usedTime = DateTime.Now - beginTime;
                Logger.LogInfo($"End test[{t}]-{testTimes} of {type.Name}, used time = {usedTime.TotalSeconds} s = {usedTime} . SumCount : {SumCountStatic.GetStaticSumCount().ToString()}. {GetCurrentProcessInfo()}");
                if (t < testTimes)
                {
                    Thread.Sleep(TimeSpan.FromSeconds(testTimesAndInterval.Item2));
                }
            }

            var totalUsedTime = DateTime.Now - allBeginTime;
            Logger.LogInfo($"Finished all tests of {type.Name}, test times = {testTimes}, used time = {totalUsedTime.TotalSeconds} s = {totalUsedTime}. {GetCurrentProcessInfo(true, "Final Info: ")}");
        }

        static void ShowUsage()
        {
            Console.WriteLine($"Usage : {ExeName} Test-Name Test-args");
            Console.WriteLine($"{new string('#', 20)} Test-Name as following: {new string('#', 20)}");
            TestClasses.ForEach(tp => Console.WriteLine(tp.Name));

            var idx = DateTime.Now.Second % TestClasses.Count; //new Random((int)DateTime.Now.Ticks & 0x0000FFFF).Next(0, TestClasses.Count - 1);
            var type = TestClasses[(int)idx];
            Console.WriteLine($"{new string('#', 20)} Example : {ExeName} {type.Name} {new string('#', 20)}");
            var kafkaTest = Activator.CreateInstance(type) as ITestKafkaBase;
            kafkaTest.GetTestTimesAndInterval(new string[] { "-help" });
            Console.WriteLine(new string('#', 60));
        }
    }
}
