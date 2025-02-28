let s:chatty_dir_fallback_template_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  " g:chatty_dir_path is user path.
  " User may have defined this in vimrc, else use default ~/.config/chatty
  let g:chatty_dir_path = expand(get(g:, 'chatty_dir_path', '~/.config/chatty'))

  " Make sure that chatty dir exists and is populated
  call files#EnsureChattyDir(s:chatty_dir_fallback_template_path)

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
