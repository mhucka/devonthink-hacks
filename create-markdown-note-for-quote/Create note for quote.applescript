-- ======================================================================
-- @file    Create note for quote.applescript
-- @brief   Create an md note, treating the highlighted text as a quote
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is meant to work anywhere, not just inside DEVONthink.
--
-- This assumes there is a template file in DEVONthink template diretory.
-- The file name is set by the "templateFileName" parameter below.
-- ======================================================================

-- Name of the template file used to create the Markdown document.
property templateFileName : "Quote.md"

-- Truncate the name of the document if it's longer than this.
property maxDocTitleLength : 256

-- Copy the text highlighted in the current application. I couldn't
-- find a more direct way of doing this than to use GUI scripting.
tell application "System Events" to keystroke "c" using {command down}

-- Create a new document in DEVONthink, prompting for the detination.
tell application id "DNtp"
	try
		set supDir to path to application support from user domain as text
		set tpDir to POSIX path of (supDir & "DEVONthink 3:Templates.noindex:")
		set templateFile to (POSIX path of tpDir & templateFileName)

		-- Unwrap the text in the clipboard.
		set selectedText to the clipboard as text

		-- Construct a name based on the quoted text, but truncated.
		if length of selectedText is less than maxDocTitleLength then
			set docTitle to selectedText
		else
			set docTitle to text 1 thru maxDocTitleLength of selectedText
		end if

		-- If you don't use the "placeholders" option, DEVONthink will not
		-- substitute its built-in placeholders. So, use at least one.
		set newDoc to import templateFile placeholders {name:docTitle}
		set the name of newDoc to docTitle
		set creation date of newDoc to current date
		set modification date of newDoc to current date
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell
