local lfs = require('lfs')

local s3 = {}

function s3.clear(self, bucket)
  local c = os.execute(
    'aws --endpoint-url=' .. s3.endpoint ..
      ' s3 rm --recursive ' .. bucket)
  if c == 0 then return true end
end

function s3.init(self, id, key, endpoint)
  if id and key and endpoint then
    local aws = os.getenv('HOME') .. '/.aws'
    lfs.mkdir(aws)
    local fd = io.open(aws .. '/credentials', 'w')
    fd:write('[default]\n')
    fd:write('aws_access_key_id = ' .. id .. '\n')
    fd:write('aws_secret_access_key = ' .. key .. '\n')
    fd:close()
    s3.endpoint = endpoint
    return true
  end
end

function s3.sync(self, src, dest)
  local c = os.execute(
    'aws --endpoint-url=' .. s3.endpoint ..
      ' s3 sync ' .. src .. ' ' .. dest)
  if c == 0 then return true end
end

return s3
