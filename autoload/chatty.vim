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

function! chatty#SetContext(context)
  let g:chatty_context = a:context
  let g:chatty_context_path = g:chatty_context_base_path .. a:context .. '.json'
endfunction

function! chatty#GetContexts() abort
  let l:context_dir = '.' .. g:chatty_context_base_path
  
  if !isdirectory(l:context_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:context_dir . '/*.json', 0, 1)
  
  " Extract just the filenames without extension
  return map(l:files, 'fnamemodify(v:val, ":t:r")')
endfunction

function! chatty#LoadContext(context_path)
  let l:script_dir = expand('<sfile>:p:h') 
  let l:plugin_root = fnamemodify(l:script_dir, ':h')
  let l:json_file = l:plugin_root . a:context_path

  try
      let l:json_content = join(readfile(l:json_file), '')
      return json_decode(l:json_content)
  catch
      echohl ErrorMsg
      echo "Failed to read config file: " .. v:exception .. '. Will be using a default context.'
      return { 'role': 'system', 'content': 'You are a helpful AI assistant.' }
  endtry
endfunction

function! chatty#ListContexts(text = '')
  let l:list = chatty#GetContexts()

  function! PopupCallback(id, result) closure
    if a:result != -1
      let l:context = l:list[a:result-1]
      " TODO: instead of execute, call SetContext, 
      call chatty#SetContext(l:context)
    endif
  endfunction

  let cursor_pos = screenpos(win_getid(), line('.'), col('.'))
  let screen_row = cursor_pos.row
  let screen_col = cursor_pos.col
  let total_height = &lines
  let space_below = total_height - screen_row
  let needed_height = len(l:list)

  let options = get(g:, 'operatorify_options', {
        \ 'callback': 'PopupCallback',
        \ 'border': [],
        \ 'padding': [0,1,0,1],
        \ 'pos': 'topleft',
        \ 'moved': [0, 0, 0],
        \ 'scrollbar': 0,
        \ 'fixed': 1
        \ })

  if space_below < needed_height
    let options.line = cursor_pos.row - needed_height
    let options.pos = 'botleft'
  else
    let options.line = screen_row + 1
  endif

  let options.col = screen_col
  let winid = popup_menu(l:list, options)
endfunction
