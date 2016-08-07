using System;
using PowerArgs;

namespace SourceLinesSocket
{
    [Serializable]
    [ArgExceptionBehavior(ArgExceptionPolicy.StandardExceptionHandling)]
    public class PowerArgOptions : IArgOptions
    {
        [ArgShortcut("H"), ArgDefaultValue("127.0.0.1"), ArgDescription("host"), ArgRegex(@"^[\d\.]+$")]
        public string Host { get; set; }

        [ArgShortcut("p"), ArgRequired, ArgDefaultValue(9111), ArgDescription("port")]
        public int Port { get; set; }

        [ArgShortcut("s"), ArgRange(0, 999999), ArgDefaultValue(100), ArgDescription("send interval by milliseconds")]
        public int SendInterval { get; set; }

        [ArgShortcut("r"), ArgDefaultValue(3600), ArgDescription("running duration by seconds")]
        public int RunningSeconds { get; set; }

        [ArgShortcut("n"), ArgDefaultValue(0), ArgDescription("messages per connection : 0 -> no limit")]
        public int MessagesPerConnection { get; set; }

        [ArgShortcut("k"), ArgDefaultValue(0), ArgDescription("key count per connection : 0 -> no limit")]
        public int KeysPerConnection { get; set; }

        [ArgShortcut("q"), ArgDefaultValue(true), ArgDescription("quit if exceeded running duration or sent message count")]
        public bool QuitIfExceededAny { get; set; }

        [ArgShortcut("x"), ArgDefaultValue(0), ArgDescription("max connect times : 0 -> no limit")]
        public int MaxConnectTimes { get; set; }

        [ArgShortcut("z"), ArgDefaultValue(0), ArgDescription("pause seconds at each connection lost : 0 -> no pause")]
        public int PauseSecondsAtDrop { get; set; }

        [HelpHook, ArgDescription("Shows this help"), ArgShortcut("-?")]
        public bool Help { get; set; }
    }
}
