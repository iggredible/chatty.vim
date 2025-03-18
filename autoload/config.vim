let s:chatty_dir_fallback_template_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  let g:chatty_dir_path = expand(get(g:, 'chatty_dir_path', '~/.config/chatty'))

  " Make sure that chatty dir exists and is populated
  call files#EnsureChattyDir(s:chatty_dir_fallback_template_path)

  let l:chatty_instruction = get(g:, 'chatty_instruction', 'default_assistant')
  call instruction#Set(l:chatty_instruction)
  call history#Init()
endfunction
