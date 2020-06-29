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
	tell application id "DNtp"
		# Need activate so that the key acode commands below act on the
		# DEVONthink window and not the current Safari window.
		activate
		repeat with theRecord in theRecords
			set theWindow to open window for record theRecord
			delay 2

			# Some pages load content dynamically, with elements not displayed
			# until they come into view. This is a hopeless situation generally
			# but the following heuristic improves outcomes for some cases.
			# We scroll the window by fifths to try to trigger loading.
			repeat with n from 1 to 5
				set scroll to "window.scrollTo(0," & n & "*document.body.scrollHeight/5)"
				do JavaScript scroll in current tab of theWindow
				delay 1
			end

			convert record theRecord to single page PDF document
			close theWindow
		end repeat
	end tell
end performSmartRule
