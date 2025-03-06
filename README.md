# Chatty.vim

Ask and process text with Chatty.

## Setup

Chatty requires Vim with a Python3 support.

Chatty currently only supports OPENAI (in the future, it will work with more AI providers).

Chatty requires an OPENAI API key.

```
export OPENAI_API_KEY=YOUR_OPENAI_KEY
```

You can install it with Vim plugin managers. For example, if you use [vim-plug](https://github.com/junegunn/vim-plug):

```
Plug 'iggredible/chatty.vim'
```

## Chatty directory

Chatty relies on data inside the `chatty/` directory. There are 3 important parts: `configs`, `instructions`, and `histories`, each stored inside a directory with the same name.

Chatty by default stores your data inside `~/.config/chatty` directory. If there isn't one created, the first time you run Vim, it will create it for you. You can override it with `g:chatty_dir_path` variable. If you want to store inside `~/.config/foo`, in your vimrc, do:

```
let g:chatty_dir_path = '~/.config/foo/'
```


### Configs

The `configs/` directory store the parameters to send to your provider. The provider file name inside `configs/` must use snake case. For example, inside `configs/open_ai.json`:

```
{
  "model": "gpt-3.5-turbo",
  "max_tokens": 2000,
  "temperature": 0.7,
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0
}
```

### Instructions

The `instructions/` directory are for your conversation guides. Think of it as Persona in ChatGPT. I did not name this directory persona because it is not a universal concept (for example, [Claude does not have a persona concept](https://www.youtube.com/watch?v=T9aRN5JkmL8&t=1469s)). I think instruction conveys a better and more universal meaning. The instruction files are JSON files.

The convention is to store your instructions for each chat provider in their directory. Chatty currently only works with `open_ai`, so put all your instructions inside `instructions/open_ai/`.

You can name JSON instruction file with any name. For example, if I want to have ChatGPT to respond in a style of shakespeare, I can create `instructions/open_ai/shakey.json`. Inside it:

```
{
  "role": "system",
  "content": "Reply in the style of William Shakespeare."
}
```

## Histories

The `histories/` directory contains your chat histories. Each chat history is a chat session. Each history is stored inside a chat provider directory. Here's an example of a chat history `histories/open_ai/331965ed-73d5-405e-a063-d8fbadefd7f9.json`:

```
{
  "id": "331965ed-73d5-405e-a063-d8fbadefd7f9",
  "name": "331965ed-73d5-405e-a063-d8fbadefd7f9",
  "history": [
    {
      "role": "system",
      "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
    },
    {
      "role": "user",
      "content": "What is the capital of Brazil?\n"
    },
    {
      "role": "assistant",
      "content": "Brasília."
    },
    {
      "role": "user",
      "content": "What is the biggest city in that country?\n"
    },
    {
      "role": "assistant",
      "content": "São Paulo."
    },
    {
      "role": "user",
      "content": "What is the estimated population of that city?\n"
    },
    {
      "role": "assistant",
      "content": "12.33 million."
    },
    {
      "role": "user",
      "content": "What is the average GDP?\n"
    },
    {
      "role": "assistant",
      "content": "$1.12 trillion."
    }
  ],
  "instruction": "default_assistant"
}
```

Notes: 
- `id` is a UUID to ensure that each history is unique. 
- `name` by default is the same as `id`, but you can rename it with `:ChattyRenameHistory` command.
- `instruction` is the context name that you used when starting a new history.
- `history` displays a list conversation history.


### A little note on History

Histories are useful for maintaining context in a conversation. That way, if you had previously asked, "What is 3 + 2?", the you can ask "What is double of that number?". Maintaining history allows your chat provider to know what 'that' number is.

Each time you open Vim, Chatty will start a NEW history. Even if you use the same instruction. I find that I usually don't maintain a long conversation history. Also, the longer your chat history, the more token it uses. Chatty sends the entire history each time you make a request. They accumulate fast, so be careful.  Because histories are just text files, they are cheap and lightweight. You can accumulate as many histories as needed.  Don't be afraid to start a new chat history often (on how to start a new chat history, keep reading!)


## Chatty Philosophy

Before getting into usages, let's talk about what Chatty is trying to do and what it isn't.

There already exists AI Vim plugins out there, many of them are more fancy than Chatty.
- [copilot.vim](https://github.com/github/copilot.vim)
- [Codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim?tab=readme-ov-file)
- [Codeium.nvim](https://github.com/Exafunction/codeium.nvim)
- [ChatGPT.vim](https://github.com/jackMort/ChatGPT.nvim)
- [vim-ai](https://github.com/madox2/vim-ai/)
- [vim-chatgpt](https://github.com/CoderCookE/vim-chatgpt)

The reason why I created Chatty is that none of them met my needs. I want AI features that are not too intrusive. Many of these plugins, in my opinion, turn Vim into a full-blown chat client program and not using Vim's existing tools.

Vim uses operators and command-line commands to modify texts. These are the bread and butter of Vim. I think a Vim chat plugin should be leveraging these. If I want a full-blown chat client, I can just go to https://claude.ai/ or https://chatgpt.com/.

That's why I built Chatty.vim: to enable, AI features to Vim, while still keeping its usage "Vim"-like. I want to leverage what Vim already excels doing (and what drew me to using Vim in the first place): operators, cmdlines, buffers, windows, etc.

I don't think we need to create a new "Chat" window type. We can do it with a "scratch note window".

Personally, I use both Chatty.vim and I still go to claude or chatgpt website. This is not a replacement for those chat clients.

## Usages
### Usage 1: Ask Operator

Chatty comes with an ask operator `ch`.

Suppose you have this text:
```
What is 1 + 5?
What is twice that?
What is half that?
```

With your cursor on the first line (on the "W" in What is 1 + 5?), if I want to ASK Chatty, I can use the line-wise Ask operator: `chh`. It will send to the AI provider the question, "What is 1 + 5?".

The response will be printed on the line below the current cursor. In this case,your AI provider (should) return 6 below "What is 1 + 5?" line.

Other Chat operations work. For examples:
- `ch$` to send the texts from the current cursor position to the end of the line
- `chj` to send the text from the current cursor's row and the row below it
- `chf?` to send the text from the current cursor's location to the first occurrence of `?` ("find nearest '?'")

### Usage 2: Ask and Process

Sometimes you don't want to ask questions, but instead you want Chatty to process a given text. No problem, you can Ask-and-process with `cH` operator.

Here are some usage examples.

#### Titlecase 

If you have the following text:
```
she sells seashells on the seashore
```

And you want to titlecase it, with your cursor at the start of the line, run `cHH` to perform a line-wise Process operator. Immediately after you do that, a prompt will come up on the cmdline (bottom of your Vim window).

```
Prompt:
```

You can then tell Chatty what you want to do with the text you just selected. I want to titlecase it, so I typed:
```
Prompt: Titlecase the text
```

It will TRANSFORM the text you selected (unlike the ask operator where it displays the response below, the process operator transforms the selected text.

```
She Sells Seashells on the Seashore
```

#### Prettify

Another example. Suppose that you have this JSON:
```
{ "meal": "breakfast", "dishes": ["eggs", "bacon", "toast"], "beverage": "coffee" }
```
And you want to make it pretty. You can do it with `cHH` (or `cH$` if your cursor is at the start of the row), then type:

```
Prompt: Prettify JSON
```

And it will transform your JSON into:
```
{
    "meal": "breakfast",
    "dishes": [
        "eggs",
        "bacon",
        "toast"
    ],
    "beverage": "coffee"
}
```

You can even get fancy with:
```
Prompt: Prettify JSON and replace all the meat products with vegetables
```

Result:
```
{
    "meal": "breakfast",
    "dishes": ["eggs", "vegetables", "toast"],
    "beverage": "coffee"
}
```

Pretty cool!

#### Code generation

Process can be used to generate codes too. For example, if you want to create a Fizbuzz, just type up the instruction:
```
Generate a fizzbuzz code in Ruby. Use recursion
```

Then type `cHH`. You don't have to type anything for Prompt. Just leave it blank. It will replace your original instruction "Generate a fizzbuzz..." with the actual code!

```ruby
def fizzbuzz_recursive(n)
  return if n == 0

  fizzbuzz_recursive(n - 1)

  if n % 3 == 0 && n % 5 == 0
    puts "FizzBuzz"
  elsif n % 3 == 0
    puts "Fizz"
  elsif n % 5 == 0
    puts "Buzz"
  else
    puts n
  end
end

fizzbuzz_recursive(100)
```

### Usage3: Visual mode

Vim operators work with visual mode. You can use both `ch` and `cH` operators with visual mode. 

On the text that you want to ask / process, highlight them with `v` / `Ctrl-v` / `V`, then press either `ch` or `cH`.

### Usage4: Cmdline

TODO:
`:%ChattyAsk`
`:1,4ChattyProcess`


## History


### Switching history

If you want to go back to a previous chat history, you can switch history with `:ChattyHistories` (default mapping `<Leader>ch`. When you do that, Chatty will show a dropdown of all history in that provider. 

Note: you can check your current provider with `g:chatty_provider`. Since Chatty currently only supports `open_ai`, you don't need to worry about that.

When you do that, it will display a dropdown, with each history having the format of `historyName__historyID` (historyID is a UUID).

When you switch history, Chatty will use that history, list and all that. It will pick up where you left off.

### Renaming history

Your history name by default is its ID, which is a UUID. When you switch history, it will display `historyName__historyID`. But `historyName` is initially is a UUID. So you will see `d71c9e35-668b-4761-af5c-c86b21d6002b__d71c9e35-668b-4761-af5c-c86b21d6002b`. Sometimes you just want to have an easier-to-remember name. I mean, what the heck is "d71c9e35..."? Is that history when I asked about Ruby Procs, or when I asked about countries of the world? It is hard to remember UUID. 

In that case, you can rename history with `:ChattyRenameHistory`. It will prompt you to enter a new name. That name will be the name of the history JSON file. By default a history name uses the same UUID as a history ID, which can be difficult to remember. Now you can save one to have a name of "ruby_proc" and another as "countries".

Next time you switch history, you will see:
```
ruby_proc__d71c9e35-668b-4761-af5c-c86b21d6002b
countries__f814af0d-b138-486d-971a-acbfc6b0b4dc
```

### New history

Think of history as chat session. I like to start a new chat session often. It keeps my usages low. It also keeps the chat provider to focus on a topic. If I was asking about Ruby Procs, then ActiveRecord queries, then Netflix architecture, then countries of the world all in one history, your chat provider may start giving unfocused answer. For that reason, I prefer to have a session for Ruby Procs, another for ActiveRecord queries, another for Netflix architecture and system design, and another for countries of the world (if I need to go back-and-forth between Ruby Procs and ActiveRecord queries, I can just toggle histories)

For that reason, create a new history often. By default you can do it with `<Leader>cn` or `:ChattyNewHistory`.


Note: each time you start Vim, Chatty start a new history

### A History is just a JSON file

Remember that history is just a JSON file. Any history operations done is usually either a creation or modifying a JSON file. You can always modify the JSON file (make sure you don't alter its `id`, `name`, and overall structure. But feel free to revise the history.

## Instruction


Instructions are the initial system prompt. If you want Chatty to act like a Senior Principal Ruby on Rails programmer, and/or make it to respond verbosely, or concisely, or like a Shakespeare, or like a pirate, you can put it here. Anything you want your AI provider to behave like.

For example, in `chatty/instructions/open_ai/default_assistant.json`:
```
{
  "role": "system",
  "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
}
```

Instructions determine the overall behavior of the chat.

### Default instruction

Chatty's default instruction is `default_assistant`. Meaning it will look inside `chatty/instructions/open_ai/default_assistant.json`. 

```
{
  "role": "system",
  "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
}
```

If you want to override the default instruction, you can just change the `content` into whatever you want.

Alternatively, you can create a new file inside `chatty/instructions/open/ai/`, name it whatever you want (example: `chatty/instructions/open_ai/ruby_developer.json`), and pass it any instruction `content` you want. Then in your vimrc, add this:

```
let g:chatty_instruction = 'ruby_developer'
```


### Switching instructions

Once you create multiple instructions, you can switch between any instructions. The default is `<Leader>ci` or `:ChattyInstructions`. 

Note: when you switch an instruction, Chatty will start a new history.

# TODO

Cmdline operations like: `:1,5 ChattyProcess` and `:% ChattyAsk`
