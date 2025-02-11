function! config#Init()
  call config#SetDefaultContext()
  let l:content = chatty#LoadContext(g:chatty_context_path)
  let g:chatty_prompt = ''
  let g:chatty_response = ''
  let g:chatty_history = json_encode(add([], l:content))
endfunction

function! config#SetDefaultContext()
  let g:chatty_context_base_path = get(g:, 'chatty_context_base_path', '/.chatty/contexts/open_ai/')
  let g:chatty_context = get(g:, 'chatty_context', 'default_assistant')
  let g:chatty_context_path = g:chatty_context_base_path .. g:chatty_context .. '.json'
endfunction
