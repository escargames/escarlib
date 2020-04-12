-- random between a and b

function crnd(a, b)
  return min(a, b) + rnd(abs(b - a))
end

-- random on the elements of a tab

function ccrnd(tab)
  n = flr(crnd(1, #tab+1))
  return tab[n]
end