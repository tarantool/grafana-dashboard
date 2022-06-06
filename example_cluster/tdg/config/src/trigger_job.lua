local repository = require('repository')

return {
    call = function(args)
        local name = args.name
        local _, err = repository.push_job('tasks.' .. name, {})
        if err ~= nil then
            return "not ok"
        end
        return "ok"
    end,
}
