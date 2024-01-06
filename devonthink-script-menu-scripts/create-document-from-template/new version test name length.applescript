-- ============================================================================
-- @file    Create document from template.applescript
-- @brief   Script to create a document from a template and name it
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the parent directory
-- @repo    https://github.com/mhucka/devonthink-hacks
-- ============================================================================

-- Configuration variables -- THE FOLLOWING MUST BE UPDATED MANUALLY.
-- ............................................................................

set templates to {"Code.md", "Diary.ooutline", "Goal plan.ooutline", ¬
	"Markdown.md", "Markdown-for-external.md", "Meeting.ooutline", ¬
	"Notes.ooutline", "Plain text.txt", "Reading notes.ooutline", ¬
	"Spreadsheet.numbers", "Term definition.md"}


-- Helper functions.
-- ............................................................................

-- The following code is based on a function posted by "jobu" on 2004-08-11
-- at https://macscripter.net/viewtopic.php?pid=32191--p32191

on withoutExtension(name)
	if name contains "." then
		set delim to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "."
		set basename to (text items 1 through -2 of (name as string) as list) as string
		set AppleScript's text item delimiters to delim
		return basename
	else
		return name
	end if
end withoutExtension

-- The following code is partly based on the 2017-05 posting by cgrunenberg at
-- https://discourse.devontechnologies.com/t/script-to-replace-text-in-given-selection-of-records/22272/2

on replace(placeholder, value, the_record)
	-- MH note: the "tell" is needed to keep Script Debugger from changing
	-- "plain text" to "string" during compilation of the code below.
	tell application id "DNtp"
		set od to AppleScript's text item delimiters
		set current_text to plain text of the_record
		if current_text contains placeholder then
			set AppleScript's text item delimiters to placeholder
			set text_item_list to every text item of current_text
			set AppleScript's text item delimiters to value
			set new_item_text to text_item_list as string
			set plain text of the_record to new_item_text
		end if
		set AppleScript's text item delimiters to od
	end tell
end replace


-- Main body.
-- ............................................................................

try
	tell application id "DNtp"
		set templateNames to {}
		repeat with t from 1 to length of templates
			copy my withoutExtension(item t of templates) to the end of templateNames
		end repeat
		
		set userSelection to (choose from list templateNames ¬
			with prompt "Template to use for new document:" default items {"Notebook"})
		if userSelection is false then
			error number -128
		end if
		
		set chosenTemplate to first item of userSelection
		set prompt to "Name for the new " & chosenTemplate & " document:"
		set docName to display name editor "New document" info prompt as string
		if docName is false then
			error number -128
		end if
		
		set templateDir to "/Users/" & (short user name of (system info)) ¬
			& "/Library/Application Support/DEVONthink 3/Templates.noindex/"
		

		-- FIXME the following doesn't seem to work


		set chosenNameLen to (count of characters in chosenTemplate)
		repeat with n from 1 to (count of templateNames)
			-- Hack to deal with AppleScripts's lack of a "continue"
			set templateFile to templates's item n
			repeat 1 times -- fake loop
				set nameLen to (count of characters in templateFile)
				if chosenNameLen > nameLen then exit repeat
				if templates's item n starts with chosenTemplate then
					set templatePath to (POSIX path of templateDir & templates's item n)
					set templateFullName to templates's item n
				end if
			end repeat
		end repeat
		
		set theGroup to current group
		set groupURL to reference URL of theGroup as string
		-- If you don't use the "placeholders" option, DEVONthink will not
		-- substitute its built-in placeholders like sortableDate. So, use
		-- at least one, just to trigger the built-in replacements.
		set newRecord to import templatePath placeholders {|%title%|:docName} to theGroup
		set creation date of newRecord to current date
		set modification date of newRecord to current date
		set the name of newRecord to docName
		set filePath to the path of the first item of newRecord
		set recordURL to reference URL of newRecord as string
		
		if templateFullName ends with "ooutline" then
			do shell script "/usr/local/bin/ottoman -m -r -i '" & filePath ¬
				& "' description=" & recordURL & " subject=" & groupURL
		else if templateFullName ends with "md" then
			set template_placeholders to {¬
				{name:"%groupURL%", value:groupURL}, ¬
				{name:"%UUID%", value:(uuid of newRecord)}, ¬
				{name:"%documentUUID%", value:(uuid of newRecord)}, ¬
				{name:"%documentURL%", value:recordURL}, ¬
				{name:"%documentRevealURL%", value:(recordURL & "?reveal=1")}}
			repeat with replacement in template_placeholders
				my replace(name of replacement, value of replacement, newRecord)
			end repeat
		end if
	end tell
on error error_message number error_number
	if the error_number is not -128 then
		display alert "DEVONthink error" message error_message as warning
	end if
end try
