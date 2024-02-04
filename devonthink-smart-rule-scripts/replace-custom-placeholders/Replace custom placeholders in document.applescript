-- Summary: replace placeholders in the text of a Markdown document.
--
-- ╭───────────────────────────── WARNING ─────────────────────────────╮
-- │ This assumes custom metadata fields that I set in my copy of      │
-- │ DEVONthink. It will almost certainly not work in anyone else's    │
-- │ copy of DEVONthink without modification.                          │
-- ╰───────────────────────────────────────────────────────────────────╯
--
-- This AppleScript program is meant to be invoked by a DEVONthink Smart Rule.
-- It searches the contents of a selected document for placeholders of the form
-- %placeholder% and for each one, replaces the placeholder text with the value
-- of the appropriate metadata field found in the DEVONthink record for that
-- document. It preprocesses the value to escape characters that have special
-- meaning in Markdown (e.g., the pound sign) so that the result is less likely
-- to be misinterpreted by the Markdown processor.
--
-- This script looks for BOTH standard placeholders defined by DEVONthink, and
-- a set of custom placeholders named in property "custom_fields" below. The
-- reason this replaces standard placeholders is because template placeholder
-- substitution is not performed by DEVONthink To Go on iOS when you create an
-- annotation document there. Now, despite that DTTG does not directly support
-- templates for annotations, it doesn't mean you can't insert template text
-- into the annotation property field of a record. For example, you could
-- create an iOS Shortcut to insert your desired template. That works well,
-- except that DTTG won't perform placeholder substitution. However, if you
-- synchronize your database with DEVONthink Pro on a Mac, and set up a
-- suitable Smart Rule, you can get placeholder substitution in annotation
-- documents after all (after a delay to sync documents and trigger the
-- Smart Rule). That is the reason this script exists.
--
-- The custom placeholder names that this script replaces will be prefixed with
-- a string (defined by property "custom_prefix" below), to avoid name
-- collisions with built-in DEVONthink placeholders. For example, in my
-- configuration, I defined a custom metadata field named "Year", which I use
-- to store the value of the year field in bibliographic items that I keep in
-- Zotero; unfortunately, it turns out that one of the standard DEVONthink
-- template placeholders is %year% (for the current year). If this script
-- didn't do something to distinguish custom year field names, then a %year%
-- appearing in a template acted on by this script would be ambiguous.
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

-- Prefix for custom placeholders (to avoid name collisions with DEVONthink).
property custom_prefix: "bib"


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

-- Do literal substitution of placeholder in string oldstr & return the result.
-- The value of "replacement" can be an empty string. If placeholder is an
-- empty string, this does nothing and returns "oldstr" unchanged.
on substitute(placeholder, oldstr, replacement)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on substitute(placeholder, oldstr, replacement)
			if (placeholder is missing value or placeholder = "") ¬
			  or (oldstr is missing value or oldstr = "") then
				return oldstr
			end if
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
		end substitute
	end script
	return wrapperScript's substitute(placeholder, oldstr, replacement)
end substitute

-- Filter the given string to quote characters that have meaning in Markdown.
on escape(oldstr)
	script wrapperScript
		property ca : a reference to current application
		use framework "Foundation"
		on escape(oldstr)
			if oldstr is missing value or oldstr = "" then
				return oldstr
			end if
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

-- Get the record that this annotation document is annotating.
on get_annotated_record(this_record)
	tell application id "DNtp"
		repeat with incoming_record in incoming references of this_record
			if (exists annotation of incoming_record) then
				set annot_of_incoming to get annotation of incoming_record
				if uuid of annot_of_incoming = uuid of this_record then
					return incoming_record
				end if
			end if
		  end repeat
	end tell
end get_annotated_record

-- Replace occurrences of "placeholder" in the "body" string, except if either
-- the placeholder or replacement are empty, in which case, nothing is done.
on replace(placeholder, body, replacement, escape_replacement)
	if replacement is missing value or replacement = "" then
		return body
	end if
	if escape_replacement is true then
		set replacement to my escape(replacement)
	end if
	return my substitute(placeholder, body, replacement)
end replace


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	tell application id "DNtp"
		try
			-- Create a list of just the Markdown documents in the selection.
			set md_records to {}
			repeat with rec in selected_records
				set rectype to (type of rec) as string
				if rectype = "markdown" or rectype = "«constant Ctypmkdn»" then
					set end of md_records to rec
				end if
			end repeat

			-- Iterate over our subset of records.
			repeat with rec in md_records
				local body
				set body to plain text of rec
				set ref_url to reference URL of rec
				set group_url to reference URL of current group

				-- Info about the current record (the annotation document).
				set body to my replace("%UUID%", body, uuid of rec, false)
				set body to my replace("%name%", body, name of rec, true)
				set body to my replace("%fileName%", body, filename of rec, true)
				set body to my replace("%referenceURL%", body, ref_url, false)
				set body to my replace("%groupURL%", body, group_url, false)

				-- When an annotation document is created on a Mac, DEVONthink
				-- replaces placeholders %document%Link% and %documentName%
				-- with the corresponding info about the *original* document
				-- (i.e., what is being annotated), not the current document,
				-- as described on p. 127 of the user manual for vers. 3.9.4.
				set source_record to my get_annotated_record(rec)
				set source_name to name of source_record
				set source_url to reference URL of source_record as string
				set body to my replace("%documentName%", body, source_name, true)
				set body to my replace("%documentURL%", body, source_url, false)

				-- Iterate over the list of custom placeholders.
				repeat with field_name in custom_fields
					local placeholder, value
					set placeholder to "%" & custom_prefix & field_name & "%"
					set value to get custom meta data for field_name from rec
					set body to my replace(placeholder, body, value, true)
				end repeat

				-- Replace the record body if we made it this far.
				set plain text of rec to body
			end repeat
		on error msg number code
			if the code is not -128 then
				my report(msg & " (error " & code & ")")
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
