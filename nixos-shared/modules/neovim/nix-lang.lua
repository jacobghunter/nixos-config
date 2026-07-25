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

	-- Formatter: nixfmt on save
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
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
