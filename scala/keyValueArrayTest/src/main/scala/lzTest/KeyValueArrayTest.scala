package lzTest

import java.io.File
import java.util.Date

import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.dstream.DStream
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._
import org.apache.spark.streaming.dstream._

import scala.collection.mutable.ArrayBuffer
import scala.reflect.io.Path

/**
  * Hello world!
  *
  */
object KeyValueArrayTest extends LogBase {
  def ToDuration(seconds: Double): Duration = {
    if (seconds < 1) {
      Milliseconds((1000 * seconds).toInt)
    } else {
      Seconds(seconds.toInt)
    }
  }

  def main(args: Array[String]): Unit = {
    //val jar = new File(KeyValueArrayTest.getClass().getProtectionDomain().getCodeSource().getLocation().toURI().getPath())
    ArgParser4J.parse(args)
    log(s"will connect ${Args4Socket.host}:${Args4Socket.port}, batchSeconds = ${Args4Socket.batchSeconds} s, windowSeconds = ${Args4Socket.windowSeconds} s. slideSeconds = ${Args4Socket.slideSeconds} s, checkpointDirectory = ${Args4Socket.checkPointDirectory}, is-array-test = ${Args4Socket.isArrayValue}")
    val prefix = KeyValueArrayTest.getClass.getCanonicalName + (if (Args4Socket.isArrayValue) (if (Args4Socket.isUnevenArray) "-uneven" else "-even") + "-array" else "-single") + "-"
    val conf = new SparkConf()
    val sc = new SparkContext(conf)
    val beginTime = new Date()
    val countList = new ArrayBuffer[SumCount]()

    for (times <- 1 to Args4Socket.testTimes) {
      val sumCount = startOneTest(times, sc, beginTime, prefix)
      countList += sumCount
      if (Args4Socket.testIntervalSeconds > 0 && times < Args4Socket.testTimes) {
        log(s"Will sleep testIntervalSeconds = ${Args4Socket.testIntervalSeconds} s ...")
        Thread.sleep(Args4Socket.testIntervalSeconds * 1000)
      }
    }

    log(s"Finished all tests of ${this.getClass.getCanonicalName}, test times = ${Args4Socket.testTimes} , used time = ${(new Date().getTime - beginTime.getTime) / 1000.0} s"
      + s", countList[${countList.length}] = ${if (countList.length < 9) countList.mkString(",") else countList.take(9).mkString(", ") + ", ... , " + countList.last}"
      + s"; ${TestUtil.getMemoryInfo()} "
    )
  }

  def startOneTest(testTime: Long, sc: SparkContext, beginTime: Date, prefix: String): SumCount = {
    val timesInfo = "[" + testTime + "]-" + Args4Socket.testTimes + " "
    log(s"Begin test${timesInfo} : ${TestUtil.getMemoryInfo()}")
    if (Args4Socket.deleteCheckDirectoryTimes >= testTime) {
      TestUtil.tryDelete(new File(Args4Socket.checkPointDirectory))
    }
    val ssc = new StreamingContext(sc, Seconds(Args4Socket.batchSeconds))
    ssc.checkpoint(Args4Socket.checkPointDirectory)
    val lines = ssc.socketTextStream(Args4Socket.host, Args4Socket.port, StorageLevel.MEMORY_AND_DISK_SER)
    val sumCount = new SumCount
    testKeyValuePairRDD(sc, lines, sumCount, prefix)

    ssc.start()
    val startTime = new Date()
    ssc.awaitTerminationOrTimeout(Args4Socket.runningSeconds * 1000)
    var validationMessage = ""
    var isValidateOK = true
    if (Args4Socket.validateCount > 0) {
      isValidateOK = Args4Socket.validateCount == sumCount.lineCount
      validationMessage = if (isValidateOK) ". Validation OK "
      else s". Validation failed : expect ${Args4Socket.validateCount} but line count = ${sumCount.lineCount}"
    }

    ssc.stop(false)
    log(s"End test${timesInfo}, used time = ${(new Date().getTime - startTime.getTime) / 1000.0} s. total cost ${(new Date().getTime - beginTime.getTime) / 1000.0} s."
      + s" reduced final sumCount = { ${sumCount} } ${validationMessage}"
      + s"; ${TestUtil.getMemoryInfo()}"
    )

    if (!isValidateOK) {
      Args4Socket.print("Trace arg :")
      throw new Exception(validationMessage)
    }
    sumCount
  }

  def testKeyValuePairRDD(sc: SparkContext, lines: DStream[String], sumCount: SumCount, prefix: String, suffix: String = ".txt"): Unit = {
    val isByKey = Args4Socket.methodName.compareToIgnoreCase("reduceByKey") == 0
    if (!Args4Socket.isArrayValue) {
      val pairs = lines.map(line => new ParseKeyValue(0).parse(line))
      val reducedStream = if (isByKey) pairs.reduceByKey((a, b) => Sum(a, b))
      else pairs.reduceByKeyAndWindow((a, b) => Sum(a, b), (a, b) => InverseSum(a, b), Seconds(Args4Socket.windowSeconds), Seconds(Args4Socket.slideSeconds))
      ForEachRDD("KeyValue", reducedStream, sumCount, prefix, suffix)
    }
    else {
      val pairs = if (Args4Socket.isUnevenArray) lines.map(line => new ParseKeyValueUnevenArray(Args4Socket.elementCount).parse(line))
      else lines.map(line => new ParseKeyValueArray(Args4Socket.elementCount).parse(line)) //{ val kv = new ParseKeyValueArray(elementCount).parse(line) ; new Tuple2[String, Array[Int]]("mykey", kv._2) })
      val reducedStream = if (isByKey) pairs.reduceByKey((a, b) => new SumReduceHelper(Args4Socket.checkArray) SumArray(a, b))
      else pairs.reduceByKeyAndWindow((a, b) => new SumReduceHelper(Args4Socket.checkArray).SumArray(a, b),
        (a, b) => new SumReduceHelper(Args4Socket.checkArray).InverseSumArray(a, b), Seconds(Args4Socket.windowSeconds), Seconds(Args4Socket.slideSeconds))
      val title = if (Args4Socket.isUnevenArray) "KeyValueUnevenArray" else "KeyValueArray"
      ForEachRDD(title, reducedStream, sumCount, prefix, suffix)
    }
  }

  def ForEachRDD[V](title: String, reducedStream: DStream[Tuple2[String, V]], sumCount: SumCount, prefix: String, suffix: String = ".txt"): Unit = {
    log("ForEachRDD " + title)
    //    val arr = new ArrayBuffer[Int]
    //    reducedStream.foreachRDD((rdd, time) => {
    //      val nv = rdd.collect().map(_._2 match {
    //        case arr: Array[Int] => arr(0)
    //        case ele: Int => ele
    //        case _ => throw new IllegalArgumentException(s"illegal value type in reduce")
    //      })
    //      arr ++= nv
    //    })
    //
    //    val arrSum = arr.sum[Int]
    //    Log(s"arrSum = ${arrSum}, arr.length = ${arr.length}")

    //    reducedStream.foreachRDD((rdd, time) => {
    //      val sum = new SumReduceHelper(Args4Socket.checkArray).forechRDD(rdd, time)
    //      sumCount.setCount(sum)
    //    })

    reducedStream.foreachRDD((rdd, time) => {
      sumCount.add(0, 1, 0)
      var taken = rdd.collect()
      for (record <- taken) {
        val kv = record.asInstanceOf[Tuple2[String, Array[Int]]]
        sumCount.add(kv._2(0), 0, 1)
        log(s"record key = ${kv._1} , ${TestUtil.GetValueText(kv._2, "value")}, sum : ${sumCount.toString()}")
      }
    })

    //    log(s"${title} lineCount = ${lineCount}, rddCount = ${rddCount}, recordCount = ${recordCount}, sumCount = ${sumCount}")
    if (Args4Socket.saveTxtDirectory.length > 0) {
      val header = new File(Args4Socket.saveTxtDirectory, prefix).toString
      reducedStream.saveAsTextFiles(header, suffix)
    }
  }

  def Sum(a: Int, b: Int): Int = {
    log(s"Sum: ${a} + ${b} = ${a + b}")
    a + b
  }

  def InverseSum(a: Int, b: Int): Int = {
    log(s"InverseSum : ${a} - ${b} = ${a - b}")
    a - b
  }

  def SumArray(a: Array[Int], b: Array[Int]): Array[Int] = {
    val checkArrayBeforeSum = Args4Socket.checkArray
    log(s"SumArray() ${TestUtil.ArrayToText("a", a)} + ${TestUtil.ArrayToText("b", b)} , checkArrayBeforeSum = ${checkArrayBeforeSum}")
    if (checkArrayBeforeSum) {
      if (a == null || b == null) {
        return if (a == null) b else a
      }
      else if (a.length == 0 || b.length == 0) {
        return if (a.length == 0) b else a
      }
    }
    var count = if (checkArrayBeforeSum) math.min(a.length, b.length) else a.length
    var c = new Array[Int](count)
    for (k <- 0 until c.length) {
      c(k) = a(k) + b(k)
    }
    log(s"SumArray() ${TestUtil.ArrayToText("a", a)} + ${TestUtil.ArrayToText("b", b)} = ${TestUtil.ArrayToText("c", c)}")
    c
  }

  def InverseSumArray(a: Array[Int], b: Array[Int]): Array[Int] = {
    val checkArrayBeforeSum = Args4Socket.checkArray
    log(s"InverseSumArray ${TestUtil.ArrayToText("a", a)} - ${TestUtil.ArrayToText("b", b)}, checkArrayBeforeSum = ${checkArrayBeforeSum}")
    if (checkArrayBeforeSum) {
      if (a == null || b == null) {
        return if (a == null) b else a
      }
      else if (a.length == 0 || b.length == 0) {
        return if (a.length == 0) b else a
      }
    }
    var count = if (checkArrayBeforeSum) math.min(a.length, b.length) else a.length
    var c = new Array[Int](count)
    for (k <- 0 until c.length) {
      c(k) = a(k) - b(k)
    }
    log(s"InverseSumArray() ${TestUtil.ArrayToText("a", a)} - ${TestUtil.ArrayToText("b", b)} = ${TestUtil.ArrayToText("c", c)}")
    c
  }
}
