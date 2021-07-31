local logger = require('logger') 
local _ = require('gettext')

local Composer = {

}

function Composer:singleDayView(data)
   local view_content = {}

   for _, r in ipairs(data.forecast.forecastday) do
      -- Collect the data      
      local date = r.date
      local condition = r.day.condition.text
      local avg_temp_c = r.day.avgtemp_c
      local high_c = r.day.maxtemp_c
      local min_c = r.day.mintemp_c
      local uv = r.day.uv
      local moon_phase = r.astro.moon_phase
      local moon_rise = r.astro.moonrise
      local moon_set = r.astro.moonset
      -- Set and order the data
      view_content =
		   {
		      {
			 "Date", date
		      },
		      {
			 "Condition", condition
		      },
		      {
			 "High of:", high_c  
		      },
		      {
			 "Low of:", low_c
		      },
		      {
			 "Average temp.", avg_temp_c
		      },
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
      
      
   end

   return view_content
end

function Composer:hourlyView(data)
   local view_content = {}

   local hours = data.forecast.forecastday[1].hour
   for i = 7, 20,1 do
      -- Collect the data
      local cell = hours[i].feelslike_c .. " | "
      cell = cell .. hours[i].condition.text
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

return Composer
