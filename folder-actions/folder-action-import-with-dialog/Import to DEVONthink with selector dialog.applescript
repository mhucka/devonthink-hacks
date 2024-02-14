# Summary: Folder Action script to import items to a selected location.
#
# This is intended to be installed as a Folder Action script on a folder in
# the Finder. It differs from a similar folder action script provided by
# DEVONthink ("DEVONthink - Import & Delete") in the following ways:
#  * asks for the destination for each item individually
#  * allows you to add tags to each item
#  * catches more errors and provides meaningful error dialogs
#  * puts the original item in the trash instead of deleting it directly
#
# Copyright 2024 Michael Hucka.
# License: MIT license – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

# ~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Return the file name of this script as a string, minus the extension.
on get_script_name()
    tell application "System Events"
        set path_alias to path to me
		set file_name to name of path_alias
		return my remove_ext(file_name)
    end tell
end get_script_name

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

# Return the file extension of the given file name or path.
on get_ext(file_name)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on get_ext(file_name)
			set fname to ca's NSString's stringWithString:file_name
			return fname's pathExtension() as string
		end get_ext
	end script
	return wrapperScript's get_ext(file_name)
end get_ext

# Tell DEVONthink to import a single item, asking the user for a name, tags,
# and destination group.
on import_into_dt(item_path)
	tell application id "DNtp"
		set msg to "Importing file '" & my remove_ext(item_path) & "'"
		set dest_info to display group selector msg tags true
		set new_record to import item_path to |group| of dest_info
		set tags of new_record to |tags| of dest_info
	end tell
end import_into_dt

# Move the item to the trash.
on move_to_trash(item)
	tell application "Finder"
		move item to trash
	end tell
end move_to_trash

# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on adding folder items to this_folder after receiving added_items
	try
		if (count of added_items) is greater than 0 then
			tell application id "DNtp"
				launch
			end tell
			repeat with this_item in added_items
				set item_path to (POSIX path of this_item)
				set item_ext to my get_ext(item_path)
				if item_ext is not in {"download", "crdownload"} then
					my import_into_dt(item_path)
					my move_to_trash(this_item)
				end if
			end repeat
		end if
	on error msg number err
		if the err is not -128 then     # (Code -128 means user cancelled.)
			set txt to "The following error occurred when running " & ¬
				"the folder action: " & linefeed & linefeed & msg
			display dialog txt buttons {"OK"} ¬
				with title "Folder action '" & my get_script_name() & "'" ¬
				with icon 0 default button 1 giving up after 60
		end if
	end try
end adding folder items to
