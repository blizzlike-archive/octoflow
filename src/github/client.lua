local cjson = require('cjson')
local https = require('ssl.https')
local ltn12 = require('ltn12')

local github = {
  api = 'https://api.github.com'
}

local _toJson = function(t)
  local json = cjson.new()
  return json.encode(t)
end

local _toTable = function(s)
  local json = cjson.new()
  return json.decode(s)
end

function github.call(self, url, method, apiKey, request,  header)
  local reqBody = nil
  local headers = header or {}
  headers['Authorization'] = 'token ' .. apiKey

  if request then
    if not header or header['Content-Type'] == 'application/json' then
      reqBody = _toJson(request)
      headers['Content-Type'] = 'application/json'
    else
      reqBody = request
      headers['Content-Type'] = header['Content-Type']
    end
      headers['Content-Length'] = #reqBody
    reqBody = ltn12.source.string(reqBody)
  end
  local respBody = {}
  local resp, respStatus, respHeader = https.request{
    method = method,
    headers = headers,
    source = reqBody,
    sink = ltn12.sink.table(respBody),
    url = github.api .. url
  }
  links = {}
  if respHeader['link'] then
    local raw1, raw2 = respHeader['Link']:match('([^,]+),([^,]+')
    for i = 1, 2 do
      local link, rel = raw1:match('<(.*)>; rel="(.*)"')
      links[rel] = link
    end
  end
  if respHeader['content-type']:match('application/json') then
    return respStatus, _toTable(respBody[1]), links
  else
    return respStatus
  end
end

function github.delete(self, url, apiKey)
  return github:call(url, 'DELETE', apiKey, nil, nil)
end

function github.get(self, url, apiKey, request)
  return github:call(url, 'GET', apiKey, request, nil)
end

function github.post(self, url, apiKey, request, ct)
  return github:call(url, 'POST', apiKey, request, ct)
end

function github.put(self, url, apiKey, request)
  return github:call(url, 'PUT', apiKey, request, nil)
end

return github
