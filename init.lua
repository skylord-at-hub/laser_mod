local cooldown = {} -- So the push isnt too op
local sabers = {} -- Store saber strings for sound effects

local function LaserSwordPushArea(user, radius, amount)
    local pos = user:get_pos()
    if not pos then
        return
    end

    local objs = core.get_objects_inside_radius(pos, radius)

    for _, obj in ipairs(objs) do
        if obj ~= user then
            local dir = vector.direction(pos, obj:get_pos())
            local push_vec = vector.multiply(vector.normalize(dir), amount)
            obj:add_velocity(push_vec)
        end
    end
end

-- Stop repeating register code. Just use functions. Simple
local function registerLaserSword(color)
    local description = color:sub(1,1):upper() .. color:sub(2) .. " Laser Sword"
    local sname = "laser_mod:" .. color
    core.register_tool(sname, {
        description = description,
        inventory_image = "laser_mod_".. color ..".png",
        tool_capabilities = { -- Copy and paste from original laser mod
            full_punch_interval = 3.0,
            max_drop_level= 1,
            groupcaps={
                cracky={times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=15, maxlevel=3},
                crumbly={times={[1]=1.20, [2]=0.60, [3]=0.30}, uses=15, maxlevel=3},
                choppy={times={[1]=2.20, [2]=1.00, [3]=0.60}, uses=15, maxlevel=3},
                snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=15, maxlevel=3}
            },
            damage_groups = {fleshy=12}, -- initially 8.. But 12 is good because of how long the punch_interval is
        },
        on_secondary_use  = function(itemstack, user, pointed_thing)
            local now = os.time()
            local name = user:get_player_name()
            if cooldown[name] == nil then
                LaserSwordPushArea(user, 4, 30)
                cooldown[name] = now + 5
                return itemstack
            end

            if now < cooldown[name] then
                core.chat_send_player(name, "[Laser_mod] Your on a cooldown! Wait " .. now - cooldown[name] .. " seconds!")
                return itemstack
            else
                LaserSwordPushArea(user, 4, 30)
                cooldown[name] = now + 5
            end
        end,
    })

    minetest.register_craft({
        output = 'laser_mod:' .. color,
        recipe = {
            {'default:glass'},
            {'dye:' .. color},
            {'default:mese_crystal'},
        }
    })
    table.insert(sabers, sname)
end

registerLaserSword("red")
registerLaserSword("blue")
registerLaserSword("yellow")
registerLaserSword("green")

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter or not hitter:is_player() then
        return
    end

    local held_item = hitter:get_wielded_item():get_name()

    for i=1, #sabers do
        if held_item ==  sabers[i] then
            core.sound_play("laser_mod_saber" .. math.random(1,3), {
                gain = 1,
                pitch = 1,
                object = player,
                max_hear_distance = 20, -- Might be a bit too much distance.. but.. LASER!
            })
            return
        end
    end
end)

core.register_on_dignode(function(pos, oldnode, digger)
    if not digger or not digger:is_player() then
        return
    end

    local held_item = digger:get_wielded_item():get_name()

        for i=1, #sabers do
        if held_item ==  sabers[i] then
            core.sound_play("laser_mod_saber" .. math.random(1,3), {
                pos = pos,
                gain = 1,
                pitch = 1,
                max_hear_distance = 20, -- Might be a bit too much distance.. but.. LASER!
            })
            return
        end
    end
end)