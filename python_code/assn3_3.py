inp = raw_input("Please enter a score [0.0 to 1.0]: ")
try:
	score = float(inp)
except:
	print("Error: We are expecting a number between 0.0 to 1.0.")
	quit()
	
grade = "Unknown"
if score < 0 or score > 1:
	print("Sorry, I can not grade the score, because it is out of range.")
	quit()
elif score >= 0.9:
	grade = "A"
elif score >= 0.8:
	grade = "B"
elif score >= 0.7:
	grade = "C"
elif score >= 0.6:
	grade = "D"
else:
	grade = "F"
	
print(grade)