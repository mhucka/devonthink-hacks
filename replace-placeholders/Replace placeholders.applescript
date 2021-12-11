-- ======================================================================
-- @file	replace-placeholders.applescript
-- @brief	Replace custom placeholders in the text of a document
-- @author	Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the repo
-- @repo	https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/replace-placeholders
-- ======================================================================

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with theRecord in selectedRecords
				set t to (type of theRecord) as string
				if t = "markdown" or t = "«constant Ctypmkdn»" then
					set docName to name of theRecord
					set docUUID to uuid of theRecord
					set docURL to reference URL of theRecord as string
					set docFileName to filename of theRecord
					set theGroup to current group
					set groupURL to reference URL of theGroup as string

					set body to plain text of theRecord
					set body to my replace(body, "%UUID%", docUUID)
					set body to my replace(body, "%fileName%", docFileName)
					set body to my replace(body, "%groupURL%", groupURL)
					set body to my replace(body, "%documentURL%", docURL)
					set body to my replace(body, "%documentName%", docName)
					set plain text of theRecord to body
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

on replace(theText, placeholder, value)
	if theText contains placeholder then
		local od
		set {od, text item delimiters of AppleScript} to ¬
			{text item delimiters of AppleScript, placeholder}
		set theText to text items of theText
		set text item delimiters of AppleScript to value
		set theText to "" & theText
		set text item delimiters of AppleScript to od
	end if
	return theText
end replace
