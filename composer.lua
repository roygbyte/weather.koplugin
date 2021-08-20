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
   local date = data.date
   local condition = data.day.condition.text
   local avg_temp_c = data.day.avgtemp_c .. " °C"
   local max_c = data.day.maxtemp_c .. " °C"
   local min_c = data.day.mintemp_c .. " °C"
   local uv = data.day.uv
   local moon_phase = data.astro.moon_phase
   local moon_rise = data.astro.moonrise
   local moon_set = data.astro.moonset
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
	    "High of:", max_c
	 },
	 {
	    "Low of:", min_c
	 },
	 {
	    "Average temp.", avg_temp_c .. " °C"
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
	 "---"
      }      
   
   return view_content
   
end
---
---
---
function Composer:hourlyView(data)
   local view_content = {}

   local hours = data.forecast.forecastday[1].hour
   for i = 7, 20,1 do
      -- Collect the data
      local cell = hours[i+1].feelslike_c .. " °C | "
      cell = cell .. hours[i+1].condition.text
      -- Set the data
      table.insert(
	 view_content,
	 {
	    _(i .. ":00"), cell 
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
--
--
function Composer:flattenArray(base_array, source_array)
   for key, value in pairs(source_array) do
      if value[2] == nil then
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
   return base_array
end



return Composer
