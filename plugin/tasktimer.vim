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

if !exists('g:tasktimer_formatfunc')
  let g:tasktimer_formatfunc = {}
endif

" function pointer which may be overridden by end user
if !has_key(g:tasktimer_formatfunc, 'format')
  let g:tasktimer_formatfunc.format = 'tasktimer#format'
endif

if !has_key(g:tasktimer_formatfunc, 'format_total')
  let g:tasktimer_formatfunc.format_total = 'tasktimer#format'
endif

if !has_key(g:tasktimer_formatfunc, 'format_taskname')
  let g:tasktimer_formatfunc.format_taskname = 'tasktimer#formattask'
endif

if !exists('g:tasktimer_execfunc')
  let g:tasktimer_execfunc = {}
endif

if !has_key(g:tasktimer_execfunc, 'start_pre')
  let g:tasktimer_formatfunc.start_pre = 'tasktimer#exec_startpre'
endif

if !has_key(g:tasktimer_execfunc, 'start_post')
  let g:tasktimer_formatfunc.start_post = 'tasktimer#exec_startpost'
endif

if !has_key(g:tasktimer_execfunc, 'stop_pre')
  let g:tasktimer_formatfunc.stop_pre = 'tasktimer#exec_stoppre'
endif

if !has_key(g:tasktimer_execfunc, 'stop_post')
  let g:tasktimer_formatfunc.stop_post = 'tasktimer#exec_stoppost'
endif

command! -n=1 TasktimerStart call tasktimer#start(<f-args>)
command! -n=0 TasktimerStop call tasktimer#stop()
command! -n=0 TasktimerStatus call tasktimer#status()
command! -n=0 TasktimerClear call tasktimer#clear()
command! -n=* -complete=customlist,s:Tasktimer_Compl Tasktimer call tasktimer#listtasks(<f-args>)

" Function: The custom complete function 
function! s:Tasktimer_Compl(ArgLead, CmdLine, CursorPos)
  let filename = fnamemodify(g:tasktimer_file, ':p')
  let tasknames = []

  for line in readfile(filename)
    let items = split(line, ';')
    let task = items[0]

    if index(tasknames, task) == -1
      call insert(tasknames, task)
    endif
  endfor
  return tasknames
endfunction
