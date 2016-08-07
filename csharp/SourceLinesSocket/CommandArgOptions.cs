using System;
using CommandLine;
using CommandLine.Text;
using CommonTestUtils;

namespace SourceLinesSocket
{
    public class CommandArgOptions : BaseTestUtil<CommandArgOptions>
    {
        public static IArgOptions Parse(string[] args, out bool parsedOK)
        {
            var options = new ArgOptions();
            var parser = new CommandLine.Parser();
            parsedOK = parser.ParseArguments(args, options);
            return options;
        }

        [Serializable]
        public class ArgOptions : IArgOptions
        {
            [Option('H', "host", DefaultValue = "127.0.0.1", HelpText = "host")]
            public string Host { get; set; }

            [Option('p', "port", DefaultValue = 9111, Required = true, HelpText = "port")]
            public int Port { get; set; }

            [Option('s', "sendInterval", DefaultValue = 100, HelpText = "send interval by milliseconds")]
            public int SendInterval { get; set; }

            [Option('r', "runningSeconds", DefaultValue = 3600, HelpText = "running seconds")]
            public int RunningSeconds { get; set; }

            [Option('n', "messagesPerConnection", DefaultValue = 0, HelpText = "send message count per connection. 0 = no limit")]
            public int MessagesPerConnection { get; set; }

            [Option('k', "keysPerConnection", DefaultValue = 0, HelpText = "key count per connection. 0 = no limit")]
            public int KeysPerConnection { get; set; }

            [Option('q', "quitIfExceededAny", DefaultValue = true, HelpText = "quit if exceed time or message-count")]
            public bool QuitIfExceededAny { get; set; }

            [Option('x', "maxConnectTimes", DefaultValue = 0, HelpText = "max connection times")]
            public int MaxConnectTimes { get; set; }

            [Option('z', "pauseSecondsAtDrop", DefaultValue = 0, HelpText = "pause seconds at each connection lost")]
            public int PauseSecondsAtDrop { get; set; }

            [Option("verbose", DefaultValue = true, HelpText = "Prints all messages to standard output.")]
            public bool Verbose { get; set; }


            [HelpOption]
            public string GetUsage()
            {
                return HelpText.AutoBuild(this,
                  (HelpText current) => HelpText.DefaultParsingErrorsHandler(this, current));
            }
        }
    }
}
