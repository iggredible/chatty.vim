call config#Init()

nnoremap <expr> ch chatty#Operator()
xnoremap <expr> ch chatty#Operator()
nnoremap <expr> chh chatty#Operator() .. '_'

" Add <leader>cc
command! ChattyContexts call chatty#ListContexts()
nnoremap <Leader>cc :ChattyContexts<CR>

command! ChattyRenameHistory let name = input('Enter a new name: ') | call chatty#RenameHistory(name)
nnoremap <Leader>cr :ChattyRenameHistory<CR>

command! ChattyHistories call chatty#ListHistories()
nnoremap <Leader>ch :ChattyHistories<CR>
