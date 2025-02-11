function! config#Init(context_path = '/.chatty/contexts/open_ai/default_assistant.json')
" function! config#Init(context_path = '/.chatty/contexts/open_ai/shakey.json')
  " TODO: allow user to pass where to store the default
  let l:content = config#LoadContext(a:context_path)
  let g:chatty_role = l:content['role'] " will I ever need this?
  let g:chatty_prompt = ''
  let g:chatty_response = ''
  let g:chatty_history = json_encode(add([], l:content))
endfunction

function! config#LoadContext(context_path)
  let l:script_dir = expand('<sfile>:p:h') 
  let l:plugin_root = fnamemodify(l:script_dir, ':h')
  let l:json_file = l:plugin_root . a:context_path

  try
      let l:json_content = join(readfile(l:json_file), '')
      return json_decode(l:json_content)
  catch
      echohl ErrorMsg
      echo "Failed to read config file: " .. v:exception .. '. Will be using a default context.'
      return { 'role': 'system', 'content': 'You are a helpful AI assistant.' }
  endtry
endfunction
