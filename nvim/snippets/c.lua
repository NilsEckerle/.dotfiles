local luasnip = require("luasnip")
local snippet = luasnip.snippet
local text_node = luasnip.text_node
local insert_node = luasnip.insert_node
local dynamic_node = luasnip.dynamic_node
local choice_node = luasnip.choice_node
local snippet_node = luasnip.snippet_node
local fmta = require("luasnip.extras.fmt").fmta

return {
  snippet({
    trig = "main ",
    snippetType = "autosnippet"
  }, fmta("int main() {\n\t<>\n\treturn 0;\n}", {
    insert_node(1)
  })),

  snippet({
    trig = "maina ",
    snippetType = "autosnippet"
  }, fmta("int main(int argc, char *argv[]) {\n\t<>\n\treturn 0;\n}", {
    insert_node(1)
  })),

  snippet("if", fmta("if (<>) {\n\t<>\n}", {
    insert_node(1, "condition"),
    insert_node(2, "// TODO")
  })),

  snippet({
    trig = "switch(%d+) ",
    regTrig = true,
    snippetType = "autosnippet"
  }, {
    text_node("switch ("),
    insert_node(1, "expression"),
    text_node({") {", ""}),
    dynamic_node(2, function(args, snip)
      local nodes = {}
      local num_cases = tonumber(snip.captures[1]) or 1

      for i = 1, num_cases do
        table.insert(nodes, text_node({"\tcase "}))
        table.insert(nodes, insert_node(i * 2 + 1, tostring(i)))
        table.insert(nodes, text_node({":", "\t\t"}))
        table.insert(nodes, insert_node(i * 2 + 2, "// TODO"))
        table.insert(nodes, text_node({"\t\tbreak;", ""}))
      end

      table.insert(nodes, text_node({"\tdefault:", "\t\t"}))
      table.insert(nodes, insert_node(num_cases * 2 + 3, "// TODO"))
      table.insert(nodes, text_node({"\t\tbreak;", "}"}))

      return snippet_node(nil, nodes)
    end),
  }),
}

