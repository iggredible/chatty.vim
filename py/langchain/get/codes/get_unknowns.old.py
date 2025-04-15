#!/usr/bin/env python3
import json
import sys
import os
from langchain_openai import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate


if len(sys.argv) > 1:
    temp_file = sys.argv[1]
    with open(temp_file, 'r') as f:
        code_lines = f.readlines()
else:
    print("Error: No file provided")
    sys.exit(1)

file_name = ""
if len(sys.argv) > 2:
    file_name = sys.argv[2]

file_content = ""
if len(sys.argv) > 3:
    file_content = sys.argv[3]
    with open(file_content, 'r') as f:
        file_content = f.read()

openai_api_key = os.environ.get('OPENAI_API_KEY')

code_snippet = "".join(code_lines)

def partition_codes(code_snippet, file_name, file_content):
    prompt = PromptTemplate(
        input_variables=["code", "file_name", "file_content"],
        template="""
            Analyze this code snippet only:
            ```
            {code}
            ```
           
        File name: {file_name}

        1. Identify the programming language and framework based on the syntax and file name.
        2. List all identifiers (variables, methods, functions, classes) in the code snippet.
        3. For each identifier, determine if it is:
           - Part of standard language syntax
           - A common framework feature/method
           - Likely a project-specific custom identifier

        Return your analysis in this JSON format:
        {{
            "language": "identified language",
            "framework": "identified framework or empty string",
            "unknowns": ["only identifiers you have LOW confidence about - those likely to be project-specific"]
        }}

        An identifier should only be included in "unknowns" if:
        - It appears verbatim in the code snippet
        - It is NOT a standard language feature
        - It is NOT a common framework method/pattern
        - You cannot determine its purpose with high confidence

        """
    )
    llm = OpenAI(temperature=0, openai_api_key=openai_api_key)
    chain = prompt | llm
    # print(chain)
    result = chain.invoke({"code": code_snippet, "file_name": file_name, "file_content": file_content})
    try:
        partitioned_symbols = json.loads(result)
        print(partitioned_symbols)
        return partitioned_symbols
    except json.JSONDecodeError:
        return {"unknowns": [], "standard_knowledge": []}


partition_codes(code_snippet, file_name, file_content)
