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
		
		local orig_up = Battle.update
		local orig_init = Battle.init
		local function safeHurt(battler, amount)
			if not battler.is_down then
				if opt("callhurt") then
					battler:hurt(amount)
				else
					battler:removeHealth(amount)
				end
				if battler.is_down then
					battler.chara.health = 0
				end
			end
		end
		function Battle:update(...)
			orig_up(self, ...)
			pcall(function()
				if self.state == "DEFENDING" or self.state == "DEFENDINGBEGIN" then
					if opt("active_turn") == "Player" then return end
				else
					if opt("active_turn") == "Enemy" then return end
				end
				if self.state == "ENEMYDIALOGUE"
				or self.state == "ATTACKING"
				or self.state == "CUTSCENE"
				or self.state == "VICTORY"
				or self.state == "ACTIONS"
				or self.state == "ACTIONSDONE"
				or self.state == "BATTLETEXT"
				then return end
				if isActive() and self.bleedtimer > 0 and self.party then
					self.bleedtimer = self.bleedtimer - ({[true] = 0.1, [false] = 0.5})[opt("rapidtimer")] -- cool ternary expression bro
					for index, --[[@type PartyBattler]] battler in ipairs(self.party) do
						self.timer:after(opt("stagger") and (math.random() * 12/30) or 0, function ()
							if not opt("overkill") then
								safeHurt(battler, opt("tick_damage"))
							elseif opt("callhurt") then
								battler:hurt(opt("tick_damage"))
							else
								battler:removeHealth(opt("tick_damage"))
							end
						end)
					end
				end
				self.bleedtimer = self.bleedtimer + DT
				if opt("hurts_to_move") and self.state == "DEFENDING" then
					if Input.down("left") or Input.down("right") then 
						self.bleedtimer = self.bleedtimer + DT
					end
					if Input.down("up") or Input.down("down") then 
						self.bleedtimer = self.bleedtimer + DT
					end
				end
				self.bleedtimer = math.max(-5, self.bleedtimer)
			end)
		end
		function Battle:init(...)
			self.bleedtimer = -0.4
			orig_init(self, ...)
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