call configs#MessagesInit()

command! CH call chatty#RunResultAndPromptWindows()
command! ChatResult call chatty#RunResultWindow()
command! ChatPrompt call chatty#RunPromptWindow()

nnoremap <expr> ch chatty#ChatOperator()
xnoremap <expr> ch chatty#ChatOperator()
nnoremap <expr> chh chatty#ChatOperator() .. '_'
