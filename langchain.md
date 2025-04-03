# Langchain Setup

## Use Python venv to create a localized environment

Inside your vim directory (wherever `chatty.vim/` is at), create a directory named `venv` and activate it with:
```
python3 -m venv venv
source venv/bin/activate
```

To test if the virtual environment is active, run:
```
echo $VIRTUAL_ENV # expect to see a path. If it returns nothing, then it is inactive
```

To deactivate, run:
```
deactivate
```

## Install Langchain in virtual environment

```
pip install langchain langchain_openai
```
