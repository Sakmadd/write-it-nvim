-- Test code for write-it-nvim plugin
-- Select this code in visual mode and press <leader>wp to start practice

-- Simple function
function greet(name)
  return "Hello, " .. name
end

-- Function with loops
function count_to_ten()
  for i = 1, 10 do
    print(i)
  end
end

-- Table manipulation
local fruits = {
  "apple",
  "banana",
  "cherry"
}

-- Conditional logic
function is_even(n)
  if n % 2 == 0 then
    return true
  else
    return false
  end
end

-- More complex example
function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end
