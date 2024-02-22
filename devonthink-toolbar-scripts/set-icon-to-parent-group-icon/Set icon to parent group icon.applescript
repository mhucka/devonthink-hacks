# Summary: set the icon of selected items to the icon of their parent group.
#
# Copyright 2024 Michael Hucka.
# License: MIT License – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

# ~~~~ Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The next two variables together control which kinds of items can have their
# icons changed. There are two lists because, depending on how many things you
# want to allow changing, it may be easier to express the condition by
# inclusion or exclusion. Testing is done on both; i.e., an item's kind has to
# be in the allow list and not be in the disallow list.

property allowed_kinds: {"Group", "Smart Group", "Bookmark"}
property disallowed_kinds: {}


# ~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Log a message in DEVONthink's log and include the path to this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		log message script_path info error_text   # DEVONthink's log.
	end tell
	log error_text				                  # Debugger & osascript log.
end report

# Return the given file name without its file name extension, if any.
on remove_ext(file_name)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on remove_ext(file_name)
			set u to ca's NSURL's fileURLWithPath:file_name
			return u's URLByDeletingPathExtension()'s lastPathComponent() as text
		end remove_ext
	end script
	return wrapperScript's remove_ext(file_name)
end remove_ext

# Return the file name of this script as a string, minus the extension.
on get_script_name()
    tell application "System Events"
        set path_alias to path to me
		set file_name to name of path_alias
		return my remove_ext(file_name)
    end tell
end get_script_name


# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on act_on_record(rec)
	tell application id "DNtp"
		# For items at the root level, there's no parent to get an icon from.
		if (location of rec) = "/" then
			set msg to "The icon of this item cannot be set to the icon of " ¬
				& "its parent group, because that parent is the root level " ¬
				& "of the database:" & linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Skip", "Cancel"} ¬
				with title my get_script_name() with icon 1 ¬
			 	default button 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
			else if button returned of result = "Skip" then
				return
			end if
		end if

		# Test that the parent actually has an icon.
		set parent_group to location group of rec
		try
			thumbnail of parent_group as anything
		on error
			set msg to "The parent of this item does not have a custom " ¬
				& "icon, and therefore, this item's icon cannot be changed: " ¬
				& linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Skip", "Cancel"} ¬
				with title my get_script_name() with icon 1 ¬
			 	default button 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
			else if button returned of result = "Skip" then
				return
			end if
		end try

		# This is not a top-level item & the parent has an icon. Go ahead.
		set rkind to (kind of rec) as string
		if (rkind is in allowed_kinds) and not (rkind is in disallowed_kinds) then
			# Note: *must* set this directly; can't use intermediate variable.
			set thumbnail of rec to thumbnail of parent_group
		else
			set msg to "The following item is of kind \"" & rkind & "\", which " ¬
				& "is not one of the expected kinds. Should its icon be " ¬
				& "changed anyway? " & linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Set icon", "Skip", "Cancel"} ¬
				with title my get_script_name() with icon 1 ¬
			 	default button 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
			else if button returned of result = "Skip" then
				return
			else if gave up of result then
				error "Timed out waiting for user input"
			end if
		end if
	end tell
end act_on_record

# ~~~~ Interfaces to DEVONthink ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Allow execution as part of a Smart Rule.
on performSmartRule(selected_records)
	tell application id "DNtp"
		try
			repeat with rec in (selected records)
				my act_on_record(rec)
			end repeat
		on error msg number err
			if the err is not -128 then     # (Code -128 means user cancelled.)
				my report(msg & " (error " & err & ")")
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

# Allow execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
