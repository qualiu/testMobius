using System;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using log4net;
using Microsoft.Spark.CSharp.Services;

namespace CommonTestUtils
{
    //public class BaseTestUtil<ClassName, TimeFormatString = "yyyy-MM-dd HH:mm:ss", IsUTC = false>

    [Serializable]
    public class BaseTestUtil<ClassName>
    {
        public const string DateFormat = "yyyy-MM-dd";
        public const string TimeFormat = "HH:mm:ss";
        public const string DateTimeFormat = DateFormat + " " + TimeFormat;
        public const string MilliTimeFormat = TimeFormat + ".fff";
        public const string MicroTimeFormat = MilliTimeFormat + "fff";
        public const string MilliDateTimeFormat = DateTimeFormat + ".fff";
        public const string MicroDateTimeFormat = MilliDateTimeFormat + "fff";

        public static String Now { get { return DateTime.Now.ToString(DateTimeFormat); } }

        public static String NowMilli { get { return DateTime.Now.ToString(MilliDateTimeFormat); } }

        public static String NowMicro { get { return DateTime.Now.ToString(MicroDateTimeFormat); } }

        public static String UtcNow { get { return DateTime.UtcNow.ToString(DateTimeFormat); } }

        public static String UtcNowMilli { get { return DateTime.UtcNow.ToString(MilliDateTimeFormat); } }

        public static String UtcNowMicro { get { return DateTime.UtcNow.ToString(MicroDateTimeFormat); } }

        public static String ExePath
        {
            get
            {
                // System.Reflection.Assembly.GetExecutingAssembly().CodeBase;
                // Process.GetCurrentProcess().MainModule.FileName;
                return System.Reflection.Assembly.GetEntryAssembly().Location;
            }
        }

        public static String ExeName { get { return Path.GetFileName(ExePath); } }

        public static string EnvironmentInfo
        {
            get
            {
                var info = new StringBuilder();
                info.Append($"sizeof(int) = {sizeof(int)}, sizeof(long) = {sizeof(long)}, IntPtr.Size = {IntPtr.Size}, Is64BitOperatingSystem = {Environment.Is64BitOperatingSystem}");
                info.Append($", Is64BitProcess = {Environment.Is64BitProcess}, OSVersion = {Environment.OSVersion}, MachineName = {Environment.MachineName}");
                info.Append($", Processors = {Environment.ProcessorCount}. ");
                info.Append(GetCurrentProcessInfo());
                return info.ToString();
            }
        }

        public static string GetCurrentProcessInfo(bool withProcessMemoryInfo = true, string header = "Current Process : ")
        {
            var process = Process.GetCurrentProcess();
            var info = new StringBuilder(header);
            info.Append($"PID = {process.Id}");

            info.Append($", CPU usage = {SystemInfo.GetCPUUsage()}, Available Memory = {SystemInfo.GetAvailableRAM()}");

            if (withProcessMemoryInfo)
            {
                info.Append($", PrivateMemorySize64 = {process.PrivateMemorySize64}, VirtualMemorySize64 = {process.VirtualMemorySize64}");
                info.Append($", TotalProcessorTime = {process.TotalProcessorTime}, UserProcessorTime = {process.UserProcessorTime}");
                info.Append($", PagedMemorySize64 = {process.PagedMemorySize64}, NonpagedSystemMemorySize64 = {process.NonpagedSystemMemorySize64}");
                info.Append($", PeakPagedMemorySize64 = {process.PeakPagedMemorySize64}, PeakVirtualMemorySize64 = {process.PeakVirtualMemorySize64}");
            }

            return info.ToString();
        }
    }

    [Serializable]
    public class BaseTestUtilLog<ClassName> : BaseTestUtil<ClassName>
    {
        private static Lazy<ILoggerService> _logger = new Lazy<ILoggerService>(() => LoggerServiceFactory.GetLogger(typeof(ClassName)));
        protected static ILoggerService Logger { get { return _logger.Value; } }
    }

    [Serializable]
    public class BaseTestUtilLog4Net<ClassName> : BaseTestUtil<ClassName>
    {
        private static Lazy<ILog> _logger = new Lazy<ILog>(() => LogManager.GetLogger(typeof(ClassName)));
        protected static ILog Logger { get { return _logger.Value; } }
    }

    [Serializable]
    public class BaseTestUtilLog4NetName<ClassName> : BaseTestUtil<ClassName>
    {
        private static Lazy<ILog> _logger = new Lazy<ILog>(() => LogManager.GetLogger(typeof(ClassName).Name));
        protected static ILog Logger { get { return _logger.Value; } }
    }


    [Serializable]
    public static class Extension
    {
        public static void OutArgs<TClass>(this TClass options, Action<string, object> OutNameValueFunc = null, string regexExcludeNames = "^(help)$", bool regexIgnoreCase = true)
        {
            var tp = options.GetType();
            var properties = tp.GetProperties();

            Action<string, object> OutNameValue = (name, value) =>
            {
                Console.WriteLine("{0} = {1}", name, value);
            };

            if (OutNameValueFunc == null)
            {
                OutNameValueFunc = OutNameValue;
            }

            var regexExclude = string.IsNullOrWhiteSpace(regexExcludeNames) ? null : new Regex(regexExcludeNames, regexIgnoreCase ? RegexOptions.IgnoreCase : RegexOptions.None);

            foreach (var property in properties)
            {
                if (null != regexExclude && regexExclude.IsMatch(property.Name))
                {
                    continue;
                }

                var pv = property.GetValue(options);
                OutNameValueFunc(property.Name, pv);
            }
        }
    }
}
