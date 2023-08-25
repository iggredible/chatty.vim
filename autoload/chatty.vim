let s:plugin_root = expand('<sfile>:p:h:h')
let s:chat_py = s:plugin_root . "/py/chat.py"

function! chatty#RunResultWindow(scratch_buffer_name = 'chatty_result')
  call utils#windows#WindowFactory(a:scratch_buffer_name)
endfunction

function! chatty#RunPromptWindow(scratch_buffer_name = 'chatty_prompt')
  call utils#windows#WindowFactory(a:scratch_buffer_name)
endfunction

function! chatty#RunResultAndPromptWindows()
  call chatty#RunResultWindow('chatty_result')
  call chatty#RunPromptWindow('chatty_prompt')
endfunction

function! chatty#GetChatResponse()
  let l:cursor_save = getpos('.')
  let l:prompt_text = join(getline(1, '$'), "\n")
  call setpos('.', l:cursor_save)

  execute "py3file " . s:chat_py
endfunction

