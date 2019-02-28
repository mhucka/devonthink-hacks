# =============================================================================
# @file    auto-deconsolidate-group
# @brief   Script to deconsolidate a group on a regular basis
# @author  Michael Hucka <mhucka@caltech.edu>
# @license Please see the file LICENSE in the parent directory
# @repo    https://github.com/mhucka/devonthink-hacks
#
# The way I use this program is through KeyboardMaestro.  I have a scheduled
# macro that executes this program every 10 minutes when DEVONthink Pro is
# running but is not the front application.  This makes DEVONthink do the work
# in the background automatically and avoids interrupting me while I'm actively
# working in DEVONthink.
# =============================================================================

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

# This sets the name of the tag to search for, to find groups to deconsolidate.
set markerTagName to "deconsolidate"

# Main body.
# .............................................................................

tell application id "DNtp"
	try
		repeat with currentDatabase in databases
			repeat with theGroup in (search markerTagName)
				deconsolidate record theGroup
			end repeat
		end repeat
	on error msg number err
		if the err is not -128 then display alert "DEVONthink Pro" message msg as warning
	end try
end tell
