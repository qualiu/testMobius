using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
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
            var config = AppDomain.CurrentDomain.SetupInformation.ConfigurationFile;
            Logger.LogInfo("{0} configuration {1}", File.Exists(config) ? "Exist" : "Not Exist", config);

            if (args.Length < 1 || args[0] == "-h" || args[0] == "--help")
            {
                ShowUsage();
                return;
            }

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

            var sparkContext = new Lazy<SparkContext>(() => new SparkContext(new SparkConf().SetAppName(type.Name)));
            kafkaTest.Run(testArgs.ToArray(), sparkContext);
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
            kafkaTest.ParseArgs(new string[] { "-help" });
            Console.WriteLine(new string('#', 60));
        }
    }
}
