local _print_stack = {}

function _G._display_print()
    local now = love.timer.getTime()
    local lifetime = 5.0

    for i,v in ipairs(_print_stack) do
        if now - v.t > lifetime then
            table.remove(_print_stack,i)
        else
            local x = 0
            local y = (i-1)*16

            local width  = love.graphics.getFont():getWidth(v.str)
            local height = love.graphics.getFont():getHeight(v.str)
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("fill",x-1,y-1,width+2,height+3)
            
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(v.str, x, y)
        end
    end

    love.graphics.setColor(1,1,1,1)
end

function _G.print(...)
    local res = ""
    local pargs = {...}
    for _,v in ipairs(pargs) do
        res = res .. tostring(v) .. "\t"
    end
    
    table.insert(_print_stack, { str=res, t=love.timer.getTime() })
    if #_print_stack*16 > love.graphics.getHeight() then
        table.remove(_print_stack,1)
    end
end

return nil