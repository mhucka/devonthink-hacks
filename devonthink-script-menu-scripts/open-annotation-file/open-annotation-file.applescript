-- Summary: open annotation file associated w/ selected document.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

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
