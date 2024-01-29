-- Summary: set the "Reference" field of a record using Zotero and BBT.
--
-- This AppleScript program is meant to be invoked by a Smart Rule in
-- DEVONthink. It assumes that the Smart Rule searches the indexed folder of a
-- Zotero storage folder containing the attachments of a Zotero database. It
-- also assumes that those DEVONthink records have been already processed using
-- a combination of Zowie and other Smart Rules, such that each record has a
-- value for a custom metadata field named "Citekey". Finally, it also assumes
-- that the Better BibTeX plugin (https://retorque.re/zotero-better-bibtex/)
-- has been installed and it's running.
--
-- ╭───────────────────────────── WARNING ─────────────────────────────╮
-- │ This assumes custom metadata fields that I set in my copy of      │
-- │ DEVONthink. It will almost certainly not work in anyone else's    │
-- │ copy of DEVONthink.                                               │
-- ╰───────────────────────────────────────────────────────────────────╯
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

-- Config variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- URL of the Better BibTeX server endpoint running in Zotero on the local host
property bbt_rpc_endpoint: "http://localhost:23119/better-bibtex/json-rpc"

-- Max duration to wait for a response from BBT.
property wait_time: 15

-- Identifier of the custom field holding the cite key in DEVONthink records.
property key_field: "citekey"

-- Identifier of the custom field holding the formatted reference.
property reference_field: "reference"


-- Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Remove leading and trailing whitespace from the text and return the result.
on trimmed(raw_text)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on trimmed(raw_text)
			set str to ca's NSString's stringWithString:raw_text
			set whitespace to ca's NSCharacterSet's whitespaceCharacterSet()
			return (str's stringByTrimmingCharactersInSet:whitespace) as text
		end trimmed
	end script
	return wrapperScript's trimmed(raw_text)
end trimmed

-- Do HTTP post to an endpoint & return the result as an (AppleScript) record.
-- Parameters headers and json_record must be AppleScript records too.
on http_post(endpoint, headers, json_record)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on http_post(endpoint, headers, json_record)
			local url_string, ignore_cache, request_alloc, request
			-- Construct the HTTP request object.
			set url_string to ca's NSURL's URLWithString:endpoint
			set ignore_cache to ca's NSURLRequestReloadIgnoringCacheData
			set request_alloc to ca's NSMutableURLRequest's alloc()
			set request to request_alloc's initWithURL:url_string ¬
				cachePolicy:(ignore_cache) timeoutInterval:wait_time
		
			-- Set the HTTP headers.
			local hdict, value
			set hdict to ca's NSDictionary's dictionaryWithDictionary:headers
			repeat with header in hdict's allKeys()
				set value to (hdict's valueForKey:header) as text	
				request's setValue:value forHTTPHeaderField:header
			end repeat
		
			-- Serialize the JSON data record & set it as the body of the post.
			local jdict, payload, err
			set jdict to ca's NSDictionary's dictionaryWithDictionary:json_record
			set {payload, err} to ca's NSJSONSerialization's ¬
				dataWithJSONObject:jdict options:0 |error|:(reference)
			if not err is missing value then
				log "Problem attempting to encode payload for " & endpoint & ¬
					": " & err's localizedDescription() as text
				return missing value
			end if
			request's setHTTPBody:payload
			request's setHTTPMethod:"POST"
		
			-- Tell the request object to do its thing.
			local returned_data, response, err
			set {returned_data, response, err} to ca's NSURLConnection's ¬
				sendSynchronousRequest:request ¬
					returningResponse:(reference) |error|:(reference)
			if not err is missing value then
				log "Error attempting to connect to " & endpoint & ": " & ¬
					(err's localizedDescription() as text)
				return missing value
			else if response's statusCode() >= 400 then
				set code to response's statusCode()
				log "Connection failure (HTTP code " & code & ") for " & endpoint
				return missing value
			else if returned_data is missing value then
				log "Empty response from " & endpoint
				return missing value
			end if
		
			-- Pull data out of the response object, return it as an AS record.
			local utf8, data_str, converted, result_data, json_dict
			set utf8 to ca's NSUTF8StringEncoding
			set data_str to ca's NSString's alloc()'s ¬
				initWithData:(contents of returned_data) encoding:utf8
			set converted to ca's NSString's stringWithString:data_str
			set result_data to converted's dataUsingEncoding:utf8
			set {json_dict, err} to ca's NSJSONSerialization's ¬
				JSONObjectWithData:result_data options:0 |error|:(reference)
			if json_dict is missing value then
				log "Could not parse returned result as JSON from " & endpoint
				return missing value
			else
				return item 1 of (parent's NSArray's arrayWithObject:json_dict)
			end if
		end http_post
	end script
	return wrapperScript's http_post(endpoint, headers, json_record)
end http_post

-- Look up a cite key in the local BBT server running in Zotero.
-- Returns a string, or missing value in case the lookup fails.
on formatted_reference(citekey)
	script wrapperScript
		property ca: a reference to current application
		use framework "Foundation"
		on formatted_reference(citekey)
			local headers, payload, bbt_result
			-- The headers and payload format are documented in the BBT docs at
			-- https://retorque.re/zotero-better-bibtex/exporting/json-rpc/index.html
			set headers to {|content-type|: "application/json", ¬
							accept: "application/json"}
			set payload to {method: "item.bibliography", ¬
							params: {{citekey}, ¬
									 {quickCopy: true, contentType: "text"}}, ¬
							jsonrpc: "2.0"}
		
			-- Call the JSON-RPC endpoint and get the JSON record back.
			set bbt_result to http_post(bbt_rpc_endpoint, headers, payload)
		
			-- The formatted content will be in the record field "result".
			if bbt_result is not missing value then
				return trimmed(bbt_result's valueForKey:"result") as string
			else
				return missing value
			end if
		end formatted_reference
	end script
	return wrapperScript's formatted_reference(citekey)
end formatted_reference


-- Main body ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Explanation for what's happening below.
--
-- I define a DEVONthink indexed folder over my Zotero attachments folder. This
-- creates database entries for every file (mostly PDF files) that I store in
-- Zotero. In my DEVONthink configuration, I define several custom metadata
-- fields. One of those custom metadata fields is "Citekey", which I use to
-- store the BibTeX citekey value of the corresponding Zotero bib entry. The
-- citekey of each Zotero bibliography item is maintained by the Zotero plugin
-- Better BibTeX; the value in the DEVONthink record is simply a copy of what's
-- found in Zotero. The citekey value of the DEVONthink records is set by a
-- Smart Rule elsewhere in my setup.
--
-- Another custom metadata field I use in DEVONthink is "Reference", to store a
-- formatted reference string generated from the Zotero bib entry. This is just
-- a text string like "Name, A. (2020). Paper title. Journal, 5(20):41-42."
-- The purpose of storing a formatted reference string in DEVONthink records is
-- to make it easier to get *some* kind of formatted reference string easily,
-- without having to jump to Zotero to get it. Other Smart Rules in my
-- DEVONthink setup make use of this field value.
--
-- The purpose of the code here is to set the value of this "Reference" field.
--
-- Better BibTeX uses the Zotero Connector facility, in which Zotero operates
-- a server listening on local port 23119. Plugins like BBT can register an
-- endpoint with this server to provide clients with the ability to control
-- them via a JSON-RPC protocol. The methods offered by BBT are described
-- at https://retorque.re/zotero-better-bibtex/exporting/json-rpc/index.html
-- One of the available methods is "item.bibliography", which takes a citekey
-- string and returns a formatted reference string. The format of the reference
-- string is determined by Zotero preferences (not BBT or the client program),
-- specifically, the user's setting for the Zotero "Quick Copy" command in
-- the Export section of the Zotero preferences. (In my case, I use the
-- American Psychological Associations.'s APA 7 reference format for
-- references, both because I'm used to it from long ago and because I find it
-- provides the most complete information; however, the code here does not
-- care about the actual quick copy format the user has selected.)
--
-- The code below assumes it is being invoked by a DEVONthink Smart Rule that
-- searches the (DEVONthink) indexed folder of Zotero attachments. As mentioned
-- above, in my setup, each DEVONthink record in that folder has a "Citekey"
-- field value. The procedure for filling in the formatted reference field
-- value is actually quite straightforward:
--
--   1. read the record's "Citekey" field value
--   2. use it in a call on the BBT JSON-RPC endpoint "item.bibliography"
--   3. save the returned value in the custom metadata field for "Reference"
--
-- Note: storing the citekey and formatted reference in DEVONthink is
-- admittedly a little bit dangerous because if the corresponding item in
-- Zotero is updated, nothing in my current DEVONthink setup will detect the
-- discrepancy. I should find a solution to that some day.

on performSmartRule(selectedRecords)
	tell application id "DNtp"
		try
			-- Using the selectedRecords argument in the next line results in
			-- runtime object class errors. The following alternative works.
			repeat with _record in selectedRecords
				local recname, citekey, val
				set recname to name of _record
				set citekey to get custom meta data for key_field from _record
				if citekey ≠ "" then
					set val to my formatted_reference(citekey)
					if val is not missing value then
						add custom meta data val for reference_field to _record
					else
						log "Could not get reference value for " & recname
					end if
				else
					log "No Citekey value found in record for " & recname
				end if
			end repeat
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink" message msg as warning
			end if
		end try
	end tell
end performSmartRule

-- Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
