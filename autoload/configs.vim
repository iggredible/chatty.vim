function! configs#MessagesInit()
  let g:messages = []
  let g:message_init =  [ { 'role': 'system', 'content': 'You are a helpful assistant.' } ]
  let g:messages += g:message_init
  let g:messages = json_encode(g:messages)
endfunction
