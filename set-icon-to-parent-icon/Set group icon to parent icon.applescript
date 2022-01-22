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
			if recType is not in {"group", "«constant ****DTgr»"} then
			   display notification "Selected item is not a group"
			   return
			end if
		
			-- Items can have multiple parents.  Look for the first one
			-- that is a group, and use it.
			repeat with parentRec in (parent of rec)
				if recType is in {"group", "«constant ****DTgr»"} then
					-- Important: *must* set directly, not using variable.
					set thumbnail of rec to thumbnail of parentRec
					return
				end if
			end repeat
		end repeat
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
