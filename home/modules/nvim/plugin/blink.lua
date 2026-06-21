-- Autocompletion: blink.cmp

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
    },
    menu = {
      draw = {
        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
      },
    },
  },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },
})
