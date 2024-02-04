-- Summary: replace custom placeholders in the text of a Markdown document.
--
-- This AppleScript program is meant to be invoked by a DEVONthink Smart
-- Rule. It searches the contents of a selected document for placeholders
-- of the form %placeholder% and for each one, replaces the placeholder
-- text with the value of the appropriate metadata field found in the
-- DEVONthink record for that document. It preprocesses the value to
-- escape characters that have special meaning in Markdown (e.g., the
-- pound sign) so that the result is less likely to be misinterpreted by
-- the Markdown processor.
--
-- ╭───────────────────────────── WARNING ─────────────────────────────╮
-- │ This assumes custom metadata fields that I set in my copy of      │
-- │ DEVONthink. It will almost certainly not work in anyone else's    │
-- │ copy of DEVONthink.                                               │
-- ╰───────────────────────────────────────────────────────────────────╯
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Set of characters (expressed as a regex) with special meaning in Markdown.
property chars_escape_regex: "[`*_{}()\\[\\]<>#+!|-]"

-- List of custom metadata fields to replace (in addition to regular fields).
property custom_fields: {"Citekey", "Year", "Type", "Abstract", "Reference"}


-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Log a message in DEVONthink's log and include the name of this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		log message script_path info error_text
	end tell
	log error_text				-- Useful when running in a debugger.
end report

-- Do literal replacement of placeholder in string oldstr & return the result.
on replace(placeholder, replacement, oldstr)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on replace(placeholder, replacement, oldstr)
			try
				set opts to ca's NSCaseInsensitiveSearch
				set newstr to ca's NSString's stringWithString:oldstr
				set newstr to (newstr's ¬
					stringByReplacingOccurrencesOfString:placeholder ¬
					withString:(replacement) options:(opts) ¬
					range:{0, newstr's |length|()})
				return newstr as string
			on error msg number code
				my report(msg & "(error " & number & ")")
				return oldstr
			end try
		end replace
	end script
	return wrapperScript's replace(placeholder, replacement, oldstr)
end replace

-- Filter the given string to quote characters that have meaning in Markdown.
on escape(oldstr)
	script wrapperScript
		property ca : a reference to current application
		use framework "Foundation"
		on escape(oldstr)
			try
				set newstr to ca's NSString's stringWithString:oldstr
				set {regex, err} to (ca's NSRegularExpression's ¬
					regularExpressionWithPattern:chars_escape_regex ¬
						options:0 |error|:(reference))
				if err is not missing value then
					set err_text to err's localizedDescription() as text
					error ("Invalid definition of the set of characters to " ¬
						   & "escape in replaced text: " & err_text) number -128
				end if
				set newstr to (regex's stringByReplacingMatchesInString:newstr ¬
					options:0 range:{0, newstr's |length|()} withTemplate:"\\\\$0")
				return newstr as string
			on error msg number code
				my report(msg & "(error " & number & ")")
				return oldstr
			end try
		end escape
	end script
	return wrapperScript's escape(oldstr)
end escape


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	tell application id "DNtp"
		try
			set md_records to {}
			repeat with rec in selected_records
				set rectype to (type of rec) as string
				if rectype = "markdown" or rectype = "«constant Ctypmkdn»" then
					set end of md_records to rec
				end if
			end repeat
			repeat with rec in md_records
				set docUUID to uuid of rec
				set docURL to reference URL of rec as string
				set groupURL to reference URL of current group as string
				set docName to my escape(name of rec)
				set docFileName to my escape(filename of rec)

				set body to plain text of rec

				set body to my replace("%UUID%", docUUID, body)
				set body to my replace("%fileName%", docFileName, body)
				set body to my replace("%groupURL%", groupURL, body)
				set body to my replace("%documentURL%", docURL, body)
				set body to my replace("%documentName%", docName, body)
				repeat with field_name in custom_fields
					set placeholder to "%" & field_name & "%"
					set val to get custom meta data for field_name from rec
					set val to my escape(val)
					set body to my replace(placeholder, val, body)
				end repeat

				set plain text of rec to body
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell