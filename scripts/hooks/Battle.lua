local Battle, super = Class(Battle)
local function opt(setting)
    return Kristal.Config["ebb/"..setting]
end
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
function Battle:update()
    super.update(self)
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
        if self.bleedtimer > 0 and self.party then
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
    super.init(self, ...)
end

return Battle