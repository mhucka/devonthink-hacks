-- ==========================================================================
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
-- ==========================================================================

-- Name of the template file used to create the Markdown document.
property templateFileName : "Quote.md"

-- Truncate the name of the document if it's longer than this.
property maxDocTitleLength : 255

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~ There are no more configurable options below this point. ~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tell application "System Events"
	-- Identify the application this is invoked in.
	set prog to name of first application process whose frontmost is true

	-- Copy the text highlighted in the current application. I couldn't
	-- find a more direct way of doing this than to use GUI scripting.
	keystroke "c" using {command down}
end tell

tell application id "DNtp"
	try
		-- Get a URL to refer back to the open document.
		set sourceURLorFile to my pageURLorFile for prog

		-- Get the path of the template to be used to create the new doc.
		set supDir to path to application support from user domain as text
		set tpDir to POSIX path of (supDir & "DEVONthink 3:Templates.noindex:")
		set templateFile to (POSIX path of tpDir & templateFileName)

		-- Unwrap the text in the clipboard.
		set selectedText to the clipboard as text
		set AppleScript's text item delimiters to {return, linefeed}
		set itemList to every text item of selectedText
		set AppleScript's text item delimiters to " "
		set the clipboard to the itemList as string

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
		set URL of newDoc to sourceURLorFile
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell


-- Get the URL or path of the frontmost document.
-- The code to get the page URL from DEVONthink was modified from a post
-- by user "pete31" to the DEVONthink forums on 2021-07-28 at https://
-- discourse.devontechnologies.com/t/link-to-specific-page-of-a-pdf/65898/3
on pageURLorFile for (prog as text)
	try
		if (prog = "DEVONthink 3") then
			tell application id "DNtp"
				if exists think window 1 then
					set theWindow to think window 1
				else
					display notification "No DEVONthink window." ¬
						with title "DEVONthink"
					return ""
				end if
				set rec to content record of theWindow
				if rec = missing value then
					display notification "Could not get window contents." ¬
						with title "DEVONthink"
					return ""
				end if
				set recType to (type of rec) as string
				if recType is in {"PDF document", "«constant ****pdf »"} then
					set thePage to current page of theWindow
					if thePage ≠ -1 then
						return reference URL of rec & "?page=" & thePage
					else
						return reference URL of rec
					end if
				else
					return reference URL of rec
				end if
			end tell
		else if (prog = "Safari") or (prog = "Webkit") then
			using terms from application "Safari"
				tell application "Safari"
					return URL of front document
				end tell
			end using terms from
		else if (prog contains "Chrome") or (prog = "Chromium") then
			using terms from application "Google Chrome"
				tell application prog
					return URL of active tab of front window
				end tell
			end using terms from
		else
			-- Try to get the path to the file in the current app's window.
			-- This next gnarly bit of code came from an answer posted on
			-- 2019-09-28 by user "CJK" to Stack Overflow at
			-- https://stackoverflow.com/a/58145535/743730
			tell application id "com.apple.systemevents" to tell ¬
			(the first process where it is frontmost) to tell ¬
			(a reference to the front window) to if it exists then
				tell its attribute "AXDocument"'s value
					-- Apparently, "irrelevant" must be misspelled like this.
					if it is not in [missing value, "file:///Irrelevent"] then ¬
						return it
				end tell
			end if
			-- Fall through if the code above doesn't return a value.
			return ""
		end if
	on error msg number err
		if err is not -128 then ¬
			display alert prog message msg as warning
	end try
end pageURLorFile
