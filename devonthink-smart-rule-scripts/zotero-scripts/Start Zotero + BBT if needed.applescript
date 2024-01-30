-- Summary: if Zotero & BBT are not running, launch & wait until they respond.
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
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- URL of the Zotero Connector endpoint for Better BibTeX.
property bbt_api_endpoint: "http://localhost:23119/better-bibtex/json-rpc"

-- Approximate duration to wait for Zotero + BBT to start, in seconds.
property wait_time: 20


-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Log a message in DEVONthink's log and include the name of this script.
on report(error_text)
	local script_path
	tell application "System Events"
		set script_path to POSIX path of (path to me as alias)
	end tell
	tell application id "DNtp"
		log message script_path info error_text
	end tell
	log error_text				-- Useful when running in a debugger.
end report

-- Return true if we connected to the BBT endpoint URL in < max_time seconds,
-- false if there was no response, and an integer HTTP status code if there was
-- a response but it was an HTTP code indicating a problem.
on connect_to_bbt(max_time)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on connect_to_bbt(max_time)
			-- Create the request object with a timeout.
			set url_str to ca's NSURL's URLWithString:bbt_api_endpoint
			set ignore_cache to ca's NSURLRequestReloadIgnoringCacheData
			set request to ca's NSURLRequest's alloc()'s initWithURL:url_str ¬
				cachePolicy:(ignore_cache) timeoutInterval:max_time
			
			-- Try to connect.
			set {body, response, err} to ca's NSURLConnection's ¬
				sendSynchronousRequest:request ¬
					returningResponse:(reference) |error|:(reference)
			
			-- Interpret the outcome. No err doesn't necessarily mean success.
			if (err is not missing value) or (response is missing value) then
				return false
			else if response's statusCode() >= 400 then
				-- This shouldn't happen. Something is wrong with the endpoint.
				return response's statusCode()
			else
				return true
			end if
		end connect_to_bbt
	end script
	return wrapperScript's connect_to_bbt(max_time)
end connect_to_bbt


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on performSmartRule(selected_records)
	tell application "Zotero"
		if it is not running then
			launch
			repeat until application "Zotero" is running
				delay 0.5
			end repeat
			-- Better BibTeX takes time to start up after Zotero is running.
			-- Wait until we can connect to the JSON-RPC endpoint. Note: it's
			-- okay to modify wait_time directly b/c every execution of this
			-- script from a Smart Rule will reload the file and thus reset it.
			set logged_error to false
			repeat while wait_time > 0
				set bbt_connection to my connect_to_bbt(1)
				if bbt_connection is true then
					return
				else if (bbt_connection is not false) and not logged_error then
					my report("Unable to connect to the Zotero Connector " ¬
							  & "endpoint for Better BibTeX (HTTP code " ¬
							  & bbt_connection & ") at " & bbt_api_endpoint)
					set logged_error to true
				end if
				set wait_time to (wait_time - 1)
				delay 1
			end repeat
			my report("Wait time exceeded for starting Zotero & Better BibTeX")
		end if
	end tell
end performSmartRule

-- Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
