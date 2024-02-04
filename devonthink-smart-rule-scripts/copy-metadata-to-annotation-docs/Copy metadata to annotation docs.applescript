-- Summary: copy specific metadata from source doc to annotation doc.
--
-- This AppleScript code will only work as a script executed by a Smart
-- Rule in DEVONthink. It also assumes that the Smart Rule is set to
-- search specifically in the database group containing annotations.
--
-- ╭───────────────────────────── WARNING ─────────────────────────────╮
-- │ This assumes custom metadata fields that I set in my copy of      │
-- │ DEVONthink. It will almost certainly not work in anyone else's    │
-- │ copy of DEVONthink.                                               │
-- ╰───────────────────────────────────────────────────────────────────╯
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- The following are specific to my DEVONthink configuration.
property custom_fields: {"Citekey", "Type", "Year", "Abstract", "Reference"}

-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on copy_meta(source_record, annotation_record)
	tell application id "DNtp"
		tell annotation_record
			set tags to tags of source_record
			set URL to reference URL of source_record
			set rating to rating of source_record
			set label to label of source_record
			repeat with _field in custom_fields
				set value to get custom meta data for _field from source_record
				add custom meta data value for _field to annotation_record
			end repeat
		end tell
	end tell
end copy_meta

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	tell application id "DNtp"
		repeat with this_record in selected_records
			-- We assume that these are annotation records already. We
			-- need to get the thing they're annotating.
			repeat with _incoming in incoming references of this_record
				if (exists annotation of _incoming) then
					set other_annot to get annotation of _incoming
					if uuid of other_annot = uuid of this_record then
						my copy_meta(_incoming, this_record)
					end if
				end if
			end repeat
		end repeat
	end tell
end performSmartRule
