# =============================================================================
# @file	   Auto convert web page to PDF.applescript
# @brief   Script for DEVONthink to convert a webpage bookmark to PDF
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo	   https://github.com/mhucka/devonthink-hacks
# =============================================================================

# This uses heuristics to try to load page content before creating a
# full-page PDF snapshot of the page. Beware that it takes 10+ seconds
# to finish, during which time it has to be the frontmost application
# so that the page-down keystrokes apply to the correct window.

on performSmartRule(theRecords)
	repeat with selected in theRecords
		set theWindow to open window for record selected
		delay 1

		# Wait until it's finished loading.
		repeat while loading of theWindow
			delay 0.5
		end repeat

		# Some pages load content dynamically, with elements not displayed
		# until they come into view. This is a hopeless situation generally
		# but the following heuristic improves outcomes for some cases.
		# We scroll the window by quarters to try to trigger loading.
		repeat with n from 1 to 4
			set scroll to "window.scrollTo(0," & n & "*document.body.scrollHeight/4)"
			do JavaScript scroll in current tab of theWindow
			delay 0.75
		end

		# Scroll back to the top. This hack was motivated by trying to deal
		# with Twitter's quirky behavior, but may have value elsewhere.
		do JavaScript "window.scrollTo(0,0)" in current tab of theWindow
		delay 0.5

		# Get the content of this current viewer window, in PDF form.
		# Doing it this way instead of using DEVONthink's "convert record
		# to single page PDF document" is critical to getting the version 
		# of the page that is produced with the user's login/session state.
		set contentAsPDF to get PDF of theWindow

		# The currently-selected item is a bookmark.  We still have to
		# create a PDF document in DEVONthink.
		set recordName to (name of selected)
		set recordURL to (URL of selected) as string
		set newRecord to create record with {name:recordName, URL:recordURL, type:PDF document} in current group
		set data of newRecord to contentAsPDF
		set creation date of newRecord to creation date of selected
		set modification date of newRecord to modification date of selected
		set comment of newRecord to comment of selected
		set label of newRecord to label of selected

		close theWindow
	end repeat
end performSmartRule
