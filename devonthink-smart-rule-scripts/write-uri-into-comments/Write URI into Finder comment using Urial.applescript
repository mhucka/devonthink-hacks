-- Summary: write the ref. URL of each record to its Finder comment.
--
-- ╭─────────────────── Notice ── Notice ── Notice ───────────────────╮
-- │ This AppleScript code will only work as a script executed by a   │
-- │ Smart Rule in DEVONthink. It won't work as a standalone script.  │
-- ╰──────────────────────────────────────────────────────────────────╯
--
-- A DEVONthink "reference URL" is a URI that begins with the URI scheme
-- "x-devonthink-item" and contains the UUID of an item in DEVONthink.
-- This script reads the DEVONthink reference URL of each selected
-- document in DEVONthink, and runs an external program (Urial) to set
-- the document's Finder comment to that URI. The reason this is useful
-- is that when you are editing a document in an external editor
-- (something that is permitted by DEVONthink), there is no inherent
-- information linking the file on disk to the database record that
-- corresponds to it. Using the reference URL is convenient on macOS
-- because of macOS's built-in URI scheme handler mechanisms, but the
-- reference URL is not a property of the file on disk. If you want to
-- know the reference URL of a given file, you have to come up with an
-- approach to storing it yourself in such a way that external programs
-- can find it. The approach taken here is to write it into the Finder
-- comment. This makes it possible to find the DEVONthink document by
-- reading the Finder comment (something that can be done in various
-- ways, such as with the use of AppleScript) and asking macOS to open
-- the document using the reference URI. For example, you can do
-- "open x-devonthink-item://474AB439-369E-429D-A856-924DDABC" from a
-- shell terminal and macOS will tell DEVONthink to open the document,
-- effectively letting you jump directly to the document from outside
-- of DEVONthink.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- This list is used to set the shell's command search $PATH. The values
-- cover the most likely places where Urial may be installed. If your
-- copy of Urial is not found in one of these locations, add the
-- appropriate directory to this list.

property shell_paths: { ¬
	"$PATH"				 , ¬
	"$HOME/.local/bin"	 , ¬
	"$HOME/.pyenv/shims" , ¬
	"$HOME/.pyenv/bin"	 , ¬
	"$HOME/bin"			 , ¬
	"/usr/local/bin"	 , ¬
	"/opt/homebrew/bin"    ¬
}

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

on sh(shell_command)
	set paths to "PATH=" & my concat(shell_paths, ":")
	set result to do shell script (paths & " " & shell_command)
end shell_cmd

-- The following function is based on code posted by user "mb21" on
-- 2016-06-26 at https://stackoverflow.com/a/38042023/743730

on substituted(search_string, replacement_string, this_text)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end substituted

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	-- The "tell" here isn't needed for DEVONthink (this whole script is
	-- executed by DEVONthink), but osacompile gives errors without it.
	tell application id "DNtp"
		try
			repeat with _record in selected_records
				set uri to reference URL of the _record as string
				set file_path to the path of _record
	
				-- Some chars in file names are problematic due to having
				-- special meaning to the shell. Need to quote them, but
				-- here, need to use 2 blackslashes, b/c the 1st backslash
				-- will be removed when the string is handed to the shell.
				set file_path to my substituted("&", "\\\\&", file_path)
	
				-- Another problem for shell strings is embedded single
				-- quotes. Combo of changing the text delimiter & using
				-- the AS "quoted form of" below seems to do the trick.
				set AppleScript's text item delimiters to "\\\\"
				set fp to quoted form of file_path
				
				set out to my sh("urial -m update -U " & uri & " " & fp)
		
				-- Display a notification if urial returned a msg.
				if out is not equal to "" then
					display alert "Urial" message out as warning
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule
