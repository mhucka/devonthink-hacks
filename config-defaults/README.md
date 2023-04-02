# Config hidden preferences

These are quick shell scripts I use to set the hidden preferences to my liking, for installing DEVONthink on a new machine. The script outputs the values in a way that makes it possible to take that output and run it as a script to set the values:
```
# Get the values on one machine
./print-devonthink-preferences > prefs.sh

# Copy prefs.sh to another machine
# Set the values on the other machine
sh prefs.sh
```
