function! chatty#get#git(arg)
  let l:parts = split(trim(a:arg))
  let l:cmd = l:parts[0]

  if l:cmd == 'diff'
    let l:optional_args = join(parts[1:], ' ')
    call chatty#get#git#Diff(l:optional_args)
  endif
endfunction
