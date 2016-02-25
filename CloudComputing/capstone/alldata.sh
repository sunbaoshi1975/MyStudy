year=1988
while [ $year -le 2008 ]
do
	./dataclean.sh $year
	year=`expr $year + 1`
done
