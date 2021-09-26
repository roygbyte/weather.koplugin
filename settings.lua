local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")

function Settings:createAuthDialog(
      value,
      default_value,
      callback
				  )
   local postal_code = self.postal_code
   local input

   input = InputDialog:new{
      title = _("Auth token"),
      input = value,
      input_type = "string",
      description = _("WeatherAPI auth token"),
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
	       callback = callback(input)
	    },
	 }
      },
   }

   return input
   
end
