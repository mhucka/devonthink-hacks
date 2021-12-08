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

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
				set raw_path to the path of the _record
				set uri to reference URL of the _record as string
		
				-- Some chars in file names are problematic due to their
				-- meaning in shell syntax. Need to quote them with 2
				-- blackslashes, b/c the 1st backslash will be removed
				-- when the shell command string is handed to the shell.
				set subst_path to my substituted("&", "\\\\&", raw_path)
		
				-- Another problem w/ is embedded single quotes. The
				-- combo of changing the text delimiter and using the
				-- AS "quoted form of" below, seems to do the trick.
				set AppleScript's text item delimiters to "\\\\"
				set quoted_path to quoted form of subst_path
				set quoted_uri to quoted form of uri
				set result to do shell script ¬
					"/Users/mhucka/.local/bin/urial -m append -G " ¬
					& quoted_uri & " " & quoted_path
		
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
