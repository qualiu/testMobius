using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace CommonTestUtils
{
    /// <summary>
    /// Parse received line to key value pairs, line example : 
    /// 2016-06-23 00:16:17.601276 from 'Microsoft Windows NT 6.2.9200.0' 'QUAPC' 127.0.0.1 times[1] send message[57] to 10.172.120.118:1982 : tick = 636022377776012761
    /// </summary>
    /// <typeparam name="ValueType"></typeparam>
    [Serializable]
    public abstract class ParseKeyValuePairBase<ValueType, ClassName> : BaseTestUtilLog<ClassName>
    {
        private static long LineCount = 0;

        protected readonly long valueArrayElements;

        protected readonly bool needPrintMessage;

        public ParseKeyValuePairBase(long valueElementCount = 0, bool needPrintMessage = true)
        {
            this.valueArrayElements = valueElementCount;
            this.needPrintMessage = needPrintMessage;
        }

        public virtual void ShowReceivedLine(string line)
        {
            LineCount++;
            if (needPrintMessage)
            {
                Logger.LogInfo($"Received Line[{LineCount}]: {line}");
            }
        }

        public virtual KeyValuePair<string, ValueType> Parse(string line)
        {
            throw new NotImplementedException();
        }

        protected static KeyValuePair<string, int[]> Parse(string line, long elements)
        {
            var match = Regex.Match(line, @"^(?<Key>[\d-]+ [\d:]+)\.(?<Value>\d+)");
            var key = match.Groups["Key"].Value;
            if (string.IsNullOrWhiteSpace(key))
            {
                throw new Exception($"cannot parse key from line : {line}");
            }

            var valueSet = Regex.Matches(match.Groups["Value"].Value, @"\d");
            if (elements == 0)
            {
                elements = valueSet.Count;
            }

            var values = new int[elements];
            var n = Math.Min(valueSet.Count, values.Length);
            for (var k = 0; k < n; k++)
            {
                values[k] = 1; // int.Parse(valueSet[k].Value);
            }

            return new KeyValuePair<string, int[]>(key, values);
        }

        protected void Print(KeyValuePair<string, int[]> kv)
        {
            if (needPrintMessage)
            {
                Logger.LogInfo($"key = {kv.Key} , {TestUtils.ArrayToText("value", kv.Value)}");
            }
        }
    }

    [Serializable]
    public class ParseKeyValueArray : ParseKeyValuePairBase<int[], ParseKeyValueArray>
    {
        public ParseKeyValueArray(long valueElementCount = 0, bool needPrintMessage = true) : base(valueElementCount, needPrintMessage) { }
        public override KeyValuePair<string, int[]> Parse(string line)
        {
            ShowReceivedLine(line);
            var kv = Parse(line, this.valueArrayElements);
            Print(kv);
            return kv;
        }
    }

    [Serializable]
    public class ParseKeyValueUnevenArray : ParseKeyValueArray
    {
        private static Random random = new Random(DateTime.Now.Second);

        public ParseKeyValueUnevenArray(long valueElementCount = 0, bool needPrintMessage = true) : base(valueElementCount, needPrintMessage) { }

        public override KeyValuePair<string, int[]> Parse(string line)
        {
            ShowReceivedLine(line);
            var kv = base.Parse(line);
            var values = kv.Value.ToList();
            int removeCount = random.Next() % (values.Count + 1);
            values.RemoveRange(0, removeCount);
            var pair = new KeyValuePair<string, int[]>(kv.Key, values.ToArray());
            Print(pair);
            return pair;
        }
    }

    [Serializable]
    public class ParseKeyValue : ParseKeyValuePairBase<int, ParseKeyValue>
    {
        public ParseKeyValue(long valueArrayElements = 0, bool needPrintMessage = true) : base(valueArrayElements, needPrintMessage) { }

        public override KeyValuePair<string, int> Parse(string line)
        {
            ShowReceivedLine(line);
            var kv = Parse(line, 1);
            Print(kv);
            return new KeyValuePair<string, int>(kv.Key, kv.Value[0]);
        }
    }
}
