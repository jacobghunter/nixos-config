return {
	-- Treesitter: proper Nix syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "nix" })
		end,
	},

	-- LSP: nixd, provided by Nix (extraPackages) - no mason install needed
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nixd = {},
			},
		},
	},

	-- Formatter: deadnix (removes dead code) + statix (fixes antipatterns) on
	-- save, then nixfmt last so it cleans up whatever those two touched.
	-- Both edit the file in place rather than via stdin/stdout, hence stdin = false.
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				statix = {
					command = "statix",
					args = { "fix", "$FILENAME" },
					stdin = false,
				},
				deadnix = {
					command = "deadnix",
					args = { "--edit", "$FILENAME" },
					stdin = false,
				},
			},
			formatters_by_ft = {
				nix = { "deadnix", "statix", "nixfmt" },
			},
		},
	},

	-- Linters: statix (antipatterns) + deadnix (dead code), run on save/insert-leave
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				nix = { "statix", "deadnix" },
			},
		},
	},
}
