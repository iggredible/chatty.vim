" TODO: instead of the persona 'You are a helpful assistant' from here, get it
" from a file

function! configs#Init(init_content = 'You are a helpful AI assistant. Any questions to create, update, or analyze code, respond with code only. Omit explanations.')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  let g:chatty_history = []
  let g:chatty_history_init =  [ { 'role': 'system', 'content': a:init_content } ]
  let g:chatty_history += g:chatty_history_init
  let g:chatty_history = json_encode(g:chatty_history)
endfunction
