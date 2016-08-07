package lzTest.CommonUtil

import java.io.Serializable
import java.util

import org.apache.spark.rdd.RDD
import org.apache.spark.streaming.Time

/**
  * Created by qualiu on 6/27/2016.
  */
class SumCount extends Serializable {
  var lineCount = 0
  var rddCount = 0
  var recordCount = 0
  var keySet = new util.HashSet[String]

  def setCount(countAll: Int, countRdd: Int, countRecord: Int): SumCount = {
    lineCount = countAll
    rddCount = countRdd
    recordCount = countRecord
    this
  }

  def setCount(countAll: Int, countRdd: Int, countRecord: Int, keys: util.HashSet[String]): SumCount = {
    setCount(countAll, countRdd, countRdd)
    keySet = new util.HashSet[String]()
    if (keys != null) {
      keySet.addAll(keys)
    }
    this
  }

  def add(addLine: Int = 0, addRdd: Int = 0, addRecord: Int = 0): SumCount = {
    lineCount += addLine
    rddCount += addRdd
    recordCount += addRecord
    this
  }

  def addKey(key: String): SumCount = {
    keySet.add(key)
    this
  }

  def addKeys(keys: util.Collection[String]): SumCount = {
    keySet.addAll(keys)
    this
  }

  def setCount(sum: SumCount): SumCount = {
    setCount(sum.lineCount, sum.rddCount, sum.recordCount)
    this
  }

  override def toString(): String = {
    s"Lines = ${lineCount} , RDDs = ${rddCount}, Records = ${recordCount}, Keys = ${keySet.size()}"
  }

  def +(that: SumCount) =
    new SumCount().setCount(this.lineCount + that.lineCount, this.rddCount + that.rddCount, that.recordCount + that.recordCount, keySet).addKeys(that.keySet)

  def -(that: SumCount): SumCount = {
    val sum = new SumCount().setCount(this.lineCount - that.lineCount, this.rddCount - that.rddCount, that.recordCount - that.recordCount, this.keySet)
    sum.keySet.removeAll(that.keySet)
    sum
  }
}

class SumReduceHelper(val checkArrayBeforeSum: Boolean = true) extends Serializable with LogBase {
  def forechRDD[V](rdd: RDD[V], time: Time): SumCount = {
    val Counts = new SumCount
    Counts.rddCount += 1
    var taken = rdd.collect()
    for (record <- taken) {
      val kv = record.asInstanceOf[Tuple2[String, Array[Int]]]
      Counts.lineCount += kv._2(0)
      Counts.recordCount += 1
      log(s"record key = ${kv._1} , value = ${TestUtil.GetValueText(kv._2, "value")}, sum count : ${Counts.toString()}")
    }
    Counts
  }

  def SumArray(a: Array[Int], b: Array[Int]): Array[Int] = {
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
