# Summary: Folder Action script to import items to a selected location.
#
# This is intended to be installed as a Folder Action script on a folder in
# the Finder. It differs from a similar folder action script provided by
# DEVONthink ("DEVONthink - Import & Delete") in the following ways:
#
#  * If given a single item, asks for new name, tags, and destination group.
#
#  * If given multiple items, asks if each item should be considered
#    separately or all should be treated as one group, and then either
#
#     a) asks for the name, tags, & destination of each item one at a time, or
#
#     b) else asks for tags & destination, and tags & moves all the items.
#
#  * Catches more errors and provides meaningful error dialogs.
#
#  * Puts the original item in the trash unless the user cancels at any time
#    or an error occurs.
#
# Copyright 2024 Michael Hucka.
# License: MIT license – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

# ~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Return the Unix-style path of the given Finder path object or alias.
on get_path(finder_alias)
	tell application "Finder"
		return POSIX path of finder_alias
	end tell
end get_path

# Return the name of the file, without the directory components.
on get_basename(file_path)
	tell application "Finder"
		return name of (info for file_path)
	end tell
end get_basename

# Return the file name of *this* script as a string, minus the file extension.
on get_script_name()
    tell application "System Events"
        set path_alias to path to me
		set file_name to name of path_alias
		return my remove_ext(file_name)
    end tell
end get_script_name

# Return the file extension of the given file name or path, minus the dot.
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

# Tell DEVONthink to import a single item, asking the user for a name, tags,
# and destination group.
on import_item(finder_alias)
	set item_path to my get_path(finder_alias)
	set item_basename to my get_basename(item_path)
	tell application "DEVONthink 3"
		set msg to "Importing file '" & item_basename & "'"
		set user_input to display group selector msg tags true name true
		set new_record to import item_path to |group| of user_input
		set new_name to |name| of user_input
		if new_name ≠ "" then
			set name of new_record to new_name
		else
			set name of new_record to item_basename
		end if
		set tags of new_record to |tags| of user_input
	end tell
end import_item

# Tell DEVONthink to import a list of items. It will only ask for the
# destination and tags once, then move all items into the destination and
# tag them all with the same set of tags.
on import_all_items(item_list)
	tell application "DEVONthink 3"
		set msg to "Importing " & (count of item_list) & " files"
		set user_input to display group selector msg tags true
		set dest_group to |group| of user_input
		set tag_list to |tags| of user_input
		repeat with thing in item_list
			set item_path to my get_path(thing)
			set new_record to import item_path to dest_group
			set tags of new_record to tag_list
		end repeat
	end tell
end import_all_items

# Move the item to the trash.
on move_to_trash(item_list)
	if class of item_list is not list then
		set item_list to {item_list}
	end if
	tell application "Finder"
		repeat with thing in item_list
			move thing to trash
		end repeat
	end tell
end move_to_trash

# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on adding folder items to this_folder after receiving added_items
	try
		# Filter the list of items to remove in-progress downloads.
		set item_list to {}
		repeat with thing in added_items
			set item_path to my get_path(thing)
			if my get_ext(item_path) is not in {"download", "crdownload"} then
				set item_list to item_list & thing
			end if
		end repeat

		# If we have something left, start by launching DEVONthink, else stop.
		if (count of item_list) is greater than 0 then
			tell application "DEVONthink 3"
				launch
				repeat until application "DEVONthink 3" is running
					delay 0.5
				end repeat
				activate
			end tell
		else
			return
		end if

		# If we get here, we have something to do.
		if (count of item_list) = 1 then
			my import_item(first item of item_list)
		else
			set handle_individually to false
			tell application "DEVONthink 3"
				set answer to display dialog ¬
					"Multiple items received. Handle individually, or as a group?" ¬
					with title my get_script_name() with icon 1 ¬
					buttons {"Individually", "As a group", "Cancel"} ¬
					default button "Individually" cancel button "Cancel" ¬
					giving up after 30
				if button returned of answer = "Cancel" then
					return
				else if button returned of answer = "Individually" then
					set handle_individually to true
				end if
			end tell
			if handle_individually is true then
				repeat with thing in item_list
					my import_item(thing)
				end repeat
			else
				my import_all_items(item_list)
			end if
		end if

		# Do this last. If the user cancels, items will be left in the folder.
		my move_to_trash(item_list)
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
