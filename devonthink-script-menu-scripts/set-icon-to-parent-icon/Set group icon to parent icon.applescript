-- Set the icon of a selected group to that of its parent group
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

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
