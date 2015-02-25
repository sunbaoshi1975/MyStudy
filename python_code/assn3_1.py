hrs = raw_input("Enter Hours:")
h = float(hrs)

## Get Rate
inp = raw_input("Enter Rate:")
rate = float(inp)

# Calculate the pay
## Make sure we have at least one float
h += 0.0
## Condition > 40?
if h <= 40: 
	pay = h * rate
else:
	pay = rate * 40 + rate * 1.5 * (h - 40)
print pay