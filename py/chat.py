import vim
import urllib.request
import json
import os
from typing import Optional, Dict, List, Any

# Load deps
root = vim.eval("s:root")
vim.command(f"py3file {root}/py/clients/open_ai.py")

def main():
    client = OpenAIClient()
    history = vim.eval('g:chatty_history')

    try:
        completion = client.create_completion(json.loads(history))
        response = completion['choices'][0]['message']['content'] # TODO: create a parser later
        vim.command(f"let g:chatty_response = '{response}'")
        print(response)
    except Exception as e:
        print(f"Error: {e}")

main()
