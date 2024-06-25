# Summary: remove all PDF subject keywords from selected PDF files.
# This calls "exiftool" as an external command-line program.
#
# This is an AppleScript fragment that will only work as the script
# executed by a Smart Rule in DEVONthink.
#
# Copyright 2024 Michael Hucka.
# License: MIT license – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

# ~~~~ Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# List used to set the shell's command search $PATH. The values cover the most
# likely places where ExifTool may be found. If your copy of ExifTool is not
# found in one of these locations, add the appropriate directory to this list.
property shell_paths: { ¬
	"$PATH"				 , ¬
	"$HOME/.local/bin"	 , ¬
	"$HOME/bin"			 , ¬
	"/usr/local/bin"	 , ¬
	"/opt/homebrew/bin"    ¬
}


# ~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Log a message in DEVONthink's log and include the name of this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		# Note: DEVONthink's "log" function is not the same as AppleScript's.
		log message script_path info error_text
	end tell
	log error_text			 # Useful when running in an AppleScript debugger.
end report

on concat(string_list, separator)
	local output
    set output to ""
    repeat with i from 1 to count of string_list
        set output to output & item i of string_list
        if i < count of string_list then
            set output to output & separator
        end if
    end repeat
    return output
end concat

on sh(paths, command)
	local output, path_env
    set output to ""
	set path_env to "PATH=" & paths
	try
		set output to do shell script (path_env & " " & command)
	on error msg number code
		if the code is not -128 then
			my report(msg)
		end if
	end try
	return output
end sh

# ~~~~ Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	local paths, rec_path, quoted_path
	tell application id "DNtp"
		try
			set paths to my concat(shell_paths, ":")
			repeat with rec in selected_records
				if type of rec is PDF document then
					# Embedded single quotes cause problems. Combo of changing
					# delims & using "quoted form" (below) seems to solve it.
					set AppleScript's text item delimiters to "\\\\"
					# Don't combine the next 2 stmts b/c that will result in
					# type coercion will go wrong and cause an error.
					set rec_path to path of rec
					set quoted_path to quoted form of rec_path
					my sh(paths, "exiftool -q -Keywords= " ¬
						 & "-overwrite_original_in_place " & quoted_path)
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				my report(msg & " (error " & code & ")")
				display alert "DEVONthink error" message msg as warning
			end if
		end try

	end tell
end performSmartRule

# Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
