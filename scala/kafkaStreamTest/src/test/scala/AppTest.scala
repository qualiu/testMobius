package lzTest

import java.text.SimpleDateFormat
import java.util.Date

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.kafka.KafkaUtils
import org.apache.spark.streaming.{Duration, StreamingContext}
import org.junit._
import org.slf4j.LoggerFactory

@Test
class AppTest {

  private lazy val logger = LoggerFactory.getLogger("siphon-test-log")

  @Test
  def testOK() {
    return;

    println("lzdbg : ---------begin AppTest ----------------------")

    //final String ZOOKEEPER_CONNECTION = "BN2SCH010000737:2181,BN2SCH010010140:2181,BN2SCH010010562:2181,BN2SCH010010646:2181,BN2SCH010020126:2181"
    //val ZOOKEEPER_CONNECTION = "CO3SCH010022024:2181"
    val ZOOKEEPER_CONNECTION = "BN2SCH010000737:2181"
    val CUSTOMER = "ODL"
    val TOPIC_SDF = "EXO_SDF_EventLogs4"
    val GROUP_SDF = "ODLEXO_SDF_EventLogs4"
    val TOPIC_PROD = "EXO_PROD_EventLogs4"
    val GROUP_PROD = "ODLEXO_PROD_EventLogs4"

    val zookeeperConnection = ZOOKEEPER_CONNECTION
    val customer = CUSTOMER
    val topics = TOPIC_SDF
    val threads = 1

    println("lzdbg : zookeeper = " + zookeeperConnection)
    println("lzdbg : customer = " + customer)
    println("lzdbg : topic = " + topics)
    println("lzdbg : threads = " + threads)

    val timeFormat = new SimpleDateFormat("yyyy-MM-dd__HH_mm_ss")

    val startTime: java.util.Date = new Date()

    //val siphonEnv: SiphonEnvironment = null
    //println("done65")
    val sparkConf = new SparkConf().setAppName("AppTest")
    //val jsc = new JavaStreamingContext(sparkConf, new Duration(200))
    //val sc = new StreamingContext(sparkConf, Seconds(2))
    val sc = new StreamingContext(sparkConf, new Duration(200))
    println("lzdbg : Created streaming context")
    //  val topics = new HashMap[String, Integer]
    //  topics.put("O365_security_analysis", 1)

    println("lzdbg : creating kafka stream")
    //val stream: JavaPairReceiverInputDStream[String, String] = KafkaUtils.createStream(sc, ZOOKEEPER_CONNECTION, "O365_sa", topicsMap)
    // AdsSiphon-Prod-Bn2:9092,AdsSiphon-Prod-Ch1d:9092,AdsSiphon-Prod-Co3:9092,AdsSiphon-Prod-DB4:9092,AdsSiphon-Prod-HK2:9092
    // BN2SCH010000737:9092,BN2SCH010010140:9092,BN2SCH010010562:9092,BN2SCH010010646:9092,BN2SCH010020126:9092
    val kafkaParams = Map[String, String](
      "metadata.broker.list" -> "localhost:9092",
      "auto.offset.reset" -> "smallest",
      //"zookeeper.session.timeout.ms" -> "200",
      //"zookeeper.sync.time.ms" -> "6000"
      //"auto.commit.interval.ms" -> "1000",
      //"serializer.class" -> "kafka.serializer.StringEncoder"
      "zookeeper.connect" -> ZOOKEEPER_CONNECTION //"localhost:2181",
    )
    //    val topics = Set("myTopic")
    //val (topic, groupId) = (args(0), args(1))
    //val kafkaParams = Map("zookeeper.connect" -> "http://www.iteblog.com:2181",  "group.id" -> groupId, "auto.offset.reset" -> "smallest")

    val topicMap = Map(TOPIC_SDF -> 1)
    //val topicMap = topics.split(",").map((_,threads)).toMap
    // val topicMap = topicSet.map((_,threads)).toMap
    //val stream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](sc, kafkaParams, topicSet)

    //val header = "hdfs://Co3B/user/amiravr/qualiu/"
    val header = "hdfs://BN1/user/qualiu/"
    var number = 1

    // method-1
    //    val lines = KafkaUtils.createStream(sc, kafkaParams, topicMap,StorageLevel.MEMORY_AND_DISK_SER).map( (key, value)=> {
    //
    //    })

    // method-2
    println("lzdbg : method2 : try map streaming")
    //val stream = KafkaUtils.createStream(sc, zookeeperConnection, GROUP_SDF, topicMap) //, StorageLevel.MEMORY_AND_DISK_SER)
    val stream = KafkaUtils.createStream(sc, kafkaParams, topicMap, StorageLevel.MEMORY_AND_DISK_SER)
    println("lzdbg : try to save to file")
    //stream.saveAsHadoopFiles(header + "out/streamclass", classOf[String], classOf[String], classOf[RDDMultipleTextOutputFormat])
    stream.saveAsTextFiles(header + "out/stream-", "txt") // failed all
    //stream.saveAsHadoopFiles(header + "out/streamhdf", "txt") // failed
    //stream.saveAsNewAPIHadoopFiles(header + "out/streamhdfNew", "txt")
    //    val keyClass = getWritableClass[K]
    //    val valueClass = getWritableClass[V]
    //    val convertKey = !classOf[Writable].isAssignableFrom(self.getKeyClass)
    //    val convertValue = !classOf[Writable].isAssignableFrom(self.getValueClass)
    //    stream.saveAsHadoopFiles(header + "out/stream-", classOf[Text], classOf[Text], classOf[TextOutputFormat[Text, IntWritable]])
    //stream.saveAsHadoopFiles("hdfs://BN1/user/qualiu/out/stream-", classOf[Text], classOf[IntWritable], classOf[TextOutputFormat[String,String]])
    //stream.saveAsNewAPIHadoopFiles(header + "out/stream-", "txt")

    //stream.saveAsNewAPIHadoopFiles(hdfsDataUrl, "csv", classOf[String], classOf[String], classOf[TextOutputFormat[String,String]], sc.sparkContext.hadoopConfiguration)
    //
    //    val keyClass = getWritableClass[K]
    //    val valueClass = getWritableClass[V]
    //    val convertKey = !classOf[Writable].isAssignableFrom(self.getKeyClass)
    //    val convertValue = !classOf[Writable].isAssignableFrom(self.getValueClass)
    //    val format = classOf[SequenceFileOutputFormat[Writable, Writable]]
    //    //stream.saveAsHadoopFiles("/user/amiravr/output/edge", "csv", String.class, String.class, TextOutputFormat.class)

    //    //stream.saveAsHadoopFiles()
    //    var lines = stream.map(_._2)
    //    //lines.saveAsHadoopFile("hdfs://BN1/user/qualiu/out/lines-", classOf[Text], classOf[IntWritable], classOf[TextOutputFormat])
    //    lines.saveAsTextFiles("user/qualiu/out/lines-", "txt")
    //    //lines.saveAsTextFiles("hdfs://BN1/user/qualiu/out/lines-", "txt")
    //    //lines.saveAsHadoopFile(path, keyClass, valueClass, format)
    //    //counts.saveAsHadoopFile("/user/qualiu/out", Text.class, IntWritable.class, TextOutputFormat.class)

    //    println("lzdbg : try print lines")
    //    println("lzdbg out: try print lines")
    //    lines.print()
    //
    //    val msgCount = lines.map(x => (x, 1)).reduceByKey(_ + _)
    //    println("lzdbg : try print counts")
    //    println("lzdbg out: try print counts")
    //    msgCount.print()

    //    val name = "/user/qualiu/out/o365-" + timeFormat.format(startTime) // hdfs:///user/qualiu/out/test.txt
    //    println("read lines = " + lines + " , save to " + name)
    //    lines.saveAsTextFiles(name, ".txt")
    //    lines.saveAsObjectFiles(name, ".obj")

    //    if (null == lines) {
    //      sys.error("get null lines.\n")
    //    } else  {
    //      println("get lines.count = " + lines.count())
    //    }

    //    stream.foreachRDD(rdd => {
    //      val offsetsList = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
    //      val kc = new KafkaCluster(kafkaParams)
    //      for (offsets < - offsetsList) {
    //        val topicAndPartition = TopicAndPartition("iteblog", offsets.partition)
    //        val o = kc.setConsumerOffsets(args(0), Map((topicAndPartition, offsets.untilOffset)))
    //        if (o.isLeft) {
    //          println(s"Error updating the offset to Kafka cluster: ${o.left.get}")
    //        }
    //      }
    //    })


    //    val words = messages.flatMap(_.split(" "))
    //    val wordCounts = words.map(x => (x, 1L)).reduceByKey(_ + _)
    //    wordCounts.print()

    //    //kafkaStream.print();
    //    //stream.saveAsHadoopFiles("/user/qualiu/output", "0365_sa_file")
    //
    //    println("before map")
    //
    //    //        JavaDStream<String> messages = kafkaStream.map(new Function<Tuple2<String, String>, String>() {
    //    //            @Override
    //    //            public String call(Tuple2<String, String> tuple2) {
    //    //                System.out.println("map " + tuple2._1() + " " + tuple2._2());
    //    //                return tuple2._2();
    //    //            }
    //    //        });
    //    println("before count")
    //
    //    //        JavaDStream<Long> count = kafkaStream.count();
    //    //        count.print();
    //    //        System.out.println(count.p);

    sc.start()
    println("lzdbg : started, awaitTermination() for test")
    sc.awaitTerminationOrTimeout(300000)
    val endTime = new Date()
    val usedTime = endTime.getTime() - startTime.getTime()
    println("lzdbg : streaming finished. used " + usedTime + " ms.")
  }

  //    @Test
  //    def testKO() = assertTrue(false)

}


