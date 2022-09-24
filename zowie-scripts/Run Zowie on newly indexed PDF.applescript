-- ======================================================================
-- @file    Run Zowie on newly indexed PDF.applescript
-- @brief   Script for DEVONthink smart rule to run Zowie on new additions
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
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
		delay 15
	end tell
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
				set raw_path to the path of _record

				-- A problem for shell strings is embedded single quotes.
				-- Combo of changing text delimiters & using AppleScript
				-- "quoted form of" seems to do the trick.
				set AppleScript's text item delimiters to "\\\\"
				set quoted_path to quoted form of raw_path

				-- Now run Zowie. The PATH setting adds common locations
				-- where Zowie may be installed on the user's computer.
				set result to do shell script ¬
					"PATH=$PATH:$HOME/.local/bin:/usr/local/bin" ¬
					& " zowie -s -q " & quoted_path

				-- If Zowie returned a msg, something went wrong.
				if result ≠ "" then
					display notification result
				else
					-- Finish by telling DT explicitly to set the comment,
					-- because it doesn't consistently "notice" addition
					-- of a comment after a file has already been indexed.
					set comment of _record to my finderComment(raw_path)
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Function to ask the Finder to read the comment. 

on finderComment(f)
	tell application "Finder"
		return comment of (POSIX file f as alias)
	end tell
end finderComment

-- Function to make literal text substitutions.
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
