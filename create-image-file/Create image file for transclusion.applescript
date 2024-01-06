-- Create an image file to use for transcluding an image in Zotero.
-- This is specific to my way of doing things in DEVONthink & Zotero.
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

property groupPath: "/Sources/Zotero/Images"

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		set grp to create location groupPath in the current database
		try
			repeat with rec in selectedRecords
				set citekey to get custom meta data for "citekey" from rec
				if citekey = "" then
					set recName to name of rec
					display notification "No citekey found for " & recName
					return
				end if
				if (exists record at groupPath & "/" & citekey) then
					return
				end if

				set u to get reference URL of rec
				set caption to "Source: [@" & citekey & "](" & u & ")"
				set body to "![" & caption & "](" & u & ")"
				create record with ¬
					{name:citekey, type:markdown, plain text:body} ¬
					in grp
			end repeat
		on error msg number code
			-- Code -128 signifies the user cancelled an operation.
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule
