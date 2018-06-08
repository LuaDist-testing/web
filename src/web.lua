local http = require('resty.http')
local std = require('deviant')

local _M = { version = "0.2" }


local url = {}

url.parse = function(str)
    
    local url = {}
    url.scheme, url.host, url.path, url.query = string.match(str,'(https?)://([%w-.]+)(/?[^?]*)%??(.*)')
    if not url.scheme then
        url.scheme, url.socket, url.path, url.query = string.match(str, '(unix):(/[^%:]+):(/?[^?]*)%??(.*)')
        url.path = 'http:' .. url.path
    end
    if url.path == '' then url.path = '/' end
    return url

end

url.escape = function(str)

   if (str) then
     str = string.gsub (str, "\n", "\r\n")
     str = string.gsub (str, "([^%w %-%_%.%~%%])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
     str = string.gsub (str, " ", "+")
   end
   return str    

end

url.build = function (url)

    if url.scheme and url.host and url.path then
        return url.scheme .. '://' .. url.host .. url.path .. escapeUrl(url.query) 
    end

end

local function request(uri, httpOpts, connectionOpts)
 
    -- if there is no connectionOpts table provided, we will use
    -- these defaults - 1s timeout and port 80 (although port will be
    -- changed to 443 if the scheme of the uri is https)
    local connectionDefaults = { timeout = 1000, port = 80 }
    -- same for httpOpts -- if there is none, we will use the defaults below
    local httpDefaults = { method = "GET", body = "", headers = {}, ssl_verify = false }
    local address

    local parsedUrl = url.parse(uri)

    if parsedUrl.scheme == 'unix' then
        address = 'unix:' .. parsedUrl.socket
        -- 'localhost' is a reasonable default for the Host header
        -- when connecting to a unix socket. Anyways it can be overriden
        -- in the httpOpts table
        httpDefaults.headers['Host'] = 'localhost'
    else
        address = parsedUrl.host 
        httpDefaults.headers['Host'] = parsedUrl.host
        if parsedUrl.scheme == 'https' then connectionDefaults.port = 443 end
    end

    httpDefaults.path = parsedUrl.path
    httpDefaults.query = parsedUrl.query
    local connectionOpts = std.mergeTables(connectionDefaults, connectionOpts)
    local httpOpts = std.mergeTables(httpDefaults, httpOpts)
    
    local httpc = http.new()
    httpc:set_timeout(connectionOpts.timeout)

    local ok, err 
    if parsedUrl.scheme ~= 'unix' then 
        ok, err = httpc:connect(address, connectionOpts.port)
    else
        ok, err = httpc:connect(address)
    end
    if not ok then return nil, err end

    local res, err = httpc:request(httpOpts)
    local results = {}

    if res then 
        if res.has_body then 
            results.body = res:read_body() 
        end
        results.status = res.status
        results.headers = res.headers
        local ok, err = httpc:set_keepalive()
        return results
    end    
    return nil, err

end


local function newAPI()
    
    local api
    api  = {
        actions = { ['nop'] = { action = function () end, pattern = '' } },
        process = function(uri)
            for name, action in pairs(api.actions) do
                if string.match(uri, action.pattern) then
                    local args = { string.match(uri, action.pattern) }
                    api.actions[name].action(table.unpack(args))
                end
            end
        end   
    }
    return api

end

_M.url = url
_M.request = request
_M.newAPI = newAPI

return _M

