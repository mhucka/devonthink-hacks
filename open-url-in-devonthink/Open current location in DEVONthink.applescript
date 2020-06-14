-- =============================================================================
-- @file    Open current Safari location in DEVONthink
-- @brief   Create a bookmark in DEVONthink & open it
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license Please see the file LICENSE in the parent directory
-- @repo    https://github.com/mhucka/devonthink-hacks
-- =============================================================================

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

global theURL
set theURL to missing value
global theTitle
set theTitle to missing value

tell application "Safari"
	try
		if not (exists window 1) then error "No window is open."
		set theTitle to get name of the current tab of the front window
		set theURL to get URL of the current tab of the front window
	on error error_message number error_number
		if error_number is not -128 then
			display alert "Safari" message error_message as warning
		end if
	end try
end tell

tell application id "DNtp"
	set theGroup to preferred import destination
	set theBookmark to create record with {name:theTitle, type:bookmark, URL:theURL} in theGroup
	open window for record theBookmark
	activate
end tell
