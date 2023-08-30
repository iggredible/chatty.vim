SSE_DATA_TEXT = 'data: '
SSE_TERMINATE_TEXT = '[DONE]'
OPENAI_API_ENDPOINT =  'https://api.openai.com/v1/chat/completions'
OPENAI_KEY = 'OPENAI_KEY'

def get_api_key():
    api_key = os.getenv(OPENAI_KEY)
    if not api_key:
        raise Exception(f"No {OPENAI_KEY} found")
    return api_key.strip()


def generate_bearer_key(key = get_api_key()):
    return f"Bearer {key}"

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

def write_prompt_response(req):
    with urllib.request.urlopen(req) as response:
        vim.command('setlocal modifiable')
        for line_bytes in response:
            line = line_bytes.decode("utf-8", errors="replace")
            if line.startswith(SSE_DATA_TEXT):
                line_data = line[len(SSE_DATA_TEXT):-1]
                if line_data == SSE_TERMINATE_TEXT:
                    pass
                else:
                    openai_obj = json.loads(line_data)
                    handle_stream_response(openai_obj)
    vim.command('setlocal nomodifiable')

def handle_stream_response(openai_obj):
    delta_dict = openai_obj['choices'][0]['delta']
    role_text = delta_dict.get('role', False)
    content_text = delta_dict.get('content','')
    vim.command("normal! a" + content_text)
    vim.command("redraw")
