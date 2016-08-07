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
    var needCallMap = true

    if (args.length < 1) {
      println(s"Usage   : ${jar} file-directory  [file-type: default = ${fileType}]  [need-call-map() : default = ${needCallMap}]")
      println(s"Example : ${jar} D:\\cosmos  *.csv")
      return
    }

    val parser = new ArgsParser()
    textDirectory = parser.getArgValue(args, "textDirectory", textDirectory, false)
    fileType = parser.getArgValue(args, "fileType", fileType)
    needCallMap = parser.getArgValue(args, "needCallMap", needCallMap)

    //val pathPattern = Paths.get(textDirectory.replaceFirst("[\\\\/]+$", "")).toString + "/" + fileType
    val pathPattern = textDirectory.replaceFirst("[\\\\/]+$", "") + "/" + fileType

    log(s"Will read text stream : ${pathPattern}")
    var beginTime = new Date

    val conf = new SparkConf().setAppName(this.getClass.getCanonicalName)
    val sc = new SparkContext(conf)
    //val mappingRDD = sc.textFile(pathPattern).map(line => line).cache()
    var mappingRDD = sc.textFile(pathPattern)
    if (needCallMap) {
      mappingRDD = mappingRDD.map(line => line)
    }
    mappingRDD = mappingRDD.cache()
    log(s"RDD count = ${mappingRDD.count()}")
    mappingRDD.unpersist()
    log(s"Finished ${this.getClass.getCanonicalName} , used time = ${(new Date().getTime - beginTime.getTime) / 1000.0} s, needCallMap = ${needCallMap}, read = ${pathPattern}")
  }
}
