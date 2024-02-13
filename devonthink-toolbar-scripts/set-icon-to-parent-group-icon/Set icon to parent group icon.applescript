# Summary: set the icon of selected items to the icon of their parent group.
#
# Copyright 2024 Michael Hucka.
# License: MIT License – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

# ~~~~ Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The record types whose icons will be changed by this script. I don't find
# it useful to change anything except groups (regular & smart groups), with
# the exception that I sometimes use links ("bookmarks" in DEVONthink terms)
# to point to groups. That's why bookmarks are in this list.
property allowed_type_pairs: {{"group"		 , "«constant ****DTgr»"}, ¬
						 	  {"smart group" , "«constant ****DTsg»"}, ¬
						 	  {"bookmark"	 , "«constant ****DTnx»"}}

# The value of (type of x) when this script is executed in a smart rule comes
# back as a "«constant ****XYZr»" string, which is meaningless to users. Using
# an explicit list of type name mappings is the only way I found to map them
# to meaningful names.
property known_type_pairs: {{"bookmark"		  , "«constant ****DTnx»"}, ¬
							{"feed"			  , "«constant ****feed»"}, ¬
							{"formatted note" , "«constant ****DTft»"}, ¬
							{"group"		  , "«constant ****DTgr»"}, ¬
							{"html"			  , "«constant ****html»"}, ¬
							{"markdown"		  , "«constant ****mkdn»"}, ¬
							{"PDF document"	  , "«constant ****pdf»"}, ¬
							{"RTF"			  , "«constant ****rtf»"}, ¬
							{"RTFD"			  , "«constant ****rtfd»"}, ¬
							{"sheet"		  , "«constant ****tabl»"}, ¬
							{"smart group"	  , "«constant ****DTsg»"}, ¬
							{"txt"			  , "«constant ****txt»"}, ¬
							{"webarchive"	  , "«constant ****wbar»"}}

# ~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Log a message in DEVONthink's log and include the path to this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		log message script_path info error_text
	end tell
	log error_text				# Useful when running in a debugger.
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

# Return a flattened version of the given list.
on flatten(the_list)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on flatten(the_list)
			return ((ca's class "NSArray"'s arrayWithArray:(the_list))'s ¬
				valueForKeyPath:("@unionOfArrays.self")) as list
		end flatten
	end script
	return wrapperScript's flatten(the_list)
end flatten

# Return the name of the given type id.
on get_type_name(type_)
	repeat with pair in known_type_pairs
		set type_name to item 1 of pair
		set type_class to item 2 of pair
		if (type_ = type_name) or (type_ = type_class) then
			return type_name
		end if
	end repeat
	return type_
end get_type_name

# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on act_on_record(rec, allowed_types)
	tell application id "DNtp"
		# For items at the root level, there's no parent to get an icon from.
		if (location of rec) = "/" then
			set msg to "The icon of this item cannot be set to the icon of " ¬
				& "its parent group, because its parent is the root level " ¬
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

		# This is not a top-level item, so go ahead and try to change the icon.
		set rtype to (type of rec) as string
		if rtype is not in allowed_types then
			set rtname to my get_type_name(rtype)
			set msg to "The following item has type \"" & rtname & "\", which " ¬
				& "is not one of the expected types. Change its icon anyway? " ¬
				& linefeed & linefeed & (name of rec)
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
		set parent_group to location group of rec
		# Note: *must* set this directly; can't use intermediate variable.
		return
		set thumbnail of rec to thumbnail of parent_group
	end tell
end act_on_record

# ~~~~ Interfaces to DEVONthink ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Allow execution as part of a Smart Rule.
on performSmartRule(selected_records)
	tell application id "DNtp"
		# Avoid repeatedly flattening the list inside the loop.
		set allowed_types to my flatten(allowed_type_pairs)
		try
			repeat with rec in (selected records)
				my act_on_record(rec, allowed_types)
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
