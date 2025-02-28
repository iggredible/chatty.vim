function! context#List() abort
  let l:context_dir = g:chatty_dir_path .. '/' .. '/contexts/' .. g:chatty_provider
  
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
  let l:json_file = expand(simplify(a:context_path))

  try
      let l:json_content = join(readfile(l:json_file), '')
      return json_decode(l:json_content)
  catch
      echohl ErrorMsg
      echo "Failed to read config file: " .. v:exception .. '. Will be using a default context.'
      echohl None
      return { 'role': 'system', 'content': 'You are a helpful AI assistant.' }
  endtry
endfunction

function! context#PopupCallBack(context)
    call config#SetContext(a:context)
    let l:context_history = context#Fetch(g:chatty_context_path)
    let g:chatty_history = json_encode(add([], l:context_history))

    " Start a new session if we change context
    if exists('g:chatty_history_id')
      unlet g:chatty_history_id
    endif
endfunction
