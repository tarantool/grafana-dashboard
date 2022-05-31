local classifier = require('classifier')

local function call(req)
    req = classifier.call(req)
    return req
end

return {
    call = call,
}
