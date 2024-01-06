-- Unset the Aliases field value of select records.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		repeat with _record in (selected records)
			set aliases of _record to ""
		end repeat
	on error msg number code
		if the code is not -128 then
			display alert "Unset Aliases" message msg as warning
		end if
	end try
end tell
