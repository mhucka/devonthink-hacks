-- ======================================================================
-- @file	Convert note to card format.applescript.applescript
-- @brief	Smart Rule script to convert a note to my card format
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/format-card/
-- ======================================================================

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with record_ in selectedRecords
				set title to name of record_ as string
				set text_ to plain text of record_ as string
				set oldTID to AppleScript's text item delimiters
				-- Before coercing the paragraphs to a single string,
				-- set the item delimiter to linefeed. By defult it's "".
				set AppleScript's text item delimiters to linefeed
				set card_body to text_'s paragraphs 2 thru -1 as string
				set plain text of record_ to ¬
					"<details><summary><h2>" & title & "</h2></summary>" ¬
					& linefeed & linefeed & card_body & linefeed & linefeed ¬
					& "</details>" & linefeed
				set AppleScript's text item delimiters to oldTID
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule
