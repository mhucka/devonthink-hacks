-- Summary: force open item in a new window or its default application.
--
-- This script exists because I want shift-command-o to behave in a certain
-- way. (1) If the selected item is a group, I want DEVONthink to open a new
-- window on the group even if there is already a window open on the group
-- somewhere. (2) If the selected item is a document, I want it
-- shift-command-o to open it in the default application (which is the default
-- action in DEVONthink for shift-command-o).
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

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

-- Open a file in the defaut application.
-- This code is based on a 2022-03-22 forum posting by Shane Stanley at
-- https://forum.latenightsw.com/t/macos-12-3-introduces-serious-fundamental-applescript-bug/3666/2
on open_in_default_app(file_path)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on open_in_default_app(file_path)
			set ws to ca's NSWorkspace's sharedWorkspace()
			set file_url to ca's |NSURL|'s fileURLWithPath:file_path
			ws's openURL:file_url
		end open_in_default_app
	end script
	return wrapperScript's open_in_default_app(file_path)
end open_in_default_app

-- ──── Main body ─────────────────────────────────────────────────────────────

on act_on_record(rec)
	tell application id "DNtp"
		set rec_type to (type of rec) as string
		if rec_type is in {"group", "smart group"} then
			open window for record rec with force
		else
			my open_in_default_app(path of rec)
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
