#pathData=${1:-"${HOME}/data/"}
#pathData=${1:-"hdfs://data/airline/"}
pathData=${1:-"s3://cloud.datatellit.com/data/airline/"}
delaySec=${2:-4}
zkeeper=${3:-"localhost:9092"}
topic=${4:-"spark"}

year=1988
while [ $year -le 2008 ]
do
	./feedstream.sh $year $pathData $delaySec $zkeeper $topic
	year=`expr $year + 1`
done
