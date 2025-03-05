let s:chatty_dir_fallback_template_path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! config#Init()
  let g:chatty_provider = get(g:, 'chatty_provider', 'open_ai')
  let g:chatty_prompt = ''
  let g:chatty_response = ''

  let g:chatty_dir_path = expand(get(g:, 'chatty_dir_path', '~/.config/chatty'))

  " Make sure that chatty dir exists and is populated
  call files#EnsureChattyDir(s:chatty_dir_fallback_template_path)

  call instruction#Set('default_assistant')
  call config#InitHistory()
endfunction

" TODO: open Vim, select a history, start a conversation.
" Then create a NEW history (same instruction)
" makesure that history is start FRESH. Nothing carries over from the previous
" convo

function! config#InitHistory()
  let l:init_history_instruction= instruction#Fetch(g:chatty_instruction_path)
  call history#Set(l:init_history_instruction)
endfunction

