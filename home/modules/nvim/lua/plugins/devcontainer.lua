return {
	{
		"https://codeberg.org/esensar/nvim-dev-container",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = {
			"DevcontainerStart",
			"DevcontainerAttach",
			"DevcontainerExec",
			"DevcontainerStop",
			"DevcontainerStopAll",
			"DevcontainerRemoveAll",
			"DevcontainerLogs",
			"DevcontainerEditNearestConfig",
		},
		config = function()
			require("devcontainer").setup({
				generate_commands = true,
			})
		end,
	},
}
