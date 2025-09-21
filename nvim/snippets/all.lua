local luasnip = require("luasnip")
local snippet = luasnip.snippet
local text_node = luasnip.text_node

return {
  -- lowercase
  snippet({trig = "ae", wordTrig = false}, text_node("ä")),
  snippet({trig = "oe", wordTrig = false}, text_node("ö")),
  snippet({trig = "ue", wordTrig = false}, text_node("ü")),
  snippet({trig = "ss", wordTrig = false}, text_node("ß")),

  -- uppercase
  snippet({trig = "Ae", wordTrig = false}, text_node("Ä")),
  snippet({trig = "Oe", wordTrig = false}, text_node("Ö")),
  snippet({trig = "Ue", wordTrig = false}, text_node("Ü")),
}
