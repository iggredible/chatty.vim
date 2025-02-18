function! helper#GenerateUUID()
  return py3eval('__import__("uuid").uuid4().__str__()')
endfunction

function! helper#Operator(type = '')
  if a:type ==# ''
    set opfunc=helper#Operator
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

