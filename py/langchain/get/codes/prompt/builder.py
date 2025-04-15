#!/usr/bin/env python3
import json
import sys
import os
from langchain_openai import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

def build(code_snippet, file_name, file_content):
    # If code_snippet is a list (e.g., from getline()), join it with newlines
    if isinstance(code_snippet, list):
        code_snippet = '\n'.join(code_snippet)
    
    return f"""
        Given the following code snippet:
        ```
        {code_snippet}
        ```

        The code snippet's file name is: {file_name}
        """

if len(sys.argv) > 1:
    langchain_data_file = sys.argv[1]
    # Read the JSON file as a single string
    with open(langchain_data_file, 'r') as f:
        json_str = f.read()
    
    # Parse the JSON string into a Python dictionary
    data = json.loads(json_str)
    
    openai_api_key = os.environ.get('OPENAI_API_KEY')
    # Extract the required fields
    code_snippet = data.get('code_snippet', [])
    file_name = data.get('file_name', '')
    file_content = data.get('file_content', []) if 'file_content' in data else []

    prompt = build(code_snippet, file_name, file_content)

    # Add the prompt to the data dictionary
    data['prompt'] = prompt

    # Write the updated data back to the file
    with open(langchain_data_file, 'w') as f:
        json.dump(data, f, indent=2)

    # Print the prompt
    print(prompt)
else:
    print("Error: No data file provided")
    sys.exit(1)
