# =============================================================================
# @file	   Create document from template.applescript
# @brief   Script to create a document from a template and name it
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo	   https://github.com/mhucka/devonthink-hacks
# =============================================================================

# Configuration variables -- THE FOLLOWING MUST BE UPDATED MANUALLY
# .............................................................................

set templateNames to {"Code", "Diary", "Goal plan", "Notebook", "Meeting", "Term"}
set templateFiles to {"Code.md", "Diary.ooutline", "Goal plan.ooutline", ¬
	"Notebook.ooutline", "Meeting.ooutline", "Term.ooutline"}

# Main body
# .............................................................................

tell application id "DNtp"
	set chosenTemplate to first item of (choose from list templateNames ¬
		with prompt "Template to use for new document:" default items {"Notebook"})
	
	set prompt to "Name for the new " & chosenTemplate & " document:"
	set reply to display dialog prompt default answer ""
	
	set docName to text returned of reply
	
	set systemInfo to system info
	set userName to short user name of systemInfo
	
	set templateDir to "/Users/" & userName ¬
		& "/Library/Application Support/DEVONthink 3/Templates.noindex/"
	
	repeat with n from 1 to (count of templateNames)
		if templateFiles's item n starts with chosenTemplate then
			set templatePath to (POSIX path of templateDir & templateFiles's item n)
		end if
	end repeat
	
	set newRecord to import templatePath to current group
	set creation date of newRecord to current date
	set the name of newRecord to docName
	try
		perform smart rule "auto-label my notes" record newRecord
	end try
end tell
