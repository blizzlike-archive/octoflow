# octoflow

this is a lua script to extend the very limited workflow design of [travis-ci](https://travis-ci.org).
Travis itself describes it's configuration file as a supa flexible way to design your project workflow.
The last two weeks I had to accept that it doesn't play well or at least you have to
write down your workflow in a script.

I don't know if it's fine for the rest of the world but it doesn't fit to my needs.
That's why I wrote `octoflow` a lua abstraction to access the github api, travis api as well as
a connector to a S3 object storage (to access build artifacts in downstream stages).

## install

    luarocks install octoflow

## usage

### create a .travis.yml

    language: generic
    sudo: required

    before_scripts:
      - echo "do something"

    stages:
      - build

    jobs:
      include:
        - stage: build
          env:
            - FOO=BLA
          script:
            - lua51 ./octoflow.lua

### design your workflow

    #!/usr/bin/env lua

    local travis = require('travis')
    local octoflow = {
      commands = {
        cmake = {
          cmd = 'cmake ..',
          workdir = '/tmp/build'
        }
      }
    }

    function octoflow.run(self)
      if not travis:init() then
        print('no travis run - nothing to do')
        os.exit(1)
      end

      if travis.env.build.stage == 'build' then octoflow:build() end
    end

    function octoflow.build(self)
      if not travis:execute(octoflow.commands.cmake) then os.exit(1) end
      if not travis:execute(octoflow.commands.make) then os.exit(1) end

      if travis.env.type ~= 'pull_request' and
          travis.env.branch == 'master' then
        print('this is a build triggered by a push to master')
      end
    end

    octoflow:run()
