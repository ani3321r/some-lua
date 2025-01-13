local http = require("socket.http")
local json = require("dkjson")

local function load_env(filename)
    local file = io.open(filename, "r")
    if not file then error("Could not open .env file") end

    local env_vars = {}
    for line in file:lines() do
        local key, value = line:match("([^=]+)=([^=]+)")
        if key and value then
            env_vars[key] = value
        end
    end
    file:close()

    return env_vars
end

local env = load_env(".env")
local api_key = env["API_KEY"]

local function fetch_weather(city)
    local base_url = "http://api.openweathermap.org/data/2.5/weather"
    local url = string.format("%s?q=%s&appid=%s&units=metric", base_url, city, api_key)

    local response, status_code = http.request(url)

    if status_code == 200 then
        local weather_data = json.decode(response)
        return weather_data
    else
        error("Failed to fetch weather data. Status code: " .. tostring(status_code))
    end
end

local function display_weather(data)
    print(string.format("Weather in %s (%s):", data.name, data.sys.country))
    print(string.format("Temperature: %.1f°C", data.main.temp))
    print(string.format("Condition: %s", data.weather[1].description))
    print(string.format("Humidity: %d%%", data.main.humidity))
    if data.wind and data.wind.speed then
        print(string.format("Wind Speed: %.1f m/s", data.wind.speed))
    else
        print("Wind Speed: Data not available")
    end
end

io.write("Enter city name: ")
local city = io.read("*l")

local success, result = pcall(fetch_weather, city)
if success then
    print("\nWeather data fetched successfully!\n")
    display_weather(result)
else
    print("\nError: " .. result)
end