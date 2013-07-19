Overview
=============
**vim-tasktimer** is a task timer for the Vim editor.

###Features
 - Starting/Stopping timer for tasks
 - List tasks in a seperate buffer
 - Sort tasks by date and task name

###Installation
If you don't have a preferred way of installing Vim plugins I suggest to install 
[vim-pathogen](https://github.com/tpope/vim-pathogen) first and afterwards install 
vim-tasktimer like that:

    cd ~/.vim/bundle
    git clone https://github.com/jens-na/vim-tasktimer.git
    
If you really don't like to use pathogen you can still install it in the <tt>~/.vim/</tt>
directory directly.
    
Usage
=====

###Basic Commands

- Use <tt>:TasktimerStart &lt;task&gt;</tt> to start a timer for a specific task
- Use <tt>:TasktimerStatus</tt> to get information about the currently active task.
- Use <tt>:TasktimerStop</tt> to stop the timer for the task
- With <tt>:TasktimerList [&lt;task...&gt;]</tt> you can see all the tasks you have already timed

###Basic variables

- <tt>g:tasktimer_timeformat</tt> the default output format for a time. See strftime(3) for the time format.
  <br/>Default: <tt>%Y-%m-%d %H:%M</tt>
- <tt>g:tasktimer_dateformat</tt> the default output format for a date. See strftime(3) for the date format.
  <br/>Default: <tt>%Y-%m-%d</tt>

License and Copyright
=====================
Licensed under the GNU General Public License 3.

(c) Jens Nazarenus, 2013
