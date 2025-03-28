function! history#Create(...)
  let l:uuid = helper#GenerateUUID()
  let l:name = a:0 > 0 ? a:1 : l:uuid

  let g:chatty_history_id = l:uuid
  let g:chatty_history_name = l:name

  let l:chatty_abs_histories_path = g:chatty_dir_path .. '/histories/' .. g:chatty_provider
  let l:history_file_path = l:chatty_abs_histories_path .. '/' .. g:chatty_history_id .. '.json'
  call history#CreateFile(l:history_file_path)
  call history#UpdateFile(l:history_file_path)
endfunction

function! history#BuildHistoryObject()
  " Push prompt into history
  call history#Push('prompt')

  " Asks chat client
  " Sets g:chatty_response
  call chatty#AskAndSetResponse()

  " Push response into history
  call history#Push('response')

  if exists('g:chatty_history_id')
    let l:history_file = history#GetFilePath()
    call history#UpdateFile(l:history_file)
  else
    call history#Create()
  endif
endfunction

function! history#Init()
  let l:init_history_instruction = instruction#Fetch(g:chatty_instruction_path)
  call history#Set(l:init_history_instruction)
endfunction

function! history#Set(history = {})
  let g:chatty_history = json_encode(add([], a:history))
endfunction

function! history#CreateFile(history_file_path)
  let l:content = [
    \ '{',
    \ '  "id": "' . g:chatty_history_id . '",',
    \ '  "name": "' . g:chatty_history_id . '",',
    \ '  "instruction": "' . g:chatty_instruction . '",',
    \ '  "history": []',
    \ '}',
    \ '',
    \ ''
    \ ] 

  let l:dir = fnamemodify(a:history_file_path, ':h')
  call mkdir(l:dir, 'p')
  call writefile(l:content, a:history_file_path)
endfunction

function! history#GetFilePath(history_id = g:chatty_history_id)
  let l:chatty_abs_histories_path = g:chatty_dir_path .. '/histories/' .. g:chatty_provider
  let l:history_file = l:chatty_abs_histories_path .. '/' .. a:history_id .. '.json'
  
  if !filereadable(l:history_file)
    throw 'No history file ' .. a:history_id .. '.json found'
  endif

  return l:history_file
endfunction

" types are either 'prompt' for user questions or 'response' for chat response
function! history#Push(type = '')
  let l:history = json_decode(g:chatty_history)

  if a:type == 'prompt'
    let l:prompt = { 'role': 'user', 'content': g:chatty_prompt }
    let l:history += [l:prompt]
  elseif a:type == 'response'
    let l:response = { 'role': 'assistant', 'content': g:chatty_response }
    let l:history += [l:response]
  endif

  let g:chatty_history = json_encode(l:history)
endfunction

function! history#UpdateFile(history_file)
  let l:history_file_expanded_path = expand(a:history_file)
  let l:content = join(readfile(l:history_file_expanded_path), '')

    try
      let l:json_content = json_decode(l:content)
      let l:json_content.history = json_decode(g:chatty_history)
      let l:json_content.instruction = g:chatty_instruction

      call writefile([json_encode(l:json_content)], l:history_file_expanded_path)

      return l:json_content
    catch
      echohl ErrorMsg
      echo 'Invalid JSON in history file ' .. g:chatty_history_id .. '.json'
      echohl None
    endtry
endfunction

function! history#Rename()
  let l:name = input('Enter a new name: ')

  if !exists('g:chatty_history_id')
    call history#Create(l:name)
  endif

  " Find history file
  let l:history_file = history#GetFilePath()

  " Update name
  let l:content = join(readfile(l:history_file), '')
    try
      let l:json_content = json_decode(l:content)
      let l:json_content.name = l:name

      call writefile([json_encode(l:json_content)], l:history_file)
      let g:chatty_history_name = l:name
    catch
      throw 'Invalid JSON in history file ' .. g:chatty_history_id .. '.json'
    endtry
endfunction

function! history#List()
  let l:instruction_dir = g:chatty_dir_path .. '/histories/' .. g:chatty_provider
  
  if !isdirectory(l:instruction_dir)
    return []
  endif
  
  " Get list of all files with .json extension
  let l:files = glob(l:instruction_dir . '/*.json', 0, 1)
  let l:result = []

  " Read each JSON file and extract name and id
  for l:file in l:files
    let l:content = readfile(l:file)
    if !empty(l:content)
      try
        let l:json = json_decode(join(l:content, ''))
        let l:name = get(l:json, 'name', '')
        if !empty(l:name)
          call add(l:result, l:name)
        endif
      catch
        " Skip invalid JSON files
        continue
      endtry
    endif
  endfor

  return l:result
endfunction

function! history#PopupCallBack(history_name)
  let l:history_dir_path = g:chatty_dir_path .. '/histories/' .. g:chatty_provider
  let l:files = glob(l:history_dir_path . '/*.json', 0, 1)

  for l:file in l:files
    let l:content = readfile(l:file)
    if !empty(l:content)
      try
        let l:json = json_decode(join(l:content, ''))
        let l:name = get(l:json, 'name', '')
        if a:history_name == l:name
          let l:id = l:json.id
        endif
      endtry
    endif
  endfor

  if !empty(l:id)
    call history#Update(l:id)
  endif
endfunction

function! history#Update(history_id)
  let l:chatty_abs_histories_path = g:chatty_dir_path .. '/histories/' .. g:chatty_provider
  let l:history_file_path = l:chatty_abs_histories_path .. '/' .. a:history_id .. '.json'
  try
    let l:json_content = join(readfile(l:history_file_path), '')
    let l:content = json_decode(l:json_content)
    let l:content_history = content.history
    let g:chatty_history = json_encode(l:content_history)
    let g:chatty_history_name = l:content.name
    let g:chatty_history_id = l:content.id
    echom 'History updated!'
  catch
    throw 'Invalid JSON in history file ' .. a:history_id .. '.json'
  endtry
endfunction
