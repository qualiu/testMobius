using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PowerArgs;

namespace CommonTestUtils
{
    public class ArgParser : BaseTestUtilLog<ArgParser>
    {
        public static TPowerArgs Parse<TPowerArgs>(string[] args, out bool parseOK, string help = "-h")
            where TPowerArgs : class, new()
        {
            parseOK = false;
            var options = new TPowerArgs();
            if (args.Length < 1)
            {
                if (string.IsNullOrWhiteSpace(help))
                {
                    Console.WriteLine(ArgUsage.GenerateUsageFromTemplate<TPowerArgs>());
                }
                else
                {
                    Args.Parse<TPowerArgs>(new string[] { help });
                }
                return options;
            }

            try
            {
                options = Args.Parse<TPowerArgs>(args);
                if (options != null)
                {
                    parseOK = true;
                    var argCount = 0;
                    options.OutArgs((name, value) => Logger.LogDebug("args[{0}] : {1} = {2}", ++argCount, name, value));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }

            return options;
        }
    }
}
