# Config hidden preferences

This is a simple shell script I use to both print and set DEVONthink hidden preferences, for installing DEVONthink on a new machine. The script is designed to output the values in a way that makes it possible to take the output and run it as a shell script to set the values. Example:

```sh
# Get the values on one machine
./print-devonthink-preferences > prefs.sh

# Copy prefs.sh to another machine
# Set the values on the other machine
sh prefs.sh
```
