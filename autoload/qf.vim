function! qf#ChattyQF(arg)
  if a:arg == 'history'
    call qf#Histories()
  elseif a:arg == 'instruction'
    call qf#Instructions()
  elseif a:arg == 'config'
    call qf#Configs()
  else
    echo "Invalid argument. Available options:"
    echo "  history     : Show chat histories"
    echo "  instruction : Show instructions"
    echo "  config      : Show configurations"
  endif
endfunction

function! qf#ChattyQFCompletion(ArgLead, CmdLine, CursorPos)
  return filter(['history', 'instruction', 'config'], 'v:val =~ "^' . a:ArgLead . '"')
endfunction

function! qf#Instructions()
  function! InstructionQFBuilder(file)
    let l:json_content = join(readfile(a:file), '')
    let l:content = json_decode(l:json_content)
    return a:file . ':1:1:' . l:content.content
  endfunction

  call qf#Base(
    \ expand(g:chatty_dir_path .. '/instructions/' .. g:chatty_provider .. '/'),
    \ function('InstructionQFBuilder')
  \ )
endfunction

function! qf#Configs()
  function! ConfigQFBuilder(file)
    let l:json_content = join(readfile(a:file), '')
    let l:content = json_decode(l:json_content)
    return a:file . ':1:1:' . l:content.model
  endfunction

  call qf#Base(
    \ expand(g:chatty_dir_path .. '/configs/'),
    \ function('ConfigQFBuilder')
  \ )
endfunction

function! qf#Histories()
  function! HistoryQFBuilder(file)
    let l:json_content = join(readfile(a:file), '')
    let l:content = json_decode(l:json_content)
    return a:file . ':1:1:' . l:content.name
  endfunction

  call qf#Base(
    \ expand(g:chatty_dir_path .. '/histories/' .. g:chatty_provider .. '/'),
    \ function('HistoryQFBuilder')
  \ )
endfunction

function! qf#Base(path, qf_builder)
  let l:path = a:path

  " Check if the directory exists
  if !isdirectory(l:path)
    echo "Directory not found: " . l:path
    return
  endif

  " Get list of JSON files using Vim's built-in globpath function
  let l:files = split(globpath(l:path, '*.json'), '\n')

  " Check if any files were found
  if empty(l:files)
    echo "No JSON files found in " . l:path
    return
  endif

  let l:qf_entries = []

  for l:file in l:files
    let l:qf = call(a:qf_builder, [l:file])
    call add(l:qf_entries, l:qf)
  endfor

  " Populate the quickfix list
  call setqflist([], 'r', {'lines': l:qf_entries})

  " Open the quickfix window
  copen

  " Set a title for the quickfix window
  let w:quickfix_title = "Chatty Histories"
endfunction

