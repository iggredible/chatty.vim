let s:chatty_dir_fallback_template_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  let g:chatty_dir_path = expand(get(g:, 'chatty_dir_path', '~/.config/chatty'))

  " Make sure that chatty dir exists and is populated
  call files#EnsureChattyDir(s:chatty_dir_fallback_template_path)

  call context#Set('default_assistant')
  let l:init_history_context= context#Fetch(g:chatty_context_path)
  call history#Set(l:init_history_context)
endfunction

