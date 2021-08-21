local logger = require('logger') 
local _ = require('gettext')

local Composer = {

}

--
-- Takes data.current
--
-- @returns array
--
function Composer:currentForecast(data)
   local view_content = {}

   view_content = {
      {
	 "Feels like: ", data.feelslike_c
      },
      {
	 "Condition: ", data.condition.text
      },
      "---"
   }

   return view_content
end
--
-- Takes data.forecast.forecastday
-- 
function Composer:singleForecast(data)
   local view_content = {}
   -- TODO: Fetch temp scale from settings
   local temp_scale = "C"
   local clock_style = "12"
   -- The values I'm interested in seeing
   local date = data.date
   local condition = data.day.condition.text
   local avg_temp
   local max_temp
   local min_temp  
   local uv = data.day.uv
   local moon_phase = data.astro.moon_phase .. ", " .. data.astro.moon_illumination .. "%"
   local moon_rise = data.astro.moonrise
   local moon_set = data.astro.moonset
   local sunrise = data.astro.sunrise
   local sunset = data.astro.sunset

   if(string.find(temp_scale, "C")) then
      avg_temp = data.day.avgtemp_c .. " °C"
      max_temp = data.day.maxtemp_c .. " °C"
      min_temp = data.day.mintemp_c .. " °C"
   else
      avg_temp = data.day.avgtemp_f .. " °F"
      max_temp = data.day.maxtemp_f .. " °F"
      min_temp = data.day.mintemp_f .. " °F"      
   end

   -- Set and order the data
   view_content =
      {
	 {
	    "Date", date
	 },
	 {
	    "Condition", condition
	 },
	 "---",
	 {
	    "High of:", max_temp
	 },
	 {
	    "Low of:", min_temp
	 },
	 {
	    "Average temp.", avg_temp
	 },
	 "---",
	 {
	    "Moonrise", moon_rise
	 },
	 {
	    "Moonset", moon_set
	 },
	 {
	    "Moon phase", moon_phase
	 },
	 "---",
	 {
	    "Sunrise", sunrise
	 },
	 {
	    "Sunset", sunset
	 },
	 "---"
      }      
   
   return view_content
   
end
---
---
---
function Composer:hourlyView(data)
   local view_content = {}
   local hourly_forecast = data.forecast.forecastday[1].hour
   
   -- TODO: fetch these from settings
   local clock_style = "12"
   local temp_scale = "C"

   -- I'm starting the view at 7AM, because it feels like time before this
   -- should actually be seen in the previous day
   for i = 7, 20,1 do      
      local cell
      local time

      if(string.find(temp_scale, "C")) then
	 cell = hourly_forecast[i+1].feelslike_c .. " °C, "
      else
	 cell = hourly_forecast[i+1].feelslike_f .. " °F, "
      end

      if(string.find(clock_style, "12")) then
	 local meridiem
	 local hour = i	 
	 if(hour <= 12) then
	    meridiem = "AM"
	 else
	    meridiem = "PM"
	    hour = hour - 12
	 end
	 time = hour .. ":00 " .. meridiem
      else
	 time = i .. ":00"
      end         

      table.insert(
	 view_content,
	 {
	    _(time),
	    cell .. hourly_forecast[i+1].condition.text
	 }
      )
   end
   
   return view_content
end
--
--
--
function Composer:weeklyView(data)
   local view_content = {}

   for _, r in ipairs(data.forecast.forecastday) do
      local date = r.date
      local condition = r.day.condition.text
      local avg_temp_c = r.day.avgtemp_c
      local max_c = r.day.maxtemp_c
      local min_c = r.day.mintemp_c
      
      local content = {
	 {
	    date, condition
	 },
	 {
	    "", avg_temp_c
	 },
	 {
	    "", "High: " .. max_c .. ", Low: " .. min_c
	 },
	 "---"
      }

      view_content = Composer:flattenArray(view_content, content)
      
   end
   
   return view_content
end
--
-- KeyValuePage doesn't like to get a table with sub tables.
-- This function flattens an array, moving all nested tables
-- up the food chain, so to speak
--
function Composer:flattenArray(base_array, source_array)
   logger.dbg("Flatten",source_array)
   for key, value in pairs(source_array) do
      if value[2] == nil then
	 -- If the value is empty, then it's probably supposed to be a line
	 table.insert(
	    base_array,
	    "---"
	 )
      else
	 table.insert(
	    base_array,
	    {
	       value[1], value[2]
	    }
	 )
      end
   end
   logger.dbg("Flattened", base_array)
   return base_array
end



return Composer
