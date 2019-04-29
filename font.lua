function load_font(font, height)
    pico8_print = pico8_print or print
    local m = 0x5f25
    local cache = {}
    local outline = 0
    local ocol = 0
    local ox, oy = 0, 0
    local center = false
    function font_outline(o, x, y, c)
        outline = o or 0
        ox, oy = x or 0, y or 0
        ocol = c or 0
    end
    function font_center(x)
        center = x or false
    end
    local function render(str, radius)
        local key = radius.."-"..str
        local value = cache[key]
        if value then
            -- pixels, xmax
            return value[1], value[2]
        end
        local x,y = 16,16
        local pixels = {}
        local xmax = 16
        for i=1,#str do
            local ch=sub(str,i,i)
            local data=font[ch]
            if ch=="\n" or #ch==0 then
                y += height
                x = 16
            elseif data then
                for dx=0,#data do
                    local v = data[1 + flr(dx)]
                    local x0,x1 = flr(x + dx - radius),flr(x + dx + radius)
                    for dy=0,height do
                        if band(v,2^flr(dy))!=0 then
                            local y0,y1 = flr(y + dy - radius),flr(y + dy + radius)
                            --pixels[flr(x + dx) + flr(y + dy) / 256] = true
                            for dy2=y0,y1 do
                                for dx2=x0,x1 do
                                    pixels[dx2 + dy2 / 256] = true
                                end
                            end
                        end
                    end
                end
                x += #data
                xmax = max(x, xmax)
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
            for k,_ in pairs(cache) do
                count -= 1
                if count == 0 then
                    cache[k]=nil
                end
            end
        end
        local new_pixels = {}
        for p,_ in pairs(pixels) do
            add(new_pixels, p)
        end
        cache[key] = { new_pixels, xmax }
        return new_pixels, xmax
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
        local startx,starty = x,y
        local pixels, xmax = render(str, 0)
        -- print outline
        local dx = startx - 16
        local dy = starty - 16
        if center then dx += flr((16 - xmax + 0.5) / 2) end
        if outline > 0 or ox != 0 or oy != 0 then
            local opixels = outline > 0 and render(str, outline) or pixels
            for p in all(opixels) do
                pset(dx + ox + flr(p), dy + oy + p%1*256, ocol)
            end
        end
        -- print actual text
        for p in all(pixels) do
            pset(dx + flr(p), dy + p%1*256, col)
        end
        -- save state
        poke(m, col)
        if missing_args then
            poke(m+1,startx - 16 + x) poke(m+2,starty - 16 + y)
        end
    end
end
