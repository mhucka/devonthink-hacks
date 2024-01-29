use AppleScript version "2.5"
use framework "Foundation"

on ping(api_url, max_time)
	-- Create the request object.
	set ca to current application
	set url_string to ca's NSURL's URLWithString:api_url
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
	else if {404, 410} contains response's statusCode() then
		return false
	else
		return true
	end if
end ping

if ping("https://httpstat.us/504?sleep=3000", 5) then
	log "yes (expected)"
else
	log "no (unexpected)"
end if

if ping("https://httpstat.us/504?sleep=3000", 2) then
	log "yes (unexpected)"
else
	log "no (expected)"
end if
