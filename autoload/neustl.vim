scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

function! neustl#Update() abort
  let l:winnr = winnr()
  let l:line = (winnr('$') == 1) ? [neuline#stl#init#Construct('active')] :
        \ [neuline#stl#init#Construct('active'), neuline#stl#init#Construct('inactive')]
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', l:line[nr!=l:winnr])
    call setwinvar(nr, 'neustl', nr!=l:winnr)
  endfor
endfunction

function! neustl#UpdateOnce() abort
  if !exists('w:neustl') || w:neustl
    call neustl#Update()
  endif
endfunction

" function! s:Construct(status) abort
"   return s:LeftPart(a:status).'%='.s:RightPart(a:status).
"         \ '%{neustl#highlight#Link()}'
" endfunction

" function! s:LeftPart(status) abort
"   if a:status ==# 'active'
"     return neustl#wrapper#Part('mode', 1)
"           \ .neustl#wrapper#Part('vcs', 1)
"           \ .neustl#wrapper#Part('bufinfo', 1)
"           \ .neustl#wrapper#Part('modification', 1)
"           \ .neustl#wrapper#Part('windowswap', 1)
"   elseif a:status ==# 'inactive'
"     " return neustl#wrapper#Part('mode', 0)
"     return neustl#wrapper#Part('bufinfo', 0)
"           \ .neustl#wrapper#Part('modification', 0)
"           \ .neustl#wrapper#Part('windowswap', 0)
"   endif
" endfunction

" function! s:RightPart(status) abort
"   if a:status ==# 'active'
"           " \ .neustl#whitespace#next()
"     return neustl#wrapper#Part('tagbar', 1).'%<'
"           \ .neustl#wrapper#Part('fileinfo', 1)
"           \ .neustl#wrapper#Part('ruler', 1)
"           \ .neustl#wrapper#Part('lintinfo', 1)
"   elseif a:status ==# 'inactive'
"     return neustl#wrapper#Part('ruler', 0)
"   endif
" endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
