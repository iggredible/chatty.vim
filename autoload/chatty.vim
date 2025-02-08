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

  " Push prompt into history
  call chatty#UpdateHistory('prompt')

  " Asks chat client
  " Sets g:chatty_response
  call chatty#SetResponse()

  " Push response into history
  call chatty#UpdateHistory('response')
endfunction

" The python file sets g:chatty_response
function! chatty#SetResponse()
  execute "py3file " . s:chat_py
endfunction

" types are either 'prompt' for user questions or 'response' for chat response
function! chatty#UpdateHistory(type = '')
  let l:history = json_decode(g:chatty_history)

  if a:type == 'prompt'
    let l:prompt = { 'role': 'user', 'content': g:chatty_prompt }
    let l:history += [l:prompt]
  elseif a:type == 'response'
    let l:response = { 'role': 'assistant', 'content': g:chatty_response }
    let l:history += [l:response]
  endif

  let g:chatty_history = json_encode(l:history)
  " TODO: update .chatty/open_ai/histories/persona_name__TIMESTAMP__chat.txt
endfunction
