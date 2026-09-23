local fontmod = require("font")
local glyph = fontmod.glyph

local M = {}

local function c(rgb, a)
  a = a == nil and 1 or a
  return rgb[1] / 255, rgb[2] / 255, rgb[3] / 255, a
end

function M.clamp(t, a, b)
  a = a or 0
  b = b or 1
  if t < a then return a end
  if t > b then return b end
  return t
end

function M.lerp(a, b, t)
  return a + (b - a) * t
end

function M.mix(c0, c1, t)
  t = M.clamp(t)
  return {
    M.lerp(c0[1], c1[1], t),
    M.lerp(c0[2], c1[2], t),
    M.lerp(c0[3], c1[3], t),
  }
end

function M.rect(x, y, w, h, col, a)
  if not col then return end
  love.graphics.setColor(c(col, a))
  love.graphics.rectangle("fill", x, y, w, h)
end

function M.diamond(cx, cy, r, col, a)
  love.graphics.setColor(c(col, a))
  love.graphics.polygon("fill", cx, cy - r, cx + r * 0.7, cy, cx, cy + r, cx - r * 0.7, cy)
end

function M.glow(cx, cy, r, col, a)
  a = a or 0.22
  for i = 4, 1, -1 do
    local k = i / 4
    love.graphics.setColor(c(col, a * k * k))
    love.graphics.circle("fill", cx, cy, r * k)
  end
end

function M.textW(s, scale)
  scale = scale or 2
  return #(s or "") * 8 * scale
end

function M.text(s, x, y, col, scale, a)
  scale = scale or 2
  s = s or ""
  local ox = x
  for i = 1, #s do
    local bits = glyph(s:sub(i, i))
    for row = 1, 8 do
      local line = bits[row] or 0
      for coln = 0, 7 do
        local bit = math.floor(line / (2 ^ (7 - coln))) % 2
        if bit == 1 then
          M.rect(ox + coln * scale, y + (row - 1) * scale, scale, scale, col, a)
        end
      end
    end
    ox = ox + 8 * scale
  end
  return ox - x
end

function M.ship(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local sx = 11 * scale * (1 + 0.14 * pulse)
  local sy = 14 * scale * (1 - 0.14 * pulse)
  local function put(px, py, w, h, col, a)
    px = px * facing
    M.rect(cx + px - w / 2, cy + py - h / 2, math.max(1, w), math.max(1, h), col, a)
  end
  M.glow(cx, cy, sx * 1.8, hull, 0.22)
  put(0.72 * sx, 0.12 * sy, 0.55 * sx, 0.18 * sy, hull)
  put(-0.72 * sx, 0.12 * sy, 0.55 * sx, 0.18 * sy, hull)
  put(0.55 * sx, 0.08 * sy, 0.22 * sx, 0.1 * sy, CYAN)
  put(-0.55 * sx, 0.08 * sy, 0.22 * sx, 0.1 * sy, CYAN)
  put(0.38 * sx, -0.42 * sy, 0.1 * sx, 0.28 * sy, CREAM)
  put(-0.38 * sx, -0.42 * sy, 0.1 * sx, 0.28 * sy, CREAM)
  put(0, 0.05 * sy, 0.38 * sx, 0.95 * sy, hull)
  put(0, -0.05 * sy, 0.22 * sx, 0.7 * sy, CREAM)
  M.diamond(cx, cy - 0.55 * sy, 0.22 * sy, CYAN)
  M.diamond(cx, cy - 0.08 * sy, 0.16 * sy, WHITE, 0.9)
  put(0.18 * sx, 0.42 * sy, 0.12 * sx, 0.28 * sy, PINK)
  put(-0.18 * sx, 0.42 * sy, 0.12 * sx, 0.28 * sy, PINK)
end

-- Pac-ish ghost: round head, wavy skirt, eyes that look toward facing.
function M.ghost(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local s = 4.2 * scale * (1 + 0.08 * pulse)
  hull = hull or PINK
  M.glow(cx, cy, s * 2.4, hull, 0.28)
  love.graphics.setColor(c(hull, 1))
  love.graphics.circle("fill", cx, cy - 2, s)
  M.rect(cx - s, cy - 4, s * 2, s * 1.15, hull)
  local wave = 3 + pulse * 2
  for i = 0, 4 do
    local wx = cx - s + i * (s * 2 / 4)
    local dip = ((i + math.floor((pulse * 6) % 2)) % 2 == 0) and wave or -wave * 0.3
    M.rect(wx, cy + s * 0.7, s * 2 / 4 + 1, 10 + dip, hull)
  end
  local eye_x = 0.38 * s * facing
  M.rect(cx - 0.55 * s + eye_x * 0.2, cy - 0.55 * s, 0.42 * s, 0.5 * s, WHITE)
  M.rect(cx + 0.12 * s + eye_x * 0.2, cy - 0.55 * s, 0.42 * s, 0.5 * s, WHITE)
  M.rect(cx - 0.38 * s + eye_x, cy - 0.38 * s, 0.2 * s, 0.28 * s, {20, 20, 80})
  M.rect(cx + 0.28 * s + eye_x, cy - 0.38 * s, 0.2 * s, 0.28 * s, {20, 20, 80})
end

-- Space-invader crab.
function M.invader(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local u = 3.2 * scale * (1 + 0.1 * pulse)
  hull = hull or {48, 255, 128}
  M.glow(cx, cy, u * 3.2, hull, 0.22)
  local function cell(gx, gy, w, h)
    M.rect(cx + gx * u, cy + gy * u, w * u, h * u, hull)
  end
  cell(-2, -3, 4, 1)
  cell(-3, -2, 6, 1)
  cell(-4, -1, 8, 1)
  cell(-4, 0, 2, 1)
  cell(-1, 0, 2, 1)
  cell(2, 0, 2, 1)
  cell(-4, 1, 8, 1)
  cell(-3, 2, 1, 1)
  cell(2, 2, 1, 1)
  if math.floor(pulse * 8) % 2 == 0 then
    cell(-5, 2, 1, 1)
    cell(4, 2, 1, 1)
    cell(-3, 3, 1, 1)
    cell(2, 3, 1, 1)
  else
    cell(-4, 3, 1, 1)
    cell(3, 3, 1, 1)
    cell(-2, 2, 1, 1)
    cell(1, 2, 1, 1)
  end
  M.rect(cx - 2.2 * u, cy - 0.4 * u, 1.1 * u, 1.1 * u, WHITE)
  M.rect(cx + 1.1 * u, cy - 0.4 * u, 1.1 * u, 1.1 * u, WHITE)
  M.rect(cx - 1.9 * u + facing * 0.4 * u, cy - 0.1 * u, 0.5 * u, 0.6 * u, {10, 10, 30})
  M.rect(cx + 1.4 * u + facing * 0.4 * u, cy - 0.1 * u, 0.5 * u, 0.6 * u, {10, 10, 30})
end

-- Arcade frog: squat body, big eyes, hop squash.
function M.frog(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local s = 4.4 * scale
  local squash = 1 - 0.18 * pulse
  local stretch = 1 + 0.18 * pulse
  hull = hull or {48, 255, 128}
  M.glow(cx, cy, s * 2.2, hull, 0.2)
  M.rect(cx - s, cy - 0.2 * s * squash, s * 2, s * 1.15 * squash, hull)
  M.rect(cx - 0.85 * s, cy - 0.85 * s * stretch, 0.7 * s, 0.7 * s, hull)
  M.rect(cx + 0.15 * s, cy - 0.85 * s * stretch, 0.7 * s, 0.7 * s, hull)
  M.rect(cx - 0.72 * s, cy - 0.72 * s * stretch, 0.42 * s, 0.42 * s, WHITE)
  M.rect(cx + 0.28 * s, cy - 0.72 * s * stretch, 0.42 * s, 0.42 * s, WHITE)
  M.rect(cx - 0.55 * s + facing * 4, cy - 0.58 * s * stretch, 0.18 * s, 0.22 * s, {20, 20, 40})
  M.rect(cx + 0.45 * s + facing * 4, cy - 0.58 * s * stretch, 0.18 * s, 0.22 * s, {20, 20, 40})
  M.rect(cx - 1.15 * s, cy + 0.55 * s * squash, 0.55 * s, 0.35 * s, hull)
  M.rect(cx + 0.6 * s, cy + 0.55 * s * squash, 0.55 * s, 0.35 * s, hull)
  M.rect(cx - 0.2 * s, cy + 0.15 * s, 0.4 * s, 0.18 * s, {20, 40, 20})
end

-- Arcade dog: floppy ears, snout, wagging tail.
function M.dog(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local s = 4.0 * scale * (1 + 0.06 * pulse)
  hull = hull or {232, 168, 72}
  local dark = {140, 72, 24}
  local snout = {255, 220, 160}
  M.glow(cx, cy, s * 2.3, hull, 0.2)
  -- body
  M.rect(cx - 0.95 * s, cy - 0.15 * s, s * 1.9, s * 1.15, hull)
  -- head
  M.rect(cx - 0.55 * s + facing * 0.35 * s, cy - 1.05 * s, s * 1.15, s * 1.05, hull)
  -- floppy ears
  local ear_y = cy - 1.15 * s + math.sin(pulse * 8) * 1.5
  M.rect(cx - 0.85 * s + facing * 0.2 * s, ear_y, 0.42 * s, 0.85 * s, dark)
  M.rect(cx + 0.42 * s + facing * 0.2 * s, ear_y + 2, 0.42 * s, 0.75 * s, dark)
  -- snout
  M.rect(cx + facing * 0.55 * s, cy - 0.42 * s, 0.7 * s, 0.42 * s, snout)
  M.rect(cx + facing * 0.95 * s, cy - 0.32 * s, 0.22 * s, 0.18 * s, {20, 12, 8})
  -- eyes
  M.rect(cx - 0.18 * s + facing * 0.2 * s, cy - 0.85 * s, 0.28 * s, 0.32 * s, WHITE)
  M.rect(cx + 0.22 * s + facing * 0.2 * s, cy - 0.85 * s, 0.28 * s, 0.32 * s, WHITE)
  M.rect(cx - 0.08 * s + facing * 0.32 * s, cy - 0.75 * s, 0.14 * s, 0.18 * s, {20, 12, 8})
  M.rect(cx + 0.32 * s + facing * 0.32 * s, cy - 0.75 * s, 0.14 * s, 0.18 * s, {20, 12, 8})
  -- paws
  M.rect(cx - 0.85 * s, cy + 0.85 * s, 0.4 * s, 0.28 * s, dark)
  M.rect(cx + 0.4 * s, cy + 0.85 * s, 0.4 * s, 0.28 * s, dark)
  -- wag
  local wag = math.sin((pulse + 0.4) * 10) * 0.55 * s
  M.rect(cx - facing * 1.15 * s, cy - 0.05 * s + wag * 0.15, 0.55 * s, 0.22 * s, hull)
  M.rect(cx - facing * 1.55 * s, cy - 0.2 * s + wag, 0.35 * s, 0.22 * s, dark)
end

-- Arcade cat: triangle ears, slit pupils, curling tail.
function M.cat(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local s = 3.9 * scale * (1 + 0.05 * pulse)
  hull = hull or {255, 168, 72}
  local dark = {40, 16, 8}
  M.glow(cx, cy, s * 2.2, hull, 0.22)
  -- body
  M.rect(cx - 0.85 * s, cy - 0.05 * s, s * 1.7, s * 1.05, hull)
  -- head
  M.rect(cx - 0.7 * s + facing * 0.15 * s, cy - 1.05 * s, s * 1.4, s * 1.05, hull)
  -- triangle ears
  local tip = 4 + pulse * 3
  M.rect(cx - 0.72 * s + facing * 0.1 * s, cy - 1.55 * s - tip * 0.15, 0.38 * s, 0.62 * s, hull)
  M.rect(cx + 0.32 * s + facing * 0.1 * s, cy - 1.55 * s - tip * 0.15, 0.38 * s, 0.62 * s, hull)
  M.rect(cx - 0.62 * s + facing * 0.1 * s, cy - 1.42 * s, 0.18 * s, 0.32 * s, PINK or {255, 48, 196})
  M.rect(cx + 0.42 * s + facing * 0.1 * s, cy - 1.42 * s, 0.18 * s, 0.32 * s, PINK or {255, 48, 196})
  -- eyes
  M.rect(cx - 0.38 * s + facing * 0.18 * s, cy - 0.72 * s, 0.38 * s, 0.32 * s, {48, 255, 128})
  M.rect(cx + 0.12 * s + facing * 0.18 * s, cy - 0.72 * s, 0.38 * s, 0.32 * s, {48, 255, 128})
  M.rect(cx - 0.22 * s + facing * 0.28 * s, cy - 0.68 * s, 0.1 * s, 0.24 * s, dark)
  M.rect(cx + 0.28 * s + facing * 0.28 * s, cy - 0.68 * s, 0.1 * s, 0.24 * s, dark)
  -- whiskers
  M.rect(cx - 1.15 * s, cy - 0.28 * s, 0.55 * s, 2, WHITE, 0.85)
  M.rect(cx + 0.62 * s, cy - 0.28 * s, 0.55 * s, 2, WHITE, 0.85)
  M.rect(cx - 1.05 * s, cy - 0.12 * s, 0.5 * s, 2, WHITE, 0.7)
  M.rect(cx + 0.58 * s, cy - 0.12 * s, 0.5 * s, 2, WHITE, 0.7)
  -- nose + mouth
  M.rect(cx + facing * 0.08 * s, cy - 0.28 * s, 0.18 * s, 0.12 * s, PINK or {255, 48, 196})
  -- paws
  M.rect(cx - 0.72 * s, cy + 0.85 * s, 0.38 * s, 0.22 * s, WHITE)
  M.rect(cx + 0.32 * s, cy + 0.85 * s, 0.38 * s, 0.22 * s, WHITE)
  -- curling tail
  local curl = math.sin(pulse * 7) * 0.4 * s
  M.rect(cx - facing * 1.05 * s, cy + 0.15 * s, 0.28 * s, 0.85 * s, hull)
  M.rect(cx - facing * 1.35 * s, cy + 0.15 * s + curl, 0.45 * s, 0.22 * s, hull)
end

function M.hero(kind, cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  kind = kind or "ghost"
  local fn = M[kind]
  if type(fn) ~= "function" or kind == "hero" then
    fn = M.ghost
  end
  fn(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
end

function M.shot(kind, x, y, col, t)
  kind = kind or "coin"
  col = col or {255, 220, 48}
  t = t or 0
  if kind == "coin" then
    M.coin(x, y, 8, t, col)
  elseif kind == "pellet" then
    M.glow(x, y, 14, col, 0.35)
    love.graphics.setColor(c(col, 1))
    love.graphics.circle("fill", x, y, 5)
  elseif kind == "bubble" then
    M.glow(x, y, 16, col, 0.22)
    love.graphics.setColor(c(col, 0.55))
    love.graphics.circle("line", x, y, 9)
    love.graphics.setColor(c({255, 255, 255}, 0.8))
    love.graphics.circle("fill", x - 3, y - 3, 2)
  elseif kind == "spark" then
    M.diamond(x, y, 7, col, 0.95)
    M.diamond(x, y, 3, {255, 255, 255}, 0.9)
  elseif kind == "bone" then
    M.glow(x, y, 14, col, 0.22)
    M.rect(x - 10, y - 3, 20, 6, col)
    M.rect(x - 13, y - 7, 7, 7, col)
    M.rect(x - 13, y, 7, 7, col)
    M.rect(x + 6, y - 7, 7, 7, col)
    M.rect(x + 6, y, 7, 7, col)
    M.rect(x - 4, y - 2, 8, 4, {255, 255, 255}, 0.55)
  elseif kind == "yarn" then
    M.glow(x, y, 16, col, 0.28)
    love.graphics.setColor(c(col, 1))
    love.graphics.circle("fill", x, y, 8)
    love.graphics.setColor(c({255, 255, 255}, 0.7))
    love.graphics.circle("line", x, y, 5)
    love.graphics.circle("fill", x - 3, y - 3, 2)
  elseif kind == "capsule" then
    M.glow(x, y, 16, col, 0.28)
    M.rect(x - 4, y - 10, 8, 20, col)
    M.rect(x - 3, y - 8, 6, 16, {255, 255, 255}, 0.45)
    love.graphics.setColor(c(col, 1))
    love.graphics.circle("fill", x, y - 10, 5)
    love.graphics.circle("fill", x, y + 10, 5)
  elseif kind == "note" then
    M.glow(x, y, 16, col, 0.28)
    local bob = math.sin((t or 0) * 10) * 2
    local ny = y + bob
    love.graphics.setColor(c(col, 1))
    love.graphics.ellipse("fill", x - 2, ny + 6, 7, 5)
    M.rect(x + 4, ny - 12, 3, 20, col)
    -- flag
    love.graphics.polygon("fill", x + 7, ny - 12, x + 16, ny - 6, x + 7, ny - 4)
    love.graphics.setColor(c({255, 255, 255}, 0.85))
    love.graphics.ellipse("fill", x - 4, ny + 5, 3, 2)
  else
    M.diamond(x - 2, y, 8, col, 0.95)
  end
end

function M.scissor(x, y, w, h, fn)
  love.graphics.setScissor(x, y, w, h)
  fn()
  love.graphics.setScissor()
end

function M.coin(cx, cy, r, t, col)
  col = col or {255, 220, 48}
  local wob = 0.55 + 0.45 * math.abs(math.sin((t or 0) * 6))
  local rw = r * wob
  M.glow(cx, cy, r * 2.2, col, 0.28)
  M.diamond(cx, cy, r * 1.15, col, 0.95)
  M.diamond(cx, cy, r * 0.55, {255, 255, 220}, 0.9)
  M.rect(cx - rw * 0.15, cy - r * 0.55, math.max(1, rw * 0.3), r * 1.1, {40, 12, 8}, 0.55)
end

-- Neon cabinet: starfield, CRT glow, Outrun grid.
function M.arcade(t, W, H, sky_tint, sky_a)
  local TOP = {12, 0, 28}
  local MID = {36, 4, 72}
  local HOT = {255, 48, 196}
  local ICE = {48, 255, 255}
  local GOLD = {255, 220, 48}
  sky_a = sky_a or 0
  local horizon = math.floor(H * 0.40)
  for i = 0, 20 do
    local k = i / 20
    local col = M.mix(TOP, MID, k)
    if sky_tint and sky_a > 0.01 then
      col = M.mix(col, sky_tint, 0.16 * sky_a)
    end
    M.rect(0, math.floor(horizon * k), W, math.ceil(horizon / 20) + 1, col)
  end
  -- twinkling stars
  for i = 0, 70 do
    local sx = (i * 173 + math.floor(t * (12 + i % 7))) % W
    local sy = (i * 97) % math.max(8, horizon - 8)
    local tw = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(t * 5 + i))
    local col = (i % 5 == 0) and GOLD or ((i % 3 == 0) and ICE or {255, 255, 255})
    M.rect(sx, sy, 2 + (i % 3), 2, col, 0.35 + 0.55 * tw)
  end
  -- sun / marquee disc
  local sun_y = horizon - 28
  M.glow(W / 2, sun_y, 90, HOT, 0.18)
  M.glow(W / 2, sun_y, 46, GOLD, 0.22)
  -- horizon neon bar
  M.rect(0, horizon - 3, W, 3, ICE, 0.85)
  M.rect(0, horizon, W, 2, HOT, 0.9)
  -- floor
  local FLOOR_A = {18, 0, 36}
  local FLOOR_B = {6, 0, 16}
  local water_h = H - horizon
  for i = 0, 22 do
    local k = i / 22
    M.rect(0, horizon + math.floor(water_h * k), W, math.ceil(water_h / 22) + 1, M.mix(FLOOR_A, FLOOR_B, k))
  end
  local vp_x = W / 2
  local scroll = (t * 70) % 48
  for i = 0, 18 do
    local k = i / 18
    local y = horizon + ((water_h + 48) * (k * k)) - scroll * (0.4 + k)
    if y >= horizon and y < H then
      local a = 0.12 + 0.55 * k
      M.rect(0, y, W, 2, (i % 2 == 0) and ICE or HOT, a)
    end
  end
  for i = -14, 14 do
    local x1 = vp_x + i * 18
    local x2 = vp_x + i * 110
    local col = (i % 2 == 0) and ICE or HOT
    love.graphics.setColor(col[1] / 255, col[2] / 255, col[3] / 255, 0.28)
    love.graphics.setLineWidth(2)
    love.graphics.line(x1, horizon + 2, x2, H)
  end
  -- floating coins
  for i = 0, 8 do
    local cx = (i * 147 + t * 40) % W
    local cy = 40 + (i * 37) % math.max(20, horizon - 50)
    local bob = math.sin(t * 3 + i) * 6
    M.coin(cx, cy + bob, 5 + (i % 3), t + i, (i % 2 == 0) and GOLD or ICE)
  end
end

function M.stage(kind, t, W, H, sky_tint, sky_a)
  kind = kind or "arcade"
  local fn = M[kind]
  if type(fn) ~= "function" or kind == "stage" then
    fn = M.arcade
  end
  fn(t, W, H, sky_tint, sky_a)
end

-- Agrabah night: moon, onion palaces, dunes, lanterns.
function M.agrabah(t, W, H, sky_tint, sky_a)
  local TOP = {18, 6, 48}
  local MID = {92, 24, 88}
  local DUSK = {255, 120, 64}
  local SAND = {255, 196, 96}
  local DUNE = {160, 72, 36}
  local DUNE2 = {92, 36, 24}
  local GOLD = {255, 220, 72}
  local CREAM = {255, 236, 196}
  local INK = {18, 6, 28}
  sky_a = sky_a or 0
  local horizon = math.floor(H * 0.52)
  for i = 0, 24 do
    local k = i / 24
    local col = k < 0.55 and M.mix(TOP, MID, k / 0.55) or M.mix(MID, DUSK, (k - 0.55) / 0.45)
    if sky_tint and sky_a > 0.01 then
      col = M.mix(col, sky_tint, 0.12 * sky_a)
    end
    M.rect(0, math.floor(horizon * k), W, math.ceil(horizon / 24) + 1, col)
  end
  -- stars
  for i = 0, 55 do
    local sx = (i * 181) % W
    local sy = (i * 53) % math.max(8, horizon - 70)
    local tw = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * 3.2 + i))
    M.rect(sx, sy, 2 + (i % 2), 2, (i % 4 == 0) and GOLD or CREAM, 0.3 + 0.55 * tw)
  end
  -- moon
  local mx, my, mr = W * 0.78, horizon * 0.32, 54
  M.glow(mx, my, mr * 2.4, GOLD, 0.18)
  love.graphics.setColor(CREAM[1] / 255, CREAM[2] / 255, CREAM[3] / 255, 0.95)
  love.graphics.circle("fill", mx, my, mr)
  love.graphics.setColor(MID[1] / 255, MID[2] / 255, MID[3] / 255, 1)
  love.graphics.circle("fill", mx + 16, my - 8, mr * 0.78)
  local function minaret(x, base, h, col)
    M.rect(x - 8, base - h, 16, h, col)
    M.rect(x - 14, base - h - 10, 28, 12, col)
    M.diamond(x, base - h - 28, 16, GOLD)
    M.rect(x - 2, base - h - 46, 4, 16, GOLD)
  end
  local function dome(x, y, r, col)
    M.glow(x, y, r * 1.6, GOLD, 0.12)
    love.graphics.setColor(col[1] / 255, col[2] / 255, col[3] / 255, 1)
    love.graphics.circle("fill", x, y, r)
    M.rect(x - r, y, r * 2, r * 0.55, col)
    M.diamond(x, y - r - 8, 10, GOLD)
  end
  local sand = {168, 96, 64}
  local sand2 = {196, 120, 72}
  local rose = {176, 64, 72}
  local plum = {96, 36, 64}
  local peach = {220, 140, 88}
  local function crenel(x, y, w)
    local n = math.max(3, math.floor(w / 18))
    for i = 0, n - 1 do
      if i % 2 == 0 then M.rect(x + i * (w / n), y - 10, w / n - 2, 10, sand2) end
    end
  end
  local function window(x, y, a)
    M.rect(x, y, 8, 14, GOLD, a or 0.7)
    M.rect(x + 1, y + 1, 6, 5, CREAM, 0.35)
  end
  local function arch(x, y, w, h, col)
    M.rect(x, y - h + w / 2, w, h - w / 2, col)
    love.graphics.setColor(col[1] / 255, col[2] / 255, col[3] / 255, 1)
    love.graphics.circle("fill", x + w / 2, y - h + w / 2, w / 2)
  end
  -- far city terrace
  M.rect(0, horizon - 58, W, 58, plum)
  for i = 0, 18 do
    local bw = 40 + (i % 4) * 16
    local bh = 36 + (i * 17) % 70
    M.rect(12 + i * 70, horizon - bh, bw, bh, (i % 3 == 0) and sand or sand2)
    crenel(12 + i * 70, horizon - bh, bw)
  end
  -- left palace
  M.rect(W * 0.10, horizon - 168, 210, 168, sand)
  crenel(W * 0.10, horizon - 168, 210)
  arch(W * 0.10 + 78, horizon, 54, 70, plum)
  M.rect(W * 0.10 + 88, horizon - 48, 34, 48, INK, 0.85)
  dome(W * 0.10 + 105, horizon - 176, 44, rose)
  -- grand palace
  M.rect(W * 0.36, horizon - 210, 280, 210, peach)
  crenel(W * 0.36, horizon - 210, 280)
  M.rect(W * 0.36 + 70, horizon - 248, 140, 48, sand2)
  dome(W * 0.36 + 140, horizon - 258, 62, rose)
  dome(W * 0.36 + 46, horizon - 218, 28, {200, 88, 64})
  dome(W * 0.36 + 234, horizon - 218, 28, {200, 88, 64})
  arch(W * 0.36 + 108, horizon, 64, 88, plum)
  M.rect(W * 0.36 + 120, horizon - 56, 40, 56, INK, 0.9)
  -- right keep
  M.rect(W * 0.64, horizon - 150, 190, 150, sand)
  crenel(W * 0.64, horizon - 150, 190)
  dome(W * 0.64 + 95, horizon - 158, 40, {188, 80, 72})
  arch(W * 0.64 + 70, horizon, 48, 62, plum)
  minaret(W * 0.08, horizon, 210, plum)
  minaret(W * 0.34, horizon, 186, {80, 28, 56})
  minaret(W * 0.62, horizon, 230, plum)
  minaret(W * 0.82, horizon, 168, {80, 28, 56})
  minaret(W * 0.92, horizon, 124, plum)
  for i = 0, 14 do
    local wx = W * 0.12 + (i % 7) * 26
    local wy = horizon - 50 - math.floor(i / 7) * 36
    window(wx, wy, 0.5 + 0.4 * (0.5 + 0.5 * math.sin(t * 4 + i)))
  end
  for i = 0, 11 do
    local wx = W * 0.38 + (i % 6) * 36
    local wy = horizon - 80 - math.floor(i / 6) * 40
    window(wx, wy, 0.65)
  end
  for i = 0, 7 do
    window(W * 0.66 + (i % 4) * 32, horizon - 48 - math.floor(i / 4) * 34, 0.55)
  end
  -- dunes
  for i = 0, 16 do
    local k = i / 16
    M.rect(0, horizon + math.floor((H - horizon) * k), W, math.ceil((H - horizon) / 16) + 1, M.mix(SAND, DUNE2, k))
  end
  love.graphics.setColor(DUNE[1] / 255, DUNE[2] / 255, DUNE[3] / 255, 0.95)
  love.graphics.ellipse("fill", W * 0.22, horizon + 40, 280, 70)
  love.graphics.ellipse("fill", W * 0.72, horizon + 28, 340, 80)
  love.graphics.setColor(SAND[1] / 255, SAND[2] / 255, SAND[3] / 255, 0.55)
  love.graphics.ellipse("fill", W * 0.5, horizon + 18, 220, 36)
  -- palms
  for i = 0, 2 do
    local px = 70 + i * 70
    M.rect(px, horizon - 70, 8, 78, INK, 0.85)
    for j = 0, 5 do
      local ang = -2.2 + j * 0.7
      love.graphics.setColor(0.08, 0.22, 0.12, 0.9)
      love.graphics.setLineWidth(4)
      love.graphics.line(px + 4, horizon - 70, px + 4 + math.cos(ang) * 34, horizon - 70 + math.sin(ang) * 18)
    end
  end
  -- flying lanterns
  for i = 0, 12 do
    local lx = (i * 97 + t * (18 + i % 5)) % W
    local ly = 70 + (i * 41) % math.max(40, horizon - 90)
    ly = ly + math.sin(t * 2 + i) * 8
    M.rect(lx, ly, 10, 14, (i % 2 == 0) and GOLD or DUSK, 0.95)
    M.rect(lx + 2, ly + 3, 6, 6, CREAM, 0.8)
    M.rect(lx + 4, ly + 14, 2, 6, INK, 0.7)
    M.glow(lx + 5, ly + 6, 16, GOLD, 0.16)
  end
  -- magic carpet silhouette
  local cx = (t * 46) % (W + 160) - 80
  local cy = 90 + math.sin(t * 1.4) * 16
  M.rect(cx, cy, 70, 10, {180, 40, 80}, 0.85)
  M.rect(cx + 8, cy - 4, 18, 8, {255, 200, 80}, 0.9)
  M.rect(cx - 8, cy + 2, 12, 4, {180, 40, 80}, 0.8)
  M.rect(cx + 66, cy + 2, 12, 4, {180, 40, 80}, 0.8)
end

-- Ghost maze: neon corridors, pellets, fruit, ghost house.
function M.maze(t, W, H, sky_tint, sky_a)
  local TOP = {4, 0, 28}
  local FLOOR = {8, 4, 36}
  local WALL = {56, 96, 255}
  local GLOW = {120, 180, 255}
  local DOT = {255, 220, 180}
  local GOLD = {255, 220, 48}
  local PINK = {255, 72, 180}
  local INK = {4, 2, 18}
  for i = 0, 18 do
    local k = i / 18
    M.rect(0, math.floor(H * k), W, math.ceil(H / 18) + 1, M.mix(TOP, FLOOR, k))
  end
  if sky_tint and (sky_a or 0) > 0.01 then
    M.rect(0, 0, W, H, sky_tint, 0.10 * sky_a)
  end
  for i = 0, 90 do
    local sx = (i * 97 + math.floor(t * 10)) % W
    local sy = (i * 53) % H
    M.rect(sx, sy, 2, 2, DOT, 0.10 + 0.08 * (i % 3))
  end
  local function wall(x, y, w, h)
    M.rect(x - 2, y - 2, w + 4, h + 4, GLOW, 0.28)
    M.rect(x, y, w, h, WALL, 0.95)
    M.rect(x + 4, y + 4, math.max(0, w - 8), math.max(0, h - 8), INK, 1)
  end
  wall(28, 28, W - 56, 16)
  wall(28, H - 44, W - 56, 16)
  wall(28, 28, 16, H - 56)
  wall(W - 44, 28, 16, H - 56)
  wall(120, 110, 320, 14)
  wall(W - 440, 110, 320, 14)
  wall(120, H - 150, 320, 14)
  wall(W - 440, H - 150, 320, 14)
  wall(120, 110, 14, 180)
  wall(W - 134, 110, 14, 180)
  wall(120, H - 330, 14, 180)
  wall(W - 134, H - 330, 14, 180)
  wall(W / 2 - 8, 110, 16, 150)
  wall(280, H / 2 + 40, 200, 14)
  wall(W - 480, H / 2 + 40, 200, 14)
  -- ghost house
  wall(W / 2 - 110, H / 2 - 70, 220, 14)
  wall(W / 2 - 110, H / 2 - 70, 14, 120)
  wall(W / 2 + 96, H / 2 - 70, 14, 120)
  wall(W / 2 - 110, H / 2 + 36, 80, 14)
  wall(W / 2 + 30, H / 2 + 36, 80, 14)
  M.rect(W / 2 - 28, H / 2 - 70, 56, 8, PINK, 0.95)
  M.glow(W / 2, H / 2 - 10, 70, PINK, 0.12)
  -- pellets
  for i = 0, 48 do
    local px = 70 + (i * 47) % (W - 140)
    local py = 64 + (i * 71) % (H - 140)
    M.rect(px, py, 5, 5, DOT, 0.88)
  end
  -- power pellets
  for i = 0, 3 do
    local px = 78 + (i % 2) * (W - 168)
    local py = 70 + math.floor(i / 2) * (H - 160)
    local pulse = 0.5 + 0.5 * math.abs(math.sin(t * 5 + i))
    M.glow(px, py, 18, GOLD, 0.28 * pulse)
    love.graphics.setColor(1, 0.86, 0.2, pulse)
    love.graphics.circle("fill", px, py, 8)
  end
  -- fruit
  local fx = W / 2 + math.sin(t * 0.7) * 40
  local fy = H / 2 + 90
  M.rect(fx - 8, fy, 16, 14, {255, 48, 72}, 0.95)
  M.rect(fx - 2, fy - 8, 4, 10, {48, 180, 64}, 0.9)
  M.glow(fx, fy, 22, {255, 80, 80}, 0.12)
end

-- Invader night: nebula, formation, bunkers, saucer.
function M.space(t, W, H, sky_tint, sky_a)
  local INK = {2, 2, 12}
  local MID = {12, 8, 36}
  local GREEN = {48, 255, 96}
  local GOLD = {255, 220, 48}
  for i = 0, 18 do
    local k = i / 18
    M.rect(0, math.floor(H * k), W, math.ceil(H / 18) + 1, M.mix(INK, MID, k * 0.55))
  end
  if sky_tint and (sky_a or 0) > 0.01 then
    M.rect(0, 0, W, H, sky_tint, 0.12 * sky_a)
  end
  M.glow(W * 0.22, 120, 160, {80, 40, 160}, 0.14)
  M.glow(W * 0.78, 80, 120, {40, 80, 160}, 0.12)
  for i = 0, 110 do
    local sx = (i * 131) % W
    local sy = (i * 47) % (H - 70)
    local tw = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(t * 4 + i))
    M.rect(sx, sy, 2 + i % 2, 2, (i % 7 == 0) and GOLD or {255, 255, 255}, 0.25 + 0.6 * tw)
  end
  -- saucer
  local ux = (t * 70) % (W + 120) - 60
  M.glow(ux, 48, 28, {255, 72, 96}, 0.22)
  M.rect(ux - 22, 44, 44, 8, {255, 72, 96})
  love.graphics.setColor(1, 0.85, 0.3, 0.95)
  love.graphics.ellipse("fill", ux, 42, 16, 8)
  local march = math.sin(t * 1.4) * 18
  for row = 0, 3 do
    for col = 0, 9 do
      local hx = 140 + col * 100 + march * ((row % 2 == 0) and 1 or -1)
      local hy = 110 + row * 52
      M.invader(hx, hy, 1, 1.15, (t + col) % 1, GREEN, GREEN, {255, 255, 220}, {255, 255, 255}, {255, 48, 196})
    end
  end
  for i = 0, 3 do
    local bx = 160 + i * 280
    M.rect(bx, H - 168, 100, 40, GREEN, 0.9)
    M.rect(bx + 32, H - 154, 36, 26, INK, 1)
    M.rect(bx + 8, H - 168, 16, 10, INK, 1)
    M.rect(bx + 76, H - 168, 16, 10, INK, 1)
  end
  M.rect(0, H - 48, W, 6, GREEN, 0.75)
  M.rect(0, H - 42, W, 42, {4, 8, 8}, 0.85)
end

-- Frog pond: moon, cattails, lily pads, fireflies.
function M.pond(t, W, H, sky_tint, sky_a)
  local TOP = {8, 12, 40}
  local MID = {16, 48, 80}
  local WATER = {8, 88, 92}
  local DEEP = {4, 28, 40}
  local PAD = {48, 196, 72}
  local MOON = {255, 244, 200}
  local GOLD = {255, 220, 72}
  local horizon = math.floor(H * 0.40)
  for i = 0, 20 do
    local k = i / 20
    local col = M.mix(TOP, MID, k)
    if sky_tint and (sky_a or 0) > 0.01 then col = M.mix(col, sky_tint, 0.14 * sky_a) end
    M.rect(0, math.floor(horizon * k), W, math.ceil(horizon / 20) + 1, col)
  end
  for i = 0, 40 do
    local sx = (i * 149) % W
    local sy = (i * 37) % math.max(8, horizon - 40)
    M.rect(sx, sy, 2, 2, MOON, 0.25 + 0.4 * (0.5 + 0.5 * math.sin(t * 3 + i)))
  end
  M.glow(W * 0.78, horizon * 0.32, 110, MOON, 0.22)
  love.graphics.setColor(MOON[1] / 255, MOON[2] / 255, MOON[3] / 255, 0.95)
  love.graphics.circle("fill", W * 0.78, horizon * 0.32, 48)
  -- treeline
  for i = 0, 16 do
    local tx = i * 86
    local th = 40 + (i % 4) * 22
    M.rect(tx, horizon - th, 18, th, {8, 28, 16}, 0.95)
    love.graphics.setColor(0.06, 0.22, 0.12, 0.95)
    love.graphics.circle("fill", tx + 9, horizon - th, 22 + (i % 3) * 6)
  end
  for i = 0, 22 do
    local k = i / 22
    M.rect(0, horizon + math.floor((H - horizon) * k), W, math.ceil((H - horizon) / 22) + 1, M.mix(WATER, DEEP, k))
  end
  local scroll = (t * 40) % 36
  for i = 0, 16 do
    local y = horizon + i * 26 - scroll * 0.4
    if y > horizon then M.rect(0, y, W, 2, {180, 255, 220}, 0.08 + 0.08 * (i / 16)) end
  end
  for i = 0, 8 do
    local px = 70 + i * 140
    local py = horizon + 56 + math.sin(t * 2 + i) * 12 + (i % 3) * 36
    love.graphics.setColor(PAD[1] / 255, PAD[2] / 255, PAD[3] / 255, 0.92)
    love.graphics.ellipse("fill", px, py, 52, 20)
    M.rect(px - 7, py - 5, 16, 7, {20, 80, 30}, 0.85)
    M.shot("bubble", px + 30, py - 18 + math.sin(t * 3 + i) * 6, {180, 255, 220}, t + i)
  end
  for i = 0, 10 do
    local rx = 24 + i * 26
    M.rect(rx, horizon - 50 - (i % 4) * 14, 5, 62 + (i % 4) * 14, {20, 70, 32}, 0.92)
    M.rect(rx - 6, horizon - 58 - (i % 4) * 14, 16, 8, {36, 120, 48}, 0.9)
  end
  for i = 0, 8 do
    local fx = 80 + (i * 137 + t * 30) % (W - 80)
    local fy = horizon + 30 + (i * 53) % (H - horizon - 40)
    M.glow(fx, fy, 10, GOLD, 0.22)
    M.rect(fx, fy, 3, 3, GOLD, 0.95)
  end
end

-- Dog yard: sunset hills, picket fence, doghouse, bones.
function M.kennel(t, W, H, sky_tint, sky_a)
  local TOP = {48, 16, 72}
  local MID = {255, 96, 72}
  local DUSK = {255, 176, 88}
  local GRASS = {48, 140, 56}
  local DARK = {16, 64, 28}
  local WOOD = {156, 84, 36}
  local GOLD = {255, 220, 72}
  local CREAM = {255, 236, 196}
  local horizon = math.floor(H * 0.50)
  for i = 0, 24 do
    local k = i / 24
    local col = k < 0.55 and M.mix(TOP, MID, k / 0.55) or M.mix(MID, DUSK, (k - 0.55) / 0.45)
    if sky_tint and (sky_a or 0) > 0.01 then col = M.mix(col, sky_tint, 0.12 * sky_a) end
    M.rect(0, math.floor(horizon * k), W, math.ceil(horizon / 24) + 1, col)
  end
  for i = 0, 40 do
    local sx = (i * 163) % W
    local sy = (i * 41) % math.max(8, horizon - 80)
    local tw = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * 3 + i))
    M.rect(sx, sy, 2, 2, CREAM, 0.25 + 0.5 * tw)
  end
  M.glow(W * 0.78, horizon * 0.38, 110, DUSK, 0.22)
  love.graphics.setColor(1, 0.9, 0.45, 0.95)
  love.graphics.circle("fill", W * 0.78, horizon * 0.38, 44)
  -- far hills
  love.graphics.setColor(0.28, 0.12, 0.28, 1)
  love.graphics.ellipse("fill", W * 0.22, horizon + 10, 260, 70)
  love.graphics.ellipse("fill", W * 0.62, horizon + 8, 320, 80)
  love.graphics.setColor(0.18, 0.22, 0.12, 0.9)
  love.graphics.ellipse("fill", W * 0.88, horizon + 16, 220, 60)
  -- trees
  for i = 0, 5 do
    local tx = 80 + i * 210
    local th = 90 + (i % 3) * 28
    M.rect(tx, horizon - th, 14, th, {72, 40, 20})
    love.graphics.setColor(0.12, 0.38, 0.16, 0.95)
    love.graphics.circle("fill", tx + 7, horizon - th, 36 + (i % 2) * 10)
    love.graphics.circle("fill", tx - 16, horizon - th + 12, 22)
    love.graphics.circle("fill", tx + 28, horizon - th + 10, 22)
  end
  for i = 0, 16 do
    local k = i / 16
    M.rect(0, horizon + math.floor((H - horizon) * k), W, math.ceil((H - horizon) / 16) + 1, M.mix(GRASS, DARK, k))
  end
  -- path
  love.graphics.setColor(0.55, 0.42, 0.22, 0.85)
  love.graphics.polygon("fill", W * 0.42, horizon, W * 0.58, horizon, W * 0.72, H, W * 0.28, H)
  -- picket fence
  for i = 0, 26 do
    local x = 12 + i * 50
    M.rect(x, horizon - 78, 12, 86, WOOD)
    M.rect(x - 4, horizon - 90, 20, 16, {196, 112, 48})
    M.diamond(x + 6, horizon - 94, 10, {196, 112, 48})
  end
  M.rect(12, horizon - 36, W - 24, 10, WOOD)
  M.rect(12, horizon - 64, W - 24, 8, WOOD)
  -- doghouse
  local hx, hy = 150, horizon
  M.rect(hx, hy - 108, 168, 108, {196, 56, 48})
  M.rect(hx + 8, hy - 100, 152, 12, {255, 96, 72}, 0.55)
  love.graphics.setColor(0.42, 0.12, 0.1, 1)
  love.graphics.polygon("fill", hx - 18, hy - 108, hx + 84, hy - 168, hx + 186, hy - 108)
  M.rect(hx + 56, hy - 58, 52, 58, {16, 8, 8})
  M.rect(hx + 70, hy - 150, 10, 28, WOOD)
  M.rect(hx + 62, hy - 128, 26, 10, GOLD)
  -- flowers
  for i = 0, 10 do
    local fx = 360 + i * 72
    local fy = horizon + 28 + (i % 3) * 18
    M.rect(fx, fy - 10, 4, 16, {20, 80, 28})
    M.rect(fx - 4, fy - 16, 12, 10, (i % 2 == 0) and {255, 80, 140} or GOLD)
  end
  for i = 0, 5 do
    local bx = 430 + i * 130
    local by = horizon + 70 + math.sin(t * 3.4 + i) * 10
    M.shot("bone", bx, by, CREAM, t + i)
  end
end

-- Cat alley: night skyline, brick walls, fire escapes, yarn.
function M.alley(t, W, H, sky_tint, sky_a)
  local TOP = {8, 4, 28}
  local MID = {28, 10, 48}
  local BRICK = {148, 52, 56}
  local BRICK2 = {112, 36, 44}
  local MORTAR = {48, 18, 22}
  local GOLD = {255, 200, 80}
  local CREAM = {255, 236, 196}
  local INK = {8, 4, 16}
  local horizon = math.floor(H * 0.28)
  for i = 0, 20 do
    local k = i / 20
    local col = M.mix(TOP, MID, k)
    if sky_tint and (sky_a or 0) > 0.01 then col = M.mix(col, sky_tint, 0.12 * sky_a) end
    M.rect(0, math.floor(horizon * k), W, math.ceil(horizon / 20) + 1, col)
  end
  for i = 0, 50 do
    local sx = (i * 181) % W
    local sy = (i * 47) % math.max(8, horizon - 20)
    local tw = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * 3.1 + i))
    M.rect(sx, sy, 2 + (i % 2), 2, (i % 5 == 0) and GOLD or CREAM, 0.28 + 0.5 * tw)
  end
  M.glow(W * 0.84, horizon * 0.42, 90, GOLD, 0.18)
  love.graphics.setColor(0.95, 0.95, 0.86, 0.92)
  love.graphics.circle("fill", W * 0.84, horizon * 0.42, 38)
  -- distant rooftops
  for i = 0, 10 do
    local bw = 70 + (i % 4) * 28
    local bh = 40 + (i * 23) % 90
    M.rect(i * 120, horizon - bh, bw, bh, (i % 2 == 0) and {24, 10, 36} or {36, 14, 48})
    M.rect(i * 120 + bw * 0.35, horizon - bh - 28, 8, 28, {20, 8, 28})
  end
  -- brick walls
  for row = 0, 16 do
    local oy = horizon + row * 28
    local shift = (row % 2 == 0) and 0 or 22
    for col = 0, 30 do
      M.rect(shift + col * 46, oy, 42, 24, (col + row) % 5 == 0 and BRICK2 or BRICK, 0.92)
      M.rect(shift + col * 46, oy, 42, 2, MORTAR, 0.7)
    end
  end
  -- wet pavement
  M.rect(0, H - 90, W, 90, {18, 10, 24}, 0.92)
  for i = 0, 10 do
    M.rect(0, H - 90 + i * 8, W, 2, GOLD, 0.04 + 0.03 * (i % 3))
  end
  -- windows
  for i = 0, 5 do
    local wx = 70 + i * 210
    M.rect(wx, horizon + 36, 78, 100, INK, 0.95)
    local glow = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(t * 2.6 + i))
    M.rect(wx + 8, horizon + 46, 28, 36, GOLD, glow)
    M.rect(wx + 42, horizon + 46, 28, 36, GOLD, glow * 0.7)
    M.rect(wx + 8, horizon + 90, 28, 36, GOLD, 0.22)
    M.rect(wx + 42, horizon + 90, 28, 36, GOLD, 0.18)
  end
  -- fire escapes
  for i = 0, 2 do
    local fx = 180 + i * 420
    M.rect(fx, horizon + 20, 6, H - horizon - 110, {80, 80, 96}, 0.9)
    M.rect(fx + 70, horizon + 20, 6, H - horizon - 110, {80, 80, 96}, 0.9)
    for r = 0, 4 do
      M.rect(fx, horizon + 40 + r * 70, 76, 6, {120, 120, 140}, 0.9)
    end
  end
  -- laundry
  M.rect(90, horizon + 24, W - 180, 3, CREAM, 0.45)
  for i = 0, 7 do
    local lx = 140 + i * 140
    M.rect(lx, horizon + 26, 18, 36, (i % 2 == 0) and {80, 160, 255} or {255, 96, 160}, 0.85)
  end
  -- cans + yarn
  for i = 0, 3 do
    local cx = 160 + i * 280
    M.rect(cx, H - 150, 58, 78, {88, 88, 96}, 0.95)
    M.rect(cx - 6, H - 162, 70, 16, {168, 168, 176}, 0.9)
    M.rect(cx + 10, H - 140, 16, 20, {40, 40, 48}, 0.8)
    M.shot("yarn", cx + 78, H - 108 + math.sin(t * 5 + i) * 8, {255, 96, 160}, t + i)
  end
end

function M.title_card(t, W, H, spec)
  spec = spec or {}
  local GOLD = {255, 220, 48}
  local PINK = {255, 48, 196}
  local CYAN = {48, 255, 255}
  local CREAM = {255, 244, 220}
  local WHITE = {255, 255, 255}
  local INK = {8, 2, 18}
  local hull = spec.hull or PINK
  M.stage(spec.stage or "arcade", t, W, H, hull, 0.22)
  -- vignette so the marquee pops
  for i = 0, 10 do
    local a = 0.04 + i * 0.035
    M.rect(0, i * 8, W, 8, INK, a)
    M.rect(0, H - 140 + i * 8, W, 10, INK, 0.12 + i * 0.055)
  end
  M.rect(0, 0, 28, H, INK, 0.35)
  M.rect(W - 28, 0, 28, H, INK, 0.35)
  -- cabinet bolts
  local bolt = function(x, y)
    M.rect(x, y, 14, 14, {40, 12, 48}, 0.95)
    M.rect(x + 3, y + 3, 8, 8, GOLD, 0.85)
  end
  bolt(18, 18)
  bolt(W - 32, 18)
  bolt(18, H - 32)
  bolt(W - 32, H - 32)
  -- neon frame
  M.rect(36, 16, W - 72, 6, hull, 0.95)
  M.rect(36, 22, W - 72, 3, CYAN, 0.7)
  M.rect(36, H - 22, W - 72, 6, hull, 0.95)
  M.rect(36, H - 25, W - 72, 3, CYAN, 0.7)
  M.rect(16, 36, 6, H - 72, hull, 0.9)
  M.rect(W - 22, 36, 6, H - 72, hull, 0.9)
  -- orbiting shots
  local shot = spec.shot or "coin"
  for i = 0, 15 do
    local a = t * 1.35 + i * (math.pi * 2 / 16)
    local r = 210 + math.sin(t * 2.4 + i) * 22
    local sx = W / 2 + math.cos(a) * r
    local sy = H * 0.50 + math.sin(a) * r * 0.46
    M.shot(shot, sx, sy, (i % 2 == 0) and GOLD or hull, t + i)
  end
  -- spotlight under the hero
  local bob = math.sin(t * 2.6) * 8
  local hx, hy = W / 2, H * 0.48 + bob
  M.glow(hx, hy + 18, 210, GOLD, 0.16)
  M.glow(hx, hy, 140, hull, 0.22)
  love.graphics.setColor(GOLD[1] / 255, GOLD[2] / 255, GOLD[3] / 255, 0.10)
  love.graphics.ellipse("fill", hx, hy + 78, 160, 28)
  local face = (math.sin(t * 0.85) > 0) and 1 or -1
  local pulse = 0.35 + 0.65 * math.abs(math.sin(t * 5))
  M.hero(spec.hero or "ghost", hx, hy, face, spec.scale or 7.2, pulse, hull, CYAN, CREAM, WHITE, PINK)
  -- marquee title
  local title = spec.title or "ARCADE"
  local sc = 6
  local tw = M.textW(title, sc)
  while tw > W - 160 and sc > 3 do
    sc = sc - 1
    tw = M.textW(title, sc)
  end
  local tx = math.floor((W - tw) / 2)
  local ty = 34
  local th = 18 + 8 * sc
  M.rect(tx - 48, ty - 18, tw + 96, th + 28, INK, 0.78)
  M.rect(tx - 48, ty - 18, tw + 96, 7, hull, 1)
  M.rect(tx - 48, ty + th + 3, tw + 96, 5, CYAN, 0.95)
  -- chasing marquee lights
  for i = 0, 18 do
    local on = ((math.floor(t * 8) + i) % 3) ~= 0
    local lx = tx - 40 + i * math.floor((tw + 80) / 18)
    M.rect(lx, ty - 12, 8, 8, on and GOLD or {80, 40, 12}, on and 1 or 0.45)
    M.rect(lx, ty + th - 2, 8, 8, on and CYAN or {12, 48, 64}, on and 1 or 0.45)
  end
  M.text(title, tx + 5, ty + 7, INK, sc)
  M.text(title, tx + 2, ty + 2, hull, sc, 0.55)
  M.text(title, tx, ty, GOLD, sc)
  -- sparkles around the title
  for i = 0, 10 do
    local sp = 0.4 + 0.6 * math.abs(math.sin(t * 7 + i * 1.7))
    local sx = tx - 30 + (i * 97 + t * 40) % (tw + 60)
    local sy = ty - 8 + (i % 3) * (th * 0.4)
    M.rect(sx, sy, 3, 3, WHITE, sp)
  end
  local tag = spec.tagline or ""
  if tag ~= "" then
    local tsc = 2
    local tgw = M.textW(tag, tsc)
    M.text(tag, math.floor((W - tgw) / 2) + 2, ty + th + 18, INK, tsc)
    M.text(tag, math.floor((W - tgw) / 2), ty + th + 16, CYAN, tsc)
  end
  -- arcade START plate
  local blink = (t % 1.25) < 0.82
  local start = "START"
  local ssc = 5
  local sw = M.textW(start, ssc)
  local sx = math.floor((W - sw) / 2)
  local sy = H - 108
  M.rect(sx - 40, sy - 18, sw + 80, 78, INK, 0.82)
  M.rect(sx - 40, sy - 18, sw + 80, 6, hull, 1)
  M.rect(sx - 40, sy + 54, sw + 80, 6, CYAN, 0.95)
  M.rect(sx - 34, sy - 8, sw + 68, 56, {28, 8, 36}, 0.95)
  if blink then
    M.glow(W / 2, sy + 22, 90, GOLD, 0.18)
    M.text(start, sx + 4, sy + 8, INK, ssc)
    M.text(start, sx, sy + 4, GOLD, ssc)
  end
end

-- Aladdin: arcade pixel — fez, vest, pants, short flute, flying carpet.
function M.aladdin(cx, cy, facing, scale, pulse, hull, CYAN, CREAM, WHITE, PINK)
  local s = 4.4 * (scale or 3)
  local f = (facing or 1) >= 0 and 1 or -1
  local bob = math.sin((pulse or 0) * 5.5) * 0.07 * s
  cy = cy + bob
  hull = hull or {196, 48, 88}
  local skin = {255, 204, 156}
  local gold = {255, 212, 72}
  local pants = CREAM or {255, 244, 220}
  local sash = {255, 188, 48}
  local ink = {28, 12, 18}
  local hair = {36, 16, 20}
  local fez = {216, 40, 52}
  local tassel = {88, 28, 120}
  local rug_in = {255, 96, 72}

  M.glow(cx, cy + 0.4 * s, s * 2.6, gold, 0.14)

  -- flying carpet under the seat
  local rug_y = cy + 0.32 * s
  M.rect(cx - 1.55 * s, rug_y, 3.10 * s, 0.34 * s, hull)
  M.rect(cx - 1.40 * s, rug_y + 0.07 * s, 2.80 * s, 0.20 * s, rug_in)
  M.rect(cx - 1.55 * s, rug_y, 3.10 * s, 0.05 * s, gold)
  M.rect(cx - 1.55 * s, rug_y + 0.29 * s, 3.10 * s, 0.05 * s, gold)
  M.rect(cx - 1.68 * s, rug_y + 0.10 * s, 0.16 * s, 0.14 * s, hull)
  M.rect(cx + 1.52 * s, rug_y + 0.10 * s, 0.16 * s, 0.14 * s, hull)
  M.diamond(cx, rug_y + 0.16 * s, 0.10 * s, gold)
  for i = 0, 2 do
    M.rect(cx - 1.40 * s + i * 0.12 * s, rug_y + 0.34 * s, 0.06 * s, 0.12 * s, gold)
    M.rect(cx + 1.08 * s + i * 0.12 * s, rug_y + 0.34 * s, 0.06 * s, 0.12 * s, gold)
  end

  -- hips and lotus legs sit ON the rug
  M.rect(cx - 0.46 * s, rug_y - 0.16 * s, 0.92 * s, 0.22 * s, pants)
  M.rect(cx - 1.12 * s, rug_y - 0.08 * s, 0.80 * s, 0.22 * s, pants)
  M.rect(cx + 0.32 * s, rug_y - 0.04 * s, 0.80 * s, 0.22 * s, pants)
  M.rect(cx - 0.12 * s, rug_y + 0.06 * s, 0.72 * s, 0.16 * s, pants)
  M.rect(cx - 0.62 * s, rug_y + 0.14 * s, 0.72 * s, 0.14 * s, pants)
  M.rect(cx + 0.46 * s, rug_y + 0.06 * s, 0.32 * s, 0.12 * s, gold)
  M.rect(cx + 0.72 * s, rug_y + 0.02 * s, 0.14 * s, 0.10 * s, gold)
  M.rect(cx - 0.86 * s, rug_y + 0.14 * s, 0.32 * s, 0.12 * s, gold)
  M.rect(cx - 0.98 * s, rug_y + 0.10 * s, 0.14 * s, 0.10 * s, gold)

  -- torso + open vest + sash
  M.rect(cx - 0.36 * s, cy - 0.22 * s, 0.72 * s, 0.50 * s, skin)
  M.rect(cx - 0.52 * s, cy - 0.24 * s, 0.22 * s, 0.56 * s, hull)
  M.rect(cx + 0.30 * s, cy - 0.24 * s, 0.22 * s, 0.56 * s, hull)
  M.rect(cx - 0.52 * s, cy + 0.22 * s, 1.04 * s, 0.13 * s, sash)
  M.rect(cx - 0.08 * s, cy + 0.22 * s, 0.16 * s, 0.13 * s, gold)

  -- back arm
  M.rect(cx - f * 0.70 * s, cy - 0.04 * s, 0.28 * s, 0.20 * s, skin)

  -- head + hair
  love.graphics.setColor(skin[1] / 255, skin[2] / 255, skin[3] / 255, 1)
  love.graphics.circle("fill", cx, cy - 0.60 * s, 0.38 * s)
  M.rect(cx - 0.36 * s, cy - 0.90 * s, 0.72 * s, 0.20 * s, hair)
  M.rect(cx - 0.40 * s, cy - 0.76 * s, 0.14 * s, 0.26 * s, hair)
  M.rect(cx + 0.26 * s, cy - 0.76 * s, 0.14 * s, 0.26 * s, hair)

  -- fez
  M.rect(cx - 0.26 * s, cy - 1.20 * s, 0.52 * s, 0.30 * s, fez)
  M.rect(cx - 0.20 * s, cy - 1.28 * s, 0.40 * s, 0.10 * s, fez)
  M.rect(cx - 0.30 * s, cy - 0.94 * s, 0.60 * s, 0.09 * s, gold)
  M.rect(cx + 0.24 * s, cy - 1.24 * s, 0.08 * s, 0.32 * s, tassel)
  M.rect(cx + 0.18 * s, cy - 0.94 * s, 0.16 * s, 0.09 * s, tassel)

  -- eyes + smile
  M.rect(cx - 0.22 * s + f * 0.06 * s, cy - 0.68 * s, 0.18 * s, 0.16 * s, WHITE)
  M.rect(cx + 0.06 * s + f * 0.06 * s, cy - 0.68 * s, 0.18 * s, 0.16 * s, WHITE)
  M.rect(cx - 0.14 * s + f * 0.10 * s, cy - 0.62 * s, 0.08 * s, 0.10 * s, ink)
  M.rect(cx + 0.14 * s + f * 0.10 * s, cy - 0.62 * s, 0.08 * s, 0.10 * s, ink)
  M.rect(cx - 0.08 * s, cy - 0.42 * s, 0.16 * s, 0.06 * s, hull)

  -- short flute
  M.rect(cx + f * 0.22 * s - (f < 0 and 0.26 * s or 0), cy - 0.40 * s, 0.26 * s, 0.14 * s, skin)
  local fx, fy, fw = cx + f * 0.30 * s, cy - 0.48 * s, 0.46 * s
  M.rect(f >= 0 and fx or (fx - fw), fy, fw, 0.08 * s, gold)
  M.rect(fx + f * 0.34 * s - (f < 0 and 0.08 * s or 0), fy - 0.05 * s, 0.08 * s, 0.14 * s, gold)
  M.rect(fx + f * 0.10 * s - (f < 0 and 0.04 * s or 0), fy + 0.02 * s, 0.04 * s, 0.04 * s, ink)
  M.rect(fx + f * 0.22 * s - (f < 0 and 0.04 * s or 0), fy + 0.02 * s, 0.04 * s, 0.04 * s, ink)
end

return M
