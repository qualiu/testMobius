using System;
using System.Text.RegularExpressions;

namespace SourceLinesSocket
{
    public interface IArgOptions
    {
        string Host { get; set; }
        int Port { get; set; }
        int SendInterval { get; set; }
        int RunningSeconds { get; set; }
        int MessagesPerConnection { get; set; }
        int KeysPerConnection { get; set; }
        bool QuitIfExceededAny { get; set; }
        int MaxConnectTimes { get; set; }
        int PauseSecondsAtDrop { get; set; }
    }
}
