local travis = {}

function travis.execute(self, task)
  print(task.cmd)
  local c = os.execute(
    'cd ' .. task.workdir .. ' && ' .. task.cmd)
  if c ~= 0 then os.exit(1) end
  return true
end

function travis.init(self)
  if os.getenv('TRAVIS') == 'true' then
    travis.env = {
      branch = os.getenv('TRAVIS_BRANCH'),
      build = {
        id = tonumber(os.getenv('TRAVIS_BUILD_ID')),
        number = tonumber(os.getenv('TRAVIS_BUILD_NUMBER')),
        stage = (os.getenv('TRAVIS_BUILD_STAGE_NAME') or ''):lower()
      },
      commit = {
        hash = os.getenv('TRAVIS_COMMIT'),
        msg = os.getenv('TRAVIS_COMMIT_MESSAGE'),
        range = os.getenv('TRAVIS_COMMIT_RANGE')
      },
      type = os.getenv('TRAVIS_EVENT_TYPE'),
      job = {
        id = tonumber(os.getenv('TRAVIS_JOB_ID')),
        number = tonumber(os.getenv('TRAVIS_JOB_NUMBER'))
      },
      os = os.getenv('TRAVIS_OS_NAME'),
      pr = {
        number = tonumber(os.getenv('TRAVIS_PULL_REQUEST')),
        branch = os.getenv('TRAVIS_PULL_REQUEST_BRANCH'),
        hash = os.getenv('TRAVIS_PULL_REQUEST_SHA'),
        slug = os.getenv('TRAVIS_PULL_REQUEST_SLUG')
      },
      slug = os.getenv('TRAVIS_REPO_SLUG'),
      secure = os.getenv('TRAVIS_SECURE_ENV_VARS') == 'true',
      sudo = os.getenv('TRAVIS_SUDO') == 'true',
      result = tonumber(os.getenv('TRAVIS_TEST_RESULT')) == 0,
      tag = (os.getenv('TRAVIS_TAG') == '' and nil or os.getenv('TRAVIS_TAG'))
    }
    return true
  end
end

return travis
