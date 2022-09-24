-- ======================================================================
-- @file    Add citekey for Zotero record.applescript
-- @brief   Script for DEVONthink smart rule to run Zoinks on new additions
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. It runs Zoinks to get the
-- Better BibTeX citation key for a Zotero record, and sets a custom
-- metadata field in DEVONthink for storing the citation key.
--
-- This expects to be passed a record that has a zotero://select/... link
-- in its "URL" metadata field. This Zotero link value is set by a
-- separate DEVONthink Smart Rule that runs another program, Zowie.
-- (C.f. https://github.com/mhucka/devonthink-hacks/zowie-scripts)
-- ======================================================================

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
				set _citekey to do shell script ¬
					"echo " & (URL of _record) & " | " & ¬
					"PATH=$PATH:$HOME/.local/bin:/usr/local/bin" ¬
					& " zoinks -U citekey"
				if _citekey ≠ "" then
					add custom meta data _citekey for "citekey" to _record
				else
					display notification ¬
						"Could not get citekey for " & (name of _record)
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "Zoinks" message msg as warning
			end if
		end try
	end tell
end performSmartRule
