-- ======================================================================
-- @file    Switch workspace.applescript
-- @brief   Save the current workspace config and switch to anotehr
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- The original version of this code was sent to me by Jim Neumann of
-- DEVONtechnologies via email on 2022-10-13 in response to my request
-- for a feature addition to DEVONthink. I have modified the original.
-- ======================================================================

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application "System Events"
	tell application process "DEVONthink 3"
		set frontmost to true
	end tell
end tell

tell application "DEVONthink 3"
	try
		set chosenWorkspace to ¬
			(choose from list (workspaces as list) ¬
				with prompt ¬
				"Choose workspace" without multiple selections allowed and empty selection allowed)
		
		if chosenWorkspace ≠ false then -- User chose, not cancelled
			if exists (current workspace) then
				save workspace (get current workspace)
			end if
			close every think window
			load workspace (item 1 of chosenWorkspace)
		end if
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
