local http = require('resty.http')
local std = require('deviant')

local _M = { version = "0.1" }


local url = {}

url.parse = function(str)
    
    local url = {}
    url.scheme, url.host, url.path, url.query = string.match(str,'(https?)://([%w-.]+)(/?[^?]*)%??(.*)')
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

local function request(url, opts)

    local defaults = { method = "GET", body = "", headers = {}, ssl_verify = false }
    local opts = std.mergeTables(defaults, opts)
    
    local httpc = http.new()
    local res, err = httpc:request_uri(url, opts) 
    return res, err

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

