use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		repeat with rec in (selected records)
			set rating of rec to 1
		end repeat
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
