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
command! ChattyNewHistory call history#Init() | call history#Create() | echom 'New history created!'
command! ChattyStats call stats#Display()

command! -range -bar -bang ChattyAsk call chatty#AskCommand(<line1>, <line2>, <bang>0)
command! -nargs=1 -complete=customlist,qf#ChattyQFCompletion ChattyQF call qf#ChattyQF(<q-args>)

command! PrettyJSON call helper#PrettyJSON()

" If user sets g:chatty_enable_operators = 0, skip keymaps
if get(g:, 'chatty_enable_operators', 1)
  call helper#OperatorMapper('ga', 'chatty#Ask')
  call helper#OperatorMapper('gA', 'chatty#AskBang')
endif

if get(g:, 'chatty_enable_instructions_mapping', 1)
  nnoremap <Leader>ai :ChattyInstructions<CR>
endif

if get(g:, 'chatty_enable_rename_history_mapping', 1)
  nnoremap <Leader>ar :ChattyRenameHistory<CR>
endif

if get(g:, 'chatty_enable_histories_mapping', 1)
  nnoremap <Leader>ah :ChattyHistories<CR>
endif

if get(g:, 'chatty_enable_new_history_mapping', 1)
  nnoremap <Leader>an :ChattyNewHistory<CR>
endif

if get(g:, 'chatty_enable_stats_mapping', 1)
  nnoremap <Leader>as :ChattyStats<CR>
endif

