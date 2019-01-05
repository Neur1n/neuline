scriptencoding utf-8

let s:tabs = {'list': [1], 'str': ''}
let s:prev_tab = 0

function! parts#tabline#Tabline() abort
  return '%#ZTLeft#'.'  %<%{parts#tabline#LeftPart()}'.'%='
        \ .'%#ZTCurTab#'.'%{parts#tabline#CurrentTab()} '
        \ .'%#ZTNotCurTab#'.'%{parts#tabline#NotCurrentTab()} '
        \ .'%999X%{parts#tabline#CloseButton()} '
endfunction

function! parts#tabline#LeftPart() abort
  return get(g:, 'zipline.talleft', getcwd())
endfunction

function! parts#tabline#CurrentTab() abort
  if tabpagenr('$') == 1
    return ''
  else
    return tabpagenr()
  endif
endfunction

function! parts#tabline#NotCurrentTab() abort
  let l:diff = tabpagenr('$') - len(s:tabs.list)

  if tabpagenr() == s:prev_tab && l:diff == 0
    return s:tabs.str
  else
    let s:tabs.str = ''
  endif

  if tabpagenr() != s:prev_tab || l:diff
    " Put the previous-current tab number back to list, or say sorting.
    " Didn't use sort() here since the following method seems faster.
    call insert(s:tabs.list, s:tabs.list[0], s:tabs.list[0])
    call remove(s:tabs.list, 0)
    let s:prev_tab = tabpagenr()
  endif

  if l:diff < 0
    call remove(s:tabs.list, l:diff, -1)
  elseif l:diff > 0
    for nr in range(1, l:diff)
      call extend(s:tabs.list, [s:tabs.list[-nr]+nr])
    endfor
  endif

  call insert(s:tabs.list, tabpagenr())
  call remove(s:tabs.list, tabpagenr())

  if len(s:tabs.list) < 2
    return ''
  endif

  for nr in s:tabs.list[1:]  " Only take the non-current part
    let s:tabs.str .= ' '.nr
  endfor
  return s:tabs.str
endfunction

function! parts#tabline#CloseButton() abort
  if tabpagenr('$') == 1
    return ''
  else
    return '[]'
  endif
endfunction
