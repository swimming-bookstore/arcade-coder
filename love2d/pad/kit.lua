-- Arcade kits: swap the hero and what it tosses.
--
--     pad.kit.register({ name = "ghost", hero = "ghost", shot = "coin", courier = true })
--     demo:use_kit("ghost")
--
-- Built-ins: ghost, invader, frog, ship, dog, cat, aladdin, harry.
-- Override with env ARCADE_KIT or Demo.new({ kit = "frog" }).

local K = {}
local REG = {}

function K.register(kit)
  assert(kit and kit.name, "kit needs a name")
  REG[kit.name] = kit
  return kit
end

function K.get(name)
  if type(name) == "table" then
    if name.name and not REG[name.name] then
      K.register(name)
    end
    return name
  end
  return REG[tostring(name or "ghost")] or REG.ghost
end

function K.names()
  local n = {}
  for name in pairs(REG) do
    n[#n + 1] = name
  end
  table.sort(n)
  return n
end

K.register({
  name = "ghost",
  title = "GHOST",
  callsign = "BLINKY",
  hero = "ghost",
  shot = "coin",
  think_shot = "coin",
  trail = "spark",
  stage = "maze",
  tagline = "WAKA WAKA CODE",
  hull = {255, 72, 180},
  courier = true,
  scale = 4.6,
  attract_scale = 8.2,
  muzzle = function(demo)
    return demo.x + demo.facing * 26, demo.y - 2
  end,
})

K.register({
  name = "invader",
  title = "INVADER",
  callsign = "INV",
  hero = "invader",
  shot = "pellet",
  think_shot = "pellet",
  trail = "spark",
  stage = "space",
  tagline = "PEW PEW COMMIT",
  hull = {48, 255, 96},
  scale = 4.6,
  attract_scale = 8.6,
  muzzle = function(demo)
    return demo.x, demo.y + 20
  end,
})

K.register({
  name = "frog",
  title = "FROG",
  callsign = "HOP",
  hero = "frog",
  shot = "bubble",
  think_shot = "bubble",
  trail = "bubble",
  stage = "pond",
  tagline = "HOP THE BUG",
  hull = {48, 255, 128},
  scale = 4.8,
  attract_scale = 8.4,
  muzzle = function(demo)
    return demo.x + demo.facing * 22, demo.y + 6
  end,
})

K.register({
  name = "ship",
  title = "SHIP",
  callsign = "ACE",
  hero = "ship",
  shot = "capsule",
  think_shot = "pellet",
  trail = "spark",
  stage = "arcade",
  tagline = "LOCK ON FILE",
  hull = {48, 255, 255},
  scale = 4.6,
  attract_scale = 7.8,
  muzzle = function(demo)
    return demo.x + demo.facing * 18, demo.y - 10
  end,
})

K.register({
  name = "dog",
  title = "DOG",
  callsign = "WOOF",
  hero = "dog",
  shot = "bone",
  think_shot = "bone",
  trail = "spark",
  stage = "kennel",
  tagline = "FETCH THE FIX",
  hull = {232, 168, 72},
  courier = true,
  scale = 4.8,
  attract_scale = 8.0,
  muzzle = function(demo)
    return demo.x + demo.facing * 28, demo.y + 4
  end,
})

K.register({
  name = "cat",
  title = "CAT",
  callsign = "MEOW",
  hero = "cat",
  shot = "yarn",
  think_shot = "spark",
  trail = "spark",
  stage = "alley",
  tagline = "POUNCE ON BUGS",
  hull = {255, 168, 72},
  scale = 4.8,
  attract_scale = 8.2,
  muzzle = function(demo)
    return demo.x + demo.facing * 24, demo.y - 4
  end,
})

K.register({
  name = "aladdin",
  title = "ALADDIN",
  callsign = "LAMP",
  hero = "aladdin",
  shot = "note",
  think_shot = "note",
  trail = "spark",
  stage = "agrabah",
  hull = {196, 48, 88},
  scale = 5.2,
  attract_scale = 8.0,
  muzzle = function(demo)
    return demo.x + demo.facing * 36, demo.y - 14
  end,
})

K.register({
  name = "harry",
  title = "HARRY",
  callsign = "WAND",
  hero = "harry",
  shot = "spell",
  think_shot = "spell",
  trail = "spell",
  stage = "hogwarts",
  tagline = "WINGARDIUM CODE-OSA",
  hull = {36, 48, 120},
  scale = 4.6,
  attract_scale = 7.6,
  -- raised wand tip — same pose as draw.harry
  muzzle = function(demo)
    local draw = require("draw")
    local wave = demo.cast or demo.t or 0
    local p = draw.harry_pose(demo.x, demo.y, demo.facing, demo.scale, wave)
    return p.tipx, p.tipy
  end,
})

return K
