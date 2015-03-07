# loop exercise
# Write a program that repeatedly prompts a user for integer numbers until the user enters 'done'. Once 'done' is entered, print out the largest and smallest of the numbers.
largest = None
smallest = None
while True:

	try:
		inp = raw_input("Enter a number: ")
		if inp.lower() == "done" :
			break
#		print inp
		num = int(inp)
	except:
		print "Invalid input"
		continue
		
	if largest is None:
		largest = num
	elif largest < num:
		largest = num
		
	if smallest is None:
		smallest = num
	elif smallest > num:
		smallest = num
		
print "Maximum is", largest
print "Minimum is", smallest