-- Check that Zotero is running and start it if it is not
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.

on performSmartRule(selectedRecords)
	tell application "Zotero"
		if it is not running then
			launch
			repeat until application "Zotero" is running
				delay 0.5
			end repeat
			-- My Zotero takes a long time to load even after it's
			-- started. I haven't found a way to test it's finished
			-- loading, so all I can do is use a delay.
			delay 15
		end if
	end tell
end performSmartRule
