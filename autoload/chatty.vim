let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

function! chatty#AskAndSetResponse()
  " Ask client, Set g:chatty_response
  execute "py3file " . s:chat_py
endfunction

" Fetch response and prints it below the prompt
function! chatty#Ask(text = '')
  let g:chatty_prompt = a:text

  call history#BuildHistoryObject()
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
  call history#BuildHistoryObject()
  call chatty#ReplaceWithResponse()
endfunction

function! chatty#ReplaceWithResponse()
  " TODO: preserve the old `gv`
  " Right now it overrides the old `gv`
  call setreg('"', g:chatty_response)
  normal! gvp
endfunction
