using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using CommonTestUtils;
using KafkaNet;
using KafkaNet.Model;
using KafkaNet.Protocol;
using PowerArgs;

namespace ReadWriteKafka
{
    [Serializable]
    [ArgExceptionBehavior(ArgExceptionPolicy.StandardExceptionHandling)]
    public class ArgReadWriteKafka
    {
        [ArgRequired(), ArgDefaultValue("http://localhost:9092"), ArgDescription("Kafka metadata.broker.list (separated by ';' if multiple)")]
        public String BrokerList { get; set; }

        [ArgDefaultValue(""), ArgDescription("Kafka topic to write for id-user")]
        public String TopicIdUser { get; set; }

        [ArgDefaultValue(""), ArgDescription("Kafka topic to write for id-count")]
        public String TopicIdCount { get; set; }

        [ArgDefaultValue(60), ArgDescription("Read/Write row count : 0 means no limit")]
        public long Rows { get; set; }

        [ArgDefaultValue(false), ArgDescription("Is writing message to Kafka (or else reading)")]
        public bool IsWrite { get; set; }

        [ArgDefaultValue(""), ArgDescription("Topic to read")]
        public string ReadTopic { get; set; }

        [ArgDefaultValue(false), ArgDescription("Display row header info")]
        public bool ShowRowHeader { get; set; }

        [ArgDefaultValue(1000), ArgDescription("Writing interval : milliseconds")]
        public int Interval { get; set; }

        [ArgDefaultValue(60), ArgDescription("Writing duration : seconds, 0 means no limit")]
        public int RunningSeconds { get; set; }

        [ArgDefaultValue(100), ArgDescription("Base id")]
        public int BaseId { get; set; }

        [ArgDefaultValue(-1), ArgDescription("Max id : -1 will use default : BaseId + Rows * 0.6 ")]
        public int MaxId { get; set; }

        [ArgDefaultValue(false), ArgDescription("Only show row count if read")]
        public bool OnlyShowCount { get; set; }

        [ArgDefaultValue(6000), ArgDescription("Reading timeout in milliseconds : -1 means wait endless")]
        public int ReadingTimeout { get; set; }

    }

    class ReadWriteKafka : BaseTestUtilLog4Net<ReadWriteKafka>
    {
        private static Random random = new Random();

        static void Main(string[] args)
        {
            Logger.Info(EnvironmentInfo);
            var parsedOK = false;
            var options = ArgParser.Parse<ArgReadWriteKafka>(args, out parsedOK);
            if (!parsedOK)
            {
                return;
            }

            var brokers = options.BrokerList.Split(";,".ToCharArray());
            var brokersUriList = new List<Uri>(brokers.Select(broker => new Uri(broker)));
            if (options.IsWrite)
            {
                WriteTestData(brokersUriList, options);
            }
            else
            {
                ReadData(brokersUriList, options);
            }
        }

        static long GerenateUserId(int baseId, int maxId)
        {
            return random.Next(baseId, maxId);
        }

        static string GerenateUserName(long id)
        {
            var name = id.ToString().ToCharArray();
            for (var k = 0; k < name.Length; k++)
            {
                name[k] = (char)('a' + name[k] - '0');
            }

            return new string(name);
        }

        static void WriteTopic(List<Uri> brokersUriList, string topic, IEnumerable<Message> messages, bool showMesage = true, bool showReadCommand = true)
        {
            var beginTime = DateTime.Now;
            var connectedTime = beginTime;
            using (var router = new BrokerRouter(new KafkaOptions(brokersUriList.ToArray())))
            using (var producer = new Producer(router))
            {
                connectedTime = DateTime.Now;
                producer.SendMessageAsync(topic, messages).Wait();
            }


            var endTime = DateTime.Now;
            if (showMesage)
            {
                Logger.Info($"Wrote {messages.Count()} messages into topic {topic}, used time = {endTime - beginTime}, connection used = {connectedTime - beginTime}");
            }

            if (showReadCommand)
            {
                Logger.Info($"You can read it by : {ExePath} -{nameof(ArgReadWriteKafka.BrokerList)} {string.Join(",", brokersUriList)} " +
                $"-{nameof(ArgReadWriteKafka.ReadTopic)} {topic} ");
            }
        }

        static void WriteTestData(List<Uri> brokersUriList, ArgReadWriteKafka options)
        {
            var baseId = options.BaseId;
            var maxRows = Math.Min(3000, Math.Max(100, options.Rows));
            var maxId = options.MaxId < baseId ? baseId + (int)(maxRows * 0.6) : options.MaxId;
            var idList = new HashSet<long>();
            for (var k = 0; k < maxId - baseId; k++)
            {
                idList.Add(GerenateUserId(baseId, maxId));
            }

            Logger.Debug($"baseId = {baseId}, maxId = {maxId}, idList.count = {idList.Count}, to write rows = {options.Rows}");

            if (!string.IsNullOrWhiteSpace(options.TopicIdUser))
            {
                var tableIdUser = new List<Message>();
                foreach (var id in idList)
                {
                    tableIdUser.Add(new Message(new RowIdUser { Id = id, User = GerenateUserName(id) }.ToString()));
                }

                WriteTopic(brokersUriList, options.TopicIdUser, tableIdUser);
            }

            if (string.IsNullOrWhiteSpace(options.TopicIdCount))
            {
                return;
            }

            var beginTime = DateTime.Now;
            var endTime = options.RunningSeconds == 0 ? DateTime.MaxValue : beginTime + TimeSpan.FromSeconds(options.RunningSeconds);
            var rows = options.Rows == 0 ? long.MaxValue : options.Rows;

            var oneMessage = new Message(new RowIdCountTime().ToString());
            var size = oneMessage.Value.Length;
            var oneBatch = 1024 * 1024 / size;
            if (options.Interval >= 100)
            {
                oneBatch = 1;
            }

            var tableIdCount = new List<Message>();

            for (var k = 0; k < rows && DateTime.Now < endTime; k++)
            {
                var time = DateTime.Now.Add(TimeSpan.FromMilliseconds(Math.Max(options.Interval, 1)));
                tableIdCount.Add(new Message(new RowIdCountTime { Id = idList.ElementAt(random.Next(0, idList.Count - 1)), Count = 1, Time = time }.ToString()));
                if (tableIdCount.Count == oneBatch)
                {
                    WriteTopic(brokersUriList, options.TopicIdCount, tableIdCount, true, false);
                    rows += tableIdCount.Count;
                    tableIdCount.Clear();
                }

                if (options.Interval > 0)
                {
                    Thread.Sleep(options.Interval);
                }
            }
            WriteTopic(brokersUriList, options.TopicIdCount, tableIdCount, tableIdCount.Count > 0, true);
        }

        static void ReadData(List<Uri> brokersUriList, ArgReadWriteKafka options)
        {
            if (string.IsNullOrWhiteSpace(options.ReadTopic))
            {
                Logger.WarnFormat($"{nameof(options.ReadTopic)} is null or empty! If you want to write, please set {nameof(options.IsWrite)} true.");
                return;
            }

            var beginTime = DateTime.Now;
            var connectedTime = beginTime;
            var endTime = beginTime;
            var rowsRead = 0;
            Action readTopicRows = () =>
            {
                using (var router = new BrokerRouter(new KafkaOptions(brokersUriList.ToArray())))
                {
                    using (var consumer = new Consumer(new ConsumerOptions(options.ReadTopic, router)))
                    {
                        connectedTime = DateTime.Now;
                        foreach (var message in consumer.Consume())
                        {
                            rowsRead++;
                            if (!options.OnlyShowCount)
                            {
                                var text = Encoding.UTF8.GetString(message.Value);
                                if (options.ShowRowHeader)
                                {
                                    Console.WriteLine("Row[{0}]: {1}", rowsRead, text);
                                }
                                else
                                {
                                    Console.WriteLine(text);
                                }
                            }

                            if (options.Rows > 0 && rowsRead >= options.Rows)
                            {
                                break;
                            }
                        }

                        endTime = DateTime.Now;
                    }
                }
            };

            if (options.ReadingTimeout > 0)
            {
                Task.Run(readTopicRows).Wait(options.ReadingTimeout);
            }
            else
            {
                Task.Run(readTopicRows).Wait();
            }

            
            Logger.InfoFormat($"Read {rowsRead} rows in topic {options.ReadTopic}, brokers = {options.BrokerList}, used time = {endTime - beginTime}, connection cost = {connectedTime - beginTime}");
        }
    }
}
