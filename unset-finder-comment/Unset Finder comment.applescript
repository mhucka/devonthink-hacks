-- ======================================================================
-- @file	Unset Finder comment
-- @brief	Unset the Finder comment of select records
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
-- ======================================================================

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		repeat with _record in (selected records)
			set comment of _record to ""
		end repeat
	on error msg number code
		if the code is not -128 then
			display alert "Unset comment" message msg as warning
		end if
	end try
end tell
