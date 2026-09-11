if exists('g:loaded_vim_test_herdr')
  finish
endif
let g:loaded_vim_test_herdr = 1

let s:pane_id = ''

function! s:run(args) abort
  let l:output = system(join(map(copy(a:args), 'shellescape(v:val)'), ' '))
  return [l:output, v:shell_error]
endfunction

function! s:error(message) abort
  echohl ErrorMsg
  echomsg 'vim-test-herdr: ' . a:message
  echohl None
endfunction

function! s:strategy(cmd) abort
  if $HERDR_ENV !=# '1'
    call s:error('HERDR_ENV is not set')
    return
  endif

  if !empty(s:pane_id)
    let [l:output, l:status] = s:run(['herdr', 'pane', 'get', s:pane_id])
    if l:status != 0
      let s:pane_id = ''
    endif
  endif

  if empty(s:pane_id)
    let [l:output, l:status] = s:run([
          \ 'herdr', 'pane', 'split', '--current', '--direction', 'down',
          \ '--cwd', getcwd(), '--no-focus',
          \ ])
    if l:status != 0
      call s:error("failed to split pane\n" . l:output)
      return
    endif

    let s:pane_id = matchstr(l:output, '"pane_id"\s*:\s*"\zs[^"]*')
    if empty(s:pane_id)
      call s:error("unexpected pane split output\n" . l:output)
      return
    endif
  endif

  if get(g:, 'test#preserve_screen', -1) == 0
    call s:run(['herdr', 'pane', 'send-text', s:pane_id, "clear\n"])
  endif

  call s:run(['herdr', 'pane', 'run', s:pane_id, a:cmd])
endfunction

function! HerdrStrategy(cmd) abort
  call s:strategy(a:cmd)
endfunction

function! s:close() abort
  if !empty(s:pane_id)
    call s:run(['herdr', 'pane', 'close', s:pane_id])
    let s:pane_id = ''
  endif
endfunction

let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
let g:test#custom_strategies.herdr = function('HerdrStrategy')
command! HerdrCloseRunner call <SID>close()
