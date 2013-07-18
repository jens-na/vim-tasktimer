" ============================================================================
" File:        tasktimer.vim 
" Description: time tasks with Vim 
" Author:      Jens Nazarenus <jens@0x6a.de>
" Licence:     GPL3
" Website:     http://github.com/jens-na/vim-tasktimer
" Version:     1.0
" ========================================================================

syn match tasktimer_task #^.\{-}|#he=e-1
hi def link tasktimer_task String
