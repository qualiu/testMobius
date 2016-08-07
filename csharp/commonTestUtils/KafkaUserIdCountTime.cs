using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading.Tasks;
//using System.ComponentModel.DataAnnotations;

namespace CommonTestUtils
{
    [Serializable]
    public abstract class RowCSV<ClassName> : BaseTestUtil<ClassName>
    {
        protected static readonly Encoding CSVEncoding = Encoding.UTF8;
        protected static readonly char[] Separator = ",".ToCharArray();

        public static string[] GetColumns(string text)
        {
            return text.Split(Separator);
        }

        public abstract ClassName Deserialize(byte[] bytes);
        //{
        //    var text = CSVEncoding.GetString(bytes);
        //    var tp = typeof(ClassName);
        //    var properties = tp.GetProperties(System.Reflection.BindingFlags.Public);
        //    var columns = GetColumns(text);
        //    var k = 0;
        //    foreach (var property in properties)
        //    {
        //        property.SetValue(this, columns[k]);
        //        k++;
        //    }

        //    return (this as ClassName);
        //}
    }

    /// <summary>
    /// Test table of Id-Count-Time
    /// </summary>
    [Serializable]
    //[ReflectionPermission(SecurityAction.PermitOnly, ReflectionEmit = true)]
    public class RowIdCountTime : RowCSV<RowIdCountTime>
    {
        public long Id { get; set; }

        public long Count { get; set; }

        public DateTime Time { get; set; } = DateTime.Now;

        public override string ToString()
        {
            return string.Format("{0},{1},{2}", Id, Count, Time.ToString(MicroDateTimeFormat));
        }

        public override RowIdCountTime Deserialize(byte[] bytes)
        {
            var text = CSVEncoding.GetString(bytes);
            var columns = GetColumns(text);
            var idx = 0;
            Id = long.Parse(columns[idx++]);
            Count = long.Parse(columns[idx++]);
            Time = DateTime.Parse(columns[idx++]);
            return this;
        }
    }

    /// <summary>
    /// Test table of User-Id
    /// </summary>
    [Serializable]
    public class RowIdUser : RowCSV<RowIdUser>
    {
        public long Id { get; set; }

        public string User { get; set; }


        public override string ToString()
        {
            return string.Format("{0},{1}", Id, User);
        }

        public override RowIdUser Deserialize(byte[] bytes)
        {
            var text = CSVEncoding.GetString(bytes);
            var columns = GetColumns(text);
            var idx = 0;
            Id = long.Parse(columns[idx++]);
            User = columns[idx++];
            return this;
        }
    }
}
