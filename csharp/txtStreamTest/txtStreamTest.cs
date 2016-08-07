using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonTestUtils;
using Microsoft.Spark.CSharp.Core;

namespace TxtStreamTest
{
    class TxtStreamTest : BaseTestUtilLog<TxtStreamTest>
    {
        static void Main(string[] args)
        {
            var fileType = "*.csv";
            var isCallingMap = true;

            if (args.Length < 1 || args[0] == "-h" || args[0] == "--help")
            {
                Console.WriteLine("Usage     : {0}  Data-directory  [file-type: default = {1} ]  [Call Map : default : {2}]", ExePath, fileType, isCallingMap);
                Console.WriteLine(@"Example-1 : {0}  D:\cosmos\download-stream\tenant\csv-2015-10-01      {1} ", ExePath, fileType);
                Console.WriteLine(@"Example-2 : {0}  hdfs:///common/AdsData/MUID", ExePath);
                return;
            }

            var idx = 0;
            var dir = args[idx];
            fileType = TestUtils.GetArgValue(ref idx, args, nameof(fileType), fileType);
            isCallingMap = TestUtils.GetArgValue(ref idx, args, nameof(isCallingMap), true);

            var pathPattern = Path.Combine(dir, fileType);
            Logger.LogDebug("Will read text stream : {0}", pathPattern);

            var beginTime = DateTime.Now;

            var sc = new SparkContext(new SparkConf());
            var mappingRDD = sc.TextFile(pathPattern);

            if (isCallingMap)
            {
                mappingRDD = mappingRDD.Map<string>(line => line);
            }

            mappingRDD = mappingRDD.Cache();

            Logger.LogInfo("RDD count = {0}", mappingRDD.Count());

            mappingRDD.Unpersist();

            var endTime = DateTime.Now;
            Logger.LogInfo($"Finished {typeof(TxtStreamTest)}, used time = {endTime - beginTime} = {(endTime - beginTime).TotalSeconds} s. isCallingMap = {isCallingMap}, read = {pathPattern}");
        }
    }
}
