local Soul, super = Class(Soul)
local function opt(setting)
    return Kristal.Config["ebb/"..setting]
end
function Soul:update()
    if opt("graze_behavior") ~= "None" then
        for _,bullet in ipairs(Game.stage:getObjects(Bullet)) do
            if bullet:collidesWith(self.graze_collider) then
                if opt("graze_behavior") == "Delay" then
                    if bullet.grazed then
                        Game.battle.bleedtimer = Game.battle.bleedtimer - (0.9 * DT)
                    else
                        Game.battle.bleedtimer = Game.battle.bleedtimer - 1
                    end
                else
                    if not bullet.grazed and self.inv_timer == 0 then
                        for i,v in ipairs(Game.battle.party) do
                            v.chara.health = math.min(v.chara:getStat("health"), v.chara.health + 5)
                            v:checkHealth()
                        end
                    end
                end
            end
        end
    end
    super.update(self)
end
return Soul