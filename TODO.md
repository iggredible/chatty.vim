# Langchain

- We can run the command with `:10,15 LangchainCodes`
- We now have a list of methods that OpenAI does not know, ie: `["member_actions", "before_action", "set_user"]`

TODO: 
- go to where `member_actions`, `before_action`, and `set_user` are defined using LSP (if LSP can find them)
- pass the context of `member_action` (context = the file they're in) and ask openai to define the token in the context of that file. 
- do the same with other unknown methods
- Compile them into a big file, then send them.
- If the unknown actions are Rails methods, can LSP tell me where the definition is? I think ruby-lsp should be able to do it?
- Do I need langchain? Can I just use plain client?
