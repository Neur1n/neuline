scriptencoding utf-8

function! parts#modification#Status() abort
  " let l:modif_glyph = get(g:, 'zipline.modification', ['[+]', '[-]'])

  return ' %m'.'%{&readonly ? " " : ""}'
endfunction
