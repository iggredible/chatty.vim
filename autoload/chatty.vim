let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

function! chatty#Operator(type = '')
  if a:type ==# ''
    set opfunc=chatty#Operator
    return 'g@'
  endif

  " save inits
  let l:sel_save = &selection
  let l:reg_save = getreginfo('"')
  let l:cb_save = &clipboard
  let l:visual_marks_save = [getpos("`<"), getpos("`>")]
  let l:pos_save = getpos('.')

  try
    " get phrase
    set clipboard= selection=inclusive
    let l:commands = #{line: "`[V`]y", char: "`[v`]y", block: "`[\<c-v>`]y"}

    silent exe 'noautocmd keepjumps normal! ' .. get(l:commands, a:type, '')

    " save the prompt_text inside g:chatty_prompt
    let l:chatty_prompt = getreg('"')
    call chatty#Execute(l:chatty_prompt)
    " call chatty#SetResponse()
    " call chatty#PushHistory()
  finally

    " restore inits
    call setreg('"', l:reg_save)
    call setpos("'<", l:visual_marks_save[0])
    call setpos("'>", l:visual_marks_save[1])
    call setpos('.', l:pos_save)
    let &clipboard = l:cb_save
    let &selection = l:sel_save
  endtry

  set opfunc=
  return
endfunction

function! chatty#Execute(prompt = '')
  " set prompt
  let g:chatty_prompt = a:prompt

  " Update history
  let l:history = json_decode(g:chatty_history)
  let l:prompt = { 'role': 'user', 'content': g:chatty_prompt }
  let l:history += [l:prompt]
  let g:chatty_history = json_encode(l:history)

  " Call Client
  " Sets g:chatty_response
  call chatty#SetResponse()

  " Update history
  let l:history = json_decode(g:chatty_history)
  let l:response = { 'role': 'assistant', 'content': g:chatty_response }
  let l:history += [l:response]
  let g:chatty_history = json_encode(l:history)
endfunction

" The python file sets g:chatty_response
function! chatty#SetResponse()
  execute "py3file " . s:chat_py
endfunction

" Append the prompt and response into history
" function! chatty#PushHistory(history = {})
"   let l:history = json_decode(g:chatty_history)
"   let l:prompt = { 'role': 'user', 'content': g:chatty_prompt }
"   let l:response = { 'role': 'assistant', 'content': g:chatty_response }
"
"   let l:history += [l:prompt]
"   let l:history += [l:response]
"
"   let g:chatty_history = json_encode(l:history)
" endfunction
