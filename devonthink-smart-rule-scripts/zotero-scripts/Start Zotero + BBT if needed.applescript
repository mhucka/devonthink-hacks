-- Summary: launch Zotero & BBT if necessary and wait until they respond.
--
-- This is an AppleScript fragment that will only work as the script
-- executed by a Smart Rule in DEVONthink.
--
-- This assumes that the Better BibTeX plugin has been installed in Zotero
-- (see https://retorque.re/zotero-better-bibtex/) but it should be safe
-- to use even if the plugin is not installed. (If it's not installed, this
-- program will end up waiting the full duration of the wait_time value.)
--
-- Copyright 2024 Michael Hucka.
-- License: MIT License – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use framework "Foundation"
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- URL of the Better BibTeX plugin for Zotero.
property bbt_api_endpoint: "http://localhost:23119/better-bibtex/json-rpc"

-- Approximate duration to wait for Zotero + BBT to start, in seconds.
property wait_time: 20


-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Internal state variable used to prevent writing repeated log messages.
property logged_error: false

-- Return true if can connect to the given endpoint URL in < max_time seconds.
on available(endpoint, max_time)
	-- Create the request object with a timeout.
	set ca to current application
	set url_string to ca's NSURL's URLWithString:endpoint
	set ignore_cache to ca's NSURLRequestReloadIgnoringCacheData
	set request to ca's NSURLRequest's alloc()'s initWithURL:url_string ¬
		cachePolicy:(ignore_cache) timeoutInterval:max_time
	
	-- Try to connect.
	set {body, response, err} to ca's NSURLConnection's ¬
		sendSynchronousRequest:request ¬
			returningResponse:(reference) |error|:(reference)
	
	-- Interpret the outcome. No error does not necessarily mean success.
	if (err is not missing value) or (response is missing value) then
		return false
	else if response's statusCode() >= 400 then
		if not logged_error then
			set code to response's statusCode()
			log "Unable to connect to Better BibTeX RPC (HTTP code " & code & ")"
			set logged_error to true
		end if
		return false
	else
		return true
	end if
end available


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selectedRecords)
	tell application "Zotero"
		if it is not running then
			launch
			repeat until application "Zotero" is running
				delay 0.5
			end repeat
			-- Better BibTeX takes time to start up after Zotero is running.
			-- Wait until we get a response.
			repeat while wait_time > 0
				if my available(bbt_api_endpoint, 1) is true then
					return
				end if
				set wait_time to (wait_time - 1)
				delay 1
			end repeat
		end if
	end tell
end performSmartRule
