using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace CommonTestUtils
{
    public class TestUtils : BaseTestUtilLog<TestUtils>
    {
        public static string ArrayToText<T>(string name, T[] array, int takeMaxElementCount = 9)
        {
            if (array == null)
            {
                return string.Format("{0}[] = null", name);
            }
            else if (array.Length == 0)
            {
                return string.Format("{0}[0] = {1}", name, array);
            }
            else if (array.Length <= takeMaxElementCount)
            {
                return string.Format("{0}[{1}] = {2}", name, array.Length, string.Join(", ", array));
            }
            else
            {
                return string.Format("{0}[{1}] = {2},...,{3}", name, array.Length, string.Join(", ", array.Take(takeMaxElementCount)), array.Last());
            }
        }

        public static long GetFirstElementValue<TData>(TData data)
        {
            var en = data as IEnumerable;
            if (en != null)
            {
                var it = en.GetEnumerator();
                it.MoveNext();
                return Convert.ToInt64(it.Current);
            }
            else
            {
                return Convert.ToInt64(data);
            }
        }

        public static string GetValueText(object value, string name = "")
        {
            if (value == null)
            {
                return null;
            }

            if (value is int)
            {
                return ((int)value).ToString();
            }
            else if (value is int[])
            {
                return TestUtils.ArrayToText(name, (int[])value);
            }
            else
            {
                return value.ToString();
            }
        }

        public static string DictionaryToString<TKey, TValue>(Dictionary<TKey, TValue> map, string separator = ", ")
        {
            var sb = new StringBuilder();
            if (map == null)
            {
                return sb.ToString();
            }

            foreach (var kv in map)
            {
                if (sb.Length > 0)
                {
                    sb.Append(separator);
                }

                sb.Append($"{kv.Key} = {kv.Value}");
            }

            return sb.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="ArgType"></typeparam>
        /// <param name="index">start from -1</param>
        /// <param name="args"></param>
        /// <param name="argName"></param>
        /// <param name="defaultValue"></param>
        /// <param name="canBeOmitted">omitted, not in args</param>
        /// <returns></returns>
        public static ArgType GetArgValue<ArgType>(ref int index, string[] args, string argName, ArgType defaultValue, bool canBeOmitted = true, string className = "")
        {
            index++;
            var header = string.IsNullOrEmpty(className) ? string.Empty : className + " ";
            if (args.Length > index)
            {
                Console.WriteLine("{0}args[{1}] : {2} = {3}", header, index, argName, args[index]);
                var argValue = args[index];
                if (defaultValue is bool)
                {
                    argValue = Regex.IsMatch(args[index], "1|true", RegexOptions.IgnoreCase).ToString();
                }

                return (ArgType)TypeDescriptor.GetConverter(typeof(ArgType)).ConvertFromString(argValue);
            }
            else if (canBeOmitted)
            {
                Console.WriteLine("{0}args-{1} : {2} = {3}", header, index, argName, defaultValue);
                return defaultValue;
            }
            else
            {
                throw new ArgumentException(string.Format("{0}must set {1} at arg[{2}]", header, argName, index + 1), argName);
            }
        }

        public static ArgType GetArgValue<ArgType>(string classType, ref int index, string[] args, string argName, ArgType defaultValue, bool canBeOmitted = true)
        {
            return GetArgValue(ref index, args, argName, defaultValue, canBeOmitted, classType);
        }

        public static IPAddress GetHost(bool print = false)
        {
            IPAddress[] ips = Dns.GetHostAddresses(Dns.GetHostName());
            foreach (IPAddress ipa in ips)
            {
                if (ipa.AddressFamily != AddressFamily.InterNetwork)
                {
                    continue;
                }

                if (print)
                {
                    Console.WriteLine("ip = {0}, AddressFamily = {1}", ipa, ipa.AddressFamily);
                }

                var ip = ipa.ToString();
                if (!ip.StartsWith("10.0.2.") && !ip.StartsWith("192.168."))
                {
                    return ipa;
                }
            }

            return IPAddress.Parse("127.0.0.1");
        }

        public static void DeleteDirectory(string dir, bool throwException = true)
        {
            try
            {
                if (Directory.Exists(dir))
                {
                    Directory.Delete(dir, true);
                    Logger.LogInfo("Deleted directory : {0}", dir);
                }

            }
            catch (Exception ex)
            {
                Logger.LogError("Error to delete directory : {0} : {1}", dir, ex.Message);
                if (throwException)
                {
                    throw ex;
                }
            }
        }
    }
}
