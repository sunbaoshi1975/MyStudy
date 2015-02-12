# This first line is provided for you

# Default values (type of float)
def_hrs = 35.0
def_rate = 2.75

# Get users input
## Get Hours
try:
	hrs = float(raw_input("Enter Hours:"))
except:
	hrs = def_hrs

## Get Rate
try:
	rate = float(raw_input("Enter Rate (default value is " + str(def_rate) + "):"))
except:
	rate = def_rate

# Type check
if not(isinstance(hrs, float) or isinstance(hrs, int)):
    hrs = def_hrs

if not(isinstance(rate, float) or isinstance(rate, int)):
    rate = def_rate
    
# Calculate the pay
## Make sure we have at least one float
hrs += 0.0
pay = hrs * rate
print pay