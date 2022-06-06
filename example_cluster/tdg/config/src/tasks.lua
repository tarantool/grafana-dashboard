return {
    succeed = function()
        return "ok"
    end,

    fail = function()
        error('This function is supposed to be failed')
        return "not ok"
    end,

    long = function()
        sleep(5)
        return "ok"
    end,
}
