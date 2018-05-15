local client = require('github.client')
local mimetypes = require('mimetypes')

local github = {}

function github.create_release(self, tag, commitish, name, desc, draft, pre)
  local data = {
    tag_name = tag,
    target_commitish = commitish,
    name = name,
    body = desc,
    draft = draft,
    prerelease = pre
  }
  local code, draft = client:post(
    '/repos/' .. github.slug .. '/releases',
    github.api_key, data)
  if code == 201 then return draft end
  return nil, 'cannot create draft' 
end

function github.create_tag(self, sha, name)
  local code, tag = client:post(
    '/repos/' .. github.slug .. '/git/refs',
    github.api_key,
    { ref = 'refs/tags/' .. name, sha = sha })
  if code == 201 then return tag end
  return nil, 'cannot create tag'
end

function github.delete_release(self, id)
  local code = client:delete(
    '/repos/' .. github.slug .. '/releases/' .. id,
    github.api_key)
  if code == 204 then return true end
  return nil, 'cannot delete release'
end

function github.delete_tag(self, name)
  local code = client:delete(
    '/repos/' .. github.slug .. '/git/refs/tags/' .. name,
    github.api_key)
  if code == 204 then return true end
  return nil, 'cannot delete tag'
end

function github.get_release(self, obj)
  if (obj or {}).tag then
    local code, release = client:get(
      '/repos/' .. github.slug .. '/releases/tags/' .. tag,
      github.api_key, nil)
  else
    local code, releases = self:get_releases()
    if code == 200 then
      for _, v in pairs(releases or {}) do
        if v.name == obj.name then return code, v end
      end
    end
  end
  return nil, nil, 'cannot get release object'
end

function github.get_releases(self, page)
  local url = '/repos/' .. github.slug .. '/releases'
  if page then url =  url .. '?page=' .. page end
  local code, releases, links = client:get(url, github.api_key, nil)
  if next(links or {}) and links.next then
    local page = links.next:match('page=(%d+)')
    local _, _releases = self:get_releases(page)
    for _, v in pairs(_releases or {}) do table.insert(releases, v) end
  end
  if code == 200 then return code, releases end
  return nil, nil, 'cannot get release page'
end

function github.get_tag(self, name)
  local code, tag = client:get(
    '/repos/' .. github.slug .. '/git/refs/tags/' .. name,
    github.api_key, nil)
  if code == 200 then return tag end
  return nil, 'cannot get tag object'
end

function github.init(self, slug, api_key)
  if slug and api_key then
    github.slug = slug
    github.api_key = api_key
    return true
  end
end

function github.publish_files(self, id, path)
  for file in lfs.dir(path) do
    if file ~= '.' and file ~= '..' and
        lfs.attributes(path .. '/' .. file, 'mode') == 'file' then
      local mimetype = mimetypes.guess(file)
      if not mimetype then
        if file:match('\.tar\.xz$') then
          mimetype = 'application/x-compressed-tar'
        end
      end
      local fd = io.open(path .. '/' .. file, 'r')
      local code, asset = client:upload(
        '/repos/' .. github.slug .. '/releases/' .. id .. '/assets?name=' .. file,
        github.api_key, fd:read('*a'), { ['Content-Type'] = mimetype })
      fd:close()
      if code ~= 201 then return nil end
    end
  end
  return true
end

return github
