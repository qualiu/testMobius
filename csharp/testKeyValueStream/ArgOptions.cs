using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using CommonTestUtils;
using PowerArgs;

namespace testKeyValueStream
{
    [Serializable]
    [ArgExceptionBehavior(ArgExceptionPolicy.StandardExceptionHandling)]
    public class ArgOptions
    {
        [ArgShortcut("H"), ArgDefaultValue("127.0.0.1"), ArgDescription("host"), ArgRegex(@"^[\d\.]+$")]
        public string Host { get; set; }

        [ArgShortcut("p"), ArgRequired(PromptIfMissing = true), ArgDefaultValue(9111), ArgDescription("port")]
        public int Port { get; set; }

        [ArgShortcut("b"), ArgDescription("batch seconds"), ArgDefaultValue(1), ArgRange(1, 999)]
        public int BatchSeconds { get; set; }

        [ArgShortcut("w"), ArgDescription("window seconds"), ArgDefaultValue(4)]
        public int WindowSeconds { get; set; }

        [ArgShortcut("s"), ArgDescription("slide seconds"), ArgDefaultValue(4)]
        public int SlideSeconds { get; set; }

        [ArgShortcut("r"), ArgDescription("running seconds"), ArgDefaultValue(30)]
        public int RunningSeconds { get; set; }

        [ArgShortcut("t"), ArgDescription("test times"), ArgDefaultValue(1)]
        public int TestTimes { get; set; }

        [ArgShortcut("I"), ArgDescription("Interval seconds between tests"), ArgDefaultValue(0), ArgRange(0, int.MaxValue)]
        public int TestIntervalSeconds { get; set; }

        [ArgShortcut("c"), ArgDefaultValue("checkDir"), ArgExample("checkDir", "check point directory")]
        public string CheckPointDirectory { get; set; } // = Path.Combine(Path.GetTempPath(), "checkDir")

        [ArgShortcut("d"), ArgDefaultValue(0), ArgDescription("Times to delete check point directory before each test")]
        public int DeleteCheckPointDirectoryTimes { get; set; }

        [ArgShortcut("m"), ArgDefaultValue("reduceByKeyAndWindow"), ArgDescription("method name, such as reduceByKeyAndWindow")]
        public string MethodName { get; set; }

        [ArgShortcut("a"), ArgDefaultValue(true), ArgDescription("is value type array")]
        public bool IsArrayValue { get; set; }

        [ArgShortcut("u"), ArgDefaultValue(false), ArgDescription("is uneven array value")]
        public bool IsUnevenArray { get; set; }

        [ArgShortcut("e"), ArgDefaultValue(0), ArgDescription("element count in value array. 0 means not set.")]
        public long ElementCount { get; set; }

        [ArgShortcut("f"), ArgDefaultValue(""), ArgDescription("save file directory, not save if empty.")]
        public string SaveTxtDirectory { get; set; } // Path.Combine(Path.GetTempPath(), "checkDir")

        [ArgShortcut("k"), ArgDefaultValue(true), ArgDescription("check array before operation such as reduce.")]
        public bool CheckArray { get; set; }

        [ArgShortcut("n"), ArgDefaultValue(-1), ArgDescription("line count to check with, ignore if < 0 ")]
        public Int64 LineCount { get; set; }

        [ArgDefaultValue(true), ArgDescription("Print received lines")]
        public bool PrintReceivedLines { get; set; }

        [ArgDefaultValue(0), ArgDescription("Wait seconds for user to attach this process and debug.")]
        public int WaitSecondsForAttachDebug { get; set; }

        [HelpHook, ArgDescription("Shows this help"), ArgShortcut("-?")]
        public bool Help { get; set; }

        public bool IsReduceByKey()
        {
            return MethodName.Equals("reduceByKey", StringComparison.OrdinalIgnoreCase);
        }
    }
}
