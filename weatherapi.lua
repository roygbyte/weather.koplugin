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

function WeatherApi:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

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

function WeatherApi:getForecast()
    local url = string.format(        "http://api.weatherapi.com/v1/forecast.json?key=%s&q=%s&days=%s&aqi=no&alerts=no",
                                      self.auth_token,
                                      self.postal_code,
                                      3
    )

    local days = {}
    local forecast = self:_makeRequest(url)

    if forecast == nil then return false end

    for _, day in ipairs(forecast.forecast.forecastday) do
        local date = day.date
        local condition = day.day.condition.text
        local avg_temp = day.day.avgtemp_c
        local t = {
            {"Date", date},
            {"Average Temp.", avg_temp},
        }
        table.insert(days,
                     {
                         "Date",date
        })
        table.insert(days, {"Condition", condition})
        table.insert(days, {"Average Temp.", avg_temp})
        table.insert(days, "-----")
    end

    logger.dbg("value" , days)

    return days



end

return WeatherApi
