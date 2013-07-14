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
    echomsg 'Tasktimer: Task with name "' . a:task . '" started.'
  else
    echomsg 'Tasktimer: There is a pending task. Please stop the task before.'
    return
  endif
endfunction

" Function: Stops the timer
function! tasktimer#stop()
  let content = tasktimer#readfile()
  let taskstop = 0

  if !empty(content)
    for entry in content
      if !empty(entry.end) && entry.end == '*PENDING*'
        let endtime = string(localtime())
        let entry.end = endtime

        call tasktimer#writefile(content)
        echomsg 'Tasktimer: Stopped task "' . entry.task . '"'
        let taskstop = 1
        break
      endif
    endfor
    
    if taskstop == 0
      echomsg 'Tasktimer: No pending task.'
    endif
  endif
endfunction

" Function: Prints a status message for the tasktimer.
function! tasktimer#status()
  let content = tasktimer#readfile()
  let taskfound = 0

  if !empty(content)
    for entry in content
      if !empty(entry.end) && entry.end == '*PENDING*'
        let starttime = strftime(g:tasktimer_timeformat, entry.start)
        echomsg 'Tasktimer: Active task "' . entry.task . '". Started: ' . starttime
        let taskfound = 1
        break
      endif
    endfor

    if taskfound == 0
      echomsg 'Tasktimer: No active task.'
    endif
  endif
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

    if len(items) == 3 
      let dict.task = items[0]
      let dict.start = items[1]
      let dict.end = items[2]
    endif

    call insert(content, dict)
  endfor
  return content
endfunction

" Function: Loops through the given content and saves
" the list in a file.
function! tasktimer#writefile(content)
  if empty(a:content)
    return
  endif

  let filename = fnamemodify(g:tasktimer_file, ':p')
  exe 'redir! > ' . filename
  redir END

  for entry in a:content
    let line = ''
    if !empty(entry.task) && !empty(entry.start)
       let line = entry.task . ';' . entry.start

       if !empty(entry.end)
         let line = line . ';' . entry.end
       endif

       call tasktimer#writeline(line)
    endif
  endfor 
endfunction

" Funtion: Checks if there is an already started task in the tasktimer
" file.
" Returns: 0, if there is no active task, 1 otherwise
function! tasktimer#findpending(content)
  if empty(a:content)
    return
  endif

  for entry in a:content
    if !empty(entry.end) && entry.end == '*PENDING*'
      return 1
    endif
  endfor
  return 0
endfunction

" Function: Sums up all the times for a specific task and returns the
" value.
" Returns: 0, no times, > 0 times found
function! tasktimer#sum(task)
  let content = tasktimer#readfile()
  let sum = 0

  for entry in content
    if !empty(entry.task) && !empty(entry.start) && !empty(entry.end)
      if entry.task == a:task
        let sum = sum + (entry.end - entry.start)        
      endif
    endif
  endfor

  return sum
endfunction
