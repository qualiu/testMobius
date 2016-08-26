package lzTest

import java.io.File
import java.nio.file.Paths
import java.util.Date

import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.dstream.DStream
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._
import org.apache.spark.streaming.dstream._

import scala.collection.mutable.ArrayBuffer
import scala.reflect.io.Path

//import NameOf._

/**
  * Hello world!
  *
  */
object TxtStreamTest extends LogBase {

  def main(args: Array[String]): Unit = {
    val jar = new File(TxtStreamTest.getClass().getProtectionDomain().getCodeSource().getLocation().toURI().getPath())
    var textDirectory = ""
    var fileType = "*.csv"
    var testTimes = 1
    var testIntervalSeconds = 0

    if (args.length < 1) {
      println(s"Usage   : ${jar} file-directory  [file-type:${fileType}] [Test-times: 1] [Test-interval: 0 seconds]")
      println(s"Example : ${jar} D:\\cosmos  *.csv")
      return
    }

    val parser = new ArgsParser()
    textDirectory = parser.getArgValue(args, "textDirectory", textDirectory, false)
    fileType = parser.getArgValue(args, "fileType", fileType)
    testTimes = parser.getArgValue(args, "testTimes", testTimes)
    testIntervalSeconds = parser.getArgValue(args, "testIntervalSeconds", testIntervalSeconds)

    //val pathPattern = Paths.get(textDirectory.replaceFirst("[\\\\/]+$", "")).toString + "/" + fileType
    val pathPattern = textDirectory.replaceFirst("[\\\\/]+$", "") + "/" + fileType
    val beginForAll = new Date

    for (times <- 1 to testTimes) {
      log(s"Begin test[${times}]-${testTimes} : will read text stream : ${pathPattern} ; ${TestUtil.getMemoryInfo()}")
      val beginTime = new Date
      val conf = new SparkConf()
      val sc = new SparkContext(conf)
      var mappingRDD = sc.textFile(pathPattern).map(line => line).cache()
      log(s"End test[${times}]-${testTimes} : RDD count = ${mappingRDD.count()} , used time = ${(new Date().getTime - beginTime.getTime) / 1000.0} s. ${TestUtil.getMemoryInfo()}")
      mappingRDD.unpersist()
      sc.stop()
      if (testIntervalSeconds > 0 && times < testTimes) {
        Thread.sleep(testIntervalSeconds * 1000)
      }
    }
    log(s"Finished all test of ${this.getClass.getCanonicalName}, test times = ${testTimes}, interval = ${testIntervalSeconds} s."
      + s"used time = ${(new Date().getTime - beginForAll.getTime) / 1000.0} s, read = ${pathPattern}"
      + s"; ${TestUtil.getMemoryInfo()}"
    )
  }
}
