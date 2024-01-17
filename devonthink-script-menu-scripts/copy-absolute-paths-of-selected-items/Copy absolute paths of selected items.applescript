-- Summary: copy the absolute database paths of the selected items.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set the clipboard to ""

tell application id "DNtp"
	try
		set paths to ""
		-- Start with no linebreak for the first time through the loop.
		set linebreak to ""	
		repeat with _record in (selected records)
			set p to (location of _record) & (name of _record)
			set paths to paths & linebreak & p
			-- Separate subsequent paths with linebreaks. This repeated
			-- assignment may seem inefficient, but the alternative is
			-- adding a conditinal in addition to having an assignment.
			set linebreak to character id 10
		end repeat
		set the clipboard to paths
	on error msg number err
		if err is not -128 then
			display alert "DEVONthink error" message msg as warning
		end if
	end try
end tell
