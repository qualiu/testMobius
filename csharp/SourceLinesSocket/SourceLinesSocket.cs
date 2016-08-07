using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using CommonTestUtils;
using log4net;

namespace SourceLinesSocket
{
    class SourceLinesSocket : BaseTestUtil<SourceLinesSocket>
    {
        private static readonly ILog Logger = LogManager.GetLogger(typeof(SourceLinesSocket));

        private static Socket ServerSocket;
        private static IPAddress HostAddress;

        private static volatile bool IsTimeout = false;

        private static Int64 TotalSentMessages = 0;

        private static int ConnectedTimes = 0;


        static void Main(string[] args)
        {
            var parsedOK = false;
            //var options = ParserByCommandLine.Parse(args, out parseOK);
            //var options = ParserByFluent.Parse(args, out parseOK);
            var options = ArgParser.Parse<PowerArgOptions>(args, out parsedOK, "-Help");

            if (!parsedOK)
            {
                return;
            }

            var runningDuration = options.RunningSeconds <= 0 ? TimeSpan.MaxValue : TimeSpan.FromSeconds(options.RunningSeconds);

            HostAddress = !string.IsNullOrWhiteSpace(options.Host) ? IPAddress.Parse(options.Host) : TestUtils.GetHost();
            ServerSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            ServerSocket.Bind(new IPEndPoint(HostAddress, options.Port));
            ServerSocket.Listen(10);

            var startTime = DateTime.Now;
            var thread = new Thread(() => { ListenToClient(startTime, options, runningDuration); });
            thread.IsBackground = options.RunningSeconds > 0;
            thread.Start();

            if (options.RunningSeconds < 1)
            {
                return;
            }

            var stopTime = runningDuration == TimeSpan.MaxValue ? DateTime.MaxValue : startTime + runningDuration;

            Logger.InfoFormat("expect to stop at " + stopTime.ToString(MilliTimeFormat));
            Logger.InfoFormat("passed " + (DateTime.Now - startTime).TotalSeconds + " s, thread id = " + thread.ManagedThreadId + " , state = " + thread.ThreadState + ", isAlive = " + thread.IsAlive);

            var interval = Math.Max(60, options.SendInterval);
            while (true)
            {
                Thread.Sleep(interval);
                var exceedCount = 0;
                if (DateTime.Now >= stopTime || !thread.IsAlive && ConnectedTimes >= options.MaxConnectTimes)
                {
                    IsTimeout = true;
                    exceedCount++;
                }

                if (!thread.IsAlive)
                {
                    exceedCount++;
                }

                if (exceedCount == 2 || exceedCount == 1 && options.QuitIfExceededAny)
                {
                    break;
                }
            }

            Logger.InfoFormat("finished, passed " + (DateTime.Now - startTime).TotalSeconds + " s, thread id = " + thread.ManagedThreadId + " , state = " + thread.ThreadState + ", isAlive = " + thread.IsAlive);
        }

        private static void ListenToClient(DateTime startTime, IArgOptions options, TimeSpan runningDuration)
        {
            ConnectedTimes++;
            Logger.DebugFormat("startTime = " + startTime.ToString(MilliTimeFormat) + ", runningDuration = " + runningDuration);
            var stopTime = runningDuration == TimeSpan.MaxValue ? DateTime.MaxValue : startTime + runningDuration;
            var stopTimeText = runningDuration == TimeSpan.MaxValue ? "endless" : (startTime + runningDuration).ToString(MilliTimeFormat);
            if (DateTime.Now - startTime > runningDuration)
            {
                Logger.InfoFormat("Not to run. start from " + startTime.ToString(MilliTimeFormat) + " , running for " + runningDuration);
                return;
            }
            else
            {
                Logger.InfoFormat("Machine = " + Environment.MachineName + ", OS = " + Environment.OSVersion
                    + ", start listening " + ServerSocket.LocalEndPoint.ToString()
                    + (runningDuration == TimeSpan.MaxValue ? "\t running endless " : "\t expect to stop at " + stopTimeText));
            }

            var sent = 0;
            var keys = new HashSet<String>();

            Action restartListen = () =>
            {
                if (DateTime.Now > stopTime || options.MaxConnectTimes > 0 && ConnectedTimes >= options.MaxConnectTimes)
                {
                    return;
                }

                Thread.Sleep(options.PauseSecondsAtDrop * 1000);
                ListenToClient(startTime, options, runningDuration);
            };

            var needRestart = false;
            try
            {
                Socket clientSocket = ServerSocket.Accept();
                var beginConnection = DateTime.Now;
                while (true)
                {
                    if (options.MessagesPerConnection > 0 && sent >= options.MessagesPerConnection)
                    {
                        needRestart = !options.QuitIfExceededAny;
                        break;
                    }
                    else if (IsTimeout)
                    {
                        break;
                    }

                    if (DateTime.Now - startTime > runningDuration)
                    {
                        Logger.InfoFormat("Stop running. start from " + startTime.ToString(MilliTimeFormat) + " , running for " + runningDuration);
                        break;
                    }

                    sent++;
                    TotalSentMessages++;
                    var now = DateTime.Now;
                    keys.Add(now.ToString(DateTimeFormat));
                    if (options.KeysPerConnection > 0 && keys.Count > options.KeysPerConnection)
                    {
                        needRestart = !options.QuitIfExceededAny;
                        break;
                    }
                    var message = string.Format("{0} from '{1}' '{2}' {3} times[{4}] send[{5}] keys[{6}] to {7}{8}",
                        now.ToString(MicroDateTimeFormat), Environment.OSVersion, Environment.MachineName, HostAddress, ConnectedTimes,
                        sent, keys.Count, clientSocket.RemoteEndPoint, Environment.NewLine);
                    Console.Write(message);
                    clientSocket.Send(Encoding.ASCII.GetBytes(message));
                    Thread.Sleep(options.SendInterval);
                }

                Logger.InfoFormat("close client : {0} , connection from {1} to {2}, used {3} s, sent {4} lines, keys = {5}",
                    clientSocket.RemoteEndPoint, beginConnection.ToString(MilliTimeFormat),
                    DateTime.Now.ToString(MilliTimeFormat), (DateTime.Now - beginConnection).TotalSeconds,
                    sent, keys.Count
                    );
                clientSocket.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                needRestart = true;
            }

            if (needRestart)
            {
                restartListen();
            }

        }
    }
}
