# vim-test-herdr

A [vim-test](https://github.com/vim-test/vim-test) strategy that runs tests in a Herdr pane.

Requires Vim or Neovim, the `herdr` CLI, and a Herdr session (`HERDR_ENV=1`).

## Configuration

For Neovim (LazyVim):

```lua
{
  "vim-test/vim-test",
  dependencies = {
    "willian/vim-test-herdr",
  },
  keys = {
    { "<leader>tc", "<CMD>HerdrCloseRunner<CR>", desc = "Close test runner pane" },
  },
  config = function()
    vim.g["test#strategy"] = "herdr"
  end,
}
```

For Vim:

```vim
let g:test#strategy = 'herdr'
nnoremap <leader>tc <Cmd>HerdrCloseRunner<CR>
```

`HerdrCloseRunner` closes the pane created for test runs.

## Using with a fallback strategy (Vimux)

Use Herdr inside a Herdr session and [Vimux](https://github.com/preservim/vimux) otherwise.

For Neovim with LazyVim:

```lua
{
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
    "willian/vim-test-herdr",
  },
  keys = {
    {
      "<leader>vq",
      function()
        vim.cmd(vim.env.HERDR_ENV == "1" and "HerdrCloseRunner" or "VimuxCloseRunner")
      end,
      desc = "Close test runner pane",
    },
  },
  config = function()
    vim.g["test#strategy"] = vim.env.HERDR_ENV == "1" and "herdr" or "vimux"
  end,
}
```

For Vim:

```vim
if $HERDR_ENV ==# '1'
  let g:test#strategy = 'herdr'
  nnoremap <leader>vq :HerdrCloseRunner<CR>
else
  let g:test#strategy = 'vimux'
  nnoremap <leader>vq :VimuxCloseRunner<CR>
endif
```
