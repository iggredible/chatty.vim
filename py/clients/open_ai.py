class OpenAIClient:
    def __init__(
            self,
            api_key: str = "YOUR_OPENAI_API_KEY"
    ) -> None:

        # export OPENAI_API_KEY=YOUR_OPENAI_API_KEY
        api_key = os.getenv("OPENAI_API_KEY") or api_key
        if not api_key:
            raise ValueError("Please set OPENAI_API_KEY environment variable")
        self.api_key = api_key
        self.base_url = "https://api.openai.com/v1"

    def create_completion(
        self,
        history: List[Dict[str, str]],
        model: str = "gpt-3.5-turbo",
        max_tokens: int = 1500,
        temperature: float = 0.7,
        top_p: float = 1.0,
        frequency_penalty: float = 0.0,
        presence_penalty: float = 0.0
    ) -> Dict[str, Any]:

        endpoint = f"{self.base_url}/chat/completions"

        config_data = {
            "model": model,
            "max_tokens": max_tokens,
            "temperature": temperature,
            "top_p": top_p,
            "frequency_penalty": frequency_penalty,
            "presence_penalty": presence_penalty
        }

        config_path = os.path.join(
            vim.eval('g:chatty_dir_path'),
            'chatty',
            'configs',
            'open_ai.json'
        )

        try:
            if os.path.exists(config_path):
                with open(config_path, 'r') as f:
                    file_config = json.load(f)
                    config_data.update(file_config)
        except (json.JSONDecodeError, IOError) as e:
            # Log error but continue with defaults
            print(f"Error reading config file: {e}")

        data = {
            "messages": history,
            **config_data
        }

        headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}"
            }

        request_data = json.dumps(data).encode('utf-8')
        request = urllib.request.Request(
            endpoint,
            data=request_data,
            headers=headers,
            method="POST"
        )

        try:
            with urllib.request.urlopen(request) as response:
                response_data = response.read()
                return json.loads(response_data)
        except urllib.error.HTTPError as e:
            error_message = e.read().decode('utf-8')
            raise Exception(f"API request failed: {error_message}")
