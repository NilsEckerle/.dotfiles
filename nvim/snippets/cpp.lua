local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node

-- Configure your copyright info here.
local copyright = {
	name = "Nils Eckerle",
	year = "2026",
	license = "MIT",
}
-- Set to false to disable copyright notices entirely
local copyright_enabled = true

local copyright_header = function(c)
	return {
		"// Copyright (c) " .. c.year .. " " .. c.name .. " (" .. c.license .. " License)",
		"",
	}
end

local copyright_footer = function(c)
	return {
		"",
		"// " .. c.license .. " License",
		"//",
		"// Copyright (c) " .. c.year .. " " .. c.name,
		"//",
		"// Permission is hereby granted, free of charge, to any person obtaining a copy",
		'// of this software and associated documentation files (the "Software"), to deal',
		"// in the Software without restriction, including without limitation the rights",
		"// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
		"// copies of the Software, and to permit persons to whom the Software is",
		"// furnished to do so, subject to the following conditions:",
		"//",
		"// The above copyright notice and this permission notice shall be included in all",
		"// copies or substantial portions of the Software.",
		"//",
		'// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
		"// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,",
		"// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE",
		"// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER",
		"// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,",
		"// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE",
		"// SOFTWARE.",
	}
end

ls.add_snippets("cpp", {
	s("ifndefc", {
		f(function()
			local guard = vim.fn.expand("%:t:r"):upper() .. "_H"
			local lines = {}

			if copyright_enabled then
				for _, line in ipairs(copyright_header(copyright)) do
					table.insert(lines, line)
				end
			end

			table.insert(lines, "#ifndef " .. guard)
			table.insert(lines, "#define " .. guard)
			table.insert(lines, "")

			return lines
		end, {}),
		i(0),
		f(function()
			local guard = vim.fn.expand("%:t:r"):upper() .. "_H"
			local lines = { "" }

			table.insert(lines, "")
			table.insert(lines, "#endif // !" .. guard)

			-- INSERT COPYRIGHT FOOT
			-- if copyright_enabled then
			-- 	for _, line in ipairs(copyright_footer(copyright)) do
			-- 		table.insert(lines, line)
			-- 	end
			-- end

			return lines
		end, {}),
	}),

	s("copyhead", {
		f(function()
			if not copyright_enabled then
				return {}
			end
			return copyright_header(copyright)
		end, {}),
		i(0),
	}),

	s("copyfoot", {
		f(function()
			if not copyright_enabled then
				return {}
			end
			return copyright_footer(copyright)
		end, {}),
		i(0),
	}),
})
