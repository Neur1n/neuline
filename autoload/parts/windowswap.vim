scriptencoding utf-8

function! parts#windowswap#Status() abort
  if exists('g:loaded_windowswap')
    let l:format = get(g:, 'zipline.windowswap', '')
    return WindowSwap#IsCurrentWindowMarked() ? l:format : ''
  else
    return ''
  endif
endfunction
