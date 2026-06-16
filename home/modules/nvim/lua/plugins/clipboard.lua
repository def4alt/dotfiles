-- OSC 52 clipboard for SSH (no X display needed)
-- Sends clipboard via terminal escape sequence through SSH/tmux
-- Requirements:
--   Tmux: set -g set-clipboard on
--   iTerm2: Settings > General > Selection > "Applications in terminal may access clipboard"
--   kitty: allow_remote_control and clipboard yes

local function write_osc52(text)
  if not text or #text == 0 then
    return
  end
  local encoded = vim.base64.encode(text)
  local seq = string.format("\027]52;c;%s\007", encoded)

  if vim.fn.filewritable("/dev/fd/2") == 1 then
    vim.fn.writefile({seq}, "/dev/fd/2", "b")
  else
    local ok, err = pcall(vim.fn.chansend, vim.v.stderr, seq)
    if not ok or err == nil or err <= 0 then
      io.stderr:write(seq)
      io.stderr:flush()
    end
  end
end

return {
  {
    "LazyVim/LazyVim",
    init = function()
      -- Only set + register for OSC 52 (system clipboard over SSH)
      -- * register (primary selection) and "" register (internal) stay default
      vim.g.clipboard = {
        name = "OSC52",
        copy = {
          ["+"] = function(lines, _)
            if lines and #lines > 0 then
              write_osc52(table.concat(lines, "\n"))
            end
          end,
        },
        paste = {
          ["+"] = function()
            return {}
          end,
        },
      }
    end,
  },
}
