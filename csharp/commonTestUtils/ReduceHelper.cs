using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonTestUtils
{
    [Serializable]
    public class ReduceHelper : BaseTestUtilLog<ReduceHelper>
    {
        private readonly bool CheckArrayFirst;

        public ReduceHelper(bool checkArrayAtFirst)
        {
            this.CheckArrayFirst = checkArrayAtFirst;
        }

        public int[] Sum(int[] a, int[] b)
        {
            Logger.LogDebug("SumArray {0} + {1} : CheckArrayFirst = {2}", TestUtils.ArrayToText("a", a), TestUtils.ArrayToText("b", b), this.CheckArrayFirst);

            if (this.CheckArrayFirst)
            {
                if (a == null || b == null)
                {
                    return a == null ? b : a;
                }

                if (a.Length == 0 || b.Length == 0)
                {
                    return a.Length == 0 ? b : a;
                }
            }

            var count = this.CheckArrayFirst ? Math.Min(a.Length, b.Length) : a.Length;
            var c = new int[count];
            for (var k = 0; k < c.Length; k++)
            {
                c[k] = a[k] + b[k];
            }

            return c;
        }

        public int[] InverseSum(int[] a, int[] b)
        {
            Logger.LogDebug("InverseSumArray {0} - {1}, CheckArrayAtFirst = {2}", TestUtils.ArrayToText("a", a), TestUtils.ArrayToText("b", b), this.CheckArrayFirst);
            if (this.CheckArrayFirst)
            {
                if (a == null || b == null)
                {
                    return a == null ? b : a;
                }

                if (a.Length == 0 || b.Length == 0)
                {
                    return a.Length == 0 ? b : a;
                }
            }

            var count = this.CheckArrayFirst ? Math.Min(a.Length, b.Length) : a.Length;
            var c = new int[count];
            for (var k = 0; k < c.Length; k++)
            {
                c[k] = a[k] - b[k];
            }
            return c;
        }
    }
}
