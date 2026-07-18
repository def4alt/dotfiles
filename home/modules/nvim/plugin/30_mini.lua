require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

require("mini.notify").setup()
require("mini.starter").setup()

local statusline = require("mini.statusline")
statusline.setup({
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 0 })
      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineFilename", strings = { "%t%m" } },
        "%=",
        { hl = mode_hl, strings = { "%l:%c" } },
      })
    end,
  },
  use_icons = false,
})

local blink = require("blink.cmp")
blink.setup({
  appearance = {
    nerd_font_variant = "mono",
    use_nvim_cmp_as_default = false,
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
    list = { selection = { auto_insert = true, preselect = false } },
    menu = {
      draw = {
        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
      },
    },
  },
  fuzzy = { implementation = "lua" },
  keymap = {
    preset = "enter",
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<Tab>"] = { "insert_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "insert_prev", "snippet_backward", "fallback" },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
})
vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })

local ai = require("mini.ai")
ai.setup({
  custom_textobjects = {
    F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
  },
  search_method = "cover",
})

local clue = require("mini.clue")
clue.setup({
  clues = {
    Config.leader_clues,
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows({ submode_resize = true }),
    clue.gen_clues.z(),
  },
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "x", keys = "'" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "s" },
    { mode = "x", keys = "s" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  window = { delay = 300 },
})

require("mini.comment").setup()
require("mini.diff").setup()
require("mini.git").setup()

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("mini.pairs").setup()
require("mini.surround").setup()
