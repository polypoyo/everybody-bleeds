local preview = {}

preview.hide_background = false

function preview:init(mod, button, menu)
	if MainMenu and not Kristal.Shatter then
		Kristal.Shatter = {
			active = false
			--[[
			options = {
				textures = Kristal.Config["shatter/textures"] or true
			}]]
		}
		
		local function check(setting, default)
			Kristal.Config["shatter/"..setting] = Kristal.Config["shatter/"..setting] == nil and default or Kristal.Config["shatter/"..setting]
		end
		check("textures", true)
		check("music", true)
		check("sounds", true)
		check("fonts", true)
		check("tilesets", true)
		check("built_in", true)
		
		local orig = Kristal.loadMod
		function Kristal.loadMod(id, ...)
			if id == mod.id then
				MainMenu:setState("SHATTER")
			else
				orig(id, ...)
			end
		end
		
		local orig = Assets.loadData
		function Assets.loadData(data)
			local self = Assets	 --lolers
				
			math.randomseed(30,30)
			print(math.random())
			local function simple_shuffle(data, callback)
				local old = {}
				local keys = {}
				for k,v in pairs(data) do
					old[k] = v
					table.insert(keys, k)
				end
				for k,v in pairs(old) do
					local key = Utils.pick(keys, nil, true)
					if key == k then
						key = Utils.pick(keys, nil, true) or k
						table.insert(keys, k)
					end
					data[key] = v
					if callback then
						callback(key, k)
					end
				end
			end
			
			--	NO DEFAULTS
			if Kristal.Shatter.active and Mod and not Kristal.Config["shatter/built_in"] then
				if Kristal.Config["shatter/textures"] or Kristal.Config["shatter/tilesets"] then
					--special case, tileset seperation
					local old = {}
					local keys = {}
					local keys_tiles = {}
					for k,v in pairs(data.texture_data) do
						old[k] = v
						if k:sub(1,9) == "tilesets/" then
							table.insert(keys_tiles, k)
						else
							table.insert(keys, k)
						end
					end
					for k,v in pairs(old) do
						if k:sub(1,9) == "tilesets/" then
							local key = Kristal.Config["shatter/tilesets"] and Utils.pick(keys_tiles, nil, true) or k
							if key == k and Kristal.Config["shatter/tilesets"] then
								key = Utils.pick(keys_tiles, nil, true) or k
								table.insert(keys_tiles, k)
							end
							data.texture_data[key] = v
						else
							local key = Kristal.Config["shatter/textures"] and Utils.pick(keys, nil, true) or k
							if key == k and Kristal.Config["shatter/textures"] then
								key = Utils.pick(keys, nil, true) or k
								table.insert(keys, k)
							end
							data.texture_data[key] = v
						end
					end
				end
				
				if Kristal.Config["shatter/music"] then
					simple_shuffle(data.music)
				end
				if Kristal.Config["shatter/sounds"] then
					simple_shuffle(data.sound_data)
				end
				if Kristal.Config["shatter/fonts"] then
					local old_settings = {}
					for k,v in pairs(data.font_settings) do
						old_settings[k] = v
					end
					data.font_settings = {}
					local old_to_new = {}
					simple_shuffle(data.font_data, function(new, old) old_to_new[old] = new; data.font_settings[new] = old_settings[old] end)
					simple_shuffle(data.font_bmfont_data, function(new, old) old_to_new[old] = new; data.font_settings[new] = old_settings[old] end)
					simple_shuffle(data.font_image_data, function(new, old) old_to_new[old] = new; data.font_settings[new] = old_settings[old] end)
					
					for _,settings in pairs(data.font_settings) do
						for _,fallback in ipairs(settings["fallbacks"] or {}) do
							if fallback["font"] then
								fallback["font"] = old_to_new[fallback["font"]]
							end
						end
					end
				end
			end
		
			Utils.merge(self.data, data, true)

			self.parseData(data)
			
			--YES DEFAULTS
			if Kristal.Shatter.active and Mod and Kristal.Config["shatter/built_in"] then
				
				if Kristal.Config["shatter/textures"] or Kristal.Config["shatter/tilesets"] then
					local old_data = {}
					for k,v in pairs(self.data.texture_data) do
						old_data[k] = v
					end
					local old = {}
					local keys = {}
					local keys_tiles = {}
					for k,v in pairs(self.data.texture) do
						old[k] = v
						if k:sub(1,9) == "tilesets/" then
							table.insert(keys_tiles, k)
						else
							table.insert(keys, k)
						end
					end
					for k,v in pairs(old) do
						if k:sub(1,9) == "tilesets/" then
							local key = Kristal.Config["shatter/tilesets"] and Utils.pick(keys_tiles, nil, true) or k
							if key == k and Kristal.Config["shatter/tilesets"] then
								key = Utils.pick(keys_tiles, nil, true) or k
								table.insert(keys_tiles, k)
							end
							self.data.texture[key] = v
							self.texture_ids[self.data.texture[key]] = key
							self.data.texture_data[key] = old_data[k]
						else
							local key = Kristal.Config["shatter/textures"] and Utils.pick(keys, nil, true) or k
							if key == k and Kristal.Config["shatter/textures"] then
								key = Utils.pick(keys, nil, true) or k
								table.insert(keys, k)
							end
							self.data.texture[key] = v
							self.texture_ids[self.data.texture[key]] = key
							self.data.texture_data[key] = old_data[k]
						end
					end
					--fuck it, just redo em???
					for key,ids in pairs(self.data.frame_ids) do
						self.data.frames[key] = {}
						for i,id in pairs(ids) do
							self.data.frames[key][i] = self.data.texture[id]
							self.frames_for[id] = {key, i}
						end
					end
				end
				
				if Kristal.Config["shatter/music"] then
					simple_shuffle(self.data.music)
				end
				if Kristal.Config["shatter/sounds"] then
					simple_shuffle(self.sounds)
				end
				if Kristal.Config["shatter/fonts"] then
					local old_settings = {}
					for k,v in pairs(self.data.font_settings) do
						old_settings[k] = v
					end
					self.data.font_settings = {}
					local old_to_new = {}
					simple_shuffle(self.data.font_data, function(new, old) old_to_new[old] = new; self.data.font_settings[new] = old_settings[old] end)
					simple_shuffle(self.data.font_bmfont_data, function(new, old) old_to_new[old] = new; self.data.font_settings[new] = old_settings[old] end)
					simple_shuffle(self.data.font_image_data, function(new, old) old_to_new[old] = new; self.data.font_settings[new] = old_settings[old] end)
					
					for _,settings in pairs(self.data.font_settings) do
						for _,fallback in ipairs(settings["fallbacks"] or {}) do
							if fallback["font"] then
								fallback["font"] = old_to_new[fallback["font"]]
							end
						end
					end

					--more parseData remaking 
					
					local data = self.data	--lol ezpz
					
					for key,file_data in pairs(data.font_data) do
						local default = data.font_settings[key] and data.font_settings[key]["defaultSize"] or 12
						self.data.fonts[key] = {default = default}
					end
					-- create bmfont fonts
					for key,file_path in pairs(data.font_bmfont_data) do
						data.font_settings[key] = data.font_settings[key] or {}
						if data.font_settings[key]["autoScale"] == nil then
							data.font_settings[key]["autoScale"] = true
						end
						self.data.fonts[key] = love.graphics.newFont(file_path)
					end
					-- set up bmfont font fallbacks
					for key,_ in pairs(data.font_bmfont_data) do
						if data.font_settings[key]["fallbacks"] then
							local fallbacks = {}
							for _,fallback in ipairs(data.font_settings[key]["fallbacks"]) do
								local font = self.data.fonts[fallback["font"]]
								if type(font) == "table" or (data.font_settings[fallback["font"]] and data.font_settings[fallback["font"]]["glyphs"]) then
									error("Attempt to use TTF or image fallback on BMFont font: " .. key)
								else
									table.insert(fallbacks, font)
								end
							end
							self.data.fonts[key]:setFallbacks(unpack(fallbacks))
						end
					end
					-- create image fonts
					for key,image_data in pairs(data.font_image_data) do
						local glyphs = data.font_settings[key] and data.font_settings[key]["glyphs"] or ""
						data.font_settings[key] = data.font_settings[key] or {}
						if data.font_settings[key]["autoScale"] == nil then
							data.font_settings[key]["autoScale"] = true
						end
						self.data.fonts[key] = love.graphics.newImageFont(image_data, glyphs)
					end
					-- set up image font fallbacks
					for key,_ in pairs(data.font_image_data) do
						if data.font_settings[key]["fallbacks"] then
							local fallbacks = {}
							for _,fallback in ipairs(data.font_settings[key]["fallbacks"]) do
								local font = self.data.fonts[fallback["font"]]
								if type(font) == "table" or not (data.font_settings[fallback["font"]] and data.font_settings[fallback["font"]]["glyphs"]) then
									error("Attempt to use TTF or BMFont fallback on image font: " .. key)
								else
									table.insert(fallbacks, font)
								end
							end
							self.data.fonts[key]:setFallbacks(unpack(fallbacks))
						end
					end
				end
			end

			self.loaded = true
		end
	end
	local shatter = Kristal.Shatter
	
	local heart_broken = love.graphics.newImage(mod.path.."/heart_broken.png")

	local function breakHeart()
		MainMenu.heart.color = {.5,0,1}
		MainMenu.heart:set(heart_broken)
	end
	local function unbreakHeart()
		MainMenu.heart.color = {Kristal.getSoulColor()}
		MainMenu.heart:set("player/heart_menu")
	end
	
	if MainMenu and MainMenu.mod_list ~= Kristal.Shatter.mod_list then
		local options = require(mod.path.."/options")
		MainMenu.state_manager:addState("SHATTER", options(MainMenu))
		
		Kristal.Shatter.mod_list = MainMenu.mod_list
		
		local orig = MainMenu.mod_list.onKeyPressed
		MainMenu.state_manager:addEvent("keypressed",{MODSELECT = function(menu, key, is_repeat)
			--Kristal.Console:log("guh.")
			if key == "q" and not is_repeat then
				shatter.active = not shatter.active
				if shatter.active then
					Assets.playSound("ui_spooky_action")
					--Assets.playSound("break2")
					breakHeart()
				else
					Assets.playSound("him_quick")
					unbreakHeart()
				end
				local hearteffect = Sprite("player/heart_menu")
				hearteffect:setOrigin(0.5, 0.5)
				hearteffect:setScale(2, 2)
				hearteffect:setPosition(MainMenu.heart:getPosition())
				hearteffect.color = menu.heart.color
				hearteffect:setLayer(menu.heart.layer - 1)
				MainMenu.stage:addChild(hearteffect)
				MainMenu.stage.timer:tween(.5, hearteffect, {scale_x=4, scale_y=4, alpha=0})
				local col = menu.heart.color
				menu.heart.color = {1,1,1,1}
				MainMenu.stage.timer:tween(.5, menu.heart, {color=col})
				MainMenu.stage.timer:after(.5, function()
					hearteffect:remove()
				end)
			else
				orig(menu.mod_list, key, is_repeat)
			end
		end})
		
		local orig = MainMenu.mod_list.onEnter
		MainMenu.state_manager:addEvent("enter",{MODSELECT = function(menu)
			if shatter.active then
				breakHeart()
			else
				unbreakHeart()
			end
			orig(menu.mod_list)
		end})
		
		local orig = MainMenu.mod_list.onLeave
		MainMenu.state_manager:addEvent("leave",{MODSELECT = function(menu, new_state)
			if new_state == "TITLE" then
				unbreakHeart()
			end
			orig(menu.mod_list)
		end})
	end
	
    button:setColor(1, 1, 1)
    button:setFavoritedColor(.8, .6, 1)
	
	if not MainMenu then
		button.subtitle = "(kristal version outdated! cannot run)"
	elseif math.random() < 1/50 then
		button.subtitle = "shatter? i barely know 'er!"
	elseif math.random() < 1/50 then
		button.subtitle = "the twilight reverie (or somethin idk)"
	else
		button.subtitle = "A kristal \"Corruptor\""
	end
end

function preview:update()
end

function preview:draw()
end

local subfont = Assets.getFont("main", 16)
function preview:drawOverlay()
	if MainMenu and MainMenu.state == "MODSELECT" then
		love.graphics.setColor(COLORS.white)
		love.graphics.setFont(subfont)
		local txt = Kristal.Shatter.active and "[Q] Deactivate shatter" or "[Q] Activate shatter"
		Draw.printShadow(txt, -70, 50, 1, "right", 640)
	end
end

return preview