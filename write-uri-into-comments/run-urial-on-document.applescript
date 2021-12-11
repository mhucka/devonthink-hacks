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
		-- A just-created record may be still getting modified by things
		-- like smart rules. Wait a short time in case those rules change
		-- the file name.
		delay 1
		try
			repeat with _record in selectedRecords
				-- I don't understand why this next value has to be
				-- "path of the first item of _record" instead of
				-- just "path of _record", but that's what it needs.
				set file_path to the path of the first item of _record
				set uri to reference URL of the _record as string
				-- A problem with file names is embedded single quotes.
				-- The combo of changing the text delimiter and using
				-- the AS "quoted form of" below, seems to do the trick.
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
