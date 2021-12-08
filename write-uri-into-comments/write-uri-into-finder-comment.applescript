-- ======================================================================
-- @file    write-uri-into-finder-comment.applescript
-- @brief   Write the item's URI into the Finder comment of a document
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/write-uri-into-comments
-- ======================================================================

on performSmartRule(theRecords)
	tell application id "DNtp"
		-- Note that this sets the comment unconditionally. To test
		-- something before writing the comment, it is easier to do it
		-- in the trigger definition of the Smart Rule itself.
		repeat with theRecord in theRecords
			set comment of theRecord to (reference URL of theRecord)
		end repeat
	end tell
end performSmartRule
