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

				-- Aother problem for shell strings is embedded single
				-- quotes. Combo of changing the text delimiter & using
				-- the AS "quoted form of" below seems to do the trick.
				set AppleScript's text item delimiters to "\\\\"
				set result to do shell script ¬
					"/Users/mhucka/.local/bin/urial -m append -G " ¬
					& uri & " " & (quoted form of file_path)
		
				-- Display a notification if urial returned a msg.
				if result is not equal to "" then
					display notification result
				end if
			end repeat
		on error _msg number _code
			if the _code is not -128 then
				display alert "DEVONthink" message _msg as warning
			end if
		end try
	end tell
end performSmartRule

on substituted(search_string, replacement_string, this_text)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end substituted
