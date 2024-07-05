local clock = require('clock')
local fiber = require('fiber')
local log = require('log')

local vshard = require('vshard')

local TIMEOUT = 60
local DELAY = 0.1

local start = clock.monotonic()
while clock.monotonic() - start < TIMEOUT do
    local ok, err = vshard.router.bootstrap({
        if_not_bootstrapped = true,
    })

    if ok then
        break
    end

    log.info(('Router bootstrap error: %s'):format(err))
    fiber.sleep(DELAY)
end
