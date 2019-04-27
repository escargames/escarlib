function load_font(data, height)
    pico8_print = pico8_print or print
    local m = 0x5f25
    local cache = {}
    local font = {}
    local acc = {}
    local outline = 0
    local ocol = 0
    local ox, oy = 0, 0
    local scale = 1
    local center = false
    for i=1,#data do
        if type(data[i])=='string' then
            font[data[i]] = acc
            acc = {}
        else
            add(acc, data[i])
        end
    end
    function font_outline(o, x, y, c)
        outline = o or 0
        ox, oy = x or 0, y or 0
        ocol = c or 0
    end
    function font_scale(s)
        scale = s or 1
    end
    function font_center(x)
        center = x or false
    end
    local function render(str, scale, radius)
        local key = scale.."-"..radius.."-"..str
        local value = cache[key]
        if value then
            -- pixels, xmax
            return value[1], value[2]
        end
        local delta = min(1, 1/scale)
        local x,y = 16,16
        local pixels = {}
        local xmax = 16
        for i=1,#str+1 do
            local ch=sub(str,i,i)
            local data=font[ch]
            if ch=="\n" or #ch==0 then
                y += height * scale
                x = 16
            elseif data then
                for dx=0,#data,delta do
                    for dy=0,height,delta do
                        if band(data[1 + flr(dx)],2^flr(dy))!=0 then
                            --pixels[flr(x + dx * scale) + flr(y + dy * scale) / 256] = true
                            for dx2=flr(x + dx * scale - radius),flr(x + dx * scale + radius) do
                                for dy2=flr(y + dy * scale - radius),flr(y + dy * scale + radius) do
                                    pixels[dx2 + dy2 / 256] = true
                                end
                            end
                        end
                    end
                end
                x += (#data + 1) * scale
                xmax = max(x - scale, xmax)
            end
        end
        -- count elements in the cache
        local count = 0
        for _,_ in pairs(cache) do
            count += 1
        end
        -- if cache is full, remove one argument at random
        if count > 32 then
            count = flr(rnd(count))
            for _,v in pairs(cache) do
                count -= 1
                if count == 0 then
                    del(cache, v)
                end
            end
        end
        cache[key] = { pixels, xmax }
        return pixels, xmax
    end
    function print(str, x, y, col)
        local missing_args = not x or not y
        if missing_args then
            x,y = peek(m+1),peek(m+2)
        else
            poke(m+1,x) poke(m+2,y)
        end
        col = col or peek(m)
        str = tostr(str)
        local key = tostr(scale)..""..str
        local startx,starty = x,y
        local pixels, xmax = render(str, scale, 0)
        -- print outline
        local dx = startx - 16
        local dy = starty - 16
        if center then dx += flr((16 - xmax + 0.5) / 2) end
        if outline > 0 or ox != 0 or oy != 0 then
            local opixels = outline > 0 and render(str, scale, outline) or pixels
            for p,_ in pairs(opixels) do
                pset(dx + ox + flr(p), dy + oy + p%1*256, ocol)
            end
        end
        -- print actual text
        for p,_ in pairs(pixels) do
            pset(dx + flr(p), dy + p%1*256, col)
        end
        -- save state
        poke(m, col)
        if missing_args then
            poke(m+1,startx - 16 + x) poke(m+2,starty - 16 + y)
        end
    end
end
