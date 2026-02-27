-- Prevent loading the plugin twice
if vim.g.loaded_write_it_nvim then
  return
end
vim.g.loaded_write_it_nvim = 1

-- Ensure setup() is called
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if not vim.g.write_it_nvim_setup_done then
      vim.notify(
        'write-it-nvim: Call require("write-it-nvim").setup() in your config',
        vim.log.levels.WARN
      )
    end
  end
})
