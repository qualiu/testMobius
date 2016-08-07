package lzTest

import java.util.regex.Pattern

/**
  * Created by qualiu on 7/26/2016.
  */
class ArgsParser {
  //  implicit def StringToInt(x: String) : Int = x.toInt
  //  implicit def StringToDouble(x: String) : Double = x.toDouble
  private var index = -1
  val BOOL_VALUE_PATTERN = Pattern.compile("1|true", Pattern.CASE_INSENSITIVE)

  def getArgValue[ArgType: Manifest](args: Array[String], argName: String, defaultValue: ArgType, canOutOfArgs: Boolean = true): ArgType = {
    //def getArgValue[@specialized(Int, Double, Long, Float, Boolean, String) ArgType](args: Array[String], argName: String, defaultValue: ArgType, canOutOfArgs: Boolean = true): ArgType = {
    index += 1
    if (args.length > index) {
      println("args[" + index + "] : " + argName + " = " + args(index))
      var argValue = args(index)
      if (defaultValue.isInstanceOf[Boolean]) {
        argValue = BOOL_VALUE_PATTERN.matcher(argValue).find().asInstanceOf[ArgType].toString
      }
      //      println(s"return ${argValue.asInstanceOf[ArgType].getClass} = ${argValue.asInstanceOf[ArgType]} ")
      //      println(s"defaultValue type = ${defaultValue.getClass}")
      //      manifest[ArgType].erasure.cast(argValue).asInstanceOf[ArgType]
      //      argValue.asInstanceOf[ArgType]
      (defaultValue match {
        case defaultValue: Double => argValue.toDouble
        case defaultValue: Int => argValue.toInt
        case defaultValue: Float => argValue.toFloat
        case defaultValue: Long => argValue.toLong
        case defaultValue: Boolean => argValue.toBoolean
        case defaultValue: String => argValue
      }).asInstanceOf[ArgType]
    }
    else if (canOutOfArgs) {
      println("args[" + index + "] : " + argName + " = " + defaultValue)
      defaultValue
    }
    else {
      throw new IllegalArgumentException(f"must set $argName%s at arg[${index + 1}%d]")
    }
  }
}