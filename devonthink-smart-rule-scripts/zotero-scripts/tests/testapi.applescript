use AppleScript version "2.4"
use framework "Foundation"

-- Function to check if an API endpoint responds.
on ping(service_url)
	-- Create the request object.
	set ca to current application
	set _url to ca's |NSURL|'s URLWithString:service_url
	set request to ca's |NSURLRequest|'s requestWithURL:_url
	
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
		-- Could not connect to the URL
		return false
	else
		log "Unexpected error code received by ping()."
		return false
	end if
end ping

-- Example usage
set apiURL to "http://localhost:23119/better-bibtex/json-rpc"
set responseStatus to ping(apiURL)

