-- For suggestions, open an issue on the github repository:
-- https://github.com/skylord-at-hub/laser_mod

local cooldown = {} -- So the push isnt too op
local sabers = { -- Store itemstrings of sabers
    ["laser_mod:red"] = true;
    ["laser_mod:yellow"] = true;
    ["laser_mod:green"] = true;
    ["laser_mod:blue"] = true;
}

local function laserSwordPushArea(user, radius, amount)
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

    core.sound_play("laser_mod_push", {
        gain = 1,
        pitch = 1,
        object = player,
        max_hear_distance = 20,
    })
end

-- Give recipe for Laser Swords depending on game (Ask to add support to a game by opening an issue on github)
local function checkGame(color)
    local getPath = core.get_modpath
    local recipe = ""
    if getPath("default") then
        recipe = {
            {"default:glass"},
            {"dyes:" .. color},
            {"default:meseblock"},
        }
    elseif getPath("mcl_core") then
        recipe = {
            {"mcl_core:glass_" .. color},
            {"mcl_dye:" .. color},
            {"mcl_core:emerald"},
        }
    end

    if type(recipe) == "table" then
        core.register_craft({
            output = "laser_mod:" .. color,
            recipe = recipe
        })
    else
        core.log("warning",
            "[laser_mod] This game is unsupported (meaning there wont be a recipe registered for this game). You may make your own recipe or suggest skylord to support this game on github."
        )
    end
end

-- Register a laser sword
local function registerLaserSword(color)
    local description = color:sub(1,1):upper() .. color:sub(2) .. " Laser Sword"
    local uses = 20
    core.register_tool("laser_mod:" .. color, {
        description = description,
        inventory_image = "laser_mod_".. color ..".png",
        tool_capabilities = { -- Copy and paste from original laser mod
            full_punch_interval = 0.6,
            max_drop_level= 1,
            groupcaps={
                cracky={times={[1]=0,8, [2]=1.6, [3]=2.3}, uses=uses, maxlevel=3},
                crumbly={times={[1]=0.3, [2]=0.60, [3]=1}, uses=uses, maxlevel=3},
                choppy={times={[1]=0.25, [2]=0.4, [3]=0.7}, uses=uses, maxlevel=3},
                snappy={times={[1]=0.1, [2]=0.3, [3]=0.5}, uses=uses, maxlevel=3}
            },
            damage_groups = {fleshy=8},
        },
        on_secondary_use  = function(itemstack, user, pointed_thing)
            local now = os.time()
            local name = user:get_player_name()

            if cooldown[name] == nil then
                cooldown[name] = now
            end

            if now < cooldown[name] then
                core.chat_send_player(name, "[Laser_mod] Your on a cooldown! Wait " .. cooldown[name] - now .. " seconds!")
                return itemstack
            else
                laserSwordPushArea(user, 4, 30)
                cooldown[name] = now + 5
                itemstack:set_wear(itemstack:get_wear() + (65535 / uses))
                return itemstack
            end
        end,
    })
    checkGame(color)
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
    if sabers[held_item] then
        core.sound_play("laser_mod_saber", {
            pos = pos,
            gain = 1,
            pitch = 1,
            max_hear_distance = 5,
        })
        return
    end
end)

core.register_on_dignode(function(pos, oldnode, digger)
    if not digger or not digger:is_player() then
        return
    end

    local held_item = digger:get_wielded_item():get_name()
    if sabers[held_item] then
        core.sound_play("laser_mod_saber", {
            pos = pos,
            gain = 1,
            pitch = 1,
            max_hear_distance = 5,
        })
        return
    end
end)