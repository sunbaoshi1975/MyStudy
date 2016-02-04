# clean a csv file
import sys
import csv

file_in = sys.argv[1]
file_out = sys.argv[2]
fh_in = csv.reader(open(file_in, 'rb'))
fh_out = csv.writer(open(file_out, 'wb'))

# FlightDate(5), AirlineID(7), Carrier(8), FlightNum(10), Origin(11), Dest(17), 
# CRSDepTime(23), DepTime(24), DepDelay(25), 
# CRSArrTime(34), ArrTime(35), ArrDelay(36), Cancelled(41)
columns = (5, 7, 8, 10, 11, 17, 23, 24, 25, 34, 35, 36, 41)

lineno = 0
for line in fh_in:
  if len(line) < max(columns): continue
#  print line
  cleanline = [line[i] for i in columns]
#  print cleanline
  fh_out.writerow(cleanline)
  lineno+=1
#  if lineno > 1000: break

print lineno,

