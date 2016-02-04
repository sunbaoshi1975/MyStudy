# data extract and clean
pathWork="${HOME}/work/"
pathRawData="${HOME}/rawdata/aviation/airline_ontime/"
pathTemp="${HOME}/data/"
pathOutput="/data/airline"
fname='On_Time_On_Time_Performance_'

year=${1:-1998}
month=1

while [ $month -le 12 ]
do
	zipfile="${pathRawData}${year}/${fname}${year}_${month}"
#       echo $zipfile
	tempfile="${pathTemp}${fname}${year}_${month}.csv"
	cleantemp="${pathTemp}ontime_${year}_${month}.csv"
	hdfsfile="${pathOutput}/ontime_${year}_${month}.csv"

# Unzip file
	unzip -oq ${zipfile} -d ${pathTemp}
#	echo ${pathTemp}
	if [ -e ${tempfile} ]
	then
		echo -n "extracted ${tempfile}"
		echo -n "...cleaning..."
		python dataclean.py ${tempfile} ${cleantemp}

		echo -n " rows...writing HDFS..."
		hadoop fs -rm -r -f ${hdfsfile}
		hadoop fs -put ${cleantemp} ${pathOutput}
		echo "Done."

# Delete temp files when file is cleaned and stored into HDFS
		sudo rm -r ${tempfile}
		sudo rm -r ${cleantemp}
	fi

	month=`expr $month + 1`
done

