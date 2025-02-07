# TODO: delete hardcoded api key
class OpenAIClient:
    def __init__(
            self,
            api_key: str = 'YOUR_API_KEY',
            model: str = "gpt-3.5-turbo"
    ) -> None:
        """
        Initialize OpenAI client with API key and optional model selection.

        Args:
            api_key: OpenAI API key
            model: Model to use for completions (default: gpt-3.5-turbo)
        """
        # Get API key from environment variable
        api_key = os.getenv("OPENAI_API_KEY") or api_key
        if not api_key:
            raise ValueError("Please set OPENAI_API_KEY environment variable")
        self.api_key = api_key
        self.model = model
        self.base_url = "https://api.openai.com/v1"

    def create_completion(
        self,
        history: List[Dict[str, str]],
        max_tokens: int = 150,
        temperature: float = 0.7,
        top_p: float = 1.0,
        frequency_penalty: float = 0.0,
        presence_penalty: float = 0.0
    ) -> Dict[str, Any]:
        """
        Send a completion request to OpenAI API.

        Args:
            history: The history that is being sent to OpenAI
            max_tokens: Maximum number of tokens to generate
            temperature: Sampling temperature (0-2)
            top_p: Nucleus sampling parameter
            frequency_penalty: Frequency penalty parameter (-2 to 2)
            presence_penalty: Presence penalty parameter (-2 to 2)

        Returns:
            Dict containing the API response

        Raises:
            urllib.error.HTTPError: If the API request fails
            json.JSONDecodeError: If the response isn't valid JSON
        """
        endpoint = f"{self.base_url}/chat/completions"

        data = {
            "model": self.model,
            "messages": history,
            "max_tokens": max_tokens,
            "temperature": temperature,
            "top_p": top_p,
            "frequency_penalty": frequency_penalty,
            "presence_penalty": presence_penalty
        }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }

        # Prepare the request
        request_data = json.dumps(data).encode('utf-8')
        request = urllib.request.Request(
            endpoint,
            data=request_data,
            headers=headers,
            method="POST"
        )

        try:
            # Send the request
            with urllib.request.urlopen(request) as response:
                response_data = response.read()
                return json.loads(response_data)
        except urllib.error.HTTPError as e:
            error_message = e.read().decode('utf-8')
            raise Exception(f"API request failed: {error_message}")


