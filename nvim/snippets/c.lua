local luasnip = require("luasnip")
local snippet = luasnip.snippet
local text_node = luasnip.text_node
local insert_node = luasnip.insert_node
local dynamic_node = luasnip.dynamic_node
local choice_node = luasnip.choice_node
local function_node = luasnip.function_node
local snippet_node = luasnip.snippet_node
local fmta = require("luasnip.extras.fmt").fmta

-- Helper function to get filename without extension
local function get_filename()
	local filename = vim.fn.expand("%:t")
	return filename ~= "" and filename or "filename.h"
end

-- Helper function to get header guard name
local function get_header_guard()
	local filename = vim.fn.expand("%:t:r") -- filename without extension
	if filename == "" then
		return "FILENAME"
	end
	return filename:upper()
end

-- Helper function to get current date
local function get_date()
	return os.date("%Y-%m-%d")
end

-- Helper function to get author (you can customize this)
-- Helper function to get author from git config
local function get_author()
	-- Try to get git user name first
	local git_name = vim.fn.system("git config --get user.name"):gsub("\n", "")

	-- If git command succeeded and returned a name
	if vim.v.shell_error == 0 and git_name ~= "" then
		return git_name
	end

	-- Fallback to system username or default
	return vim.fn.expand("$USER") or "Author Name"
end

return {
	snippet(
		{
			trig = "main ",
			snippetType = "autosnippet",
		},
		fmta("int main() {\n\t<>\n\treturn 0;\n}", {
			insert_node(1),
		})
	),

	snippet(
		{
			trig = "maina ",
			snippetType = "autosnippet",
		},
		fmta("int main(int argc, char *argv[]) {\n\t<>\n\treturn 0;\n}", {
			insert_node(1),
		})
	),

	snippet(
		"if",
		fmta("if (<>) {\n\t<>\n}", {
			insert_node(1, "condition"),
			insert_node(2, "// TODO"),
		})
	),

	snippet({
		trig = "switch(%d+) ",
		regTrig = true,
		snippetType = "autosnippet",
	}, {
		text_node("switch ("),
		insert_node(1, "expression"),
		text_node({ ") {", "" }),
		dynamic_node(2, function(args, snip)
			local nodes = {}
			local num_cases = tonumber(snip.captures[1]) or 1

			for i = 1, num_cases do
				table.insert(nodes, text_node({ "\tcase " }))
				table.insert(nodes, insert_node(i * 2 + 1, tostring(i)))
				table.insert(nodes, text_node({ ":", "\t\t" }))
				table.insert(nodes, insert_node(i * 2 + 2, "// TODO"))
				table.insert(nodes, text_node({ "\t\tbreak;", "" }))
			end

			table.insert(nodes, text_node({ "\tdefault:", "\t\t" }))
			table.insert(nodes, insert_node(num_cases * 2 + 3, "// TODO"))
			table.insert(nodes, text_node({ "\t\tbreak;", "}" }))

			return snippet_node(nil, nodes)
		end),
	}),

	snippet(
		{
			trig = "H ",
			snippetType = "autosnippet",
		},
		fmta(
			[[/**
 ********************************************************************************
 * @file    <>
 * @author  <>
 * @date    <>
 * @brief   <>
 ********************************************************************************
 */

#ifndef <>_H
#define <>_H

<>

#endif // !<>_H]],
			{
				function_node(get_filename),
				function_node(get_author),
				function_node(get_date),
				insert_node(1, "brief description"),
				function_node(get_header_guard),
				function_node(get_header_guard),
				insert_node(2),
				function_node(get_header_guard),
			}
		)
	),
}
