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
            var cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            cpuCounter.NextValue();
            System.Threading.Thread.Sleep(1000);
            return cpuCounter.NextValue().ToString("F2") + "%";
        }

        public static string GetAvailableRAM()
        {
            var ramCounter = new PerformanceCounter("Memory", "Available MBytes");
            return (ramCounter.NextValue() / 1024.0).ToString("F2") + " GB";
        }

        public static bool IsWindows { get { return Environment.OSVersion.Platform <= PlatformID.WinCE; } }
    }
}
