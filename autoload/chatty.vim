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
function! chatty#Transform(text = '')
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
  let l:text = join(l:lines, "\n")
  call chatty#Ask(l:text)
endfunction

function! chatty#TransformCommand(...) abort
  let [l:lnum1, l:lnum2] = [a:1, a:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:force = a:0 > 2 && a:3

  let l:text = join(l:lines, "\n")

  let l:user_prompt = input('Prompt: ')
  let l:combined_prompt =  l:text .. "\n" .. l:user_prompt

  if !l:force
    let l:prompt_text = l:lnum1 == l:lnum2 ?
      \ 'This will replace all text on line ' .. l:lnum1 .. '. Are you sure? (y/n) ' :
      \ 'This will replace all texts between lines ' .. l:lnum1 .. ' and ' .. l:lnum2 .. '. Are you sure? (y/n) '

    let l:are_you_sure = input(l:prompt_text)

    if l:are_you_sure != 'y'
      echom "\nCancelled."
      return -1
    endif
  endif

  let g:chatty_prompt = l:combined_prompt

  " This would call AskAndSetResponse
  call history#BuildHistoryObject()

  let l:result = g:chatty_response
  let l:result_lines = split(l:result, "\n")
  call deletebufline(bufnr('%'), l:lnum1, l:lnum2)
  call appendbufline(bufnr('%'), l:lnum1 - 1, l:result_lines)
endfunction
