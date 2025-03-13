" Chatty global variables
" g:chatty_dir_path: absolute path to chatty data directory
" Note: user can use this to override the path. IE: let g:chatty_dir_path = '~/.config/foo/'
" 
" g:chatty_prompt: latest prompt (String)
" g:chatty_response: latest response (String)
"
" g:chatty_instruction_path: absolute path to instruction file (String)
" g:chatty_instruction: current instruction path (String)
"
" g:chatty_history = current history (Encoded JSON)
" g:chatty_history_id = current history ID (String)
"
" g:chatty_provider: AI client provider, ex: 'open_ai' (String)
" g:chatty_openai_api_key: OpenAI API Key

call config#Init()

command! ChattyInstructions call helper#Popup('instruction#List', 'instruction#PopupCallBack')
command! ChattyHistories call helper#Popup('history#List', 'history#PopupCallBack')
command! ChattyRenameHistory call history#Rename()
command! ChattyNewHistory call history#Init() | call history#Create() | echom 'History created!'

command! -range -bar ChattyAsk call chatty#AskCommand(<line1>, <line2>)
command! -range -bar -bang ChattyTransform call chatty#TransformCommand(<line1>, <line2>, <bang>0)

command! -nargs=1 ChattyQF call ChattyQF(<q-args>)

" If user sets g:chatty_enable_operators = 0, skip keymaps
if get(g:, 'chatty_enable_operators', 1)
  call helper#OperatorMapper('ch', 'chatty#Ask')
  call helper#OperatorMapper('cH', 'chatty#Transform')
endif

if get(g:, 'chatty_enable_instructions_mapping', 1)
  nnoremap <Leader>ci :ChattyInstructions<CR>
endif

if get(g:, 'chatty_enable_rename_history_mapping', 1)
  nnoremap <Leader>cr :ChattyRenameHistory<CR>
endif

if get(g:, 'chatty_enable_histories_mapping', 1)
  nnoremap <Leader>ch :ChattyHistories<CR>
endif

if get(g:, 'chatty_enable_new_history_mapping', 1)
  nnoremap <Leader>cn :ChattyNewHistory<CR>
endif

