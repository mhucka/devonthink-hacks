-- Summary: set the icon of selected items to the icon of their parent group.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

-- ──── Config variables ──────────────────────────────────────────────────────

-- The record types whose icons will be changed by this script. I don't find
-- it useful to change anything except groups (regular & smart groups), with
-- the exception that I sometimes use links ("bookmarks" in DEVONthink terms)
-- to point to groups. That's why bookmarks are in this list.
property allowed_types: {"group", "«constant ****DTgr»", ¬
						 "smart group", "«constant ****DTsg»", ¬
						 "bookmark", "«constant ****DTnx»"}

-- ──── Helper functions ──────────────────────────────────────────────────────

-- Log a message in DEVONthink's log and include the name of this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		log message script_path info error_text
	end tell
	log error_text				-- Useful when running in a debugger.
end report

-- ──── Main body ─────────────────────────────────────────────────────────────

on act_on_record(rec)
	tell application id "DNtp"
		set rec_type to (type of rec) as string
		if rec_type is in allowed_types then
			set parent_group to location group of rec
			-- Note: *must* set this directly; can't use intermediate variable.
			set thumbnail of rec to thumbnail of parent_group
		else
			set rname to name of rec
			-- Don't display alert here in case the user selected many items.
			my report("Icon not changed because item is not a group: " & rname)
		end if
	end tell
end act_on_record

-- ──── Interfaces to DEVONthink ──────────────────────────────────────────────

-- Allow execution as part of a Smart Rule.
on performSmartRule(selected_records)
	tell application id "DNtp"
		try
			repeat with rec in (selected records)
				my act_on_record(rec)
			end repeat
		on error msg number err
			if the code is not -128 then
				my report(msg & " (error " & code & ")")
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Allow execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
