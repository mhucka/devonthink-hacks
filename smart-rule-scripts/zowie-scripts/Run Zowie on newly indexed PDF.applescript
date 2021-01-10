# =============================================================================
# @file	   Run Zowie on newly indexed PDF.applescript
# @brief   Script for DEVONthink smart rule to run Zowie on new additions
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo	   https://github.com/mhucka/devonthink-hacks
# =============================================================================

on performSmartRule(selectedRecords)
	repeat with _record in selectedRecords
		set p to the path of the _record
		set result to do shell script "/usr/local/bin/zowie -q '" & p & "'"
                if result is not equal to "" then
                   display notification result
                end if
	end repeat
end performSmartRule
