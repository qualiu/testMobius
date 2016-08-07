package lzTest

import java.util.Calendar

import org.apache.commons.lang.NotImplementedException

import scala.util.Random
import scala.util.matching.Regex

/**
  * Created by qualiu on 6/22/2016.
  */

abstract class ParseKeyValuePairBase[ValueType](val valueArrayElements: Int = 0, val needPrintMessage: Boolean = true) extends LogBase {
  //  def log(message: String): Unit = {
  //    println(s"${TestUtil.NowMilli} : ${this.getClass.getName} $message")
  //  }

  def parse(line: String): Tuple2[String, ValueType] = {
    throw new NotImplementedException
  }

  def printTuple(kv: Tuple2[String, Array[Int]]): Unit = {
    if (needPrintMessage) {
      log(s"key = ${kv._1} , ${TestUtil.ArrayToText("value", kv._2)}")
    }
  }

  // 2016-06-23 00:16:17.601276 from 'Microsoft Windows NT 6.2.9200.0' 'QUAPC' 127.0.0.1 times[1] send message[57] to 10.172.120.118:1982 : tick = 636022377776012761
  def parseToArray(line: String, elements: Int): Tuple2[String, Array[Int]] = {
    log(s"received line = ${line}")
    // val regLine = new Regex("""^.*tick\s*=\s*(?<Key>\d{9})(?<Value>\d+)""", "Key", "Value")
    val regLine = new Regex("""^([\d-]+ [\d:]+)\.(\d+)""", "Key", "Value")
    val matched = regLine.findFirstMatchIn(line).get
    val key = matched.group("Key")
    val valueSet = """\d""".r.findAllMatchIn(matched.group("Value")).toArray
    val values = new Array[Int](math.max(1, elements))
    for (k <- 0 until math.min(valueSet.length, values.length)) {
      values(k) = 1 // valueSet(k).group(0).toInt
    }
    new Tuple2[String, Array[Int]](key, values)
  }
}

class ParseKeyValueArray(valueArrayElements: Int = 0, needPrintMessage: Boolean = true)
  extends ParseKeyValuePairBase[Array[Int]](valueArrayElements, needPrintMessage) {
  override def parse(line: String): Tuple2[String, Array[Int]] = {
    val kv = parseToArray(line, valueArrayElements)
    printTuple(kv)
    kv
  }
}

class ParseKeyValueUnevenArray(valueArrayElements: Int = 0, needPrintMessage: Boolean = true)
  extends ParseKeyValuePairBase[Array[Int]](valueArrayElements, needPrintMessage) {
  val random = new Random(System.currentTimeMillis) //new Random(Calendar.getInstance().getTimeInMillis)

  override def parse(line: String): Tuple2[String, Array[Int]] = {
    val kv = parseToArray(line, valueArrayElements)
    val values = kv._2.toList
    val removeCount = random.nextLong() % (values.length + 1)
    //values.remove(0, removeCount)
    val newArray = values.takeRight((values.length - removeCount).toInt)
    var pair = new Tuple2[String, Array[Int]](kv._1, values.toArray)
    printTuple(pair)
    pair
  }
}

class ParseKeyValue(valueArrayElements: Int = 0, needPrintMessage: Boolean = true)
  extends ParseKeyValuePairBase[Int](valueArrayElements, needPrintMessage) {
  override def parse(line: String): Tuple2[String, Int] = {
    var kv = parseToArray(line, 1)
    printTuple(kv)
    new Tuple2[String, Int](kv._1, kv._2(0))
  }
}
