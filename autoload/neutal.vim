scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

set showtabline=2

function! neutal#Update() abort
  let &tabline=neuline#tal#init#Construct()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
