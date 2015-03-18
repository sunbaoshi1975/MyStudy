# exercise 7.1
# Write a program that prompts for a file name, 
# then opens that file and reads through the file, and print the contents of the file in upper case.

# Use words.txt as the file name
try:
	fname = raw_input("Enter file name: ")
	fh = open(fname)
except:
	print 'File cannot be opened:', fname
	exit()

#inp = fh.read()
#print filecontent

for dataln in fh:
	dataln = dataln.strip()
	dataln = dataln.upper()
	print dataln
	