-- Open current web browser location in DEVONthink
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on showError(msg)
	display dialog msg buttons {"OK"} default button 1 with icon 0
end showError

on getWebPageData()
	set status to "OK"
	set theURL to ""
	set theTitle to ""
	
	tell application "System Events"
		set frontApp to item 1 of (get name of processes whose frontmost is true)
	end tell
	
	try
		if (frontApp = "Safari") then
			tell application "Safari"
				set theTitle to get name of the current tab of the front window
				set theURL to get URL of the current tab of the front window
			end tell
		else if (frontApp = "Google Chrome") then
			tell application "Google Chrome"
				set theTitle to get title of the active tab of the front window
				set theURL to get URL of the active tab of the front window
			end tell
		else
			set status to "Don't know how to get the URL from " & frontApp & "."
		end if
	on error
		set status to "Could not obtain info from " & frontApp & "."
	end try
	
	return {status, theURL, theTitle}
end getWebPageData

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tell application "DEVONthink 3" to launch

set {status, theURL, theTitle} to my getWebPageData()
if status as string is equal to "OK" then
	tell application id "DNtp"
		set theGroup to preferred import destination
		set theBookmark to create record with {name:theTitle, type:bookmark, URL:theURL} in theGroup
		open window for record theBookmark
		activate
	end tell
else
	my showError(status)
	error number -128
end if
