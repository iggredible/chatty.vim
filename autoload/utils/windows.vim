function! utils#windows#SetScratchWindow(win_file_type)
  let &l:buftype='nofile'
  let &l:ft=a:win_file_type
  let &l:bh='hide'
  setlocal noswapfile
endfunction

function! utils#windows#CreateNewScratchWindow(scratch_buffer_name)
  below new
  call utils#windows#SetScratchWindow(a:scratch_buffer_name)
  execute "file " . a:scratch_buffer_name
  return
endfunction

function! utils#windows#OpenScratchWindow(scratch_buffer_name)
  split
  execute "buffer " . a:scratch_buffer_name
  return
endfunction

function! utils#windows#GoToScratchWindow(scratch_buffer_name)
  let l:chat_win_id = bufwinid(a:scratch_buffer_name)
  call win_gotoid(l:chat_win_id)
  return
endfunction

function! utils#windows#WindowFactory(scratch_buffer_name)
  let l:scratch_buffer_name = a:scratch_buffer_name
  if bufwinnr(l:scratch_buffer_name) == -1
    if bufexists(l:scratch_buffer_name)
      call utils#windows#OpenScratchWindow(l:scratch_buffer_name)
    else
      call utils#windows#CreateNewScratchWindow(l:scratch_buffer_name)
    endif
  else
    if &filetype != 'chatty_result'
      call utils#windows#GoToScratchWindow(l:scratch_buffer_name)
    endif
  endif
endfunction

function! utils#windows#GetWindowContent(window_name)
  let l:current_window_id = win_getid()
  let l:current_line = line('.')

  call utils#windows#GoToScratchWindow(a:window_name)
  let g:chat_result_text = join(getline(1, '$'), "\n")

  call win_gotoid(l:current_window_id)
  call cursor(l:current_line, 0)

  return g:chat_result_text
endfunction

