-- Ron and Hermione, seen from the back.
-- The wand tip is draw.harry_pose, the same point Harry's spell leaves from.
local Draw = require("draw")
local D = setmetatable({}, { __index = Draw })

local function setc(rgb, a)
  love.graphics.setColor(rgb[1] / 255, rgb[2] / 255, rgb[3] / 255, a or 1)
end

local function paint(cx, cy, facing, scale, pulse, look, CYAN)
  local p = Draw.harry_pose(cx, cy, facing, scale, pulse)
  local s, f, cast = p.s, p.f, p.cast
  cy = p.cy
  local skin = look.skin
  local robe, robe_sh, robe_hi = look.robe, look.robe_sh, look.robe_hi
  local scarf, gold = look.scarf, look.gold
  local bolt = CYAN or {48, 255, 255}
  local wand = {132, 78, 32}

  D.glow(cx + f * 0.2 * s, cy - 0.4 * s, s * 1.8, bolt, 0.08)
  setc({0, 0, 0}, 0.30)
  love.graphics.ellipse("fill", cx, cy + 1.55 * s, 0.72 * s, 0.12 * s)

  if look.hair_back then look.hair_back(cx, cy, s, f) end

  -- back of the robe: a center seam, no front opening
  setc(robe)
  love.graphics.polygon("fill", cx - 0.32 * s, cy - 0.55 * s, cx + 0.32 * s, cy - 0.55 * s, cx + 0.58 * s, cy + 1.35 * s, cx + 0.16 * s, cy + 1.48 * s, cx - 0.52 * s, cy + 1.35 * s)
  setc(robe_sh)
  love.graphics.polygon("fill", cx - 0.08 * s, cy - 0.48 * s, cx + 0.08 * s, cy - 0.48 * s, cx + 0.14 * s, cy + 1.32 * s, cx - 0.10 * s, cy + 1.32 * s)
  setc(robe_hi, 0.45)
  love.graphics.polygon("fill", cx - 0.28 * s, cy - 0.42 * s, cx - 0.16 * s, cy - 0.42 * s, cx - 0.28 * s, cy + 1.10 * s, cx - 0.42 * s, cy + 1.05 * s)
  setc(gold)
  love.graphics.polygon("fill", cx - 0.50 * s, cy + 1.28 * s, cx + 0.54 * s, cy + 1.28 * s, cx + 0.16 * s, cy + 1.48 * s, cx - 0.46 * s, cy + 1.40 * s)
  setc(robe)
  love.graphics.polygon("fill", cx - 0.44 * s, cy + 1.32 * s, cx + 0.48 * s, cy + 1.32 * s, cx + 0.16 * s, cy + 1.44 * s, cx - 0.40 * s, cy + 1.38 * s)

  setc({16, 10, 8})
  love.graphics.ellipse("fill", cx - 0.22 * s, cy + 1.46 * s, 0.18 * s, 0.07 * s)
  love.graphics.ellipse("fill", cx + 0.16 * s, cy + 1.46 * s, 0.18 * s, 0.07 * s)

  -- scarf tied at the nape; tails only hang for short hair
  setc(scarf)
  love.graphics.ellipse("fill", cx, cy - 0.52 * s, 0.28 * s, 0.09 * s)
  if not look.hair_over then
    love.graphics.polygon("fill", cx - 0.10 * s, cy - 0.48 * s, cx - 0.02 * s, cy - 0.48 * s, cx - 0.04 * s, cy + 0.22 * s, cx - 0.14 * s, cy + 0.30 * s)
    love.graphics.polygon("fill", cx + 0.02 * s, cy - 0.48 * s, cx + 0.10 * s, cy - 0.48 * s, cx + 0.14 * s, cy + 0.34 * s, cx + 0.04 * s, cy + 0.26 * s)
    setc(gold)
    love.graphics.rectangle("fill", cx - 0.14 * s, cy - 0.08 * s, 0.12 * s, 0.045 * s)
    love.graphics.rectangle("fill", cx + 0.02 * s, cy + 0.02 * s, 0.12 * s, 0.045 * s)
    love.graphics.rectangle("fill", cx - 0.12 * s, cy + 0.12 * s, 0.10 * s, 0.04 * s)
  end

  -- free (left) arm hangs on the left; wand is the right hand
  setc(robe_sh)
  love.graphics.polygon("fill", cx - 0.22 * s, cy - 0.35 * s, cx - 0.42 * s, cy + 0.05 * s, cx - 0.32 * s, cy + 0.22 * s, cx - 0.14 * s, cy - 0.08 * s)
  setc(skin)
  love.graphics.circle("fill", cx - 0.36 * s, cy + 0.22 * s, 0.07 * s)

  -- back of the head, no face
  setc(skin)
  love.graphics.circle("fill", cx, cy - 0.92 * s, 0.34 * s)
  setc(look.skin_sh)
  love.graphics.ellipse("fill", cx - f * 0.30 * s, cy - 0.90 * s, 0.07 * s, 0.10 * s)
  love.graphics.ellipse("fill", cx + f * 0.30 * s, cy - 0.90 * s, 0.07 * s, 0.10 * s)

  -- short hair stays under the wand; bushy hair is painted after so the wand sits behind it
  if look.hair and not look.hair_over then look.hair(cx, cy, s, f) end

  local shx, shy = p.shx or (cx + 0.18 * s), p.shy or (cy - 0.32 * s)
  setc(robe)
  love.graphics.setLineWidth(0.22 * s)
  love.graphics.line(shx, shy, p.ax, p.ay)
  setc(robe_hi, 0.7)
  love.graphics.setLineWidth(0.08 * s)
  love.graphics.line(shx + 0.04 * s, shy - 0.04 * s, p.ax, p.ay)
  setc(gold)
  love.graphics.circle("fill", p.ax - 0.04 * s, p.ay + 0.06 * s, 0.09 * s)
  setc(skin)
  love.graphics.circle("fill", p.ax, p.ay, 0.11 * s)

  local hx, hy = p.ax - 0.02 * s, p.ay + 0.08 * s
  setc(wand)
  love.graphics.setLineWidth(math.max(1.6, 0.035 * s))
  love.graphics.line(hx, hy, p.tipx, p.tipy)
  setc({186, 124, 58})
  love.graphics.setLineWidth(math.max(1, 0.02 * s))
  love.graphics.line(hx, hy, p.tipx, p.tipy)
  setc(gold)
  love.graphics.circle("fill", hx, hy, 0.045 * s)
  if cast > 0.12 then
    D.glow(p.tipx, p.tipy, 0.36 * s, bolt, 0.18 + 0.45 * cast)
    setc({255, 255, 255})
    love.graphics.circle("fill", p.tipx, p.tipy, 0.045 * s)
  else
    setc({210, 190, 140})
    love.graphics.circle("fill", p.tipx, p.tipy, 0.03 * s)
  end
  love.graphics.setLineWidth(1)

  if look.hair and look.hair_over then look.hair(cx, cy, s, f) end
end

local function ron_hair(cx, cy, s)
  -- back-view bowl: one round cap, no horns or peanut nape
  local red, hi, dark = {196, 62, 28}, {232, 128, 58}, {148, 36, 16}
  setc(dark)
  love.graphics.circle("fill", cx, cy - 0.96 * s, 0.40 * s)
  love.graphics.ellipse("fill", cx, cy - 0.72 * s, 0.32 * s, 0.20 * s)
  setc(red)
  love.graphics.circle("fill", cx, cy - 0.98 * s, 0.36 * s)
  love.graphics.ellipse("fill", cx, cy - 0.74 * s, 0.28 * s, 0.16 * s)
  -- ears just covered, same round silhouette
  love.graphics.ellipse("fill", cx - 0.30 * s, cy - 0.90 * s, 0.09 * s, 0.14 * s)
  love.graphics.ellipse("fill", cx + 0.30 * s, cy - 0.90 * s, 0.09 * s, 0.14 * s)
  setc(hi)
  love.graphics.ellipse("fill", cx + 0.04 * s, cy - 1.18 * s, 0.10 * s, 0.05 * s)
end

local function hermione_hair(cx, cy, s, f)
  -- one solid bush from crown through the nape; no hole in the low back
  local dark, brown, hi = {62, 30, 14}, {104, 54, 26}, {196, 132, 74}
  setc(dark)
  love.graphics.ellipse("fill", cx, cy - 0.70 * s, 0.78 * s, 0.90 * s)
  love.graphics.ellipse("fill", cx, cy + 0.06 * s, 0.64 * s, 0.52 * s)
  love.graphics.ellipse("fill", cx, cy + 0.32 * s, 0.50 * s, 0.32 * s)
  setc(brown)
  love.graphics.ellipse("fill", cx, cy - 0.78 * s, 0.70 * s, 0.84 * s)
  love.graphics.ellipse("fill", cx, cy + 0.00 * s, 0.56 * s, 0.46 * s)
  love.graphics.ellipse("fill", cx, cy + 0.28 * s, 0.44 * s, 0.28 * s)
  local curls = {
    {0, -1.28, 0.26},
    {0, -1.02, 0.28},
    {0, -0.72, 0.26},
    {-0.22, -1.18, 0.24}, {0.22, -1.18, 0.24},
    {-0.40, -0.96, 0.24}, {0.40, -0.96, 0.24},
    {-0.18, -0.90, 0.24}, {0.18, -0.90, 0.24},
    {-0.58, -0.70, 0.22}, {0.58, -0.70, 0.22},
    {-0.34, -0.62, 0.24}, {0.34, -0.62, 0.24},
    {0, -0.50, 0.26},
    {-0.70, -0.38, 0.20}, {0.70, -0.38, 0.20},
    {-0.46, -0.32, 0.22}, {0.46, -0.32, 0.22},
    {-0.20, -0.28, 0.22}, {0.20, -0.28, 0.22},
    {0, -0.22, 0.24},
    {-0.76, -0.02, 0.18}, {0.76, -0.02, 0.18},
    {-0.52, 0.04, 0.20}, {0.52, 0.04, 0.20},
    {-0.28, 0.10, 0.20}, {0.28, 0.10, 0.20},
    {0, 0.08, 0.24},
    {-0.64, 0.28, 0.18}, {0.64, 0.28, 0.18},
    {-0.36, 0.32, 0.20}, {0.36, 0.32, 0.20},
    {0, 0.30, 0.22},
    {-0.18, 0.42, 0.18}, {0.18, 0.42, 0.18},
    {0, 0.46, 0.20},
  }
  setc(dark)
  for i = 1, #curls do
    local c = curls[i]
    love.graphics.circle("fill", cx + c[1] * s, cy + (c[2] + 0.05) * s, (c[3] + 0.04) * s)
  end
  setc(brown)
  for i = 1, #curls do
    local c = curls[i]
    love.graphics.circle("fill", cx + c[1] * s, cy + c[2] * s, c[3] * s)
  end
  setc(hi)
  love.graphics.circle("fill", cx - 0.10 * s, cy - 1.32 * s, 0.08 * s)
  love.graphics.circle("fill", cx + 0.22 * s, cy - 1.10 * s, 0.06 * s)
  love.graphics.circle("fill", cx - 0.40 * s, cy - 0.86 * s, 0.05 * s)
end

function D.harry(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  return Draw.harry(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
end

function D.ron(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  paint(cx, cy, facing, scale, pulse, {
    skin = {255, 196, 150}, skin_sh = {214, 132, 96},
    robe = {22, 28, 72}, robe_sh = {12, 16, 42}, robe_hi = {58, 78, 156},
    scarf = {196, 48, 28}, gold = {232, 168, 48},
    hair = ron_hair,
  }, CYAN)
end

function D.hermione(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  paint(cx, cy, facing, scale, pulse, {
    skin = {255, 214, 186}, skin_sh = {232, 160, 140},
    robe = {48, 22, 88}, robe_sh = {28, 12, 52}, robe_hi = {132, 86, 186},
    scarf = {196, 64, 118}, gold = {240, 204, 112},
    hair = hermione_hair, hair_over = true,
  }, CYAN)
end

return D
