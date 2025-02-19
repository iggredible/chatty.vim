" NOTES: global variables
" g:chatty_prompt: latest prompt (String)
" g:chatty_response: latest response (String)
"
" g:chatty_abs_path: absolute path to chatty.vim (String)
"
" g:chatty_context_path: absolute path to context file (String)
" g:chatty_context: current context path (String)
" g:chatty_context_base_path: context path user override (String)
"
" g:chatty_history = current history (Encoded JSON)
" g:chatty_history_id = current history ID (String)
"
" g:chatty_provider: AI client provider, ex: 'open_ai' (String)

call config#Init()
call helper#OperatorMapper('ch', 'chatty#Execute')

command! ChattyContextsPopup call helper#Popup('context#List', 'context#PopupCallBack')
nnoremap <Leader>cc :ChattyContextsPopup<CR>

command! ChattyRenameHistory let name = input('Enter a new name: ') | call history#Rename(name)
nnoremap <Leader>cr :ChattyRenameHistory<CR>

" command! ChattyHistoriesPopup call history#Popup()
command! ChattyHistoriesPopup call helper#Popup('history#List', 'history#PopupCallBack')
nnoremap <Leader>ch :ChattyHistoriesPopup<CR>
