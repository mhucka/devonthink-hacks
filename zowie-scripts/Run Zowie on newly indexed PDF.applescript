# =============================================================================
# @file	   Run Zowie on newly indexed PDF.applescript
# @brief   Script for DEVONthink smart rule to run Zowie on new additions
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo	   https://github.com/mhucka/devonthink-hacks
# =============================================================================

on performSmartRule(selectedRecords)
	repeat with _record in selectedRecords
		# In my environment, Zotero takes some time to upload a newly-
		# added PDF to the cloud. The following delay is needed to
		# give time for the upload to take place, so that when Zowie
		# runs, it can get the proper data from the Zotero API.
		delay 30
		set p to the path of the _record
		set result to do shell script "/usr/local/bin/zowie -q '" & p & "'"
                if result is not equal to "" then
                   display notification result
                end if
	end repeat
end performSmartRule
