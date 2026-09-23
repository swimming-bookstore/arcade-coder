-- Neon cabinet palette / stage size for Arcade Coder.
local T = {
  W = 1280,
  H = 720,
  VOID = {8, 2, 22},
  NAVY = {28, 6, 58},
  SKY_RUST = {255, 72, 168},
  SKY_GO = {48, 255, 208},
  SKY_CPP = {96, 168, 255},
  SKY_PY = {255, 224, 48},
  COIN = {255, 220, 48},
  CYAN = {48, 255, 255},
  PINK = {255, 48, 196},
  CREAM = {255, 244, 220},
  INK = {10, 2, 18},
  GRASS = {48, 255, 128},
  BRICK = {255, 56, 88},
  DIM = {148, 108, 176},
  GUTTER = {32, 8, 56},
  WELL = {8, 2, 18},
  WHITE = {255, 255, 255},
  TERM = {4, 0, 14},
}

T.SKY_BY_LANG = {
  RUST = T.SKY_RUST,
  GO = T.SKY_GO,
  ["C++"] = T.SKY_CPP,
  PYTHON = T.SKY_PY,
  SH = T.SKY_GO,
}

T.TOOL_COL = {
  READ = T.CYAN,
  WRITE = T.GRASS,
  EDIT = T.COIN,
  BASH = T.PINK,
}

T.LANG_BY_EXT = {
  rs = "RUST",
  go = "GO",
  cpp = "C++",
  py = "PYTHON",
  md = "MD",
  json = "JSON",
  html = "HTML",
  sh = "SH",
}

return T
