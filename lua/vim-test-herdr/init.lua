local M = {}

local pane_id

local function run(args)
  local output = vim.fn.system(args)
  return output, vim.v.shell_error
end

function M.run(cmd)
  if vim.env.HERDR_ENV ~= "1" then
    vim.notify("vim-test-herdr: HERDR_ENV is not set", vim.log.levels.ERROR)
    return
  end

  if pane_id then
    local _, status = run({ "herdr", "pane", "get", pane_id })
    if status ~= 0 then
      pane_id = nil
    end
  end

  if not pane_id then
    local output, status = run({
      "herdr",
      "pane",
      "split",
      "--current",
      "--direction",
      "down",
      "--cwd",
      vim.fn.getcwd(),
      "--no-focus",
    })

    if status ~= 0 then
      vim.notify("vim-test-herdr: failed to split pane\n" .. output, vim.log.levels.ERROR)
      return
    end

    local ok, data = pcall(vim.json.decode, output)
    pane_id = ok and data and data.result and data.result.pane and data.result.pane.pane_id
    if not pane_id then
      vim.notify("vim-test-herdr: unexpected pane split output\n" .. output, vim.log.levels.ERROR)
      return
    end
  end

  if vim.g["test#preserve_screen"] == 0 then
    run({ "herdr", "pane", "send-text", pane_id, "clear\n" })
  end

  run({ "herdr", "pane", "run", pane_id, cmd })
end

function M.close()
  if pane_id then
    run({ "herdr", "pane", "close", pane_id })
    pane_id = nil
  end
end

function M.setup()
  vim.cmd([[
    function! HerdrStrategy(cmd) abort
      call luaeval("require('vim-test-herdr').run(_A) or true", a:cmd)
    endfunction

    let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
    let g:test#custom_strategies.herdr = function('HerdrStrategy')
  ]])
  vim.api.nvim_create_user_command("HerdrCloseRunner", M.close, {})
end

return M
