year=1988
while [ $year -le 2008 ]
do
	./datacleans3.sh $year
	year=`expr $year + 1`
done
