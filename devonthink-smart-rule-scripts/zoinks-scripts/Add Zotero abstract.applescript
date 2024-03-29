-- Set custom metadata "abstract" using Zonks
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. It runs Zoinks to get the
-- abstract for a Zotero record (technically, what Better BibTeX alls
-- the "abstractNote" field), and sets a metadata field in DEVONthink
-- for storing the abstract. If there is no abstract in the Zotero
-- record, this sets the metadata field value to "(No abstract.)".
--
-- This expects to be passed a record that has a zotero://select/...
-- link in its "URL" metadata field. This Zotero link value is set by
-- a separate DEVONthink Smart Rule that runs another program, Zowie.
-- (C.f. https://github.com/mhucka/devonthink-hacks/zowie-scripts)

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			repeat with _record in selectedRecords
				set _abstract to do shell script ¬
					"echo " & (URL of _record) & " | " & ¬
					"PATH=$PATH:$HOME/.local/bin:$HOME/.pyenv/shims:$HOME/.pyenv/bin:/usr/local/bin:/opt/homebrew/bin" ¬
					& " zoinks -U abstractNote"
				if _abstract ≠ "" then
				    -- Remove embedded newlines in the abstract.
				    set _abstract to do shell script ¬
					    "echo " & quoted form of _abstract & "| tr -s '\\r\\n' ' '"
				else
				    set _abstract to "(No abstract.)"
				end if
				add custom meta data _abstract for "abstract" to _record
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "Zoinks" message msg as warning
			end if
		end try
	end tell
end performSmartRule
