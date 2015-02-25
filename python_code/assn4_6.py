# Function computepay()
def computepay(hour, rate):
	## Condition > 40?
	pay = 0.0
	if hour <= 40: 
		pay = hour * rate
	else:
		pay = rate * 40 + rate * 1.5 * (hour - 40)
	return pay

# Get users input
try:
## Get Hours
	inp = raw_input("Enter Hours:")
	inpHour = float(inp)
## Get Rate
	inp = raw_input("Enter Rate:")
	inpRate = float(inp)
except:
	quit()

# Calculate the pay
p = computepay(inpHour, inpRate)
print p
