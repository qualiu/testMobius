package lzTest

import java.io.File

import kafka.serializer.{DefaultDecoder, StringDecoder}
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat
import org.apache.spark.SparkContext
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.Seconds
import org.apache.spark.streaming.dstream.DStream
import org.apache.spark.streaming.kafka.{HasOffsetRanges, KafkaUtils, OffsetRange}

//import org.apache.spark.examples.streaming.StreamingExamples
//import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat

import org.apache.spark.SparkConf
import org.apache.spark.streaming.{Duration, StreamingContext}

import scala.collection.immutable.Map

//import org.apache.spark.streaming.kafka.KafkaCluster.{LeaderOffset, Err};
//import org.apache.log4j.Logger;

import java.text.SimpleDateFormat
import java.util.Date

import org.slf4j.LoggerFactory
import org.apache.hadoop.mapreduce.lib.output;

object KafkaStreamTest extends LogBase {
  //private lazy val logger = LoggerFactory.getLogger(this.getClass.getCanonicalName)

  def main(args: Array[String]) {
    ArgParser4J.parse(args)
    log(s"batchSeconds = ${Args4Kafka.batchSeconds} s, windowSeconds = ${Args4Kafka.windowSeconds} s. slideSeconds = ${Args4Kafka.slideSeconds} s, checkpointDirectory = ${Args4Kafka.checkPointDirectory}")
    val beginForAll = new Date
    for (times <- 1 to Args4Kafka.testTimes) {
      startOneTest(times)
      if (Args4Kafka.testIntervalSeconds > 0 && times < Args4Kafka.testTimes) {
        log(s"Will sleep testIntervalSeconds = ${Args4Kafka.testIntervalSeconds} s ...")
        Thread.sleep(Args4Kafka.testIntervalSeconds * 1000)
      }
    }

    log(s"Finished all tests of ${this.getClass.getCanonicalName}, test times = ${Args4Kafka.testTimes}, interval = ${Args4Kafka.testIntervalSeconds} s."
      + s"used time = ${(new Date().getTime - beginForAll.getTime) / 1000.0} s. ${TestUtil.getMemoryInfo()}")
  }

  def startOneTest(testTime: Int): Unit = {
    log(s"Begin test[${testTime}]-${Args4Kafka.testTimes} : ${TestUtil.getMemoryInfo()}")
    if (Args4Kafka.deleteCheckDirectoryTimes >= testTime) {
      TestUtil.tryDelete(new File(Args4Kafka.checkPointDirectory))
    }

    val prefix = KafkaStreamTest.getClass.getCanonicalName + "-"
    val beginTime: java.util.Date = new Date()
    val sparkConf = new SparkConf()
    var sc = new SparkContext(sparkConf)

    val kafkaParams = Map[String, String](
      "group.id" -> Args4Kafka.groupId,
      "metadata.broker.list" -> Args4Kafka.brokerList,
      "auto.offset.reset" -> Args4Kafka.autoOffset,
      //"zookeeper.session.timeout.ms" -> "200",
      //"zookeeper.sync.time.ms" -> "6000"
      //"auto.commit.interval.ms" -> "1000",
      //"serializer.class" -> "kafka.serializer.StringEncoder"
      "zookeeper.connect" -> Args4Kafka.zookeeper,
      "zookeeper.connection.timeout.ms" -> "1000"
    )

    val sumCount = new SumCount
    val streamingContext = StreamingContext.getActiveOrCreate(Args4Kafka.checkPointDirectory, () => {
      val ssc = new StreamingContext(sc, Seconds(Args4Kafka.batchSeconds))
      ssc.checkpoint(Args4Kafka.checkPointDirectory)
      val lines = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, Set(Args4Kafka.topic)).map(line => line._2) //.flatMap(line => line._2)
      val pairs = lines.map(line => new ParseKeyValueArray().parse(line))
      val reducedStream = pairs.reduceByKeyAndWindow(
        (a, b) => new SumReduceHelper(Args4Kafka.checkArray).SumArray(a, b),
        (a, b) => new SumReduceHelper(Args4Kafka.checkArray).InverseSumArray(a, b), Seconds(Args4Kafka.windowSeconds), Seconds(Args4Kafka.slideSeconds))
      ForEachRDD("test-kafka-RDD", reducedStream, sumCount, prefix)
      ssc
    })

    streamingContext.start()
    //logger.debug("lzdbg : started, awaitTermination() for test")
    if (Args4Kafka.runningSeconds > 0) {
      streamingContext.awaitTerminationOrTimeout(Args4Kafka.runningSeconds * 1000)
    } else {
      streamingContext.awaitTermination()
    }

    log(s"End test[${testTime}]-${Args4Kafka.testTimes} : used time = " +
      s"${(new Date().getTime - beginTime.getTime) / 1000.0} s. total cost = ${(new Date().getTime - beginTime.getTime) / 1000.0} s."
      + s" reduced final sumCount = { ${sumCount} }"
      + s"; ${TestUtil.getMemoryInfo()}"
    )

    streamingContext.stop(true)
  }

  def ForEachRDD[V](title: String, reducedStream: DStream[Tuple2[String, V]], sumCount: SumCount, prefix: String, suffix: String = ".txt"): Unit = {
    log("ForEachRDD " + title)
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
    if (Args4Kafka.saveTxtDirectory.length > 0) {
      val header = new File(Args4Kafka.saveTxtDirectory, prefix).toString
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
    val checkArrayBeforeSum = Args4Kafka.checkArray
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
    val checkArrayBeforeSum = Args4Kafka.checkArray
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
