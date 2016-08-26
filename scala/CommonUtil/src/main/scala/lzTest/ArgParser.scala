package lzTest

//import org.scala_tools.javautils.Implicits._
//import scalaj.collection.Imports._
import scala.collection.JavaConverters._
import org.kohsuke.args4j.{CmdLineException, CmdLineParser, Option => Option4J}

/**
  * Created by qualiu on 6/28/2016.
  */

/*
import org.apache.commons.cli.{Options, Option => CmdOption}

object ArgParserApacheCLI {
  val host = new CmdOption("H", "host", true, "host")
  val port = new CmdOption("p", "port", true, "port")
  val batchSeconds = new CmdOption("b", "batchSeconds", true, "batch seconds")
  val windowSeconds = new CmdOption("w", "windowSeconds", true, "window seconds")
  val slideSeconds = new CmdOption("s", "slideSeconds", true, "slide seconds")
  val runningSeconds = new CmdOption("r", "runningSeconds", true, "running seconds")
  val testTimes = new CmdOption("t", "testTimes", true, "test times")
  val checkPointDirectory = new CmdOption("c", "checkPointDirectory", true, "check point directory")
  val deleteCheckDirectoryTimes = new CmdOption("d", "deleteCheckDirectoryTimes", 0, "dtimes to delete check point directory before each test")
  val methodName = new CmdOption("m", "methodName", true, "method name, such as reduceByKeyAndWindow")
  val isArrayValue = new CmdOption("a", "isArrayValue", true, "is value type array")
  val isUnevenArray = new CmdOption("u", "isUnevenArray", true, "is uneven array value")
  val elementCount = new CmdOption("e", "elementCount", true, "element count in value array")
  val saveTxtDirectory = new CmdOption("f", "saveTxtDirectory", true, "save file directory, not save if empty.")
  val checkArray = new CmdOption("k", "checkArray", true, "check array before operation such as reduce.")
  val validateCount = new CmdOption("v", "validateCount", true, "line count to validate with, ignore if < 0 ")
}
*/

object Args4Socket {
  // .Option.'(\w+)'\s*,\s*"(\w+)".*?DefaultValue\s*=\s*(\S+).*?HelpText\s*=\s*"([^"]+)".*?[\r\n]+\s*public (\w+) (\w+).*?[\r\n]+
  // @Option4J(name = "-$1", usage = "$4")
  // var $2 : $5 = $3
  @Option4J(name = "-H", usage = "host")
  var host: String = "127.0.0.1"

  @Option4J(name = "-p", usage = "port", required = true)
  var port: Int = 9111

  @Option4J(name = "-b", usage = "batch seconds")
  var batchSeconds: Int = 1

  @Option4J(name = "-w", usage = "window seconds")
  var windowSeconds: Int = 4

  @Option4J(name = "-s", usage = "slide seconds")
  var slideSeconds: Int = 4

  @Option4J(name = "-r", usage = "running seconds")
  var runningSeconds: Int = 30

  @Option4J(name = "-t", usage = "test times")
  var testTimes: Int = 1

  @Option4J(name = "-c", usage = "check point directory")
  var checkPointDirectory: String = "checkDir"

  @Option4J(name = "-d", usage = "times to delete check point directory before each test")
  var deleteCheckDirectoryTimes: Int = 0

  @Option4J(name = "-m", usage = "method name, such as reduceByKeyAndWindow")
  var methodName: String = "reduceByKeyAndWindow"

  @Option4J(name = "-a", usage = "is value type array")
  var isArrayValue: Boolean = true

  @Option4J(name = "-u", usage = "is uneven array value")
  var isUnevenArray: Boolean = false

  @Option4J(name = "-e", usage = "element count in value array")
  var elementCount: Int = 0 // 1024 * 1024 * 20

  @Option4J(name = "-f", usage = "save file directory, not save if empty.")
  var saveTxtDirectory: String = ""

  @Option4J(name = "-k", usage = "check array before operation such as reduce.")
  var checkArray: Boolean = true

  @Option4J(name = "-v", usage = "line count to validate with, ignore if < 0 ")
  var validateCount: Long = -1

  def print(header: String = "Parsed arg : "): Unit = {
    println(s"${header} host = ${host}")
    println(s"${header} port = ${port}")
    println(s"${header} batchSeconds = ${batchSeconds}")
    println(s"${header} windowSeconds = ${windowSeconds}")
    println(s"${header} slideSeconds = ${slideSeconds}")
    println(s"${header} runningSeconds = ${runningSeconds}")
    println(s"${header} testTimes = ${testTimes}")
    println(s"${header} checkPointDirectory = ${checkPointDirectory}")
    println(s"${header} deleteCheckDirectoryTimes = ${deleteCheckDirectoryTimes}")
    println(s"${header} methodName = ${methodName}")
    println(s"${header} isArrayValue = ${isArrayValue}")
    println(s"${header} isUnevenArray = ${isUnevenArray}")
    println(s"${header} elementCount = ${elementCount}")
    println(s"${header} saveTxtDirectory = ${saveTxtDirectory}")
    println(s"${header} checkArray = ${checkArray}")
    println(s"${header} validateCount = ${validateCount}")
  }
}

object ArgParser4J {
  val parser = new CmdLineParser(Args4Socket)

  def parse(args: Array[String]): Unit = {
    try {
      parser.parseArgument(args.toList.asJava)
    } catch {
      case ex: CmdLineException =>
        println(s"Error parsing args, exception : ${ex.getMessage}")
        parser.printUsage(System.out)
        System.exit(1)
    }
    Args4Socket.print()
  }
}