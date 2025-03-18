# Chatty.vim

Ask Chatty!

Note: Chatty is still being improved. Expect new features to be added. However, it is good enough for daily usage. 

## Setup

Chatty requires Vim with Python3 support. Chatty currently only supports OPENAI (in the future, it will work with more AI providers).

### Install

You can install Chatty with Vim plugin managers. For example, if you use [vim-plug](https://github.com/junegunn/vim-plug):

```
Plug 'iggredible/chatty.vim'
```

### API Keys

Chatty requires an OPENAI API key. You can either use an environment variable or define it in Vimrc.

```
# Terminal
export OPENAI_API_KEY=YOUR_OPENAI_KEY

" vimrc
let g:chatty_openai_api_key = 'YOUR_OPENAI_KEY'
```

If you want to use `g:chatty_openai_api_key` but do not want to live on the edge (exposing your API keys in your vimrc), check out [vim-dotenv](https://github.com/tpope/vim-dotenv) to store them inside `.env`.

### Directories

Chatty relies on data inside the `chatty/` directory. There are 3 important parts: `configs`, `instructions`, and `histories`, each stored inside a directory with the same name.

After you installed chatty, Vim should automatically generate the chatty directories in `~/.config/` (or if you defined them in `let g:chatty_dir_path = '~/.config/foo/'`). If for whatever reason they are not generated (permission issue?), you can add them yourself. Copy the `chatty/` directory and everything inside from [chatty.vim/chatty/](https://github.com/iggredible/chatty.vim/tree/main/chatty) Github page.

## Chatty Directory

Chatty by default stores your data inside `~/.config/chatty` directory. If there isn't one created, the first time you run Vim, it will create it for you. You can override it with `g:chatty_dir_path` variable. If you want to store inside `~/.config/foo`, in your vimrc, do:

```
let g:chatty_dir_path = '~/.config/foo/'
```


### Configs

The `configs/` directory stores the parameters to send to your provider. To use it, create a JSON file having the provider file name, in snake case, inside `configs/`. 

For example, inside `configs/open_ai.json`:

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

The `instructions/` directory is for your conversation guides. Think of it as Persona in ChatGPT. I did not name this directory persona because it is not a universal concept (for example, [Claude does not have a persona concept](https://www.youtube.com/watch?v=T9aRN5JkmL8&t=1469s)). I think instruction conveys a better and more universal meaning.

The convention is to store your instructions, in JSON files, for each chat provider in their directory. Chatty currently only works with `open_ai`, so put all your instructions inside `instructions/open_ai/`. Note that the chat provider directory name must match the config file name above. The actual JSON instruction file can be given any name.

For example, if I want to have ChatGPT to respond in a style of Shakespeare, I can create `instructions/open_ai/shakey.json`. Inside it:

```
{
  "role": "system",
  "content": "Reply in the style of William Shakespeare."
}
```

## Histories

The `histories/` directory contains your chat histories. Each chat history is a chat session. It is stored inside a directory named after a chat provider, similar to instructions. Unlike configs and instructions files where you manually need to create them, histories are automatically created and updated.

For example, a chat history `histories/open_ai/331965ed-73d5-405e-a063-d8fbadefd7f9.json` will look like this:

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
- `name` is to make it easier to identify and select a chat history; its value by default is the same as `id`, but you can rename it with `:ChattyRenameHistory` command.
- `instruction` is the context name that you used when starting a new history.
- `history` is a list of prompt-response.


### A Note On Chat History

Histories are useful for maintaining conversation contexts. If you had previously asked, "What is 3 + 2?", then you can ask "What is double of that number?". Maintaining history allows your chat provider to know what 'that' number is.

After you ask your first question to Chatty after you open Vim, Chatty will start a new history. Keep in mind that the longer your chat history grows, the more tokens it uses. Chatty sends the entire history each time you make a request. They accumulate fast, so be careful.

Because histories are just text files, they are cheap and lightweight. Don't be afraid to accumulate as many histories as needed and delete ones you don't use (just make sure you don't delete the current history).

If your conversation starts to rabbit trail, don't be afraid to start a new chat history (for how to start a new chat history, keep reading).

## Usages

### Usage 1: Ask (Operator)

Chatty comes with an ask operator `ch`.

Suppose you have this text:
```
What is 1 + 5?
What is twice that?
What is half that?
```

With your cursor on the first line (on the "W" in "What is 1 + 5?"), if I want to ask Chatty, I can use the line-wise Ask operator: `chh`. It will send to the AI provider the question, "What is 1 + 5?". The response will be printed on the line below the current cursor. In this case, your AI provider (should) return 6 below "What is 1 + 5?" line.

Because `ch` is just an operation, motions and visuals work. Some examples:
- `ch$` to send the texts from the current cursor position to the end of the line
- `chj` to send the text from the current cursor's row and the row below it
- `chf?` to send the text from the current cursor's location to the first occurrence of `?` ("find nearest '?'")

### Chatty Visual Operator

Vim operators work with visual mode. You can use the `ch` operator with visual mode. On the text that you want to ask, highlight them with `v` / `Ctrl-v` / `V`, then press `ch`.

### Chatty Doesn't Have a Chat Window Type

Chatty doesn't have a "Chat" window type. If you want to have a conversation with Chatty, just open a new file (`:new` or `:vnew`) and start typing your questions.

### Overriding the operator

If you want to use your open operator instead of `ch`, say you want to map it to `gh` operator instead:

```
let g:chatty_enable_operators = 0
call helper#OperatorMapper('gh', 'chatty#Ask')
```

The `helper#OperatorMapper` is a helper function. The first argument is the operator key (`gh`). The second argument is the function to execute. Have it mapped to `chatty#Ask`.

### Usage 2: Ask! (Operator)

Sometimes you don't want to ask questions. Sometimes you want to transform a given text. No problem, you can ask-and-transform it with the `cH` operator.

Below is a lits of a few things you can do with the process operator.

#### Titlecase 

If you have the following text:

```
she sells seashells on the seashore
```

To titlecase it, with your cursor at the start of the line, run `cHH` to perform a line-wise `ChattyAsk!` operator. Immediately after, a prompt will come up on the cmdline (bottom of your Vim window).

```
Prompt:
```

Tell Chatty what you want to do with the target text.

```
Prompt: Titlecase the text
```

It will transform the text you selected (unlike the ask operator where it displays the response below, this operator replaces the selected text).

```
She Sells Seashells on the Seashore
```

#### Prettify

Another example. Suppose that you have this JSON:

```
{ "meal": "breakfast", "dishes": ["eggs", "bacon", "toast"], "beverage": "coffee" }
```

To make it pretty, with your cursor at the start of the row, press `cHH` or `cH$`, then give it the prompt:

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

#### Code Generation

The operator can be used to generate codes too.

For example, if you want to create a Fizzbuzz code:

```
Generate a fizzbuzz code in Ruby. Use recursion
```

Type `cHH`. You don't have to type anything for Prompt. Leave it blank. It will replace your original instruction "Generate a Fizzbuzz..." with the actual code!

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

### Usage 3: Cmdline

Chatty comes with 2 commands to complement the ask and ask-and-transform operators: `:ChattyAsk` and `:ChattyAsk!`.

Like any commands, you can pass them a range argument. `:ChattyAsk` will pass all the text in the given range to chat provider. `:ChattyAsk!` will consume and transform all the text in the given range to chat provider.

For example, if I have the following text:

```
Peter Piper picked a peck of pickled peppers.
A peck of pickled peppers Peter Piper picked.
If Peter Piper picked a peck of pickled peppers,
Where’s the peck of pickled peppers Peter Piper picked?
```

If my cursor is on the first line and if I run `:.,+3ChattyProcess`, it will take the texts from the current cursor to 3 lines below me then it'll  ask me for a prompt. If I tell it to "uppercase the given text", it will replace it with the uppercased text.

When you run `:ChattyProcess`, it will ask for confirmation if you want to proceed or not. If you run it with a bang (`:ChattyProcess!`), it won't ask for confirmation.

More examples:
- `:%ChattyAsk`: pass the text from the entire buffer to Chatty.
- `5,10ChattyAsk!`: consume the texts on lines 5 to 10 and transform them according to prompt.
- `:5,ChattyAsk`: pass the text from lines 5 to the current line where the cursor is as a prompt.

You can also create your own custom command. If you want to create a custom command `:Chat` and `:Chat!` to do the same thing as `:ChattyAsk` and `:ChattyAsk!`, do this in Vimrc:

```
command! -range -bar -bang Chat call chatty#AskCommand(<line1>, <line2>, <bang>0)
```

#### Global Command

You can use `ChattyAsk` and `ChattyAsk!` with the global (`:g`) command to ask consecutive questions.

Given a list of questions, but you don't want to answer them all. You only want to ask some lines (the `TODO` lines):

```
TODO: What is 1 + 5?
TODO: What is twice that?
TODO: What is half that?
What is the capital of Japan?
```

If you run `:g/TODO/ChattyAsk`, Vim will get only the `TODO` lines.

```
TODO: What is 1 + 5?
6
TODO: What is twice that?
12
TODO: What is half that?
3
What is the capital of Japan?
```

Note: Due to the nature of the global command, Vim submits a prompt for each matching row. In the above example, the history looks like this:

```json
[
    {
        "role": "system",
        "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
    },
    {
        "role": "user",
        "content": "TODO: What is 1 + 5?"
    },
    {
        "role": "assistant",
        "content": "6"
    },
    {
        "role": "user",
        "content": "TODO: What is twice that?"
    },
    {
        "role": "assistant",
        "content": "12"
    },
    {
        "role": "user",
        "content": "TODO: What is half that?"
    },
    {
        "role": "assistant",
        "content": "3"
    }
]
```

Keep that in mind so that you don't run the `:g` command with 1000+ matches.

## Provider

Chatty only supports openAI right now. Chatty stores the provider information with `g:chatty_provider` (`:echo g:chatty_provider`). In the future, you will be able to change providers. Chatty provider is spelled the same way as your config (ex: `chatty/configs/open_ai.json`).

## History

### Switching History

You can switch history with `:ChattyHistories` (default mapping `<Leader>ch`). Chatty will show a dropdown of all histories in that provider, each history having the format of `HISTORYNAME__HISTORYID`. Recall HISTORYID is a UUID.

When you switch history, Chatty will use that history, for subsequent chat. If in that history you've asked "What is the capital of Brazil?", you can pick up your chat and ask, "What is the biggest city of that city?". It knows that you were talking about Brazil, so it knows what the biggest city is. It picks up where you left off.

### Renaming History

Your history name by default is its ID, which is a UUID. So you will see `d71c9e35-668b-4761-af5c-c86b21d6002b__d71c9e35-668b-4761-af5c-c86b21d6002b`, which can be hard to tell what history is this about (without looking at the `histories/` directory. You probably want to have an easier-to-remember name. I mean, what the heck is "d71c9e35..."? Is that the history when I asked about Ruby Procs or when I asked about countries of the world?

This is why you can rename history with `:ChattyRenameHistory`. It will prompt you to enter a new name. Think of it like a nickname. Now you can name one history `"ruby_proc"` and another as `"countries"`.

Next time you switch history, you will see:

```
ruby_proc__d71c9e35-668b-4761-af5c-c86b21d6002b
countries__f814af0d-b138-486d-971a-acbfc6b0b4dc
```

That's a lot easier to choose from.

### New History

Think of history as chat session. Start a new chat session often. It keeps my token usages low. It also keeps the chat provider to focus on a topic. If I was asking about Ruby Procs, then ActiveRecord queries, then Netflix architecture, then countries of the world all in one history, your chat provider may start giving unfocused answer. For that reason, I prefer to have a session for Ruby Procs, another for ActiveRecord queries, another for Netflix architecture (system design), and another for countries of the world. If I need to go back-and-forth between Ruby Procs and ActiveRecord queries, I can just toggle histories.:w

For that reason, create a new history often. By default you can do it with `<Leader>cn` or `:ChattyNewHistory`.

Note: each time you start Vim, Chatty starts a new history.

### A History Is Just A JSON File

Remember that a history is just a JSON file. Chatty history operations are either creating or modifying a JSON file. You can always modify the JSON file (make sure you don't alter its `id`, `name`, and overall structure). But feel free to revise the history.

## Instruction

An instruction is an initial system prompt. It determine the overall behavior of the chat. If you want Chatty to act like a Senior Principal Ruby on Rails programmer, and/or make it to respond verbosely, or concisely, or like a Shakespeare, or like a pirate, you can put it here. Anything you want your AI provider to behave like.

For example, in `chatty/instructions/open_ai/default_assistant.json`:

```
{
  "role": "system",
  "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
}
```

### Default Instruction

Chatty's default instruction is `default_assistant`. Meaning it will look inside `chatty/instructions/open_ai/default_assistant.json`. 

```
{
  "role": "system",
  "content": "You are a helpful AI assistant. Any programming-related questions to create, update, or analyze code, respond with code only. Omit explanations. If the question is not related to programming, answer concisely."
}
```

To override the default instruction, you can just change the `content` of that file into whatever you want.

Alternatively, you can create a new file inside `chatty/instructions/open/ai/`, name it whatever you want (example: `chatty/instructions/open_ai/ruby_developer.json`), and pass it any instruction `content` you want. Then in your vimrc, add this:

```
let g:chatty_instruction = 'ruby_developer'
```

Now when you start Vim, chatty will use `ruby_developer` as default instruction

### Switching Instructions

Once you create multiple instructions, you can switch between any instructions. The default is `<Leader>ci` or `:ChattyInstructions`. 

Note: when you switch an instruction, Chatty will start a new history.

## Quick(fix) Access to Config, History, and Instruction

You can quickly see all histories, instructions, and configs quickfix list with the `:ChattyQF -OPTS` command, where `OPTS` represent either history / instruction / config and their longhand:

```
:ChattyQF -h " or :ChattyQF --history
:ChattyQF -i " or :ChattyQF --instruction
:ChattyQF -c " or :ChattyQF --config
```

It will open a quickfix that lists all histories / instructions / configs. When you choose one of them, it will take you to that file so you can read / configure it.

# Alternatives

There are other Vim AI plugins out there:
- [copilot.vim](https://github.com/github/copilot.vim)
- [Codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim?tab=readme-ov-file)
- [Codeium.nvim](https://github.com/Exafunction/codeium.nvim)
- [ChatGPT.vim](https://github.com/jackMort/ChatGPT.nvim)
- [vim-ai](https://github.com/madox2/vim-ai/)
- [vim-chatgpt](https://github.com/CoderCookE/vim-chatgpt)
- etc

# Contributing

Ideas, suggestions, and bug fixes are welcome. Feel free to submit a PR! Your help is highly coveted and appreciated.

# License

MIT (c) Igor Irianto
