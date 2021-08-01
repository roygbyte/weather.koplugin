--[[--
A simple plugin for getting the weather forcast on your KOReader

@module koplugin.Weather
--]]--

local Dispatcher = require("dispatcher")  -- luacheck:ignore
local DataStorage = require("datastorage")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local NetworkMgr = require("ui/network/manager")
local InfoMessage = require("ui/widget/infomessage")
local InputDialog = require("ui/widget/inputdialog")
local LuaSettings = require("luasettings")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local KeyValuePage = require("ui/widget/keyvaluepage")
local ListView = require("ui/widget/listview")
local WeatherApi = require("weatherapi")
local logger = require("logger")
local _ = require("gettext")

local Screen = require("device").screen
local FrameContainer = require("ui/widget/container/framecontainer")
local Blitbuffer = require("ffi/blitbuffer")
local TextWidget = require("ui/widget/textwidget")
local Font = require("ui/font")

local Composer = require("composer")
local ffiutil = require("ffi/util")
local T = ffiutil.template


local Weather = WidgetContainer:new{
    name = "weather",
    settings_file = DataStorage:getSettingsDir() .. "/weather.lua",
    settings = nil,
    default_postal_code = "T0L0B6",
    default_api_key = "2eec368fb9a149dd8a4224549212507"
}

function Weather:onDispatcherRegisterActions()
   -- 
end

function Weather:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Weather:loadSettings()
   if self.settings then
      return
   end
   -- Load the default settings
   self.settings = LuaSettings:open(self.settings_file)
   self.postal_code = self.settings:readSetting("postal_code") or self.default_postal_code
   self.api_key = self.settings:readSetting("api_key") or self.default_api_key
end
--
-- Add Weather to the device's menu
--
function Weather:addToMainMenu(menu_items)
    menu_items.weather = {
        text = _("Weather"),
	sub_item_table_func= function()
	   return self:getSubMenuItems()
	end,
    }
end
--
-- Create and return the list of submenu items
--
-- return @array
--
function Weather:getSubMenuItems()
   self:loadSettings()
   self.whenDoneFunc = nil
   local sub_item_table
   sub_item_table = {
      {
	 text = _("Settings"),
	 sub_item_table = {
	    {
	       text_func = function()
		  return T(_("Postal Code (%1)"), self.postal_code)
	       end,
	       keep_menu_open = true,
	       callback = function(touchmenu_instance)
  		  local postal_code = self.postal_code
		  local input
		  input = InputDialog:new{
		     title = _("Postal Code"),
		     input = postal_code,
		     input_hint = _("Format: " .. self.default_postal_code),
		     input_type = "string",
		     description = _(""),
		     buttons = {
			{
			   {
			      text = _("Cancel"),
			      callback = function()
				 UIManager:close(input)
			      end,
			   },
			   {
			      text = _("Save"),
			      is_enter_default = true,
			      callback = function()
				 self.postal_code = input:getInputValue()
				 UIManager:close(input)
				 touchmenu_instance:updateItems()
			      end,
			   },
			}
		     },
		  }
		  UIManager:show(input)
		  input:onShowKeyboard()

	       end,
	    },
	    {
	       text_func = function()
		  return T(_("Auth Token (%1)"), self.api_key)
	       end,
	       keep_menu_open = true,
	       callback = function(touchmenu_instance)
  		  local api_key = self.api_key
		  local input
		  input = InputDialog:new{
		     title = _("Auth token"),
		     input = api_key,
		     input_type = "string",
		     description = _("Get an auth token from WeatherAPI.com"),
		     buttons = {
			{
			   {
			      text = _("Cancel"),
			      callback = function()
				 UIManager:close(input)
			      end,
			   },
			   {
			      text = _("Save"),
			      is_enter_default = true,
			      callback = function()
				 self.api_key = input:getInputValue()
				 UIManager:close(input)
				 touchmenu_instance:updateItems()
			      end,
			   },
			}
		     },
		  }
		  UIManager:show(input)
		  input:onShowKeyboard()		 
	       end,
	    }
	 },
      },
      {
	 text = _("Today's forecast"),
	 keep_menu_open = true,
	 callback = function()
	    NetworkMgr:turnOnWifiAndWaitForConnection(function()
		  self:todaysForecast()
	    end)
	 end,
      },
      {
	 text = _("Weekly forecast (TODO)"),
	 keep_menu_open = true,
	 callback = function()
	    NetworkMgr:turnOnWifiAndWaitForConnection(function()
		  self:weeklyForecast()
	    end)
	 end,
      },
      
   }
   return sub_item_table
end
--
-- This doesn't do anything yet.
--
function Weather:weeklyForecast()
   self.kv = {}

   local api = WeatherApi:new{
      api_key = self.api_key
   }
   -- Fetch the forecast
   local result = api:getForecast(3, self.postal_code)
   if result == false then return false end
   -- Create the view content
   local view_content = Composer:weeklyView(result)

   self.kv = KeyValuePage:new{
      title = _("Weekly forecast"),
      return_button = true,
      kv_pairs = view_content
   }

   UIManager:show(
      self.kv
   )

end
--
--
-- TODO: make this function a single day forecast,
-- and have some way to indicate what day we want the weather
-- possibly, we could pass an offset, so currentday + offset
-- and then grab the corresponding result returned by our api result
function Weather:todaysForecast()
   self.kv = {}
   -- Init the weather API
   local api = WeatherApi:new{
      api_key = self.api_key
   }  
   -- Fetch the forecast
   local result = api:getForecast(1, self.postal_code)
   if result == false then return false end
   -- Create the view content 
   local view_content = Composer:singleDayView(result)
   -- Add an hourly forecast button to forecast
   table.insert(
      view_content,
      {
	 _("Hourly Forecast"), "",
	 callback = function()
	    local kv = self.kv
	    UIManager:close(self.kv)
	    self.kv = KeyValuePage:new{
	       title = _("Hourly forecast"),
	       value_overflow_align = "right",
	       kv_pairs = Composer:hourlyView(result),
	       callback_return = function()
		  UIManager:show(kv)
		  self.kv = kv
	       end
	    }
	    UIManager:show(self.kv)
	 end
      }
   )
   -- Create the KV page 
   self.kv = KeyValuePage:new{
      title = _("Today's Forecast"),
      return_button = true,
      kv_pairs = view_content
   }
   -- Show it
   UIManager:show(
      self.kv
   )
end

function Weather:onFlushSettings()
   if self.settings then
      self.settings:saveSetting("postal_code", self.postal_code)
      self.settings:saveSetting("api_key", self.api_key)
      self.settings:flush()
   end
end

return Weather
