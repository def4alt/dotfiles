return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	keys = function()
		local keys = {
			{
				"<leader>H",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon File",
			},
			{
				"<leader>h",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon Quick Menu",
			},
		}

		-- Only bind 1 through 9
		for i = 1, 9 do
			table.insert(keys, {
				"<leader>" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Harpoon to File " .. i,
			})
		end
		return keys
	end,
	-- LazyVim's extra also defines <leader>9 for harpoon.
	-- We have to explicitly nuke it after loading since specs get merged.
	init = function()
		-- Wrap in VimEnter so it runs after all keymaps are set up
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				-- Remove harpoon's <leader>9 mapping
				pcall(vim.keymap.del, "n", "<leader>9")
			end,
		})
	end,
}
