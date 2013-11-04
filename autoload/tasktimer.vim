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
if exists("g:loaded_tasktimer_autoload")
    finish
endif
let g:loaded_tasktimer_autoload = 1


" Function: Starts the timer for a specified task
function! tasktimer#start(...)
  call tasktimer#preparefile()
  let content = tasktimer#readfile()

  if tasktimer#findpending(content) == 0
    let task = ''
    if a:0 == 0
      let task = inputdialog('Taskname: ')
    else
      let task = a:1
    endif
    
    " exec: pre start
    if exists("g:tasktimer_execfunc.start_pre")
      let FnExecPre = function(g:tasktimer_execfunc.start_pre)
      let exitcode = FnExecPre(task)

      if exitcode != 0
        return
      endif
    endif
    
    if empty(task)
      echomsg 'Tasktimer: task cannot be empty.'
      return
    endif

    let start = string(localtime())
    let taskid = string(tasktimer#nextid(content))
    call tasktimer#writeline(taskid . ';' . task . ';' . start . ';*PENDING*')

    " exec: post start
    if exists("g:tasktimer_execfunc.start_post")
      let FnExecPost = function(g:tasktimer_execfunc.start_post)
      let exitcode = FnExecPost(task)

      if exitcode != 0
        return
      endif
    endif
    
    echomsg 'Tasktimer: Task with name "' . task . '" started.'
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

        " exec: pre stop
        if exists("g:tasktimer_execfunc.stop_pre")
          let FnExecPre = function(g:tasktimer_execfunc.stop_pre)
          let exitcode = FnExecPre(entry)

          if exitcode != 0
            return
          endif
        endif
        
        call tasktimer#writefile(content)

        " exec: post stop
        if exists("g:tasktimer_execfunc.stop_post")
          let FnExecPre = function(g:tasktimer_execfunc.stop_post)
          let exitcode = FnExecPre(entry)

          if exitcode != 0
            return
          endif
        endif

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

" Function: Clears the tasktimer file
function! tasktimer#clear()
  if filewritable(g:tasktimer_file)
    let filename = fnamemodify(g:tasktimer_file, ':p')
    exe 'redir! >' . filename
    redir END
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

function! tasktimer#listtasks(...)
  let content = tasktimer#readfile()
  let content = sort(content, 'tasktimer#sorttask') 
  let FnChanged = function('tasktimer#taskchanged')
  " 1 if at least one item found
  let foundtask = 0
  let tasksum = 0

  if !exists('g:tasktimer_formatfunc.format')
    echomsg 'Tasktimer: g:tasktimer_formatfunc.format must be defined.'
    return
  endif

  if !empty(a:0 > 0)
    for j in range(0, len(content) -1)
      let entry = get(content, j)
      if !empty(entry.task) && !empty(entry.start)
        for task in a:000
          if task == entry.task
            if foundtask == 0
              call tasktimer#preparebuffer()
              let foundtask = 1
            endif

            let tasksum = tasksum + tasktimer#calc(entry)
            call tasktimer#appendbuffer(entry)
            if j+1 > len(content) -1 || FnChanged(get(content, j+1), entry)
              call tasktimer#appendtasksum(tasksum) 
              let tasksum = 0
            endif
          endif
        endfor
      endif
    endfor
  else
    for j in range(0, len(content) -1) 
      let entry = get(content, j)
      if !empty(entry.task) && !empty(entry.start)
        if foundtask == 0
          call tasktimer#preparebuffer()
          let foundtask = 1
        endif
        
        let tasksum = tasksum + tasktimer#calc(entry)
        call tasktimer#appendbuffer(entry)
        if j+1 > len(content) -1 || FnChanged(get(content, j+1), entry)
            call tasktimer#appendtasksum(tasksum)
            let tasksum = 0
        endif
      endif
    endfor
  endif

  if foundtask != 0
    silent 1delete
    1
    call tasktimer#completebuffer()
  else
    echomsg 'Tasktimer: No task found.'
  endif
endfunction

" Function: Appends an entry to the current buffer
function! tasktimer#appendbuffer(entry)
  let FnFormat = function(g:tasktimer_formatfunc.format_taskname)
  let line = FnFormat(a:entry.task) . '|' . strftime(g:tasktimer_timeformat, a:entry.start)

  " show current time if not finished yet
  if a:entry.end == "*PENDING*"
    let a:entry.end = string(localtime())
    let calc = tasktimer#calc(a:entry)
    let line = line . '|until now'
  else
    let calc = tasktimer#calc(a:entry)
    let line = line . '|' . strftime(g:tasktimer_timeformat, a:entry.end)
  endif

  let FnFormat = function(g:tasktimer_formatfunc.format)
  let line = line . '|' . FnFormat(calc)

  call append(line('$'), line)
endfunction

function! tasktimer#appendtasksum(tasksum)
  let line = 'Total: ' 

  let FnFormat = function(g:tasktimer_formatfunc.format_total)
  let line = line . FnFormat(a:tasksum)

  call append(line('$'), line)
endfunction

" Function: Creates the tasktimer file if it doesn't exist already.
" Returns: 0 if everything is OK, 1 otherwise
function! tasktimer#preparefile()
  if filewritable(g:tasktimer_file)
    return 0
  else
    let filename = fnamemodify(g:tasktimer_file, ':p')
    exe 'redir! >' . filename
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
    exe 'redir >>' . filename
    silent echon a:line . "\r\n"
    redir END
  endif
endfunction

" Function: Calculates the next task id for the tasktimer
" Returns: The next task id based on the current content
function! tasktimer#nextid(content)
  let list = []
  for entry in a:content
    let id = entry.id
    call add(list, entry.id)
  endfor
  
  if empty(list)
    return 0
  else
    return str2nr(sort(list)[-1])+1
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

    if len(items) == 4
      let dict.id = items[0]
      let dict.task = items[1]
      let dict.start = items[2]
      let dict.end = items[3]
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
  exe 'redir! >' . filename
  redir END

  for entry in a:content
    let line = ''
    if !empty(entry.id) && !empty(entry.task) && !empty(entry.start)
       let line = entry.id . ';' . entry.task . ';' . entry.start
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

" Function: Sums up all the times for a task and returns the value.
" Returns: 0, no times, > 0 times found. Returns seconds
function! tasktimer#sum(task)
  let content = tasktimer#readfile()
  let sum = 0

  for entry in content
    if entry.task == a:task
      let sum = sum + tasktimer#calc(entry) 
    endif
  endfor
  return sum
endfunction

" Function: Calcs the time for one specific timed task.
" Returns: 0, no times, > 0 times found. Returns seconds
function! tasktimer#calc(entry)
  let pending = 0
  if a:entry.end == '*PENDING*'
    let pending = 1
    let a:entry.end = localtime()
  endif

  if !empty(a:entry.task) && !empty(a:entry.start) && !empty(a:entry.end)
    let diff = a:entry.end - a:entry.start
    if pending == 1
      let a:entry.end = '*PENDING*'
    endif
    return diff
  endif
  return 0
endfunction

" Function: The format function for the task name
function! tasktimer#formattask(taskname)
  return a:taskname
endfunction

" Function: The format function, which is responsibe of formatting
" the calculated seconds to a humand readable time like HH:mm:ss.
function! tasktimer#format(seconds)
  let time = tasktimer#parse(a:seconds)
  return printf('%dh %dm %ds', time.hours, time.minutes, time.seconds) 
endfunction

" Function: This function returns an dictionary which contains 'hours,
" minutes, seconds' for the timed seconds.
function! tasktimer#parse(seconds)
    let time = {}
    let time.hours = float2nr(floor(a:seconds / 3600))
    let time.minutes = float2nr(floor((a:seconds / 60) % 60))
    let time.seconds = float2nr(a:seconds % 60)
    return time
endfunction

" Function: Returns a decimal representation of the time. Returns
" a dictionary with hours, minutes and seconds.
function! tasktimer#parsedecimal(seconds)
  let time = tasktimer#parse(a:seconds)

  if !empty(time)
    let dec_min = (time.minutes * 100) / 60 
    let dec_sec = (time.seconds * 100) / 60
    let time.minutes = float2nr(floor(dec_min))
    let time.seconds = float2nr(floor(dec_sec))
    return time
  endif
endfunction

" Function: Prepares the buffer where all the listing information should
" be listed.
function! tasktimer#preparebuffer() 
  if tasktimer#isopen() == -1
    let cmd = g:tasktimer_windowpos
    let cmd = cmd . ' ' . g:tasktimer_windowheight
    let cmd = cmd . ' new'
    exe cmd
    setlocal modifiable
    setlocal statusline=0
    setf tasktimer
    setlocal buftype=nofile
    let t:tasktimer_winnr = bufnr('$')
  else
    setlocal modifiable
    exe t:tasktimer_winnr . "wincmd w"
    silent %delete
  endif
endfunction

" Funtion: Sort content by 1) task and 2) date
function! tasktimer#sorttask(i1, i2)
  let task1 = a:i1.task
  let task2 = a:i2.task

  if task1 == task2
    return 0
  endif

  for j in range(0, len(task1) -1)
    let cnr1 = char2nr(task1[j])
    let cnr2 = char2nr(task2[j])
    if cnr1 < cnr2
      return -1
    else
      if cnr1 > cnr2
        return 1
      endif
    endif
  endfor
endfunctio

" Function: Sort content by 1) date 
function! tasktimer#sortdate(i1, i2)
  if a:i1.start == a:i2.start
    return 0
  endif
  return a:i1.start < a:i2.start ? 1  : -1 
endfunction

" Function: Checks if day of month changed and returns 1 if true or 0 if
" otherwise.
function! tasktimer#daychanged(i1, i2)
  let day1 = strftime("%d", a:i1.start)
  let day2 = strftime("%d", a:a2.start)

  if day2 == day1
    return 0
  else
    return 1
  endif
endfunction

" Function: Checks if the task name has changed and return 1 if true or 0
" otherwise.
function! tasktimer#taskchanged(i1, i2)
  let tname1 = a:i1.task
  let tname2 = a:i2.task

  if tname1 == tname2
    return 0
  else
    return 1
endfunction

" Function: Completes The buffer. Specifically this function sets to buffer to
" 'nomodifiable.
function tasktimer#completebuffer()
  if exists('t:tasktimer_winnr') 
    set nomodifiable
  endif
endfunction

" Function: Checks if the buffer of tasktimer is associated with a window
function! tasktimer#isopen()
  if exists('t:tasktimer_winnr')
    return bufwinnr(t:tasktimer_winnr)
  else
    return -1
  endif
endfunction
