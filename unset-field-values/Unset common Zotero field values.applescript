-- Unset record fields I use in conjunction with Zotero.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		repeat with _record in (selected records)
			set URL of _record to ""
			set aliases of _record to ""
			set comment of _record to ""
			add custom meta data "" for "year" to _record
			add custom meta data "" for "type" to _record
			add custom meta data "" for "citekey" to _record
			add custom meta data "" for "abstract" to _record
		end repeat
	on error msg number code
		if the code is not -128 then
			display alert "Unset URL" message msg as warning
		end if
	end try
end tell
