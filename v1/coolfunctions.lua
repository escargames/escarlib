-- cool timer

function ctimer(t)
    if t.min == 0 and (t.sec % 1 >= 29/30) then
        if t.sec < 1 then
            sfx(12)
        elseif t.sec < 11 then
            sfx(11)
        end
    end

    if t.sec > 0 then
        t.sec -= 1/30
    end

    if (t.sec <= 0) then 
        t.min -= 1
        t.sec += 60
    end

    if t.min < 0  then
        t.sec = 0
        t.min = 0
        state = "pause"
        begin_pause()
    end
end

-- cool tostring (adding "0")

function ctostr(n, l)
    local a = tostr(n)
    while #a < l do
        a = "0"..a
    end
    return a
end

