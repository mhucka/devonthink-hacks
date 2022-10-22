-- ============================================================================
-- @file    Create document from template.applescript
-- @brief   Script to create a document from a template and name it
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license -- please see the file LICENSE in the parent directory
-- @repo    https://github.com/mhucka/devonthink-hacks
-- ============================================================================

-- Configuration variables -- THE FOLLOWING MUST BE UPDATED MANUALLY.
-- ............................................................................

set templates to { ¬
	"Code.md", ¬
	"Diary.ooutline", ¬
	"Empty markdown.md", ¬
	"Goal plan.ooutline", ¬
	"Markdown.md", ¬
	"Meeting.ooutline", ¬
	"Notes.ooutline", ¬
	"Records markdown.md", ¬
	"Spreadsheet.numbers", ¬
	"Term definition.md" ¬
}


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

on replace(theText, placeholder, value)
	if theText contains placeholder then
		local od
		set {od, text item delimiters of AppleScript} to ¬
			{text item delimiters of AppleScript, placeholder}
		set theText to text items of theText
		set text item delimiters of AppleScript to value
		set theText to "" & theText
		set text item delimiters of AppleScript to od
	end if
	return theText
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
			with prompt "Template to use for new document:" default items {"Notes"})
		if userSelection is false then
		   error number -128
		end if

		set chosenTemplate to first item of userSelection
		set prompt to "Name for the new " & chosenTemplate & " document:"
		set docName to display name editor "New document" info prompt as string
		if docName is false then
		   error number -128
		end if
		
		set supportDir to path to application support from user domain as text
		set templateDir to POSIX path of (supportDir & "DEVONthink 3:Templates.noindex:")
		
		repeat with n from 1 to (count of templateNames)
			if templates's item n starts with chosenTemplate then
				set templatePath to (POSIX path of templateDir & templates's item n)
				set templateFullName to templates's item n
			end if
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
		set docUUID to uuid of newRecord
		set docRevealURL to recordURL & "?reveal=1"
		set docFileName to filename of newRecord
	
		if templateFullName ends with "md" then
			set body to plain text of newRecord
			set body to my replace(body, "%UUID%", docUUID)
			set body to my replace(body, "%fileName%", docFileName)
			set body to my replace(body, "%groupURL%", groupURL)
			set body to my replace(body, "%documentURL%", recordURL)
			set body to my replace(body, "%documentRevealURL%", docRevealURL)
			set body to my replace(body, "%documentName%", docName)
			set plain text of newRecord to body
		end if

		-- Execute all smart rules as the final step. This ignores the
		-- result, because the value is either true/false, and there's no
		-- point to showing a dialog that says "a smart rule failed but I
		-- can't tell you which one".
		perform smart rule record newRecord trigger creation event
	end tell
on error error_message number error_number
	if the error_number is not -128 then
		display alert "DEVONthink error" message error_message as warning
	end if
end try
