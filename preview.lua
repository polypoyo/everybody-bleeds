local preview = {}

preview.hide_background = false

function preview:init(mod, button)
	-- TODO: find a better way to hide from mod list while still running this script
	MainMenu.mod_list.list:removeChild(button)
	local function isActive()
		return Kristal.Config["plugins/enabled_plugins"][mod.id]
	end
	if MainMenu and not Kristal.Ebb then
		Kristal.Ebb = {
			--[[
			options = {
				textures = Kristal.Config["ebb/textures"] or true
			}]]
		}
		
		local function check(setting, default)
			Kristal.Config["ebb/"..setting] = Kristal.Config["ebb/"..setting] == nil and default or Kristal.Config["ebb/"..setting]
		end
		local function opt(setting)
			return Kristal.Config["ebb/"..setting]
		end
		check("callhurt", false)
		check("stagger", false)
		check("rapidtimer", true)
		check("graze_behavior", "Heal")
		check("overkill", true)
		check("active_turn", "Enemy")
		check("hurts_to_move", true)
		check("tick_damage", 1)
		
		local orig = Kristal.loadMod
		function Kristal.loadMod(id, ...)
			if id == mod.id then
				MainMenu:setState("ebb")
			else
				orig(id, ...)
			end
		end
	end
	local ebb = Kristal.Ebb
	
	if MainMenu and MainMenu.mod_list ~= Kristal.Ebb.mod_list then
		local options = require(mod.path.."/options")
		MainMenu.state_manager:addState("ebb", options(MainMenu))
		
		Kristal.Ebb.mod_list = MainMenu.mod_list
	end
	
    button:setColor(1, 1, 1)
    button:setFavoritedColor(.8, .6, 1)
	
	if not MainMenu then
		button.subtitle = "(kristal version outdated! cannot run)"
	elseif math.random() < 1/50 then
		button.subtitle = "sadness"
	elseif math.random() < 1/50 then
		button.subtitle = "suffering"
	else
		button.subtitle = "pain"
	end
end

function preview:update()
end

function preview:draw()
end

return preview