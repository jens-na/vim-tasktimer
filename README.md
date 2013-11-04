Overview
=============
**vim-tasktimer** is a task timer for the Vim editor.

###Features
 - Starting/Stopping timer for tasks
 - List tasks in a seperate buffer

###Installation
If you don't have a preferred way of installing Vim plugins I suggest to install 
[vim-pathogen](https://github.com/tpope/vim-pathogen) first and afterwards install 
vim-tasktimer like that:

    cd ~/.vim/bundle
    git clone https://github.com/jens-na/vim-tasktimer.git
    
If you really don't like to use pathogen you can still install it in the <tt>~/.vim/</tt>
directory directly.

###Screenshot
![tasktimer][1]
    
Usage
=====

###Basic Commands

- Use <tt>:TasktimerStart [&lt;task&gt;]</tt> to start a timer for a specific task
- Use <tt>:TasktimerStatus</tt> to get information about the currently active task.
- Use <tt>:TasktimerStop</tt> to stop the timer for the task
- With <tt>:Tasktimer [&lt;task...&gt;]</tt> you can see all the tasks you have already timed

###Basic variables

- <tt>g:tasktimer_timeformat</tt> the default output format for a time. See strftime(3) for the time format.
  <br/>Default: <tt>%Y-%m-%d %H:%M</tt>
- <tt>g:tasktimer_dateformat</tt> the default output format for a date. See strftime(3) for the date format.
  <br/>Default: <tt>%Y-%m-%d</tt>

###Basic functions

- <tt>g:tasktimer_formatfunc.format</tt> defines the function how to output a time.
- <tt>g:tasktimer_formatfunc.format_total</tt> defines the output format of the total time of a task.
- <tt>g:tasktimer_formatfunc.format_taskname</tt> defines the function how a task is displayed in the buffer.

Example format functions
- decimal representation of all times
- bugtracker prefix of all tasktimer entries

```vim
let g:tasktimer_formatfunc = {
 \ 'format' : 'Tasktimer_Custom_Format',
 \ 'format_total' : 'Tasktimer_Custom_Format',
 \ 'format_taskname' : 'Tasktimer_Custom_Taskname'
 \ }

function! Tasktimer_Custom_Format(seconds)
  let time = tasktimer#parsedecimal(a:seconds)
  return printf('%d,%.2d', time.hours, time.minutes)
endfunction

function! Tasktimer_Custom_Taskname(taskname)
  return "Bug-" . a:taskname
endfunction

```

The default output for a time is <tt>HH mm ss</tt>.

Example
=======
You have to work on a change request named 'CR-223'. You can now start your task timer in Vim:

    :TasktimerStart CR-223


When you are finished with the development of CR-223 you can stop the timer.

    :TasktimerStop


If you later need to know the time of development for CR-223 you can see all the times with:

    :Tasktimer CR-223


License and Copyright
=====================
Copyright (c) Jens Nazarenus. Distributed under the same terms as Vim itself. 
See <tt>:help license.</tt>

[1]: http://i.imgur.com/HxiTeBz.png
