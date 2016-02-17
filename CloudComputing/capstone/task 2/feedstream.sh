# feed stream with csv files
pathTemp="${HOME}/tmp/"

year=${1:-1988}
pathData=${2:-"${HOME}/data/"}
#pathData=${2:-"hdfs://data/airline/"}
#pathData=${2:-"s3://cloud.datatellit.com/data/airline/"}
delaySec=${3:-4}
zkeeper=${4:-"localhost:9092"}
topic=${5:-"spark"}
kafkaPath="~/kafka/bin/kafka-console-producer.sh --broker-list ${zkeeper} --topic ${topic}"

if [ $year == 2008 ]
then
    	maxmonth=10
else
    	maxmonth=12
fi

month=1
while [ $month -le $maxmonth ]
do
        rawfile="${pathData}ontime_${year}_${month}.csv"
        csvfile="${pathTemp}ontime_${year}_${month}.csv"
        if [ ${pathData:0:2} = "s3" ]
        then
                if [ -e ${csvfile} ]
               	then
                    	sudo rm -r ${csvfile}
                fi
                aws s3 cp ${rawfile} ${csvfile}
                cmdPrefix="cat ${csvfile}"
        else
            	if [ ${pathData:0:4} = "hdfs" ]
                then
                        hdfile=${rawfile#*/}
        #               hadoop fs -get ${hdfile} ${csvfile}
                        cmdPrefix="hadoop fs -cat ${hdfile}"
                else
			csvfile=${rawfile}
                       	cmdPrefix="cat ${csvfile}"
               	fi
        fi

        cmdline="${cmdPrefix} | ${kafkaPath}"
        echo -n "streaming file ${rawfile}..."
       	eval ${cmdline}
        echo "Done."

        # Remove temp file
	if [ ${pathData:0:2} = "s3" ]
        then
                if [ -e ${csvfile} ]
               	then
                    	sudo rm -r ${csvfile}
                fi
       	fi

        sleep ${delaySec}

        month=`expr $month + 1`
done
