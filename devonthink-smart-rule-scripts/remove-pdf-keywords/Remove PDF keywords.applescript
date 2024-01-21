-- Summary: remove all PDF subject keywords from selected PDF files.
-- This calls "exiftool" as an external command-line program.
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- This list is used to set the shell's command search $PATH. The values
-- cover the most likely places where ExifTool may be installed. If your
-- copy of ExifTool is not found in one of these locations, add the
-- appropriate directory to this list.
property shell_paths: { ¬
	"$PATH"				 , ¬
	"$HOME/.local/bin"	 , ¬
	"$HOME/bin"			 , ¬
	"/usr/local/bin"	 , ¬
	"/opt/homebrew/bin"    ¬
}

-- The name of this script, for error messages.
property script_name: "Remove PDF keywords"

-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on concat(string_list, separator)
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
	set path_env to "PATH=" & paths
	try
		set result to do shell script (path_env & " " & command)
	on error msg number code
		if the code is not -128 then
			display alert script_name message msg as warning
		end if
	end try
	return result
end sh

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	tell application id "DNtp"
		set paths to my concat(shell_paths, ":")
		repeat with _record in selected_records
			if type of _record is PDF document then
				-- A problem for shell strings is embedded single quotes.
				-- Combo of changing text delimiters & using AppleScript
				-- "quoted form of" seems to do the trick.
				set AppleScript's text item delimiters to "\\\\"
				set p to quoted form of path of _record
				my sh(paths, "exiftool -overwrite_original -Keywords= " & p)
			end if
		end repeat
	end tell
end performSmartRule
