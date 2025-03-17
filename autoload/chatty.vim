let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

function! chatty#AskAndSetResponse()
  " Ask client, Set g:chatty_response
  execute "py3file " . s:chat_py
endfunction

" Fetch response and prints it below the prompt
function! chatty#Ask(text = '', linenum = -1)
  let g:chatty_prompt = a:text

  call history#BuildHistoryObject()
  call chatty#PutResponse(g:chatty_response, a:linenum)
endfunction

function! chatty#PutResponse(response, linenum = -1)
  if a:linenum < 0
    put =a:response
  else
    call append(a:linenum, split(a:response, '\n'))
  endif
endfunction

" Replaces the prompt with the response
function! chatty#AskBang(text = '', _linenum = -1)
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

function! chatty#AskCommand(...) abort
  let [l:lnum1, l:lnum2] = [a:1, a:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:force = a:0 > 2 && a:3

  let l:text = join(l:lines, "\n")

  if !l:force
    call chatty#Ask(l:text, l:lnum2)
  else
    let l:user_prompt = input('Prompt: ')
    let l:combined_prompt =  l:text .. "\n" .. l:user_prompt

    let g:chatty_prompt = l:combined_prompt

    " This would call AskAndSetResponse
    call history#BuildHistoryObject()

    let l:result = g:chatty_response
    let l:result_lines = split(l:result, "\n")
    call deletebufline(bufnr('%'), l:lnum1, l:lnum2)
    call appendbufline(bufnr('%'), l:lnum1 - 1, l:result_lines)
  endif
endfunction
