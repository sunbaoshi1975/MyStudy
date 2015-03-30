# exercise 9.4
# Write a program to read through the mbox-short.txt and figure out who has the 
# sent the greatest number of mail messages. The program looks for 'From ' lines and 
# takes the second word of those lines as the person who sent the mail. The program 
# creates a Python dictionary that maps the sender's mail address to a count of the 
# number of times they appear in the file. After the dictionary is produced, the program 
# reads through the dictionary using a maximum loop to find the most prolific committer.

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
  word = words[1]
  counts[word] = counts.get(word, 0) + 1

# Find the most prolific committer
bigcount = None
bigword = None
for work,count in counts.items():
  if bigcount is None or bigcount < count:
    bigword = word
    bigcount = count

# Print sender count
print bigword, bigcount
