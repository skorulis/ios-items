"""Configuration for the LLM playtester. Base URL, timeouts, and episode limits."""

import os

BASE_URL: str = os.environ.get("ITEMS_DEBUGGER_URL", "http://localhost:8765")
REQUEST_TIMEOUT_SECONDS: float = float(os.environ.get("ITEMS_REQUEST_TIMEOUT", "10.0"))
MAX_STEPS_PER_EPISODE: int = int(os.environ.get("ITEMS_MAX_STEPS", "50"))
MODEL_NAME: str = os.environ.get("ITEMS_PLAYTEST_MODEL", "gpt-4o-mini")

# LLM API: leave unset to use OpenAI. Set to a base URL for a local/free OpenAI-compatible server (e.g. Ollama).
# Example: OPENAI_API_BASE=http://localhost:11434/v1 and ITEMS_PLAYTEST_MODEL=llama3.2
OPENAI_API_BASE: str | None = os.environ.get("OPENAI_API_BASE") or None
OPENAI_API_KEY: str | None = os.environ.get("OPENAI_API_KEY") or None

# OpenRouter: free models with tool calling. Get a key at https://openrouter.ai/keys
# Set OPENROUTER_API_KEY to use OpenRouter; ITEMS_PLAYTEST_MODEL can override the default.
OPENROUTER_API_BASE: str = "https://openrouter.ai/api/v1"
OPENROUTER_DEFAULT_MODEL: str = "arcee-ai/trinity-large-preview:free"
