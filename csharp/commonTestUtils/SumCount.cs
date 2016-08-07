using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Microsoft.Spark.CSharp.Core;

namespace CommonTestUtils
{

    [Serializable]
    public class SumCount : BaseTestUtilLog<SumCount>
    {
        private ConcurrentDictionary<string, byte> keySet { get; set; }
        protected long lineCount = 0;
        protected long rddCount = 0;
        protected long recordCount = 0;

        public long LineCount
        {
            get { return Interlocked.Read(ref lineCount); }
            set { Interlocked.Exchange(ref lineCount, value); }
        }

        public long RddCount
        {
            get { return Interlocked.Read(ref rddCount); }
            set { Interlocked.Exchange(ref rddCount, value); }
        }

        public long RecordCount
        {
            get { return Interlocked.Read(ref recordCount); }
            set { Interlocked.Exchange(ref recordCount, value); }
        }

        public void Set(long lineCount = 0, long rddCount = 0, long recordCount = 0)
        {
            this.LineCount = lineCount;
            this.RddCount = rddCount;
            this.RecordCount = recordCount;
        }

        public override string ToString()
        {
            return string.Format("Lines = {0}, RDDs = {1}, Records = {2}, Keys = {3}", LineCount, RddCount, RecordCount, keySet.Count);
        }

        public virtual void ForeachRDD<V>(double time, RDD<dynamic> rdd)
        {
            RddCount += 1;
            var taken = rdd.Collect();
            //Logger.LogDebug("{0} taken.length = {1} , taken = {2}", TestUtils.NowMilli, taken.Length, taken);

            foreach (object record in taken)
            {
                RecordCount += 1;
                KeyValuePair<string, V> kv = (KeyValuePair<string, V>)record;
                Logger.LogDebug("record: key = {0}, {1}, temp sumCount : {2}", kv.Key, TestUtils.GetValueText(kv.Value, "value"), this.ToString());
                LineCount += TestUtils.GetFirstElementValue(kv.Value);
                AddKey(kv.Key);
            }

            Logger.LogDebug("ForeachRDD end : sumCount : {0}", this.ToString());
        }

        public SumCount(long lineCount = 0, long rddCount = 0, long recordCount = 0, IEnumerable<string> keySet = null)
        {
            this.lineCount = lineCount;
            this.rddCount = rddCount;
            this.recordCount = recordCount;
            this.keySet = new ConcurrentDictionary<string, byte>();
            AddKeys(keySet);
        }

        public SumCount(SumCount sum) : this(sum.lineCount, sum.rddCount, sum.RecordCount, sum.keySet.Keys) { }

        public void AddKey(string key)
        {
            this.keySet.AddOrUpdate(key, 1, (k, v) => 1);
        }

        public void AddKeys(IEnumerable<string> keys)
        {
            if (keys != null)
            {
                foreach (var key in keys)
                {
                    this.keySet.AddOrUpdate(key, 1, (k, v) => 1);
                }
            }
        }

        public static SumCount operator -(SumCount s1, SumCount s2)
        {
            return new SumCount(s1.LineCount - s2.LineCount, s1.RddCount - s2.RddCount, s1.RecordCount - s2.RecordCount,
                s1.keySet.Keys.Where(key => !s2.keySet.Keys.Contains(key)));
        }

        public static SumCount operator +(SumCount s1, SumCount s2)
        {
            var keys = s1.keySet.Keys.ToList();
            keys.AddRange(s2.keySet.Keys);
            return new SumCount(s1.LineCount + s2.LineCount, s1.RddCount + s2.RddCount, s1.RecordCount + s2.RecordCount, keys);
        }
    }

    [Serializable]
    public class SumCountStatic : BaseTestUtilLog<SumCountStatic>
    {
        private static SumCount _SumCountKeys = new SumCount();

        public static SumCount GetStaticSumCount() { return _SumCountKeys; }

        public virtual void ForeachRDD<V>(double time, RDD<dynamic> rdd)
        {
            _SumCountKeys.ForeachRDD<V>(time, rdd);
        }
    }
}
