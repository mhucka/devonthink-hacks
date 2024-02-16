-- Summary: sleep for 10 seconds.
--
-- When Smart Rule actions invoke other Smart Rules, sometimes it doesn't
-- work if the subsequent rules are invoked immediately. This script can
-- be used to insert a 5 second delay in the sequence of actions in a
-- Smart Rule.
--
-- Copyright 2024 Michael Hucka.
-- License: MIT license – see file "LICENSE" in the project website.
-- Website: https://github.com/mhucka/devonthink-hacks

use AppleScript version "2.5"
use scripting additions

on performSmartRule(selected_records)
	tell application "System Events"
		delay 10
	end tell
end performSmartRule

-- Scaffolding for execution outside of a Smart Rule (e.g., in a debugger).
tell application id "DNtp"
	my performSmartRule(selection as list)
end tell
