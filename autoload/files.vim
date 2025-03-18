function! files#EnsureChattyDir(fallback_template_path) abort
  let l:chatty_dir = g:chatty_dir_path

  if !isdirectory(l:chatty_dir)
    " create a chatty dir, then copy from chatty plugin itself the defaults
    call files#CreateAndPopulateDir(l:chatty_dir, a:fallback_template_path)
  endif
endfunction

function! files#CreateAndPopulateDir(chatty_dir, fallback_template_path)
  call mkdir(a:chatty_dir, 'p')  " Need to create the directory first
  call files#CopyDir(a:fallback_template_path.. '/chatty/', a:chatty_dir)
  echom "Created Chatty configuration directory and copied defaults to " . a:chatty_dir
endfunction

function! files#CopyDir(src, dst) abort
  let l:files = glob(a:src . '/*', 0, 1)

  for l:item in l:files
    let dest = substitute(l:item, escape(a:src, '\'), escape(a:dst, '\'), '')
    let l:item_expanded_path = expand(l:item)
    let l:dest_expanded_path = expand(l:dest)

    if isdirectory(l:item_expanded_path)
      call mkdir(l:dest_expanded_path, 'p')
      call files#CopyDir(l:item_expanded_path, l:dest_expanded_path)
    else
      call writefile(readfile(l:item_expanded_path, 'b'), l:dest_expanded_path, 'b')
    endif
  endfor
endfunction

