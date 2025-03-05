function! instruction#Set(instruction = 'default_assistant')
  let g:chatty_instruction = a:instruction
  let l:chatty_instruction_path = g:chatty_dir_path .. '/instructions/' .. g:chatty_provider
  let g:chatty_instruction_path = l:chatty_instruction_path .. '/' .. g:chatty_instruction .. '.json'
endfunction

function! instruction#List() abort
  let l:instruction_dir = g:chatty_dir_path .. '/' .. '/instructions/' .. g:chatty_provider
  
  if !isdirectory(l:instruction_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:instruction_dir . '/*.json', 0, 1)
  
  " Extract just the filenames without extension
  return map(l:files, 'fnamemodify(v:val, ":t:r")')
endfunction

" Return { 'role': 'system', 'content': 'You are a helpful ai assistant' }
function! instruction#Fetch(instruction_path)
  let l:json_file = expand(simplify(a:instruction_path))

  try
      let l:json_content = join(readfile(l:json_file), '')
      return json_decode(l:json_content)
  catch
      echohl ErrorMsg
      echo "Failed to read config file: " .. v:exception .. '. Will be using a default instruction.'
      echohl None
      return { 'role': 'system', 'content': 'You are a helpful AI assistant.' }
  endtry
endfunction

function! instruction#PopupCallBack(instruction)
    call instruction#Set(a:instruction)
    let l:instruction_history = instruction#Fetch(g:chatty_instruction_path)
    let g:chatty_history = json_encode(add([], l:instruction_history))

    " Start a new session if we change instruction
    if exists('g:chatty_history_id')
      unlet g:chatty_history_id
    endif
endfunction
