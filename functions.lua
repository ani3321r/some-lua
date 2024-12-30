local function do_something(name, age)
  print("Hello " .. name)
  age() -- whatever func is passed it just executes
end

function Age()
  print("Age is 10000")
end

Age2 = function () -- another valid way of defining the function
  print("Age is 12000")
  return function()
    print("You are a god right?")
   end
end

do_something("Raiden", Age) -- maintaining the order is a must while calling normally
--[[                    |
                        V
        we are just passing reference of the func
]]

do_something("Liu", Age2()) -- we are calling the func here as we initialized a func in the func

function Unknown_args(...) -- we use "..." to give unknown number of arguments
  local args = {...}
  for name = 1, 4 do
    print("Hello " .. args[name])
  end
  print("In one day we will step into " .. args[5])
end

Unknown_args("Raiden", " Liu", "Cetrion", "Katana", 2025) -- we can pass different arguments