# =============================================================================
# @file    Auto convert web page to PDF.applescript
# @brief   Script for DEVONthink to convert a webpage bookmark to PDF
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license -- please see the file LICENSE in the parent directory
# @repo    https://github.com/mhucka/devonthink-hacks
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
			tell application "System Events"
				# Some pages don't load images unless they come into view.
				# Page down a few times to try to trigger image loading.
				# This doesn't work for all pages, and an arbitrary no. of
				# times is not a general solution.  This is a hopeless 
				# situation, but maybe this will get _some_ images.
				repeat 3 times
					key code 121
					delay 1
				end repeat
				# Some pages don't load the full content until the user
				# reaches the bottom. There's no telling how much there
				# is, so this is another hopeless situation. Repeat this
				# a few times to try to load a decent amount.
				repeat 2 times
					key code 119
					delay 1
				end repeat
			end tell
			convert record theRecord to single page PDF document
			close theWindow
		end repeat
	end tell
end performSmartRule
