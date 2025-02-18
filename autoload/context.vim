function! context#List() abort
  let l:context_dir = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/contexts/' .. g:chatty_provider)
  
  if !isdirectory(l:context_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:context_dir . '/*.json', 0, 1)
  
  " Extract just the filenames without extension
  return map(l:files, 'fnamemodify(v:val, ":t:r")')
endfunction

" Return { 'role': 'system', 'context': 'You are a helpful ai assistant' }
function! context#Fetch(context_path)
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

function! context#Popup()
  let l:list = context#List()

  function! PopupCallback(id, result) closure
    if a:result != -1
      let l:context = l:list[a:result-1]
      call config#SetContext(l:context)
      let l:content = context#Fetch(g:chatty_context_path)
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


