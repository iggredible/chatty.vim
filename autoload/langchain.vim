let s:root = expand('<sfile>:p:h:h')
let s:langchain_py = s:root . "/py/langchain/get/codes.py"
let s:python_path = s:root . "/venv/bin/python"

function! langchain#Codes(...)
  let [l:lnum1, l:lnum2] = [a:1, a:2]
  let l:lines = getline(l:lnum1, l:lnum2)

  let l:temp_file = tempname()
  call writefile(l:lines, l:temp_file)

  let l:env = "OPENAI_API_KEY=" . shellescape(g:chatty_openai_api_key)
  let l:cmd = l:env . " " . s:python_path . " " . s:langchain_py . " " . l:temp_file

  let l:result = system(l:cmd)

  echo l:result

  call delete(l:temp_file)
endfunction
