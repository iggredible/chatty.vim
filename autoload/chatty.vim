let s:root = expand('<sfile>:p:h:h')
let s:chat_py = s:root . "/py/chat.py"

function! chatty#RunResultWindow(scratch_buffer_name = 'chatty_result')
  call helpers#windows#WindowFactory(a:scratch_buffer_name)
endfunction

function! chatty#RunPromptWindow(scratch_buffer_name = 'chatty_prompt')
  call helpers#windows#WindowFactory(a:scratch_buffer_name)
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

function! chatty#ChatOperator(type = '')
  if a:type ==# ''
    set opfunc=chatty#ChatOperator
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

    let l:prompt_text = getreg('"')

    execute "py3file " . s:chat_py
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
