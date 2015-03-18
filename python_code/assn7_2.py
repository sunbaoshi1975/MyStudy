# exercise 7.2
# Write a program that prompts for a file name, 
# then opens that file and reads through the file, looking for lines of the form:
#        X-DSPAM-Confidence:    0.8475
# Count these lines and extract the floating point values from each of the lines and compute the average of those values and produce an output as shown below.
# You can download the sample data at http://www.pythonlearn.com/code/mbox-short.txt when you are testing below enter mbox-short.txt as the file name.
# Expected output is:
# Average spam confidence: 0.750718518519

# Use the file name mbox-short.txt as the file name
fname = raw_input("Enter file name: ")
fh = open(fname)
count = 0
total = 0
for line in fh:
  if not line.startswith("X-DSPAM-Confidence:") : continue
  line = line.rstrip()
  count = count + 1
  posColon = line.find(":")
  strpos = line[posColon+1:]
  num = float(strpos)
  total = total + num
	
if count > 0:
  average = total / count
else:
  average = 0
print "Average spam confidence:", average
