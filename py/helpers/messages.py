def update_messages():
    add_to_messages(get_message_prompt())

def add_to_messages(data):
    messages = get_messages()
    messages.append(data)
    json_messages = json.dumps(messages)
    vim.command("let g:messages=json_encode(" + json_messages + ")")

def get_messages():
    messages = vim.eval('g:messages')
    return json.loads(messages)

def get_message_prompt():
    prompt_text = get_current_prompt()
    return { 'role': 'user', 'content': prompt_text }

def get_current_prompt():
    return vim.eval('l:prompt_text')

def generate_current_result():
    result_text = get_current_result()
    return { 'role': 'assistant', 'content': result_text }

def get_current_result():
    vim.command('call helpers#windows#GetWindowContent("chatty_result")')
    chat_result_content = vim.eval('g:chat_result_text')
    return chat_result_content


