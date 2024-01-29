-- This script will produce an error if used as the 

use AppleScript version "2.5"
use framework "Foundation"
use scripting additions

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with theRecord in selectedRecords
				set theRecord to item 1 of selectedRecords
				display dialog (name of theRecord) as text
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule
