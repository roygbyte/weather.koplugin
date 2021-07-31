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
    default_auth_token = "2eec368fb9a149dd8a4224549212507"
}

function Weather:onDispatcherRegisterActions()
    Dispatcher:registerAction("helloworld_action", {category="none", event="HelloWorld", title=_("Hello World"), filemanager=true,})
end

function Weather:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Weather:loadSettings()
   if self.settings then
      return
   end
   self.settings = LuaSettings:open(self.settings_file)
   self.postal_code = self.settings:readSetting("postal_code") or self.default_postal_code
   self.auth_key = self.settings:readSetting("auth_key") or self.default_auth_token
end
--
--
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
--
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
		  return T(_("Auth Token"), self.auth_token)
	       end,
	       keep_menu_open = true,
	       callback = function(touchmenu_instance)
		  
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
	 text = _("Week forecast"),
	 keep_menu_open = true,
	 callback = function()
	    NetworkMgr:turnOnWifiAndWaitForConnection(function()
		  self:loadForecast()
	    end)
	 end,
      },
      
   }
   return sub_item_table
end
--
--
--
function Weather:loadForecast()
   local api = WeatherApi:new{
      auth_token = self.auth_token
   }
   local day = "today"
   forecast = api:getForecast(3)

   UIManager:show(
      ListView:new{
	 height = Screen:scaleBySize(400),
	 width = Screen:scaleBySize(200),
	 page_update_cb = function(curr_page_num, total_pages)
	    -- This callback function will be called whenever a page
	    -- turn event is triggered. You can use it to update
	    -- information on the parent widget.
	 end,
	 items = {
	    FrameContainer:new{
	       bordersize = 0,
	       background = Blitbuffer.COLOR_WHITE,
	       TextWidget:new{
		  text = "foo",
		  face = Font:getFace("cfont"),
	       }
	    },
	    FrameContainer:new{
	       bordersize = 0,
	       background = Blitbuffer.COLOR_LIGHT_GRAY,
	       TextWidget:new{
		  text = "bar",
		  face = Font:getFace("cfont"),
	       }
	    },
	    -- You can add as many widgets as you want here...
	 }
      }
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
      auth_token = self.auth_token
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
      self.settings:saveSetting("auth_token", self.auth_token)
      self.settings:flush()
   end
   logger.dbg("postal code",self.postal_code)
end

return Weather
