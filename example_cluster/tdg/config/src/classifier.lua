return {
    call = function(param)
        if param.obj.header ~= nil and
            param.obj.header.metadata ~= nil and
            param.obj.header.metadata.source == 'FXQE' then
            param.routing_key = 'quotation'
        end

        return param
    end
}
