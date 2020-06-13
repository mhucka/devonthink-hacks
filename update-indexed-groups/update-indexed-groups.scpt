# =============================================================================
# @file    updated-indexed-groups
# @brief   Tell DEVONthink to update external indexed folders
# @author  Michael Hucka <mhucka@caltech.edu>
# @license Please see the file LICENSE in the parent directory
# @repo    https://github.com/mhucka/devonthink-hacks
#
# This script relies on you tagging indexed groups with "indexed-folder".
#
# The way I use this program is through KeyboardMaestro.  I have a scheduled
# macro that executes this program every 10 minutes when DEVONthink Pro is
# running but is not the front application.  This makes DEVONthink update its
# index in the background automatically, yet avoids interrupting me while I'm
# actively working in DEVONthink.
# =============================================================================

# Main body.
# .............................................................................

tell application id "DNtp"
	try
		repeat with grp in (search "indexed-folder")
			if type of grp is group then
				synchronize record grp
			end if
		end repeat
	on error msg number err
		if the err is not -128 then display alert "DEVONthink Pro" message msg as warning
	end try
end tell

