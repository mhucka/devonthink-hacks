-- Summary: copy the absolute file paths of the selected documents.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		set paths to ""
		-- Start with no linebreak for the first time through the loop.
		set linebreak to ""	
		repeat with _record in (selected records)
			set _type to (type of _record) as string
			-- Skip groups in DEVONthink b/c they don't exist on disk.
			if _type is not in {"group", "«constant ****DTgr»", ¬
						        "smart group", "«constant ****DTsg»"} then
				set paths to paths & linebreak & (path of _record)
			end if
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
