function! chatty#get#git(arg)
  let l:arg = trim(a:arg)
  call chatty#get#git#Cmd(l:arg)
endfunction
