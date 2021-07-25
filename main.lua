--[[--
A simple plugin for getting the weather forcast on your KOReader

@module koplugin.Weather
--]]--

local Dispatcher = require("dispatcher")  -- luacheck:ignore
local DataStorage = require("datastorage")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local NetworkMgr = require("ui/network/manager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local Weather = WidgetContainer:new{
    name = "weather",
    settings_file = DataStorage:getSettingsDir() .. "/weather.lua",
    is_doc_only = false,
}

function Weather:onDispatcherRegisterActions()
    Dispatcher:registerAction("helloworld_action", {category="none", event="HelloWorld", title=_("Hello World"), filemanager=true,})
end

function Weather:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Weather:addToMainMenu(menu_items)
    menu_items.hello_world = {
        text = _("Weather"),
        -- in which menu this should be appended
        sub_item_table = {
            {
                text = _("Get forecast"),
                keep_menu_open = true,
                callback = function()
                    NetworkMgr:runWhenOnline(function()
                            self:loadForecast()
                    end)
                end,
            }
        }
    }
end

function Weather:loadForecast()
    local UI = require("ui/trapper")
    UI:info("Loading forecast...")

    UI:info("Forecast fonud!")
    NetworkMgr:afterWifiAction()
end

function Weather:onHelloWorld()
    local popup = InfoMessage:new{
        text = _("Hello World"),
    }
    UIManager:show(popup)
end

return Weather
