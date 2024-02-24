# Summary: set the icon of selected items to the icon of their parent group.
#
# Copyright 2024 Michael Hucka.
# License: MIT License – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions


# ~~~~ Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The next two properties together control which kinds of items can have their
# icons changed automatically. There are two lists because, depending on how
# many kinds of things you want to allow changing, it may be easier to express
# the condition by inclusion or exclusion. The code that sets icons tests on
# both; i.e., an item's kind has to be in the allow list and not be in the
# disallow list. If an item's kind is not listed as allowed, this script will
# ask if an exception should be made.

property allowed_kinds:    {"Group", "Smart Group", "Tag"}
property disallowed_kinds: {}

# If an item is a bookmark, it may be desirable to change its icon not based
# on the fact that it's a bookmark, but rather based on whether it points to
# an allowed or disallowed item. For example, if allowed_kinds contains
# "Group", you may want a bookmark that points to a DEVONthink group to be
# changed as if it were itself a group. (Note: the icon of the bookmark will
# still be set to its parent's icon, not the destination icon.)

property consider_bookmark_destination: true


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

# Return true if the given item is a tag.
on is_tag(rec)
	tell application id "DNtp"	
		return (tag type of rec) is in {group tag, ordinary tag} 
	end tell
end is_tag

# Return true if the given item has a custom color. (Only possible for tags.)
on has_color(rec)
	tell application id "DNtp"
		try
			color of rec as anything
		on error
			return false
		end try
		return true
	end tell
end has_color

# Return true if the given item has an icon/thumbnail.
on has_thumbnail(rec)
	tell application id "DNtp"
		try
			thumbnail of rec as anything
		on error
			return false
		end try
		return true
	end tell
end has_thumbnail

# Return true if the given kind matches the allow/disallow conditions.
on is_acceptable_kind(kname)
	return (kname is in allowed_kinds and not kname is in disallowed_kinds)
end is_acceptable_kind

# Return true if the given record has a kind that we want to act on.
on is_allowed_kind(rec)
	tell application id "DNtp"
		set rkind to (kind of rec) as string
		if my is_acceptable_kind(rkind) then
			return true
		else if consider_bookmark_destination then
			set dest_url to url of rec
			if dest_url starts with "x-devonthink-item" then
				# It points to a DEVONthink destination, so get its kind.
				set dest_uuid to text 21 thru -1 of dest_url
				set dest_rec to get record with UUID dest_uuid
				set dest_kind to (kind of dest_rec) as string
				return my is_acceptable_kind(dest_kind)
			end if
		end if
		return false
	end tell
end is_allowed_kind


# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on act_on_record(rec)
	tell application id "DNtp"
		# For items at the root level, there's no parent to get an icon from.
		if (location of rec) = "/" then
			set msg to "The icon of this item cannot be set because the " ¬
				& "item is at the root level of the database:" & ¬
				linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Skip", "Cancel"} ¬
				with title my get_script_name() with icon 1 ¬
			 	default button 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
			end if
			return 
		end if

		# If this is not the desired kind, ask the user what to do.
		if not my is_allowed_kind(rec) then
			set msg to "This item is of kind \"" & kind of rec & "\", which " ¬
				& "is not one of the expected kinds. Should its icon " ¬
				& "be changed anyway? " & linefeed & linefeed & (name of rec)
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

		# Either it's the right kind, or the user said to go ahead anyway.
		set parent_group to location group of rec
		if my has_thumbnail(parent_group) then
			# Note: *must* set this directly; can't use intermediate var.
			set thumbnail of rec to thumbnail of parent_group
		else if my is_tag(rec) and my has_color(parent_group) then
			# Special case: if the parent doesn't have an icon but this is
			# a tag, we can still change its color to its parent's color.
			set color of rec to color of parent_group
		else
			set msg to "The parent of this item does not have a custom " ¬
				& "icon, and therefore, the item's icon cannot be changed: " ¬
				& linefeed & linefeed & (name of rec)
			display dialog msg buttons {"Skip", "Cancel"} ¬
				with title my get_script_name() with icon 1 ¬
				default button 1 giving up after 60
			if button returned of result = "Cancel" then
				error "User cancelled operation"
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
