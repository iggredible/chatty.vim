# Chatty.vim

ChatGPT plugin for Vim.

## Setup

Add your OpenAI key in env

```
export OPENAI_KEY=YOUR_OPENAI_KEY
```

## Usage 1 (Prompt)

To launch Chatty, run `:CH`.

This opens two windows: `chatty_prompt` (prompt window) and `chatty_result` (response window). Enter your prompt in the prompt window. To send your prompt, press `Ctrl-p` (in either normal or insert mode).


## Usage 2 (Operator)

You can also use `ch` operator around your text.

If your cursor is on the `def fizzbuzz(n)` line, press `ch3j` to send the entire code block, including the comment instruction, to ChatGPT.

```
def fizzbuzz(n)
    # generate a fizzbuzz function in Ruby
    # use recursion
end
```

---

This plugin is still under construction, but it is working (I am already using it for everyday tasks).

Inspired by:
- https://github.com/jackMort/ChatGPT.nvim
- https://github.com/wsdjeg/vim-chat
- https://github.com/madox2/vim-ai/
- https://github.com/CoderCookE/vim-chatgpt
