# Cloud Computing Capstone Task 2: Q2.1 & Q2.2
## From the airport's point of view,
## query the top 10 airlines and destination airports in terms of average departure delay
from __future__ import print_function

import sys
import boto3
import json

from datetime import datetime, timedelta
from collections import namedtuple
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

#-----------------------------------------------------
## Module Constants
APP_NAME = "PythonStreamingDirectKafkaAirportQuery"
DATE_FMT = "%Y-%m-%d"
TIME_FMT = "%H%M"

CHECKPOINT_DIR = "airport-query-checkpoint"

# FlightDate(5), AirlineID(7), Carrier(8), FlightNum(10), Origin(11), Dest(17), 
# CRSDepTime(23), DepTime(24), DepDelay(25), 
# CRSArrTime(34), ArrTime(35), ArrDelay(36), Cancelled(41)
fields   = ('date', 'airline', 'carrier', 'flightnum', 'origin', 'dest', 'crsdep', 'dep', \
            'dep_delay', 'crsarv', 'arv', 'arv_delay', 'cancelled')
Flight   = namedtuple('Flight', fields)

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

#-----------------------------------------------------
## Stream process functionalities
def parse(row):
    '''
    Parses a row and returns a named tuple.
    '''
    if row[0] == 'FlightDate':
        return;
    
    row[0] = datetime.strptime(row[0], DATE_FMT).date()
    
    try:
        if len(row[6]) > 0:
            row[6] = datetime.strptime(row[6], TIME_FMT).time()
        else:
            row[12]='1'
    except:
        row[12]='1'
    
    try:
        if len(row[7]) > 0:
            row[7] = datetime.strptime(row[7], TIME_FMT).time()
        else:
            row[12]='1'
    except:
        row[12]='1'
        
    try:
        if len(row[8]) > 0:
            row[8] = float(row[8])
        else:
            row[8] = 0.0
    except:
        row[8]=0.0
        
    try:
        if len(row[9]) > 0:
            row[9] = datetime.strptime(row[9], TIME_FMT).time()
        else:
            row[12]='1'
    except:
        row[12]='1'
        
    try:
        if len(row[10]) > 0:
            row[10] = datetime.strptime(row[10], TIME_FMT).time()
        else:
            row[12]='1'
    except:
        row[12]='1'
    
    try:
        if len(row[11]) > 0:
            row[11] = float(row[11])
        else:
            row[11] = 0.0
    except:
        row[11] = 0.0
        
    return Flight(*row[:13])
    
#-----------------------------------------------------
## Stream process functionalities
def topAirportUpdateFunction(newValues, runningCount):
    if runningCount is None:
        runningCount = 0
    return sum(newValues, runningCount)    # add the new values with the previous running count t0 get the new count

def totalUpdateFunction(newValues, runningCount):
    if runningCount is None:
        runningCount = (0, 0)

    tv = runningCount[0]
    tc = runningCount[1]
    for value in newValues:
        tv+=value
        tc+=1
    return((tv,tc))

def minDelayUpdate(newValues, runningCount):
    if runningCount is None:
        minArrDelay = 6000.0
    else:
        minArrDelay = runningCount[3]
    
    for value in newValues:
        if value[3] < minArrDelay:
            minArrDelay = value[3]
            runningCount = value
            
    return(runningCount)        
    
#def groupTransformFunction(rdd):
    # rdd = (K1, (K2, V)) => ((K1, K2), V)
#    groupedData = rdd.map(lambda x:((x[0],x[1][0]), x[1][1]))
               
#    return(groupedData)

def topAirportSortGetTopN(rdd):
    global totalCount
    global timerCount
    global runStatus
    global dataSaved5
    
    sortedData = rdd.map(lambda x: (x[1],x[0])) \
    		    .sortByKey(ascending=False)
    topKData = sortedData.take(11)
    
    if runStatus == 2 and dataSaved5 == False:
        # Save data, and allow to exit
        table = dynamodb.Table('capstone_a1')
        with table.batch_writer() as batch:
            lc = 0
            for (a, c) in topKData:
                lc+=1
                try:
                    batch.put_item(
                           Item={
                               'key': '%i' % lc,
                               'airport': c,
                               'flights': '%i' % a
                           }
                        )                    
                except Exception, err:
                    print("Error: failed to write capstone_a1")
                    print(err)
        dataSaved5 = True
        print('capstone_a1 saved!')
    else:    
        print("Airport Flights")
        for (a, c) in topKData:
            print("%s: %i" % (c, a))
            if c == "Total":
                if a > totalCount:
                    timerCount = 0
                    totalCount = a
    
def topAirlineSortGetTopN(rdd):
    global runStatus
    global dataSaved6
    
    #sortedData = rdd.mapValues(lambda v: v[0]/v[1]) \
    #        .sortBy(lambda x: x[1], ascending=True)
    sortedData = rdd.map(lambda x: (x[1][0]/x[1][1], x[0])) \
            .sortByKey(ascending=True)
    topKData = sortedData.take(10)
    if runStatus == 2 and dataSaved6 == False:
        # Save data, and allow to exit
        table = dynamodb.Table('capstone_a2')
        with table.batch_writer() as batch:
            lc = 0
            for (value, key) in topKData:
                lc+=1
                try:
                    batch.put_item(
                           Item={
                               'key': '%d' % lc,
                               'carrier': key,
                               'avgDelay': '%.2f' % value
                           }
                        )                    
                except Exception, err:
                    print("Error: failed to write capstone_a2")
                    print(err)
        dataSaved6 = True
        print('capstone_a2 saved!')
    else:
        print("Airline Avg.Delay(mins)")
        for (value, key) in topKData:
            print("%s: %.2f" % (key, value))
        
# Group, sort and get top 10 (airlines list & airports list)
def outputQ2N1(rdd):
    # rdd = ((K1, K2), (V1, V2)) => (K1, (K2, V1/V2))
    groupedData = rdd.map(lambda x: (x[0][0], (x[0][1], x[1][0]/x[1][1]))) \
            .groupByKey()

    global runStatus
    global dataSaved1

    #topKData = groupedData.take(1)
    #print(topKData)
    
    if runStatus == 2 and dataSaved1 == False:
        # Save data, and allow to exit
        allData = groupedData.collect()
        table = dynamodb.Table('capstone_b1')
        #print("Airport Airline Delay(mins)")
        with table.batch_writer() as batch:
          for (key, value) in allData:
              sortedValue = sorted(value, key=lambda v:v[1])
              lc = 0
              for (str, num) in sortedValue:
                  lc+=1
                  #print("%s: %s %.2f" % (key, str, num))
                  try:
                      batch.put_item(
                      #table.put_item(
                             Item={
                                 'key': key+str,
                                 'airport': key,
                                 'carrier': str,
                                 'avgDepDelay': '%.2f' % num
                             }
                          )                    
                  except Exception, err:
                      print("Error: failed to write capstone_b1")
                      print(err)
                  if lc >= 10:
                      break
        dataSaved1 = True
        print('capstone_b1 saved!')

def outputQ2N2(rdd):
    # rdd = ((K1, K2), (V1, V2)) => (K1, (K2, V1/V2))
    groupedData = rdd.map(lambda x: (x[0][0], (x[0][1], x[1][0]/x[1][1]))) \
            .groupByKey()

    global runStatus
    global dataSaved2

    #topKData = groupedData.take(1)
    #print(topKData)
    
    if runStatus == 2 and dataSaved2 == False:
        # Save data, and allow to exit
        allData = groupedData.collect()
        table = dynamodb.Table('capstone_b2')
        #print("Airport Airport Delay(mins)")
        with table.batch_writer() as batch:
          for (key, value) in allData:
              sortedValue = sorted(value, key=lambda v:v[1])
              lc = 0
              for (str, num) in sortedValue:
                  lc+=1
                  #print("%s: %s %.2f" % (key, str, num))
                  try:
                      batch.put_item(
                      #table.put_item(
                             Item={
                                 'key': key+str,
                                 'airport': key,
                                 'dest': str,
                                 'avgDepDelay': '%.2f' % num
                             }
                          )                    
                  except Exception, err:
                      print("Error: failed to write capstone_b2")
                      print(err)
                  if lc >= 10:
                      break
        dataSaved2 = True
        print('capstone_b2 saved!')

# Group, sort and get top 10 carries that connect airports X -> Y
def outputQ2N3(rdd):
    # rdd = ((K1, K2, K3), (V1, V2)) => ((K1, K2), (K3, V1/V2))
    groupedData = rdd.map(lambda x: ((x[0][0], x[0][1]), (x[0][2], x[1][0]/x[1][1]))) \
            .groupByKey()

    global runStatus
    global dataSaved3
    
    #topKData = groupedData.take(1)
    #print(topKData)
    
    if runStatus == 2 and dataSaved3 == False:
        # Save data, and allow to exit
        allData = groupedData.collect()
        table = dynamodb.Table('capstone_b3')
        #print("AirportPair Airline Delay(mins)")
        with table.batch_writer() as batch:
          for (key, value) in allData:
              sortedValue = sorted(value, key=lambda v:v[1])
              lc = 0
              for (str, num) in sortedValue:
                  lc+=1
                  #print("%s->%s: %s %.2f" % (key[0], key[1], str, num))
                  try:
                      batch.put_item(
                      #table.put_item(
                             Item={
                                 'key': key[0]+key[1]+str,
                                 'origin_dest': key[0]+"->"+key[1],
                                 'carrier': str,
                                 'avgDelay': '%.2f' % num
                             }
                          )
                  except Exception, err:
                       print("Error: failed to write capstone_b3")
                       print(err)
                  if lc >= 10:
                      break
        dataSaved3 = True
        print('capstone_b3 saved!')
          
# Only save legs at the last moment
def outputQ3N2(rdd):
    # rdd = ((K1, K2, K3, 0/1), (V1, V2, V3, V4))
    global runStatus
    global dataSaved4
    
    #topKData = rdd.take(2)
    #print("Origin Dest Date Trip Airline Flight Departure Delay")
    #print(topKData)
    
    if runStatus == 2 and dataSaved4 == False:
        # Save data, and allow to exit
        rdd.saveAsTextFile("/data/q/rdd%i" % rdd.id())
        #allData = rdd.collect()
        #table = dynamodb.Table('capstone_c2')
        #with table.batch_writer() as batch:
        #for (key, value) in allData:
            #print("%s, %s, %s, %d, %s, %s, %s, %.2f" % \
            #  (key[0], key[1], key[2].strftime(DATE_FMT), key[3], \
            #  value[0], value[1], value[2].strftime("%H:%M"), value[3]))
            #try:
                #batch.put_item(
                #table.put_item(
                       #Item={
                        #   'key': ('%d' % key[3])+key[0]+key[1]+key[2].strftime(DATE_FMT),
                        #   'origin': key[0],
                        #   'dest': key[1],
                        #   'date': key[2].strftime(DATE_FMT),
                        #   'trip': key[3],
                        #   'airline': value[0]+value[1],
                        #   'dep': value[2].strftime("%H:%M"),
                        #   'delay': '%.2f' % value[3]
                       #}
                    #)
            #except Exception, err:
            #     print("Error: failed to write capstone_c2")
            #     print(err)
        dataSaved4 = True
        print('capstone_c2 saved!')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: dk_airportquery.py <broker_list> <topic>", file=sys.stderr)
        exit(-1)

    runStatus = 0
    totalCount = 0
    timerCount = 0
    dataSaved1 = False
    dataSaved2 = False
    dataSaved3 = False
    dataSaved4 = False
    dataSaved5 = False
    dataSaved6 = False
    
    sc = SparkContext(appName=APP_NAME)
    ssc = StreamingContext(sc, 6)
    ssc.checkpoint(CHECKPOINT_DIR)
    
    brokers, topic = sys.argv[1:]
    kvs = KafkaUtils.createDirectStream(ssc, [topic], {"metadata.broker.list": brokers})
    lines = kvs.map(lambda x: x[1])
    flights = lines.map(lambda f: f.split(',')) \
         .filter(lambda f: f[0]<>'FlightDate' and f[12]<>'1') \
         .map(parse)

    # Q1.1
    topAirports = flights.flatMap(lambda f:{(f.origin, 1),(f.dest, 1), ('Total', 2)}) \
                  .updateStateByKey(topAirportUpdateFunction)
    # Q1.2
    topAirlines = flights.map(lambda f:(f.carrier, f.arv_delay)) \
                  .updateStateByKey(totalUpdateFunction)
    # Q2.1
    airportAirlines = flights.map(lambda f:(f.origin, (f.carrier, f.dep_delay))) \
                  .map(lambda x:((x[0],x[1][0]), x[1][1])) \
                  .updateStateByKey(totalUpdateFunction)
    # Q2.2
    airportAirports = flights.map(lambda f:(f.origin, (f.dest, f.dep_delay))) \
                  .map(lambda x:((x[0],x[1][0]), x[1][1])) \
                  .updateStateByKey(totalUpdateFunction)
    # Q2.3
    carriersA2A = flights.map(lambda f:((f.origin, f.dest, f.carrier), f.arv_delay)) \
                  .updateStateByKey(totalUpdateFunction)

    # Q3.2, Only 2008
    dataset2008 = flights.filter(lambda f:f.date.year == 2008 and f[12]<>'1')
    topHopFlights = dataset2008.map(lambda f:((f.origin, f.dest, \
                    f.date if f.dep.hour<12 else f.date-timedelta(days=2), \
                    0 if f.dep.hour<12 else 1), \
                    (f.carrier, f.flightnum, f.dep, f.arv_delay))) \
                  .updateStateByKey(minDelayUpdate)
                  
    topAirports.checkpoint(60)
    topAirports.foreachRDD(topAirportSortGetTopN)

    topAirlines.checkpoint(60)
    topAirlines.foreachRDD(topAirlineSortGetTopN)
    
    airportAirlines.checkpoint(60)
    airportAirlines.foreachRDD(outputQ2N1)
                  
    airportAirports.checkpoint(60)
    airportAirports.foreachRDD(outputQ2N2)

    carriersA2A.checkpoint(60)
    carriersA2A.foreachRDD(outputQ2N3)

    topHopFlights.checkpoint(60)
    topHopFlights.foreachRDD(outputQ3N2)
    
    print("STARTED!")
    ssc.start()
    runStatus = 1
    
    while True:
        res = ssc.awaitTerminationOrTimeout(10) # 10 seconds timeout
        if dataSaved1 and dataSaved2 and dataSaved3 and dataSaved4 and dataSaved5 and dataSaved6:
            runStatus = 0
        if res:
            # stopped elsewhere
            break
        else:
            # still running
            timerCount+=1
            print("still running...%d" % timerCount)
                        
            if runStatus == 0:
                print("Finish saving data. Stopping streaming...")
                ssc.stop(stopSparkContext=True, stopGraceFully=True)
                break
            
            if timerCount >= 12 and totalCount > 0:
                runStatus = 2
                print("No data received for 120 seconds, saving data...")
                
    print("FINISHED!")
      
 