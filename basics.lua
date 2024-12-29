-- global variables might start with capital letters
local name = nil -- support for null variables using nil
True = "Raiden" -- as lua is case sensitive, "True" can be used as a variable

print(name)
print(True)
print(#True) -- prints the length of the string
-- datatypes are as usual number, strings, nil, boolean

-- string concatination happens in a special way
Name = "God " .. True
print(Name)

-- special syntax for multiline strings
local age = 10000
local name2 = [[
Raiden
is
God
]] .. "he is " .. age .. " years old"
print(name2)

-- Table datatypes similar to arrays, in lua we follow 1 based indexing
local gods = {"raiden", "liu", nil, "cetrion", 23} -- we can mix and match datatypes
print(gods) -- this give the memory address of the table
print(gods[1]) -- in order to access the elements inside the table
print(#gods) -- we can get the length of the table like this

--[[
if we keep nil at the end, nil is not considered as an element and thus not included while getting the length,
but if we keep nil anywhere in between it is counted as an element
]]

-- tables can also act as dictionaries / hashmaps
local phones = { iphone15 = "a16 bionic", sam24= "8 gen 3"}
print(phones.sam24)