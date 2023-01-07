-- ======================================================================
-- @file    Auto convert web page to PDF.applescript
-- @brief   Script for DEVONthink to convert a webpage bookmark to PDF
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink. For more information, see
-- https://github.com/mhucka/devonthink-hacks/auto-convert-web-page-to-PDF/
-- ======================================================================

-- This script will add a tag to the PDF document it creates. Set the
-- next property value to the tag name that you want it to use.

property tagForPDF : "π-archived-page"

-- The companion bookmarklet can be used on regular web pages as well
-- as pages that are open on PDF files.  In the case of web pages, this
-- script uses heuristics to try to force page content to be loaded
-- fully before creating a full-page PDF snapshot of the page using the
-- PDF conversion facilityin DEVONthink. Beware that this takes 10+
-- seconds to finish (possibly longer, depending on page contents).

on performSmartRule(theRecords)
	repeat with selected in theRecords
		set recordURL to (URL of selected) as string
		set recordWindow to open window for record selected
		delay 2
		
		-- Wait until it's finished loading.
		repeat while loading of recordWindow
			delay 0.5
		end repeat
		
		-- If it's already a PDF, don't need to do more.
		if (recordURL ends with ".pdf") is not true then
			-- Some pages load content dynamically, with elements not
			-- displayed until they come into view. This is a hopeless
			-- situation in general but the following heuristic improves
			-- outcomes for some cases. It scrolls the window by
			-- quarters to try to trigger loading of more page elements.
			repeat with n from 1 to 4
				set scroll to "window.scrollTo(0," & n ¬
					& "*document.body.scrollHeight/4)"
				do JavaScript scroll in current tab of recordWindow
				delay 0.75
			end repeat

			-- Return to the top. Do it twice because sometimes on some
			-- pages (notably Twitter), the first attempt gets stuck in
			-- some random location. (Ugh, what an utter hack this is.)
			do JavaScript "window.scrollTo(0,0)" ¬
			    in current tab of recordWindow
			delay 0.5
			do JavaScript "window.scrollTo(0,0)" ¬
			    in current tab of recordWindow
			delay 0.25
		end if
		
		-- Get the content of our current viewer window, in PDF form.
		-- This approach instead of using DEVONthink's "convert record
		-- to single page PDF document" is critical to getting the
		-- version of the page that is produced with the user's
		-- login/session state.
		set contentAsPDF to get PDF of recordWindow
		
		set recordName to (name of selected)
		set recordParents to (parents of selected)
		set recordGroup to item 1 of recordParents
		
		-- Create the new record in the 1st parent group of the selected
		-- item. (FIXME: that's an arbitrary choice of groups if item is
		-- replicated. Should do something smarter here.)
		set newDoc to create record with ¬
		    {name:recordName, URL:recordURL, type:PDF document} ¬
			in recordGroup
		set data of newDoc to contentAsPDF
		set creation date of newDoc to creation date of selected
		set modification date of newDoc to modification date of selected
		set comment of newDoc to comment of selected
		set label of newDoc to label of selected
		
		-- Copy the tags of the original document and add tagForPDF.
		set {od, AppleScript's text item delimiters} ¬
		    to {AppleScript's text item delimiters, ","}
 		set the tags of newDoc to (tags of selected & tagForPDF)
		set AppleScript's text item delimiters to od

		close recordWindow
	end repeat
end performSmartRule
