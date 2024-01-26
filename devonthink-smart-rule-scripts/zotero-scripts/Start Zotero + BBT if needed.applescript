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

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- URL of the Better BibTeX plugin for Zotero.
property bbt_api_url: "http://localhost:23119/better-bibtex/json-rpc"

-- Approximate duration to wait for Zotero + BBT to start, in seconds.
property wait_time: 15

-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- The following code is based in part on a 2019-04-03 posting by Shane Stanley
-- to MacScripters.net at https://www.macscripter.net/t/nsurl-oddity/71558/3

on ping(api_url, max_time)
	-- Create the request object.
	set ca to current application
	set url_string to ca's |NSURL|'s URLWithString:api_url
	set ignore_cache to ca's NSURLRequestReloadIgnoringCacheData
	set request to ca's NSURLRequest's alloc()'s initWithURL:url_string ¬
		cachePolicy:(ignore_cache) timeoutInterval:max_time
	
	-- Try to connect.
	set {conn, resp, err} to ca's NSURLConnection's ¬
		sendSynchronousRequest:request ¬
			returningResponse:(reference) |error|:(reference)
	
	-- No error object => connected.
	return (err is missing value)
end ping

-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tell application "Zotero"
	if it is not running then
		launch
		repeat until application "Zotero" is running
			delay 0.5
		end repeat
		-- Better BibTeX takes time to start up after Zotero is running.
		-- Wait until we get a response.
		repeat while wait_time > 0
			if my ping(bbt_api_url, 1) is true then
				return
			end if
			set wait_time to (wait_time - 1)
			delay 1
		end repeat
	end if
end tell
