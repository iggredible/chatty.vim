function! helpers#windows#SetScratchWindow(win_file_type)
  let &l:buftype='nofile'
  let &l:ft=a:win_file_type
  let &l:bh='hide'
  setlocal noswapfile

  if a:win_file_type == 'chatty_result'
    let &l:modifiable=0
  endif
endfunction

function! helpers#windows#CreateNewScratchWindow(scratch_buffer_name)
  below new
  call helpers#windows#SetScratchWindow(a:scratch_buffer_name)
  execute "file " . a:scratch_buffer_name
  return
endfunction

function! helpers#windows#OpenScratchWindow(scratch_buffer_name)
  split
  execute "buffer " . a:scratch_buffer_name
  return
endfunction

function! helpers#windows#GoToScratchWindow(scratch_buffer_name)
  let l:chat_win_id = bufwinid(a:scratch_buffer_name)
  call win_gotoid(l:chat_win_id)
  return
endfunction

function! helpers#windows#WindowFactory(scratch_buffer_name)
  let l:scratch_buffer_name = a:scratch_buffer_name
  if bufwinnr(l:scratch_buffer_name) == -1
    if bufexists(l:scratch_buffer_name)
      call helpers#windows#OpenScratchWindow(l:scratch_buffer_name)
    else
      call helpers#windows#CreateNewScratchWindow(l:scratch_buffer_name)
    endif
  else
    if &filetype != 'chatty_result'
      call helpers#windows#GoToScratchWindow(l:scratch_buffer_name)
    endif
  endif
endfunction

function! helpers#windows#GetWindowContent(window_name)
  let l:current_window_id = win_getid()
  let l:current_line = line('.')

  call helpers#windows#GoToScratchWindow(a:window_name)
  let g:chat_result_text = join(getline(1, '$'), "\n")

  call win_gotoid(l:current_window_id)
  call cursor(l:current_line, 0)

  return g:chat_result_text
endfunction

