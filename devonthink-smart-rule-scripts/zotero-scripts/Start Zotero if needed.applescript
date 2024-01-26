-- Summary: check that Zotero is running and start it if it is not.
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.4"
use framework "Foundation"

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- URL of the Better BibTeX plugin for Zotero.
property bbt_api_url: "http://localhost:23119/better-bibtex/json-rpc"

-- Duration to wait for Zotero + BBT to start, in seconds. This is only
-- approximate, because we use blocking network calls to test the BBT endpoint
-- and those network calls can take an indeterminate amount of time.
property wait_time: 15


-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Function to check if an API endpoint responds.
on ping(api_url)
	-- Create the request object.
	set ca to current application
	set url_string to ca's |NSURL|'s URLWithString:api_url
	set request to ca's |NSURLRequest|'s requestWithURL:url_string
	
	-- Try to connect to the endpoint.
	set responseData to missing value
	set status to missing value
	
	set _response to ca's NSHTTPURLResponse's alloc()'s init()
	set {_data, _error} to ca's NSURLConnection's sendSynchronousRequest:request ¬
		returningResponse:_response |error|:(reference)
	
	if _error is missing value then
		-- No error => connected.
		return true
	else if class of _error is ca's NSURLError then
		return false
	else
		-- I'm unsure this can ever happen, but let's play it safe.
		log "Unexpected error received by ping()."
		return false
	end if
end ping


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selectedRecords)
	tell application "Zotero"
		if it is not running then
			launch
			repeat until application "Zotero" is running
				delay 0.5
			end repeat
			-- BetterBibTeX takes time to start up after Zotero is
			-- running. Wait until we get a response.
			repeat while wait_time > 0
				delay 1
				if my ping(bbt_api_url) is true then
					return
				end if
				set wait_time to (wait_time - 1)
			end repeat
		end if
	end tell
end performSmartRule
