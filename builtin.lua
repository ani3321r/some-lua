-- there are a lot of lua builtin functions like math, os, coroutine, etc

-- math

math.randomseed(2) -- used to get predictable randoms
print(math.random()) -- same seed gets us the same random number

math.randomseed(os.time()) -- to get completly random numbers
print(math.random())

-- we have the max and min as usual


-- string

local name = "God Raiden"
print(string.sub(name, 2)) -- a single digit signifies where the substring would start from
print(string.sub(name, 5, -1)) -- similarly this signifies the start and end of substr

print(string.find(name, "Raiden")) -- give the indexes of the occuring string

local start_ch, end_ch = string.find(name, "Raiden") -- can initialize more than one var
local res = "start char " .. start_ch .. " end char " .. end_ch
print(res)


-- io

io.write("Enter ur name: ")
local name = io.read()

io.write("Give ur age: ")
local age = tonumber(io.read())

print("Hello " .. name .. " u were born in " .. tonumber(2024-age))


-- os

os.execute("export NAME=Raiden")

local clock = os.clock
local function sleep(n)
   local t0 = clock()
   while clock() - t0 <= n do
   end
end

sleep(2)

local name = os.getenv("NAME")
print("hello, " .. tostring(name))