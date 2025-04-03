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

# Get API key from environment
openai_api_key = os.environ.get('OPENAI_API_KEY')

# Join the lines to form the code snippet
code_snippet = "".join(code_lines)

from langchain_openai import OpenAI  # Updated import
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

def identify_unknown_symbols(code_snippet):
    prompt = PromptTemplate(
        input_variables=["code"],
        template="""
        Analyze this Ruby code snippet:
        ```ruby
        {code}
        ```
        
        List ONLY the method names and variables whose definitions you cannot confidently infer from the context.
        Return your answer as a JSON array of strings. Include only the symbol names you need defined.
        """
    )
    
    llm = OpenAI(temperature=0, openai_api_key=openai_api_key)
    chain = prompt | llm
    # chain = LLMChain(llm=llm, prompt=prompt)
    
    # result = chain.run(code=code_snippet)
    result = chain.invoke({"code": code_snippet})

    
    # Parse the result to get a list of symbols
    try:
        unknown_symbols = json.loads(result)
        return unknown_symbols
    except json.JSONDecodeError:
        # Fallback if the LLM doesn't return valid JSON
        return []

# Call the function and print the result
unknown_symbols = identify_unknown_symbols(code_snippet)
print(json.dumps(unknown_symbols))
