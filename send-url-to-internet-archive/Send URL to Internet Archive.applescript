-- ======================================================================
-- @file    Send URL to Internet Archive.applescript
-- @brief   Send the URL of the selected items to the Internet Archive
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This is meant to be executed by a smart rule in DEVONthink.
-- This script assumes a metadata field named "archiveurl" exists on the
-- records of your database.
-- ======================================================================

-- Set to the name of the smart rule, so notifications can mention it.
property smartRuleName : "send URL to IA"

on performSmartRule(selectedRecords)
	repeat with _record in selectedRecords
		set theURL to get URL of _record
		if theURL ≠ "" then
			if "discourse" is in theURL or "forum" is in theURL then
				if theURL ends with "/print" then
					-- Strip off /print part before sending these URLs.
					set theURL to (characters 1 thru -7 of theURL) as string
				end if
			end if
			try
				set result to do shell script ¬
					"curl -sSI 'https://web.archive.org/save/" & theURL & "'"
				set result_lines to every paragraph of result
				set status_line to item 1 of result_lines as string
				set status to ((characters -4 thru -1 of status_line) as string) as number
				if status < 400 then
					set location_line to item 6 of result_lines
					set archiveURL to (characters 11 thru -1 of location_line) as string
					add custom meta data archiveURL for "archiveurl" to _record
					my notify("Sent URL to the IA", theURL)
				else if status = 404 then
					-- There's something wrong with the URL.
					add custom meta data "NOT FOUND" for "archiveurl" to _record
				else if status = 451 then
					-- Unavailable for legal reasons.
					add custom meta data "UNAVAILABLE" for "archiveurl" to _record
				else if status = 429 or status = 410 or status > 500 then
					-- Can't save a copy right now, possibly due to rate
					-- limits or the site is offline or an error. Did
					-- IA ever archive it? If so, use the last copy.
					set available_result to do shell script ¬
						"curl -sSI 'https://web.archive.org/wayback/available?url=" & theURL & "'"
					set result_lines to every paragraph of available_result
					set location_line to item 8 of result_lines as string
					if location_line contains "memento-location" then
						set archiveURL to (characters 19 thru -1 of location_line) as string
						add custom meta data archiveURL for "archiveurl" to _record
						my notify("Found existing copy in IA", theURL)
					-- Some of the following repeat tests done above,
					-- because we may have gotten here due to the 429
					-- when attempting to save the URL, and also, these
					-- cases test the results of a different API call.
					else if status = 404 then
						-- There's something wrong with the URL.
						add custom meta data "NOT FOUND" for "archiveurl" to _record
					else if status = 410 or status = 451 then
						-- Gone or unavailable for legal reasons.
						add custom meta data "UNAVAILABLE" for "archiveurl" to _record
					else if status ≥ 525 then
						add custom meta data "NO ARCHIVED COPY" for "archiveurl" to _record
					end if
					-- All others cases: try another time. Assume other
					-- rules in DEVONthink will deal with that.
				end if
			on error msg number code
				if the code is not -128 then
					my notify(msg, "leaving item in queue")
				end if
			end try
		end if
	end repeat
end performSmartRule

on notify(headline, body)
	display notification body with title headline ¬
		subtitle "(Smart rule '" & smartRuleName & "')"
end notify


-- Reminder about HTTP codes that IA may return:
--
-- #   Description
-- --- -----------
-- 404	HTTP Not Found
-- 408	HTTP Request Timeout
-- 410	HTTP Gone
-- 429	Rate limit reached; try later
-- 451	Unavailable for Legal Reasons
-- 500	Internal Server Error
-- 502	Bad Gateway
-- 503	Gateway Timeout
-- 509	Bandwidth Limit Exceeded
-- 520	Server Returned an Unknown Error
-- 521	Web Server is Down
-- 523	Origin is Unreachable
-- 524	A Timeout Occurred
-- 525	SSL Handshake Failed
-- 526	Invalid SSL Certificate
