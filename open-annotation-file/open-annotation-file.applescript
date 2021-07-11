-- ============================================================================
-- @file    open-annotation-file.applescript
-- @brief   Open the annotation file associated with the selected document
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the parent directory
-- @repo    https://github.com/mhucka/devonthink-hacks
-- ============================================================================

tell application id "DNtp"
	try
		repeat with theRecord in (selection as list)
			if (exists annotation of theRecord) then
				set annot to get annotation of theRecord
				set annotRecord to get record with uuid (get uuid of annot)
				open window for record annotRecord with force
			else
				set rec_name to get name of theRecord
				display alert "Document has no annotation" message rec_name
			end if
		end repeat
	on error error_message number error_number
		if the error_number is not -128 then
			display alert "DEVONthink" message error_message as warning
		end if
	end try
end tell
