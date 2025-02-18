let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

" The python file sets g:chatty_response
function! chatty#SetResponse()
  execute "py3file " . s:chat_py
endfunction

function! chatty#Execute(prompt = '')
  " set prompt
  let g:chatty_prompt = a:prompt

  " Push prompt into history
  call history#Push('prompt')

  " Asks chat client
  " Sets g:chatty_response
  call chatty#SetResponse()

  " Push response into history
  call history#Push('response')

  if exists('g:chatty_history_id')
    let l:history_file = history#GetFilePath()
    call history#UpdateFile(l:history_file)
  else
    call history#Create()
  endif
endfunction

