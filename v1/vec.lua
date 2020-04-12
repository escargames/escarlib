do
  -- vec2 metatable
  local t2 = {
    __eq=function(v,w) return v.x==w.x and v.y==w.y end,
    __add=function(v,w) return vec2(v.x+w.x,v.y+w.y) end,
    __sub=function(v,w) return vec2(v.x-w.x,v.y-w.y) end,
    __unm=function(v) return vec2(-v.x,-v.y) end,
    __div=function(v,n) return vec2(v.x/n,v.y/n) end,
    __mul=function(a,b)
      if type(a)=='number' then
        return vec2(a*b.x,a*b.y)
      elseif type(b)=='number' then
        return vec2(a.x*b,a.y*b)
      end
      return a.x*b.x+a.y*b.y
    end,
    __index={
      str = function(v) return "["..v.x..","..v.y.."]" end,
    },
  }
  -- constructor
  function vec2(x,y)
    local v = { x=x or 0, y=y or 0, tostring=t2.__tostring }
    setmetatable(v,t2)
    return v
  end
  -- utility functions
  function length(v) return sqrt(v*v) end
  function normalize(v) return v/length(v) end
  function distance(a,b) return length(a-b) end
  function dot(a,b) return a*b end
end
