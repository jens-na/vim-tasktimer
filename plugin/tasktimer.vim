" ============================================================================
" File:        tasktimer.vim 
" Description: time tasks with Vim 
" Author:      Jens Nazarenus <jens@0x6a.de>
" Licence:     GPL3
" Website:     http://github.com/jens-na/vim-tasktimer
" Version:     1.0
" ============================================================================

scriptencoding utf-8

" Initialization
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
call s:init_var("g:tasktimer_timeformat", "%Y-%m-%d %H:%M")
call s:init_var("g:tasktimer_dateformat", "%Y-%m-%d")
call s:init_var("g:tasktimer_windowpos", "belowright")
call s:init_var("g:tasktimer_windowheight", "10")

if !exists('g:tasktimer_userfunc')
  let g:tasktimer_userfunc = {}
endif

" function pointer which may be overridden by end user
if !has_key(g:tasktimer_userfunc, 'format')
  let g:tasktimer_userfunc.format = 'tasktimer#format'
endif

command! -n=1 TasktimerStart call tasktimer#start(<f-args>)
command! -n=0 TasktimerStop call tasktimer#stop()
command! -n=0 TasktimerStatus call tasktimer#status()
command! -n=* -complete=customlist,s:Tasktimer_Compl TasktimerList call tasktimer#listtasks(<f-args>)

" Function: The custom complete function 
function! s:Tasktimer_Compl(ArgLead, CmdLine, CursorPos)
  echo 'test'
endfunction

" :TasktimerStart <task>
" :TasktimerStop
" :TasktimerStatus
" :TasktimerList [<task>]
" :TasktimerListDate <date_from> [<date_to>]
