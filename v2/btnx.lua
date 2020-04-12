-- btnx(): same as btnp() but ignores autorepeat
-- overrides _update_buttons()
-- will become obsolete with 0.1.12d (autorepeat is configurable)
do
    local _ub = _update_buttons
    local oldstate, state = 0, btn()
    function _update_buttons(n)
        _ub(n)
        oldstate, state = state, btn()
    end
    function btnx(i, p)
        local bitfield = band(btnp(), bnot(oldstate))
        return not i and bitfield or band(bitfield, 2^(i + 8 * (p or 0))) != 0
    end
end
