package lzTest

import java.text.SimpleDateFormat
import java.util.Date
import java.util.regex.Pattern
import java.io.{File}

import scala.reflect.runtime.universe._
import scala.reflect.ClassTag

//import scala.reflect.api.TypeTags.TypeTag
/**
  * Created by qualiu on 6/20/2016.
  */

trait LogBase extends Serializable {
  def log(message: String): Unit = {
    println(s"${TestUtil.NowMilli} : ${this.getClass.getName} $message")
  }
}

object TestUtil {
  val TimeFomart = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
  val MilliFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")

  def NowMilli(): String = {
    MilliFormat.format(new Date())
  }

  def getMemoryInfo(): String = {
    val GB: Double = 1024 * 1024 * 1024
    val runtime = Runtime.getRuntime
    val format = "%.2f"
    s"Used Memory = ${format.format((runtime.totalMemory - runtime.freeMemory) / GB)} GB" +
      s", Free Memory = ${format.format(runtime.freeMemory / GB)} GB" +
      s", Total Memory = ${format.format(runtime.totalMemory / GB)} GB" +
      s", Max Memory = ${format.format(runtime.maxMemory / GB)} GB"
  }

  def ArrayToText[T](arrayName: String, array: Array[T], takeMaxElementCount: Int = 9): String = {
    if (array == null) {
      s"${arrayName}[] = null"
    }
    else if (array.length == 0) {
      s"${arrayName}[0] = " + array
    }
    else if (array.length <= takeMaxElementCount) {
      s"${arrayName}[${array.length}] = " + array.mkString(", ")
    }
    else {
      s"${arrayName}[${array.length}] = " + array.take(takeMaxElementCount).mkString(", ") + ", ... , " + array.last
    }
  }

  def GetValueText[T](value: T, name: String = ""): String = {
    if (value == null) {
      null
    }
    else if (value.isInstanceOf[Int]) {
      value.toString
    }
    else if (value.isInstanceOf[Array[Int]]) {
      TestUtil.ArrayToText(name, value.asInstanceOf[Array[Int]])
    }
    else {
      value.toString
    }
  }

  def delete(path: File) {
    if (path.isDirectory)
      Option(path.listFiles).map(_.toList).getOrElse(Nil).foreach(delete(_))
    path.delete
  }

  def tryDelete(path: File): Unit = {
    try {
      TestUtil.delete(path)
      println(s"Deleted path : ${path}")
    } catch {
      case ex: Exception =>
        println(s"Failed to delete path : ${path}:")
        ex.printStackTrace(System.out)
    }
  }
}