-- ======================================================================
-- @file    Send URL to Internet Archive.applescript
-- @brief   Send the URL of the selected items to the Internet Archive
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This assumes a metadata field named "archiveurl" exists on the
-- records of your database.
-- ======================================================================

on performSmartRule(selectedRecords)
	repeat with _record in selectedRecords
		set theURL to get URL of _record
		if theURL ≠ "" then
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
				else if status = 404 then
					-- There's something wrong with the URL.
					display notification ("URL not found: " & theURL) with title "DEVONthink"
					add custom meta data "NOT FOUND" for "archiveurl" to _record
				else if status = 451 then
					-- Unavailable for legal reasons.
					add custom meta data "UNAVAILABLE" for "archiveurl" to _record
				else if status = 429 or status = 410 or status > 500 then
					-- Can't save a copy right now, possibly due to rate
					-- limits or the site is offline or something. Did
					-- IA ever archive it? If so, use the last copy.
					set past_result to do shell script ¬
						"curl -sSI 'https://web.archive.org/wayback/available?url=" & theURL & "'"
					set result_lines to every paragraph of past_result
					set status_line to item 1 of result_lines as string
					set status to ((characters -4 thru -1 of status_line) as string) as number
					if status = 200 then
						set location_line to item 8 of result_lines as string
						set archiveURL to (characters 19 thru -1 of location_line) as string
						add custom meta data archiveURL for "archiveurl" to _record
					else
						-- It's not available. In this case, return a
						-- result so that we stop trying.
						display notification ("Not available in IA: " & theURL) with title "DEVONthink"
						add custom meta data "NO ARCHIVED COPY" for "archiveurl" to _record
					end if
				end if
			on error msg number code
				if the code is not -128 then
					display alert "DEVONthink smart rule" message msg as warning
				end if
			end try
		end if
	end repeat
end performSmartRule

-- I found a list of status codes returned by the Wayback Machine at
-- https://github.com/brave/brave-browser/wiki/Wayback-Machine-Infobar#observed-status-codes
-- but I don't know how current or accurate it is.
