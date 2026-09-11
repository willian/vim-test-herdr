#!/usr/bin/env sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
env -u HERDR_ENV nvim --clean --headless --cmd "set rtp^=$repo" \
  '+runtime plugin/vim-test-herdr.lua' \
  '+lua assert(vim.fn.exists("*HerdrStrategy") == 1); assert(vim.fn.exists(":HerdrCloseRunner") == 2); assert(vim.g["test#custom_strategies"].herdr)' \
  '+silent! call call(g:test#custom_strategies.herdr, ["true"])' \
  +qa
