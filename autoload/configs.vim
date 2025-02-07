function! configs#Init(init_content = 'You are a helpful assistant.')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  let g:chatty_history = []
  let g:chatty_history_init =  [ { 'role': 'system', 'content': a:init_content } ]
  let g:chatty_history += g:chatty_history_init
  let g:chatty_history = json_encode(g:chatty_history)
endfunction
