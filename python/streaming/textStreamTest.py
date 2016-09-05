from __future__ import print_function
import sys, os, re, time
from datetime import datetime
from random import random
from operator import add

if __name__ == "__main__":
    argCount = len(sys.argv)
    if argCount < 2:
        exeName = os.path.basename(__file__)
        sys.stderr.write("Usage:     " + exeName + "  dataDir   [file-type : default -> *.csv]\n")
        sys.stderr.write("Example-1: " + exeName + "  d:\cosmos   *.csv \n")
        sys.stderr.write("Example-2: " + exeName + "  hdfs:///common/AdsData/MUID \n");
        exit(-1)
    
    dataDir = re.sub("[/\\\\]$", "", sys.argv[1])
    fileType = sys.argv[2] if argCount > 2  else "*.csv"
    dataPattern = dataDir + "/" + fileType
    print(str(datetime.now()) + " dataPattern = " + dataPattern)
    
    from pyspark import SparkContext
    beginTime = time.time()
    
    sc = SparkContext(appName="text-stream-test-python")
    rdd = sc.textFile(dataDir + "/*.csv").map(lambda line: line)
    rdd.cache()
    print(str(datetime.now()) + " RDD count = "+ str(rdd.count()))
    rdd.unpersist()
    
    print(str(datetime.now()) + " " + os.path.basename(__file__) + " Used time = " + str(time.time() - beginTime) + " s.")
    sc.stop()
    

    