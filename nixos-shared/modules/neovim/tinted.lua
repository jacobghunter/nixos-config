return {
	{
		"tinted-theming/tinted-nvim",
		priority = 1000,
		lazy = false,
		opts = {
			default_scheme = "base16-ayu-dark", -- fallback; irrelevant once selector is wired to tinty
			selector = {
				enabled = true,
				mode = "file",
				path = "~/.cache/tinted-nvim-current-scheme",
				watch = true,
			},
		},
	},
}
