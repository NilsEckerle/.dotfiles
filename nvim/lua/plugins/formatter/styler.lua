return {
	styler = {
		command = "R",
		args = {
			"--slave",
			"--no-restore",
			"--no-save",
			"-e",
			"styler::style_file(commandArgs(TRUE)[[1]])",
			"--args",
			"$FILENAME",
		},
		stdin = false,
	},
}
