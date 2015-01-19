def series(series_name, index)
  case series_name
    when 'fibonacci' then fibonacci(index)
    when 'lucas' then lucas(index)
    else fibonacci(index) + lucas(index)
  end
end

def fibonacci(index)
  (index == 1 or index == 2) ? 1 : fibonacci(index - 1) + fibonacci(index - 2)
end

def lucas(index)
  case index
    when 1 then 2
    when 2 then 1
    else lucas(index - 1) + lucas(index - 2)
  end
end