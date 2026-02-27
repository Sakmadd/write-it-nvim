---@class WriteItConfig
---@field highlights table<string, any>
---@field preprocess table<string, boolean>
---@field keymaps table<string, string>

local M = {}

---@type WriteItConfig
M.defaults = {
  highlights = {
    passed = "Normal",
    error = "ErrorMsg",
    cursor = "CursorLine",
    pending = "Comment",
    hidden = { fg = "bg" }
  },
  preprocess = {
    remove_comments = true,
    remove_empty_lines = true
  },
  keymaps = {
    start = "<leader>wp",
    reset = "<Esc>",
    stop = "<C-S-Esc>",
    delete_word = "<C-BS>"
  }
}

---@type WriteItConfig
M.options = {}

---Setup configuration
---@param opts WriteItConfig|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
