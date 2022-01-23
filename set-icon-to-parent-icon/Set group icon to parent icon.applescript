-- ======================================================================
-- @file	Set group icon to parent icon.applescript
-- @brief	Set the icon of a selected group to that of its parent group
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This script only acts on groups.
-- ======================================================================

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application id "DNtp"
	try
		repeat with rec in (selected records)
			set recType to (type of rec) as string
			if recType is in {"group", "«constant ****DTgr»"} then
				set locGroup to location group of rec
				-- Note: *must* set directly; can't use intermediate var.
				set thumbnail of rec to thumbnail of locGroup
			else
				set recName to name of rec
				display notification ¬
					"Ignoring item because it's not a group: " & recName
			end if
		end repeat
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
