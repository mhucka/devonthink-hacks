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

			# Some pages load content dynamically, with images not displayed
			# until they come into view and/or the full extent of the page
			# not made visible until the bottom is reached.	 This is a hopeless
			# situation in general, but the following heuristics work for many
			# cases.  We first try to scroll the window by quarters, then for
			# good measure, use AppleScript to send the "go to the end" key
			# to the window.
			repeat 4 times
				do JavaScript "window.scrollTo(0, document.body.scrollHeight/4)" in theWindow
				delay 1
			end repeat
			tell application "System Events"
				key code 119		# "End" key
			end tell
			delay 1

			convert record theRecord to single page PDF document
			close theWindow
		end repeat
	end tell
end performSmartRule
