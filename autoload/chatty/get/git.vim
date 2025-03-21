function! chatty#get#git#Completion(ArgLead, CmdLine, CursorPos)
  return filter(['diff'], 'v:val =~ "^' . a:ArgLead . '"')
endfunction

function! chatty#get#git#Diff(...)
  execute 'read !git diff ' .. a:1
endfunction

