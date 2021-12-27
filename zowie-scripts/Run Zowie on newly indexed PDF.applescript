-- ======================================================================
-- @file	Run Zowie on newly indexed PDF.applescript
-- @brief	Script for DEVONthink smart rule to run Zowie on new additions
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/zowie-scripts
-- ======================================================================

on performSmartRule(selectedRecords)
	tell application "System Events"
		-- In my environment, Zotero takes time to upload a newly-added
		-- PDF to the cloud. The following delay is needed to give time
		-- for the upload to take place, so that when Zowie runs and
		-- queries Zotero via the network API, the data will be there.
		delay 30
	end tell
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
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
				set quoted_file_path to quoted form of file_path
		
				set result to do shell script ¬
					"PATH=$PATH:/usr/local/bin:$HOME/.local/bin zowie" ¬
					& " -s -q " & quoted_file_path
		
				-- Display a notification if zowie returned a msg.
				if result is not equal to "" then
					display notification result
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
