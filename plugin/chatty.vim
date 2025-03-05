" NOTES: global variables
" g:chatty_dir_path: absolute path to chatty data directory
" Note: user can use this to override the path. IE:
" let g:chatty_dir_path = '~/.config/foo/'
" This will make the directory ~/.config/foo/ instead of ~/.config/chatty
" Full absolute path theoretically should work. 
" TODO: test if something like /Users/Plato/some/path would work too
" 
" g:chatty_prompt: latest prompt (String)
" g:chatty_response: latest response (String)
"
" g:chatty_context_path: absolute path to context file (String)
" g:chatty_context: current context path (String)
"
" g:chatty_history = current history (Encoded JSON)
" g:chatty_history_id = current history ID (String)
"
" g:chatty_provider: AI client provider, ex: 'open_ai' (String)

call config#Init()

command! ChattyContextsPopup call helper#Popup('context#List', 'context#PopupCallBack')
command! ChattyRenameHistory let name = input('Enter a new name: ') | call history#Rename(name)
command! ChattyHistoriesPopup call helper#Popup('history#List', 'history#PopupCallBack')

" If user sets g:chatty_enable_operators = 0, skip keymaps
if get(g:, 'chatty_enable_operators', 1)
  call helper#OperatorMapper('ch', 'chatty#Ask')
  call helper#OperatorMapper('cH', 'chatty#Process')
endif

if get(g:, 'chatty_enable_contexts_popup_mapping', 1)
  nnoremap <Leader>cc :ChattyContextsPopup<CR>
endif

if get(g:, 'chatty_enable_rename_history_mapping', 1)
  nnoremap <Leader>cr :ChattyRenameHistory<CR>
endif

if get(g:, 'chatty_enable_histories_popup_mapping', 1)
  nnoremap <Leader>ch :ChattyHistoriesPopup<CR>
endif
