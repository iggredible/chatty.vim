let s:chatty_dir_fallback_template_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  " g:chatty_dir_path is user path.
  " User may have defined this in vimrc, else use default ~/.config/chatty
  let g:chatty_dir_path = expand(get(g:, 'chatty_dir_path', '~/.config/chatty'))

  " Make sure that chatty dir exists and is populated
  call config#EnsureChattyDir()

  call config#SetContext('default_assistant')
  let l:init_history_context= context#Fetch(g:chatty_context_path)
  call config#SetHistory(l:init_history_context)
endfunction

function! config#SetContext(context = 'default_assistant')
  let g:chatty_context = a:context
  let l:chatty_context_path = g:chatty_dir_path .. '/contexts/' .. g:chatty_provider
  let g:chatty_context_path = l:chatty_context_path .. '/' .. g:chatty_context .. '.json'
endfunction

function! config#SetHistory(history = {})
  let g:chatty_history = json_encode(add([], a:history))
endfunction

function! config#EnsureChattyDir() abort
  let l:chatty_dir = g:chatty_dir_path

  if !isdirectory(l:chatty_dir)
    " create a chatty dir, then copy from chatty plugin itself the defaults
    call config#CreateAndPopulateDir(l:chatty_dir)
  endif
endfunction

function! config#CreateAndPopulateDir(chatty_dir)
  call mkdir(a:chatty_dir, 'p')  " Need to create the directory first
  call config#CopyDir(s:chatty_dir_fallback_template_path .. '/chatty/', a:chatty_dir)
  echom "Created Chatty configuration directory and copied defaults to " . a:chatty_dir
endfunction


function! config#CopyDir(src, dst) abort
  let l:files = glob(a:src . '/*', 0, 1)

  for l:item in l:files
    let dest = substitute(l:item, escape(a:src, '\'), escape(a:dst, '\'), '')
    let l:item_expanded_path = expand(l:item)
    let l:dest_expanded_path = expand(l:dest)

    if isdirectory(l:item_expanded_path)
      call mkdir(l:dest_expanded_path, 'p')
      call config#CopyDir(l:item_expanded_path, l:dest_expanded_path)
    else
      call writefile(readfile(l:item_expanded_path, 'b'), l:dest_expanded_path, 'b')
    endif
  endfor
endfunction
