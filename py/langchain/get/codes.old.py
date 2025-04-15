#!/usr/bin/env python3
import json
import sys
import os

# Get the filename from command-line arguments
if len(sys.argv) > 1:
    temp_file = sys.argv[1]
    with open(temp_file, 'r') as f:
        code_lines = f.readlines()
else:
    print("Error: No file provided")
    sys.exit(1)

original_file_path = ""
if len(sys.argv) > 2:
    original_file_path = sys.argv[2]

entire_file_content = ""
if len(sys.argv) > 3:
    entire_file_temp = sys.argv[3]
    with open(entire_file_temp, 'r') as f:
        entire_file_code = f.read()

# Get API key from environment
openai_api_key = os.environ.get('OPENAI_API_KEY')

# Join the lines to form the code snippet
code_snippet = "".join(code_lines)

from langchain_openai import OpenAI  # Updated import
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

def partition_codes(code_snippet, file_name, entire_file_code):
    prompt = PromptTemplate(
        input_variables=["code", "file_name", "entire_file_code"],
        template="""
            Analyze ONLY this Ruby code snippet and nothing else:
            ```ruby 
            {code}
            ```
            
            This snippet comes from this file: {file_name}

            For context only, the entire file is:
            ```ruby
            {entire_file_code}
            ```

            IMPORTANT: You must ONLY analyze method and variable names that appear in the first code snippet above, NOT from the entire file.

            For each method and variable name in the FIRST code snippet ONLY, assign a confidence level:
            - HIGH: You know exactly what this does based on Ruby/Rails standards
            - LOW: You would need additional context to understand its implementation

            Example knowledge you should have HIGH confidence about:
            - Rails controller filters like before_action
            - Standard Ruby syntax like %i for symbol arrays
            - Common parameter patterns like :only

            Return this JSON structure with ONLY items from the first code snippet:
            {{
                "need_definition": ["list of items with LOW confidence only"],
                "standard_knowledge": ["list of items with HIGH confidence only"]
            }}
            
            Do not include ANY methods or variables from the entire file unless they also appear in the first code snippet.
        """
    )
    llm = OpenAI(temperature=0, openai_api_key=openai_api_key)
    chain = prompt | llm
    result = chain.invoke({"code": code_snippet, "file_name": file_name, "entire_file_code": entire_file_code})
    try:
        partitioned_symbols = json.loads(result)
        print(partitioned_symbols)
        return partitioned_symbols
    except json.JSONDecodeError:
        return {"need_definition": [], "standard_knowledge": []}

def analyze_code(code_snippet, file_name, entire_file_code):
    # First, identify which symbols the AI doesn't understand
    partitions = partition_codes(code_snippet)

    # TODO: implement get_definitions_for_symbols where it gets the definition for the given symbols.
    # definitions = get_definitions_for_symbols(file_path, unknown_symbols, code_snippet)
    definitions = {}
    result = analyze_code_with_definitions(code_snippet, definitions)

    print(result)
    return result

# def get_definitions_for_symbols(file_path, unknown_symbols, code_context = ''):
#     definitions = {}
#
#     for symbol in unknown_symbols:
#         # Find the symbol in the code context to get line and character
#         # This would need a more sophisticated implementation
#         line, character = find_symbol_position(code_context, symbol)
#
#         if line and character:
#             definition = get_definition_with_lsp(file_path, symbol, line, character)
#             definitions[symbol] = definition
#
#     return definitions
#
# def analyze_code_with_definitions(code_snippet, definitions={}):
#     # Convert definitions to a string
#     definitions_text = "\n".join([f"{symbol}: {definition}"
#                                 for symbol, definition in definitions.items()])
#
#     prompt = PromptTemplate(
#         input_variables=["code", "definitions"],
#         template="""
#         Analyze this Ruby code snippet:
#         ```ruby
#         {code}
#         ```
#
#         Additional definitions:
#         {definitions}
#
#         Explain what this code does in detail.
#         """
#     )
#
#     llm = OpenAI(temperature=0)
#
#     chain = prompt | llm
#
#     return chain.invoke({"code": code_snippet, "definitions": definitions_text})
#
#
#
# # TODO: uncomment
# # analyze_code(original_file_path, code_snippet)

partition_codes(code_snippet, original_file_path, entire_file_code)
