let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

" The python file sets g:chatty_response
function! chatty#SetResponse()
  execute "py3file " . s:chat_py
endfunction

function! chatty#BuildHistory()
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

function! chatty#Ask(prompt = '')
  let g:chatty_prompt = a:prompt

  call chatty#BuildHistory()
  call chatty#PutResponse(g:chatty_response)
endfunction

function! chatty#PutResponse(response)
  put =a:response
endfunction

function! chatty#Process(prompt = '')
  " set prompt
  " TODO: Prompt is now defined as: highlighted text + cmdline
  let g:chatty_prompt = a:prompt

  call chatty#BuildHistory()
  " TODO: replace the highlighted text + print the response
  " call chatty#PutResponse(g:chatty_response)
endfunction
