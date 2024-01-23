-- Summary: set the URL of an annotation document to the source doc.
--
-- This AppleScript code will only work as a script executed by a Smart
-- Rule in DEVONthink. It also assumes that the Smart Rule is set to
-- search specifically in the database group containing annotations.
--
-- As of DEVONthink 3.9.4, annotations are stored in such a way that the
-- record for the document being annotated (call it the source) points to
-- the annotation record, but the annotation record does NOT store a link
-- back to the source. This is problematic when you need to access the
-- source record. So, in my DEVONthink configuration, I set the URL field
-- of annotation documents to point to the source document. I find this
-- makes sense conceptually, and is convenient because then you use the
-- keyboard shortcut control-command-u to jump to the source document.
-- The script here is used in combination with a Smart Rule to set the
-- field when an annotation document is first created.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_annotation_records)
	tell application id "DNtp"
		-- This assumes the Smart Rule searches the group containing
		-- annotation documents. For efficiency, it doesn't test that.
		repeat with this_record in selected_annotation_records
			-- Look at each record that points to this record.
			repeat with _incoming in incoming references of this_record
				-- Does this other record have an annotation?
				if (exists annotation of _incoming) then
					set incoming_annot to get annotation of _incoming
					-- Is that annotation doc *this* annotation doc?
					if uuid of incoming_annot = uuid of this_record then
						set URL of this_record to reference URL of _incoming
					end if
				end if
			end repeat
		end repeat
	end tell
end performSmartRule
