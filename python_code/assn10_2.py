# exercise 10.2
# Write a program to read through the mbox-short.txt and figure out 
# distribution by hour of the day for each of the messages. You can pull the hour out 
# from the 'From ' line by finding the time and then splitting the string a second time 
# using a colon.
# e.g.: From stephen.marquard@uct.ac.za Sat Jan  5 09:14:16 2008
# Once you have accumulated the counts for each hour, print out the counts, sorted by 
# hour as shown below. Note that the autograder does not have support for the sorted() function.

# You can download the sample data at http://www.pythonlearn.com/code/mbox-short.txt
name = raw_input("Enter file:")
if len(name) < 1 : name = "mbox-short.txt"
handle = open(name)

# Build the dictionary
counts = dict()
for line in handle:
  line = line.rstrip()
  if line == '': continue
  if not line.startswith('From '): continue
  words = line.split()
  time = words[5]
  # A second splitting
  em_hms = time.split(':')
  em_hour = em_hms[0]
  counts[em_hour] = counts.get(em_hour, 0) + 1

# Sort by hour
lstHour = list()
for em_hour,count in counts.items():
  lstHour.append((em_hour, count))
lstHour.sort()

# Print out
for em_hour,count in lstHour:
  print em_hour, count
