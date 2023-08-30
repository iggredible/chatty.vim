import vim
import json
import urllib.request
import time

root = vim.eval("s:root")
vim.command(f"py3file {root}/py/helpers/messages.py")
vim.command(f"py3file {root}/py/helpers/open_ai.py")

# start_time = time.time()
def prepare_chat_result_window():
    vim.command('ChatResult')
    vim.command('normal! gg')
    vim.command('setlocal modifiable')
    vim.command('%delete')
    vim.command('setlocal nomodifiable')

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
