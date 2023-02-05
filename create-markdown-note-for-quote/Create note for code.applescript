-- ============================================================================
-- @file    Create note for code.applescript
-- @brief   Create an md note oriented for code snippets
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is meant to work anywhere, not just inside DEVONthink.
--
-- This assumes there is a template file in DEVONthink template diretory.
-- The file name is set by the "templateFileName" parameter below.
-- ============================================================================

-- Name of the template file used to create the Markdown document.
property templateFileName : "Code.md"

-- Truncate the name of the document if it's longer than this.
property maxDocTitleLength : 255

-- Main logic
-- ............................................................................

tell application id "com.apple.systemevents"
	try
		-- Get a URL and title to refer back to the open document.
		set theApp to first application process whose frontmost is true
		set {sourceURL, sourceTitle} to my sourceInfo for theApp
	
		-- Copy the text highlighted in the current application. I couldn't
		-- find a more direct way of doing this than to use GUI scripting.
		keystroke "c" using {command down}
	on error msg number err
		display alert "Create note for quote" message msg as warning
	end try
end tell

tell application id "DNtp"
	try
		-- Get the path of the template to be used to create the new doc.
		set supDir to path to application support from user domain as text
		set tpDir to POSIX path of (supDir & "DEVONthink 3:Templates.noindex:")
		set templateFile to (POSIX path of tpDir & templateFileName)

		set selectedText to the clipboard as text

		-- Construct a name based on the selected text, but truncated.
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
		set URL of newDoc to sourceURL

		-- Replace additional custom placeholders. DEVONthink can't do
		-- these itself because the document has to be created first.
		set docURL to reference URL of newDoc as string
		set docRevealURL to docURL & "?reveal=1"
		if templateFileName ends with "md" then
			set body to plain text of newDoc
			set body to my replace(body, "%sourceURL%", sourceURL)
			set body to my replace(body, "%sourceTitle%", sourceTitle)
			set body to my replace(body, "%documentURL%", docURL)
			set body to my replace(body, "%documentRevealURL%", docRevealURL)
			set body to my replace(body, "%UUID%", uuid of newDoc)
			set plain text of newDoc to body
		end if
	on error msg number err
		if err is not -128 then ¬
			display alert "DEVONthink" message msg as warning
	end try
end tell


-- Miscellaneous handlers.
-- ............................................................................

-- Get the URL or path of the frontmost document.
-- The code to get the page URL from DEVONthink was modified from a post
-- by user "pete31" to the DEVONthink forums on 2021-07-28 at https://
-- discourse.devontechnologies.com/t/link-to-specific-page-of-a-pdf/65898/3
on sourceInfo for (theApp)
	set appName to name of theApp
	try
		-- First, check for common cases in which we know exactly what to do.
		if appName = "DEVONthink 3" then
			tell application id "DNtp"
				if exists think window 1 then
					set theWindow to think window 1
				else
					display notification "No DEVONthink window." ¬
						with title "DEVONthink"
					return {"", "Document"}
				end if
				set rec to content record of theWindow
				if rec = missing value then
					display notification "Could not get window contents." ¬
						with title "DEVONthink"
					return {"", "Document"}
				end if
				set sourceTitle to name of rec
				set sourceURL to reference URL of rec
				set recType to (type of rec) as string
				if recType is in {"PDF document", "«constant ****pdf »"} then
					set thePage to current page of theWindow
					if thePage ≠ -1 then
						set sourceURL to reference URL of rec & "?page=" & thePage
					end if
				end if
				return {sourceURL, sourceTitle}
			end tell
		else if appName = "Safari" or appName = "Webkit" then
			using terms from application "Safari"
				tell application "Safari"
					return {URL of front document, name of front document}
				end tell
			end using terms from
		else if (appName contains "Chrome") or (appName = "Chromium") then
			using terms from application "Google Chrome"
				tell application appName
					set sourceURL to URL of active tab of front window
					set sourceTitle to title of active tab of front window
					return {sourceURL, sourceTitle}
				end tell
			end using terms from
		else if appName = "Preview" then
			tell application id "com.apple.Preview"
				return {path of document 1, name of document 1}
			end tell
		else if appName = "TextEdit" then
			tell application "TextEdit"
				set theDoc to document of window 1
				return {path of theDoc, name of theDoc}
			end tell
		else if appName = "OmniOutliner" then
			tell application "OmniOutliner"
				set theFile to file of document 1
				return {POSIX path of theFile, name of document 1}
			end tell
		end if

		-- If we get here, it means we didn't recognize the application. Assume
		-- the source is a document, and use a generic approach to try get the
		-- path to the file in the current app's window. The next bit of code
		-- is based in part on a posting by user "user2330514" on 2016-11-01
		-- to Stack Overflow at https://stackoverflow.com/a/58145535/743730
		-- Note: the "tell systemevents" part is needed to avoid error -2471.
		tell application id "com.apple.systemevents"
		    tell process appName
		        if exists (1st window whose value of attribute "AXMain" is true) then
		            tell (1st window whose value of attribute "AXMain" is true)
						set sourceURL to value of attribute "AXDocument"
		                set sourceTitle to value of attribute "AXTitle"
						return {sourceURL, sourceTitle}
		            end tell
		        end if
		    end tell
		end tell

		-- Fall-through default case, if the code above doesn't return a value.
		return {"", "Document"}
	on error msg number err
		if err is not -128 then ¬
			display alert appName message msg as warning
	end try
end sourceInfo


-- Replace text inside a DEVONthink document.
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
