function! chatty#get#git#Completion(ArgLead, CmdLine, CursorPos)
  let l:wiki_git_dir_path = g:chatty_dir_path .. '/wiki/git/'
  let l:split_cmd = split(a:CmdLine)
  let l:arg_count = len(l:split_cmd) - 1

  if l:arg_count > 1
    return []
  endif

  let l:first_arg = l:arg_count >= 1 ? l:split_cmd[1] : ''
  let l:git_sub_cmds = helper#ReadDirectory(l:wiki_git_dir_path)

  for l:sub_cmd in l:git_sub_cmds
    if l:first_arg =~ '^' . l:sub_cmd
      let l:completions = helper#ReadFile(l:wiki_git_dir_path . l:sub_cmd . '.txt')
      return filter(l:completions, 'v:val =~ "^" . a:ArgLead')
    endif
  endfor

  let l:completions = l:git_sub_cmds
  return filter(l:completions, 'v:val =~ "^" . a:ArgLead')
endfunction

function! chatty#get#git#Cmd(...)
  execute 'read !git ' .. a:1
endfunction

