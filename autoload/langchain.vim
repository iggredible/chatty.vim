let s:root = expand('<sfile>:p:h:h')
let s:langchain_py = s:root . "/py/langchain/get/codes.py"
let s:python_path = s:root . "/venv/bin/python"

function! langchain#Analyze()
  " Main
  let l:code = langchain#GetCode()
  let l:code_partition = langchain#PartitionCode(l:code)
  let l:context = []
  l:context =+ l:code
  let l:unknown_codes = l:code_partition['l:unknown_codes']
  " for l:unknown_code in l:unknown_codes
  "   let l:unknown_code_snippet = langchain#GetCode(l:unknown_code)
  "   let l:code_partition = langchain#PartitionCode(l:code)
  "   " until there is no more unknown codes, OR if it hits DEPTH, keep
  "   appending l:code into l:context
    " append l:context
  " endfor
  " We now end up with a big context
  let l:prompt = langchain#PromptBuilder(l:context)
  " execute analyze with Python using prompt
endfunction

" In: content, type?
" Out: prompt (string)
function! langchain#PromptBuilder(content)
  let l:prompt = buildPrompt(l:code, l:context)
  return l:prompt
endfunction

function langchain#GetCode()
  " call vim-lsp
  " use job
endfunction

function langchain#PartitionCode(code)
  " Call Python
  " use job
endfunction

function! langchain#Codes(...)
  let [l:lnum1, l:lnum2] = [a:1, a:2]
  let l:lines = getline(l:lnum1, l:lnum2)

  let l:temp_file = tempname()
  call writefile(l:lines, l:temp_file)

  let l:current_file = expand('%:p') " Get the current file absolute path

  let l:entire_file_temp = tempname()
  let l:entire_file_content = getline(1, '$')
  call writefile(l:entire_file_content, l:entire_file_temp)

  let l:env = "OPENAI_API_KEY=" . shellescape(g:chatty_openai_api_key)
  let l:cmd = l:env . " " . s:python_path . " " . s:langchain_py . " " . 
              \ l:temp_file . " " . 
              \ shellescape(l:current_file) . " " . 
              \ l:entire_file_temp

  let l:result = system(l:cmd)

  echom l:result

  call delete(l:temp_file)
  call delete(l:entire_file_temp)
endfunction

function! langchain#Execute(...)

endfunction
