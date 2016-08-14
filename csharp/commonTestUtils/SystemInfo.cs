using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonTestUtils
{
    internal static class SystemInfo
    {
        public static string GetCPUUsage()
        {
            var cpuCounter = new PerformanceCounter();
            cpuCounter.CategoryName = "Processor";
            cpuCounter.CounterName = "% Processor Time";
            cpuCounter.InstanceName = "_Total";
            return cpuCounter.NextValue() + "%";
        }

        public static string GetAvailableRAM()
        {
            var ramCounter = new PerformanceCounter("Memory", "Available MBytes");
            return (ramCounter.NextValue() / 1024.0).ToString("F2") + " GB";
        }

        public static bool IsWindows { get { return Environment.OSVersion.Platform <= PlatformID.WinCE; } }
    }
}
