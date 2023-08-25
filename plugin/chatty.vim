let s:plugin_root = expand('<sfile>:p:h:h')
let s:chat_py = s:plugin_root . "/py/chat.py"

command! CH call chatty#RunResultAndPromptWindows()
command! ChatResult call chatty#RunResultWindow()
command! ChatPrompt call chatty#RunPromptWindow()

let g:messages = []
let g:message_init =  [ { 'role': 'system', 'content': 'You are a helpful assistant.' } ]
let g:messages += g:message_init
let g:messages = json_encode(g:messages)

function! Chat(type = '')
  if a:type ==# ''
    set opfunc=Chat
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

nnoremap <expr> ch Chat()
xnoremap <expr> ch Chat()
nnoremap <expr> chh Chat() .. '_'
