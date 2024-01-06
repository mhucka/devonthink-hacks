-- Test if image file exists.
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

property imageGroup : "/Sources/Zotero/Images"

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		repeat with rec in selectedRecords
			set citekey to get custom meta data for "citekey" from rec
			if citekey = "" then
				set recName to name of rec
				display notification "No citekey found for " & recName
				return
			end if
			set rec to exists record at imageGroup & "/" & "foo"
			if not rec then
				display dialog rec
				error -128
			end if
		end repeat
	end tell
end performSmartRule
