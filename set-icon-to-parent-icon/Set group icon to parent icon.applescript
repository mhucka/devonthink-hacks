-- ======================================================================
-- @file	Set group icon to parent icon.applescript
-- @brief	Set the icon of a selected group to that of its parent group
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This script only acts on groups and smart groups.
-- ======================================================================

property scriptName : "Set group icon to parent icon"

tell application id "DNtp"
	try
		repeat with rec in (selected records)
			set recType to (type of rec) as string
			if recType is in {"group", "«constant ****DTgr»", ¬
							  "smart group", "«constant ****DTsg»"} then
				set locGroup to location group of rec
				-- Note: *must* set directly; can't use intermediate var.
				set thumbnail of rec to thumbnail of locGroup
			else
				set recName to name of rec
				-- Don't use display alert here in case the user selected
				-- a lot of items. Just log failures instead.
				log message "[" & scriptName & "] " & ¬
					"Icon not changed because item is not a group: " ¬
					& recName
			end if
		end repeat
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
