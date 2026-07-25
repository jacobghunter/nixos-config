return {
	-- LazyVim's official Rust extra: rustaceanvim (LSP extensions, runnables,
	-- hover actions) + rust-analyzer + rustfmt wiring, all in one import.
	-- rust-analyzer/rustfmt/clippy are provided by Nix (extraPackages above).
	{ import = "lazyvim.plugins.extras.lang.rust" },
}
