scriptencoding utf-8

function! parts#lintinfo#status() abort
  let l:bufnr = bufnr('%')
  let l:loclist = getloclist(0)
  let l:loclist = filter(copy(l:loclist), {key -> l:loclist[key].lnum > 0})

  let l:e_cnt = 0
  let l:w_cnt = 0
  let l:first_e = !empty(l:loclist) ? l:loclist[-1].lnum : ''
  let l:first_w = l:first_e

  for l:item in l:loclist
    if l:item.bufnr == l:bufnr
      if l:item.type ==# 'E'
        let l:e_cnt += 1
      endif
      if l:item.type ==# 'W'
        let l:e_cnt += 1
      endif

      " Assume the loclist is sorted, check only once.
      if l:e_cnt == 1
        let l:first_e = l:item.lnum < l:first_e ? l:item.lnum : l:first_e
      endif
      if l:w_cnt == 1
        let l:first_w = l:item.lnum < l:first_w ? l:item.lnum : l:first_w
      endif
    endif
  endfor

  if l:e_cnt == 0
    let l:error = '%#ZError#'
  else
    let l:error = '%#ZError'.printf('%%{%s%d(%s%d)}',
                                    \ assets#glyph#glyph('error'),
                                    \ assets#glyph#glyph('lnum'),
                                    \ l:e_cnt,
                                    \ l:first_e)
  endif

  if l:w_cnt == 0
    let l:warning = '%#ZWarning'
  else
    let l:warning = '%#ZWarning'.printf('%%{%s%d(%s%d)}',
                                      \ assets#glyph#glyph('warning'),
                                      \ assets#glyph#glyph('lnum'),
                                      \ l:w_cnt,
                                      \ l:first_w)
  endif

  return l:warning.l:error
endfunction

function! parts#lintinfo#error() abort
  let l:bufnr = bufnr('%')
  let l:loclist = getloclist(0)
  let l:loclist = filter(copy(l:loclist), {key -> l:loclist[key].lnum > 0})

  let l:e_cnt = 0
  let l:first_e = !empty(l:loclist) ? l:loclist[-1].lnum : ''

  for l:item in l:loclist
    if l:item.bufnr == l:bufnr
      if l:item.type is# 'E'
        let l:e_cnt += 1
      endif

      if l:e_cnt == 1
        let l:first_e = l:item.lnum < l:first_e ? l:item.lnum : l:first_e
      endif
    endif
  endfor

  let l:e_cnt = l:e_cnt == 0 ? '' : '✘'.l:e_cnt.'('.l:first_e.')'
  return l:e_cnt
endfunction

function! parts#lintinfo#warning() abort
  let l:bufnr = bufnr('%')
  let l:loclist = getloclist(0)
  let l:loclist = filter(copy(l:loclist), {key -> l:loclist[key].lnum > 0})

  let l:w_cnt = 0
  let l:first_w = !empty(l:loclist) ? l:loclist[-1].lnum : ''

  for l:item in l:loclist
    if l:item.bufnr == l:bufnr
      if l:item.type is# 'W'
        let l:w_cnt += 1
      endif

      if l:w_cnt == 1
        let l:first_w = l:item.lnum < l:first_w ? l:item.lnum : l:first_w
      endif
    endif
  endfor

  let l:w_cnt = l:w_cnt == 0 ? '' : ''.l:w_cnt.'('.l:first_w.')'
  return l:w_cnt
endfunction

function! parts#lintinfo#jump(direction, wrap) abort
  let l:nearest = s:get_nearest(a:direction, a:wrap)

  if !empty(l:nearest)
    normal! m`
    call cursor(l:nearest)
  endif
endfunction

function! s:get_nearest(direction, wrap) abort
  let l:bufnr = bufnr('%')
  let l:cur_lnum = getcurpos()[1]
  let l:buflist = s:get_buflist()

  if !empty(l:buflist)
    let l:nearest = s:margin_check(l:buflist, l:cur_lnum,
          \ a:direction, a:wrap)
    if !empty(l:nearest)
      return l:nearest
    endif

    " if a:direction is# 'prev'
    "     call reverse(l:buflist)
    " endif

    " if len(l:buflist) < 20
    let l:nearest = s:linear_search(l:buflist, l:cur_lnum,
          \ a:direction, a:wrap)
    " else
    "     let l:nearest = s:InsertionSearch(l:buflist, l:cur_lnum,
    "                                     \ a:direction, a:wrap)
    " endif

    if !empty(l:nearest)
      return l:nearest
    endif
  endif

  return []
endfunction

function! s:get_buflist() abort
  let l:bufnr = bufnr('%')
  let l:loclist = getloclist(0)
  return filter(l:loclist, 'v:val.bufnr == l:bufnr')
endfunction

function! s:margin_check(buflist, cur_lnum, direction, wrap) abort
  if a:direction is# 'prev'
    if a:cur_lnum <= a:buflist[0].lnum || a:cur_lnum > a:buflist[-1].lnum
      return a:wrap ? [a:buflist[-1].lnum, a:buflist[-1].col] : []
    endif
  elseif a:direction is# 'next'
    if a:cur_lnum < a:buflist[0].lnum || a:cur_lnum >= a:buflist[-1].lnum
      return a:wrap ? [a:buflist[0].lnum, a:buflist[0].col] : []
    endif
  endif

  return []
endfunction

function! s:linear_search(buflist, cur_lnum, direction, wrap) abort
  let l:list = copy(a:buflist)
  if a:direction is# 'prev'
    let l:list = reverse(l:list)
  endif

  for l:item in l:list
    if a:direction is# 'prev' && a:cur_lnum > l:item.lnum
          \ || a:direction is# 'next' && a:cur_lnum < l:item.lnum
      return [l:item.lnum, l:item.col]
    endif
  endfor

  return []
endfunction

" Not warking yet
function! s:InsertionSearch(buflist, cur_lnum, direction, wrap) abort
  let l:low = 0
  let l:high = len(a:buflist) - 1

  while l:low <= l:high
    let l:mid = l:low
          \ + (a:cur_lnum - a:buflist[l:low].lnum)
          \ / (a:buflist[l:high].lnum - a:buflist[l:low].lnum)
          \ * (l:high - l:low)

    let l:item = a:buflist[l:mid]

    if (a:direction is# 'prev' && a:cur_lnum >= l:item.lnum)
          \ || (a:direction is# 'next' && a:cur_lnum <= l:item.lnum)
      let l:high = l:mid - 1
    else
      let l:low = l:mid + 1
    endif
  endwhile

  return [l:item.lnum, l:item.col]
endfunction
