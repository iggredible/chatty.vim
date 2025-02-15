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

  if exists('g:chatty_history_id')
    let l:history_file = chatty#GetHistoryFile()
    call chatty#UpdateHistoryFileHistory(l:history_file)
  else
    call chatty#CreateNewHistory()
  endif
endfunction

function! chatty#CreateNewHistory()
  let g:chatty_history_id = chatty#GenerateUUID()
  let l:chatty_abs_histories_path = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/histories/open_ai')
  let l:history_file = l:chatty_abs_histories_path .. '/' .. g:chatty_history_id .. '.json'
  call chatty#CreateHistoryFile(l:history_file)
  call chatty#UpdateHistoryFileHistory(l:history_file)
endfunction

function! chatty#CreateHistoryFile(history_file)
  let l:content = [
    \ '{',
    \ '  "id": "' . g:chatty_history_id . '",',
    \ '  "name": "' . g:chatty_history_id . '",',
    \ '  "history": []',
    \ '}',
    \ '',
    \ ''
    \ ] 

  let l:dir = fnamemodify(a:history_file, ':h')
  call mkdir(l:dir, 'p')
  call writefile(l:content, a:history_file)
endfunction

function! chatty#GetHistoryFile()
  let l:chatty_abs_histories_path = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/histories/open_ai')
  let l:history_file = l:chatty_abs_histories_path .. '/' .. g:chatty_history_id .. '.json'
  
  if !filereadable(l:history_file)
    throw 'No history file ' .. g:chatty_history_id .. '.json found'
  endif

  return l:history_file
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

function! chatty#GetContexts() abort
  let l:context_dir = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/contexts/open_ai')
  
  if !isdirectory(l:context_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:context_dir . '/*.json', 0, 1)
  
  " Extract just the filenames without extension
  return map(l:files, 'fnamemodify(v:val, ":t:r")')
endfunction

" Return { 'role': 'system', 'context': 'You are a helpful ai assistant' }
function! chatty#LoadContext(context_path)
  let l:json_file = simplify(a:context_path)

  try
      let l:json_content = join(readfile(l:json_file), '')
      return json_decode(l:json_content)
  catch
      echohl ErrorMsg
      echo "Failed to read config file: " .. v:exception .. '. Will be using a default context.'
      return { 'role': 'system', 'content': 'You are a helpful AI assistant.' }
  endtry
endfunction

function! chatty#ListContexts()
  let l:list = chatty#GetContexts()

  function! PopupCallback(id, result) closure
    if a:result != -1
      let l:context = l:list[a:result-1]
      call config#SetContext(l:context)
      let l:content = chatty#LoadContext(g:chatty_context_path)
      let g:chatty_history = json_encode(add([], l:content))

      " Start a new session if we change context
      if exists('g:chatty_history_id')
        unlet g:chatty_history_id
      endif
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

function! chatty#GenerateUUID()
  return py3eval('__import__("uuid").uuid4().__str__()')
endfunction

function! chatty#UpdateHistoryFileHistory(history_file)
  let l:content = join(readfile(a:history_file), '')

    try
      let l:json_content = json_decode(l:content)
      let l:json_content.history = json_decode(g:chatty_history)
      " let l:json_content.context = json_decode(g:chatty_context)

      call writefile([json_encode(l:json_content)], a:history_file)

      return l:json_content
    catch
      throw 'Invalid JSON in history file ' .. g:chatty_history_id .. '.json'
    endtry
endfunction

function! chatty#GetHistories()
  let l:context_dir = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/histories/open_ai')
  
  if !isdirectory(l:context_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:context_dir . '/*.json', 0, 1)
  let l:result = []

  " Read each JSON file and extract name and id
  for l:file in l:files
    let l:content = readfile(l:file)
    if !empty(l:content)
      try
        let l:json = json_decode(join(l:content, ''))
        let l:name = get(l:json, 'name', '')
        let l:id = get(l:json, 'id', '')
        if !empty(l:name) && !empty(l:id)
          call add(l:result, l:name .. ' - ' .. l:id)
        endif
      catch
        " Skip invalid JSON files
        continue
      endtry
    endif
  endfor

  return l:result
endfunction

function! chatty#RenameHistory(name)
  if !exists('g:chatty_history_id')
    call chatty#CreateNewHistory()
  endif

  " Find history file
  let l:history_file = chatty#GetHistoryFile()

  " Update name
  let l:content = join(readfile(l:history_file), '')
    try
      let l:json_content = json_decode(l:content)
      let l:json_content.name = a:name

      call writefile([json_encode(l:json_content)], l:history_file)
    catch
      throw 'Invalid JSON in history file ' .. g:chatty_history_id .. '.json'
    endtry
endfunction
