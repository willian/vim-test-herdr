if vim.g.loaded_vim_test_herdr then
  return
end
vim.g.loaded_vim_test_herdr = true

require("vim-test-herdr").setup()
