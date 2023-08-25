import vim
import json
import urllib.request
import time

plugin_root = vim.eval("s:plugin_root")

SSE_DATA_TEXT = 'data: '
SSE_TERMINATE_TEXT = '[DONE]'
OPENAI_API_ENDPOINT =  'https://api.openai.com/v1/chat/completions'
OPENAI_KEY = 'OPENAI_KEY'

# start_time = time.time()

def get_api_key():
    api_key = os.getenv(OPENAI_KEY)
    if not api_key:
        raise Exception(f"No {OPENAI_KEY} found")
    return api_key.strip()

def generate_bearer_key(key = get_api_key()):
    return f"Bearer {key}"

def get_current_prompt():
    return vim.eval('l:prompt_text')

def get_messages():
    messages = vim.eval('g:messages')
    return json.loads(messages)

def generate_current_result():
    result_text = get_current_result()
    return { 'role': 'assistant', 'content': result_text }

def add_to_messages(data):
    messages = get_messages()
    messages.append(data)
    json_messages = json.dumps(messages)
    vim.command("let g:messages=json_encode(" + json_messages + ")")

def get_message_prompt():
    prompt_text = get_current_prompt()
    return { 'role': 'user', 'content': prompt_text }

def update_messages():
    add_to_messages(get_message_prompt())

def get_current_result():
    vim.command('call utils#windows#GetWindowContent("chatty_result")')
    chat_result_content = vim.eval('g:chat_result_text')
    return chat_result_content

def generate_openai_request(messages):
    api_endpoint = OPENAI_API_ENDPOINT
    headers = {
        'Content-Type': 'application/json',
        'Authorization': generate_bearer_key()
    }
    data = {
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'temperature': 0,
        'stream': True
    }
    return urllib.request.Request(
            api_endpoint, 
            data=json.dumps({**data}).encode("utf-8"), 
            headers=headers, method="POST"
        )

def handle_stream_response(openai_obj):
    delta_dict = openai_obj['choices'][0]['delta']
    role_text = delta_dict.get('role', False)
    content_text = delta_dict.get('content','')
    vim.command("normal! a" + content_text)
    vim.command("redraw")

def write_prompt_response(req):
    with urllib.request.urlopen(req) as response:
        for line_bytes in response:
            line = line_bytes.decode("utf-8", errors="replace")
            if line.startswith(SSE_DATA_TEXT):
                line_data = line[len(SSE_DATA_TEXT):-1]
                if line_data == SSE_TERMINATE_TEXT:
                    pass
                else:
                    openai_obj = json.loads(line_data)
                    handle_stream_response(openai_obj)

def prepare_chat_result_window():
    vim.command('ChatResult')
    vim.command('normal! gg')
    vim.command('%delete')
    return

def openai_write_response(req, messages):
    prepare_chat_result_window()
    write_prompt_response(req)
    add_to_messages(generate_current_result())

update_messages()
messages_array = get_messages()
chat_req = generate_openai_request(messages_array)
openai_write_response(chat_req, messages_array)

# elapsed_time = time.time() - start_time
# vim.command(f"normal! Go\n\n[ Time ellapsed: {elapsed_time}s ]")
