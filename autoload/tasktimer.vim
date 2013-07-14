" ============================================================================
" File:        tasktimer.vim 
" Description: time tasks with Vim 
" Author:      Jens Nazarenus <jens@0x6a.de>
" Licence:     Vim licence
" Website:     http://github.com/jens-na/vim-tasktimer
" Version:     1.0
" ============================================================================

scriptencoding utf-8

if exists("g:loaded_tasktimer_autoload")
    finish
endif
let g:loaded_tasktimer_autoload = 1

" Function: Starts the timer for a specified task
function! tasktimer#start(task)
  if empty(a:task)
    echomsg 'Tasktimer: task cannot be empty.'
    return
  endif

  call tasktimer#preparefile()
  let content = tasktimer#readfile()

  if tasktimer#findpending(content) == 0
    let start = string(localtime())
    call tasktimer#writeline(a:task . ';' . start . ';*PENDING*')
  else
    echomsg 'Tasktimer: There is a pending task. Please stop the task before'
    return
  endif
endfunction

" Function: Stops the timer
function! tasktimer#stop()
endfunction

" Function: Creates the tasktimer file if it doesn't exist already.
" Returns: 0 if everything is OK, 1 otherwise
function! tasktimer#preparefile()
  if filewritable(g:tasktimer_file)
    return 0
  else
    let filename = fnamemodify(g:tasktimer_file, ':p')
    exe 'redir! > ' . filename
    redir END

    if !filewritable(g:tasktimer_file)
      echomsg 'Tasktimer: could not create file ' . filename
      return 1
    endif
    return 0
  endif
endfunction

" Function: Writes a line to the tasktimer file
function! tasktimer#writeline(line)
  if !empty(a:line)
    let filename = fnamemodify(g:tasktimer_file, ':p')
    execute 'redir >> ' . filename
    silent echon a:line . "\n"
    redir END
  endif
endfunction

" Function: Reads the content of the tasktimer file
" Returns: The file content as an array of dictinoaries
function! tasktimer#readfile()
  let filename = fnamemodify(g:tasktimer_file, ':p')
  let content = []

  for line in readfile(filename)
    let items = split(line, ';')
    let dict = {}
    let dict.task = items[0]
    let dict.start = items[1]
    let dict.end = items[2]
    call insert(content, dict)
  endfor
  return content
endfunction

" Funtion: Checks if there is an already started task in the tasktimer
" file.
" Returns: 0, if there is no active task, 1 otherwise
function! tasktimer#findpending(content)
  for entry in a:content
    if entry.end == '*PENDING*'
      return 1
    endif
  endfor
  return 0
endfunction
