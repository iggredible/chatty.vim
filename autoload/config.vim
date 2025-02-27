" change this
let s:chatty_plugin_fallback_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''
  call config#SetContext('default_assistant')
  let l:content = context#Fetch(g:chatty_context_path)
  call config#SetHistory(l:content)
endfunction

function! config#SetContext(context = 'default_assistant')
  let g:chatty_abs_path = exists('g:chatty_abs_path') ? g:chatty_abs_path : s:chatty_plugin_fallback_path
  let g:chatty_context = a:context
  let l:chatty_abs_context_path = g:chatty_abs_path .. '/' .. 'chatty/contexts/' .. g:chatty_provider
  let g:chatty_context_path = l:chatty_abs_context_path .. '/' .. g:chatty_context .. '.json'
endfunction

function! config#SetHistory(history = {})
  let g:chatty_history = json_encode(add([], a:history))
endfunction
