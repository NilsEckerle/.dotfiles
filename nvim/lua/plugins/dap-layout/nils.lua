return {
	layouts = {
		-- Left side: Watches, Scopes
		{
			elements = {
				{ id = "watches", size = 0.3 },
				{ id = "scopes", size = 0.7 },
			},
			size = 80,
			position = "left",
		},
		-- Right side: Stacks
		{
			elements = {
				{ id = "stacks", size = 1.0 },
			},
			size = 30,
			position = "right",
		},
		-- Bottom: Console, REPL, Breakpoints (small)
		{
			elements = {
				{ id = "breakpoints", size = 0.2 },
				{ id = "repl", size = 0.4 },
				{ id = "console", size = 0.4 },
			},
			size = 10,
			position = "bottom",
		},
	},
}
