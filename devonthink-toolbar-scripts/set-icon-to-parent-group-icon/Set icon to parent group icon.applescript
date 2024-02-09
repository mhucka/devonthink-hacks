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
		set rtype to (type of rec) as string
		if rtype is not in allowed_types then
			set msg to "The following item has type \"" & rtype & "\", which " ¬
				& "is not one of the expected types. Change its icon anyway? " ¬
				& linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Cancel", "OK"} ¬
			 	default button 1 with icon 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
			else if gave up of result then
				error "Timed out waiting for user input"
			end if
		end if
		set parent_group to location group of rec
		-- Note: *must* set this directly; can't use intermediate variable.
		set thumbnail of rec to thumbnail of parent_group
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
			if the err is not -128 then       -- (Code -128 => user cancelled.)
				my report(msg & " (error " & err & ")")
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Allow execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
