let s:plugin_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  call config#SetContext('default_assistant')
  let g:chatty_prompt = ''
  let g:chatty_response = ''
  let l:content = chatty#LoadContext(g:chatty_context_path)
  call config#SetHistory(l:content)
endfunction

function! config#SetContext(context = 'default_assistant')
  let g:chatty_abs_path = s:plugin_path
  let g:chatty_context = get(a:, 'context', 'default_assistant')
  let l:chatty_abs_context_path = g:chatty_abs_path .. '/' .. get(g:, 'chatty_context_base_path', '.chatty/contexts/open_ai')
  let g:chatty_context_path = l:chatty_abs_context_path .. '/' .. g:chatty_context .. '.json'
endfunction

function! config#SetHistory(history = {})
  let g:chatty_history = json_encode(add([], a:history))
endfunction
