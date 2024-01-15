-- Summary: create Markdown-formatted links to the selected items.
-- The links use the DEVONthink reference URLs of the items.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set the clipboard to ""

tell application id "DNtp"
	try
		-- The first time through the loop, the clipboard will be empty,
		-- so to avoid prepending a newline before the first item, this
		-- is set to an empty string.
		set linebreak to ""	
		repeat with _record in (selected records)
			set _name to name of _record
			set _ref_url to reference URL of _record
			set _link to "[" & _name & "](" & _ref_url & ")"
			set the clipboard to (get the clipboard) & linebreak & _link
			-- If we have more than one item in the selection, subsequent
			-- additions will be separated by a newline. This repeated
			-- assignment may seem inefficient, but it's either this or
			-- doing a conditional test + branch. This is shorter.
			set linebreak to character id 10
		end repeat
	on error msg number err
		if err is not -128 then
			display alert "DEVONthink error" message msg as warning
		end if
	end try
end tell
