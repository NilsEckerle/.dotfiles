local luasnip = require("luasnip")
local snippet = luasnip.snippet
local text_node = luasnip.text_node
local insert_node = luasnip.insert_node
local dynamic_node = luasnip.dynamic_node
local choice_node = luasnip.choice_node
local snippet_node = luasnip.snippet_node
local fmta = require("luasnip.extras.fmt").fmta
local function_node = luasnip.function_node

return {
  snippet({
    trig = "main ",
    snippetType = "autosnippet"
  }, fmta("int main() {\n\t<>\n\treturn 0;\n}", {
    insert_node(1)
  })),

}
