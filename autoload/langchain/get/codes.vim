let s:root = expand('<sfile>:p:h:h:h:h')  " One more :h to go up to the plugin root
let s:prompt_py = s:root . "/py/langchain/get/codes/prompt/builder.py"
let s:python_path = s:root . "/venv/bin/python"

function! langchain#get#codes#run(...)
  let [l:lnum1, l:lnum2] = [a:1, a:2]

  let l:langchain_data_temp_file = tempname()

  " Create dictionary with data
  let l:data = {}
  let l:data.code_snippet = getline(l:lnum1, l:lnum2)
  let l:data.file_name = expand('%:p')
  " let l:data.file_content = getline(1, '$')
  let l:data.file_content = 'REPLACE ME LATER'
  let l:data.depth = 0
  let l:data.unknowns = []
  let l:data.resolved = []
  let l:data.prompt = ''
  
  " Convert to JSON string
  let l:json_data = json_encode(l:data)

  try
    " Write JSON string to file as a list with one item
    call writefile([l:json_data], l:langchain_data_temp_file)

    " Prepare and execute the Python command
    let l:env = "OPENAI_API_KEY=" . shellescape(g:chatty_openai_api_key)
    let l:cmd = l:env . " " . s:python_path . " " . s:prompt_py . " " . 
                \ l:langchain_data_temp_file . " "

    let l:result = system(l:cmd)
    let l:updated_json = join(readfile(l:langchain_data_temp_file), '')

    " Decode the JSON and assign it to the global variable
    let g:langchain_data = json_decode(l:updated_json)

    return l:result
    
    return l:result
  catch
    " Handle any exceptions
    echom "Error in langchain#get#codes#run: " . v:exception
    return ""
  finally
    " Guarantee cleanup of temporary files
    call delete(exists('l:langchain_data_temp_file') ? l:langchain_data_temp_file : '')
  endtry
endfunction
