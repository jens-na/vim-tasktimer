" ============================================================================
" File:        tasktimer.vim 
" Description: time tasks with Vim 
" Author:      Jens Nazarenus <jens@0x6a.de>
" Licence:     Vim licence
" Website:     http://github.com/jens-na/vim-tasktimer
" Version:     1.0
" ============================================================================

scriptencoding utf-8

if exists("loaded_tasktimer")
    finish
endif
if v:version < 700
    echoerr "Tasktimer: this plugin requires vim >= 7." 
    finish
endif
let loaded_tasktimer = 1

function! s:init_var(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
    return 1
  endif
  return 0
endfunction

call s:init_var("g:tasktimer_file", expand('$HOME') . '/.vim_tasktimer')

