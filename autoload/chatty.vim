let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

function! chatty#AskAndSetResponse()
  " Ask client, Set g:chatty_response
  execute "py3file " . s:chat_py
endfunction

function! chatty#BuildHistory()
  " Push prompt into history
  call history#Push('prompt')

  " Asks chat client
  " Sets g:chatty_response
  call chatty#AskAndSetResponse()

  " Push response into history
  call history#Push('response')

  if exists('g:chatty_history_id')
    let l:history_file = history#GetFilePath()
    call history#UpdateFile(l:history_file)
  else
    call history#Create()
  endif
endfunction

" Fetch response and prints it below the prompt
function! chatty#Ask(text = '')
  let g:chatty_prompt = a:text

  call chatty#BuildHistory()
  call chatty#PutResponse(g:chatty_response)
endfunction

function! chatty#PutResponse(response)
  put =a:response
endfunction

" Replaces the prompt with the response
function! chatty#Process(text = '')
  let l:user_prompt = input('Prompt: ')
  let l:combined_prompt =  a:text .. "\n" .. l:user_prompt

  let g:chatty_prompt = l:combined_prompt
  call chatty#BuildHistory()
  call chatty#ReplaceWithResponse()
endfunction

function! chatty#ReplaceWithResponse()
  " TODO: preserve the old `gv`
  " Right now it overrides the old `gv`
  call setreg('"', g:chatty_response)
  normal! gvp
endfunction
