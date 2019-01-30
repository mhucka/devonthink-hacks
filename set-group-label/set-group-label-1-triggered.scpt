on triggered(the_group)
	tell application id "DNtp"
		set group_records to children of the_group
		repeat with r in group_records
			set the label of r to 1
		end repeat
	end tell
end triggered
