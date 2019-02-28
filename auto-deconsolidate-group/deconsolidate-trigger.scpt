# =============================================================================
# @file    deconsolidate-trigger
# @brief   Script to deconsolidate a group when it is selected in DEVONthink
# @author  Michael Hucka <mhucka@caltech.edu>
# @license Please see the file LICENSE in the parent directory
# @repo    https://github.com/mhucka/devonthink-hacks
#
# This is based on the information posted by user "Greg Jones" at
# https://forum.devontechnologies.com/viewtopic.php?f=2&t=16193
#
# This script needs to be attached to a group in DEVONthink.
# =============================================================================

# Main body.
# .............................................................................

on triggered(theRecord)
	try
		tell application id "DNtp"
			deconsolidate record theRecord
		end tell
	end try
end triggered
