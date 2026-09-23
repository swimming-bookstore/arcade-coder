-- Arcade Coder pad: chalkboard + kit hero.
--
--     local pad = require("pad")
--     local demo = pad.Demo.new({ kit = "ghost" })  -- ghost | invader | frog | ship | dog | cat | aladdin
--     pad.kit.register({ name = "slime", hero = "frog", shot = "bubble", courier = true })
--     pad.client.apply(demo, event, { name = "Arcade Coder", callsign = "ARCADE" })
--
local demo = require("pad.demo")
local theme = require("pad.theme")
local client = require("pad.client")
local kit = require("pad.kit")

return {
  Demo = demo.Demo,
  W = theme.W,
  H = theme.H,
  VOID = theme.VOID,
  CREAM = theme.CREAM,
  COIN = theme.COIN,
  CYAN = theme.CYAN,
  INK = theme.INK,
  DIM = theme.DIM,
  PINK = theme.PINK,
  theme = theme,
  client = client,
  kit = kit,
}
