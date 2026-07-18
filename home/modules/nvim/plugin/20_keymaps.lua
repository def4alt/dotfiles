local map = vim.keymap.set
local nmap = function(keys, action, desc)
  map("n", keys, action, { desc = desc })
end
local leader = function(keys, action, desc)
  nmap("<Leader>" .. keys, action, desc)
end
local xleader = function(keys, action, desc)
  map("x", "<Leader>" .. keys, action, { desc = desc })
end

Config.leader_clues = {
  { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
  { mode = "n", keys = "<Leader>f", desc = "+Find" },
  { mode = "n", keys = "<Leader>g", desc = "+Git" },
  { mode = "n", keys = "<Leader>c", desc = "+Code" },
  { mode = "x", keys = "<Leader>g", desc = "+Git" },
  { mode = "x", keys = "<Leader>c", desc = "+Code" },
}

nmap("<Esc>", "<Cmd>nohlsearch<CR>", "Clear search")
map("n", "q", function()
  if vim.fn.getcmdwintype() ~= "" then
    return "<C-c>"
  end
  if vim.bo.buftype ~= "" or vim.api.nvim_win_get_config(0).relative ~= "" then
    return "<Cmd>close<CR>"
  end
  return "q"
end, { expr = true, desc = "Close dialog or record macro" })
nmap("<C-h>", "<C-w>h", "Window left")
nmap("<C-j>", "<C-w>j", "Window down")
nmap("<C-k>", "<C-w>k", "Window up")
nmap("<C-l>", "<C-w>l", "Window right")
nmap("[b", "<Cmd>bprevious<CR>", "Previous buffer")
nmap("]b", "<Cmd>bnext<CR>", "Next buffer")
map({ "n", "x" }, "gy", '"+y', { desc = "Copy clipboard" })
map({ "n", "x" }, "gp", '"+p', { desc = "Paste clipboard" })
leader("y", '"+y', "Yank clipboard")
xleader("y", '"+y', "Yank clipboard")
leader("ba", "<Cmd>b#<CR>", "Alternate")
leader("bd", "<Cmd>bdelete<CR>", "Delete")
leader("bD", "<Cmd>bdelete!<CR>", "Delete!")
leader("bs", function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end, "Scratch")
leader("bw", "<Cmd>bwipeout<CR>", "Wipeout")

leader("e", "<Cmd>Oil<CR>", "Explorer")

leader("fb", "<Cmd>FzfLua buffers<CR>", "Buffers")
leader("fd", "<Cmd>FzfLua diagnostics_workspace<CR>", "Diagnostics workspace")
leader("fD", "<Cmd>FzfLua diagnostics_document<CR>", "Diagnostics buffer")
leader("ff", "<Cmd>FzfLua files<CR>", "Files")
leader("fg", "<Cmd>FzfLua live_grep<CR>", "Grep live")
leader("fG", "<Cmd>FzfLua grep_cword<CR>", "Grep word")
leader("fh", "<Cmd>FzfLua help_tags<CR>", "Help")
leader("fl", "<Cmd>FzfLua lines<CR>", "Lines")
leader("fr", "<Cmd>FzfLua resume<CR>", "Resume")
leader("fR", "<Cmd>FzfLua lsp_references<CR>", "References")
leader("fs", "<Cmd>FzfLua lsp_live_workspace_symbols<CR>", "Symbols workspace")
leader("fS", "<Cmd>FzfLua lsp_document_symbols<CR>", "Symbols document")

leader("ga", "<Cmd>Git diff --cached<CR>", "Added diff")
leader("gc", "<Cmd>Git commit<CR>", "Commit")
leader("gd", "<Cmd>Git diff<CR>", "Diff")
leader("gl", [[<Cmd>Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order<CR>]], "Log")
leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")
leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")
xleader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

leader("ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Actions")
leader("cd", "<Cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostic")
leader("cf", '<Cmd>lua require("conform").format({ async = true })<CR>', "Format")
leader("ch", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
leader("ci", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation")
leader("cr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
leader("cR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
leader("cs", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definition")
leader("ct", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Type definition")
xleader("cf", '<Cmd>lua require("conform").format({ async = true })<CR>', "Format selection")

leader("m", function()
  require("miniharp").toggle_file()
end, "Toggle mark")
nmap("<C-n>", function()
  require("miniharp").next()
end, "Next mark")
nmap("<C-p>", function()
  require("miniharp").prev()
end, "Previous mark")
leader("l", function()
  require("miniharp").show_list()
end, "Marks list")
for index = 1, 9 do
  local mark = index
  leader(tostring(mark), function()
    require("miniharp").go_to(mark)
  end, "Mark " .. mark)
end
