-- Summary: copy the absolute file paths of the selected documents.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set LF to character id 10
set the clipboard to ""

tell application id "DNtp"
	try
		repeat with _record in (selected records)
			set _type to (type of _record) as string
			-- Groups in DEVONthink don't have equivalent disk folders.
			if _type is not in {"group", "«constant ****DTgr»", ¬
						        "smart group", "«constant ****DTsg»"} then
				set _path to (path of _record)
				set the clipboard to (get the clipboard) & LF & _path
			end if
		end repeat
	on error msg number err
		if err is not -128 then
			display alert "DEVONthink error" message msg as warning
		end if
	end try
end tell
