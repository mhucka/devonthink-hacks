-- Summary: create Markdown-formatted links to the selected items.
-- The links use the DEVONthink reference URLs of the items.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		set links to ""
		-- Start with no linebreak for the first time through the loop.
		set linebreak to ""	
		repeat with _record in (selected records)
			set _name to name of _record
			set _ref_url to reference URL of _record
			set _link to "[" & _name & "](" & _ref_url & ")"
			set links to links & linebreak & _link
			-- Separate subsequent items with linebreaks. This repeated
			-- assignment may seem inefficient, but the alternative is
			-- adding a conditinal in addition to having an assignment.
			set linebreak to character id 10
		end repeat
		set the clipboard to links
	on error msg number err
		if err is not -128 then
			display alert "DEVONthink error" message msg as warning
		end if
	end try
end tell
