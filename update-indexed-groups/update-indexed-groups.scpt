# =============================================================================
# @file    updated-indexed-groups
# @brief   Tell DEVONthink to update external indexed folders
# @author  Michael Hucka <mhucka@caltech.edu>
# @license Please see the file LICENSE in the parent directory
# @repo    https://github.com/mhucka/devonthink-hacks
#
# Portions of this program were based on a posting by user Christian Brunenberg
# http://forum.devontechnologies.com/viewtopic.php?f=20&t=18794&p=88001#p87999
#
# The way I use this program is through KeyboardMaestro.  I have a scheduled
# macro that executes this program every 10 minutes when DEVONthink Pro is
# running but is not the front application.  This makes DEVONthink update its
# index in the background automatically, yet avoids interrupting me while I'm
# actively working in DEVONthink.
# =============================================================================

# Global variables and constants.
# .............................................................................

# How many folders deep from root should we descend looking for indexes?
property MAX_DEPTH : 2


# Utility functions.
# .............................................................................

on indexGroup(currentGroup, currentDepth)
	if currentDepth > MAX_DEPTH then
		return
	end if
	tell application id "DNtp"
		if currentGroup is indexed then
			synchronize record currentGroup
		end if
		repeat with subgroup in (every child of currentGroup whose type is group)
			my indexGroup(subgroup, currentDepth + 1)
		end repeat
	end tell
end indexGroup


# Main body.
# .............................................................................

tell application id "DNtp"
	try
		repeat with currentDatabase in databases
			repeat with currentGroup in (records of currentDatabase)
				my indexGroup(currentGroup, 0)
			end repeat
		end repeat
	on error msg number err
		if the err is not -128 then display alert "DEVONthink Pro" message msg as warning
	end try
end tell

