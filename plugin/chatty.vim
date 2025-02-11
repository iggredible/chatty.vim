call config#Init()

nnoremap <expr> ch chatty#Operator()
xnoremap <expr> ch chatty#Operator()
nnoremap <expr> chh chatty#Operator() .. '_'

" Add <leader>cc
command! ChattyContexts call chatty#ListContexts()
nnoremap <Leader>cc :ChattyContexts<CR>
