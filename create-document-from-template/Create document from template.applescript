# =============================================================================
# @file	   Create document from template.applescript
# @brief   Script to create a document from a template and name it
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo	   https://github.com/mhucka/devonthink-hacks
# =============================================================================

# Configuration variables -- THE FOLLOWING MUST BE UPDATED MANUALLY
# .............................................................................

set templates to {"Clipboard to markdown.md", "Code.md", "Diary.ooutline", ¬
	"Document.ooutline", "Goal plan.ooutline", "Markdown.md", ¬
	"Meeting.ooutline", "Note.ooutline", "Plain text.txt", ¬
        "Reading notes.ooutline", "Term.ooutline"}


# Helper functions
# .............................................................................

# The following code is based on a function posted by "jobu" on 2004-08-11
# at https://macscripter.net/viewtopic.php?pid=32191#p32191

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


# Main body
# .............................................................................

tell application id "DNtp"
	set templateNames to {}
	repeat with t from 1 to length of templates
		copy my withoutExtension(item t of templates) to the end of templateNames
	end repeat
	
	set chosenTemplate to first item of (choose from list templateNames ¬
		with prompt "Template to use for new document:" default items {"Notebook"})
	
	set prompt to "Name for the new " & chosenTemplate & " document:"
	set reply to display dialog prompt default answer ""
	set docName to text returned of reply
	
	set templateDir to "/Users/" & (short user name of (system info)) ¬
		& "/Library/Application Support/DEVONthink 3/Templates.noindex/"
	
	repeat with n from 1 to (count of templateNames)
		if templates's item n starts with chosenTemplate then
			set templatePath to (POSIX path of templateDir & templates's item n)
		end if
	end repeat
	
	set newRecord to import templatePath to current group
	set creation date of newRecord to current date
	set modification date of newRecord to current date
	set the name of newRecord to docName
	try
		perform smart rule "auto-label my notes" record newRecord
	end try
end tell
