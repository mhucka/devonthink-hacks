-- ======================================================================
-- @file	write-urial-on-document.applescript
-- @brief	Execute urial as an external program
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/write-uri-into-comments
-- ======================================================================

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
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

				set result to do shell script ¬
					"PATH=$PATH:$HOME/.local/bin:/usr/local/bin urial" ¬
					& " -m update -U " & uri & " " & fp
		
				-- Display a notification if urial returned a msg.
				if result is not equal to "" then
					display alert "Urial" message result as warning
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

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
