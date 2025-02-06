import vim
import urllib.request
import json
import os
from typing import Optional, Dict, Any

# Load deps
root = vim.eval("s:root")
vim.command(f"py3file {root}/py/clients/open_ai.py")

print("HEYYY")
def main():

    # Initialize client
    client = OpenAIClient()
    prompt = vim.eval('l:prompt_text') or 'What is the capital of Japan?'

    try:
        # TODO: create a parser
        response = client.create_completion(prompt)

        message = response['choices'][0]['message']['content']
        print(message)

    except Exception as e:
        print(f"Error: {e}")

main()

