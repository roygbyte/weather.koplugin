local UI = require("ui/trapper")
local http = require("socket.http")
local socket = require("socket")
local socketutil = require("socketutil")
local ltn12 = require("ltn12")
local logger = require("logger")
local json = require("json")

local WeatherApi = {
    auth_token = "2eec368fb9a149dd8a4224549212507",
    postal_code = "E3B3R8"
}
--
-- Create a new instance of the WeatherApi
--
-- @returns WeatherApi
--
function WeatherApi:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end
--
-- Takes a URL to an API endpoint and
-- returns a decoded json object of the result
--
-- @returns JSON
--
function WeatherApi:_makeRequest(url)
    local sink = {}
    socketutil:set_timeout()
    local request = {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(sink),
    }
    -- Make request
    local headers = socket.skip(2, http.request(request))
    socketutil:reset_timeout()
    -- Check to see if headers exist
    if headers == nil then
        return nil
    end
    -- Not sure what this does
    local result_response = table.concat(sink)
    -- Output result to debugger
    logger.dbg("result: ", result_response)
    -- Check for result
    if result_response ~= "" then
        local _, result = pcall(json.decode, result_response)
        return result
    else
        return nil
    end
end
--
-- 
--
-- @returns table of forecast
--
function WeatherApi:getForecast()
   -- Construct the endpoint URL
   -- TODO: Put the postal code var in this method
   -- if it's not given, default to origx
   local forecast_days = 5
   local url = string.format(
      "http://api.weatherapi.com/v1/forecast.json?key=%s&q=%s&days=%s&aqi=no&alerts=no",
      self.auth_token,
      self.postal_code,
      forecast_days
   )
   -- Make the request
   local result = self:_makeRequest(url)
   -- Check to see if the result is empty
   if result == nil then return false end
   -- Prepare an object to store data we will return to the view
   local forecast_days = {}
   -- Loop through the forecast days
   for _, r in ipairs(result.forecast.forecastday) do
      -- Collect the data      
      local date = r.date
      local condition = r.day.condition.text
      local avg_temp = r.day.avgtemp_c
      -- Add the data to the table we're returning
      table.insert(
	 forecast_days,
	 {
	    "Date", date
	 }
      )
      -- Condition
      table.insert(
	 forecast_days,
	 {
	    "Condition", condition
	 }
      )
      -- Average daily temperature
      table.insert(
	 forecast_days,
	 {
	    "Average temp.", avg_temp
	 }
      )
      -- Add a line to divide the forecast
      table.insert(
	 forecast_days,
	 "---"
      )
   end

   return forecast_days

end

return WeatherApi
