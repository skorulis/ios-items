"""Orchestrator: runs playtest episodes using the LLM agent and ItemsEnv, then requests a structured feedback report."""

from __future__ import annotations

import json
import sys
import threading
from typing import Any

from openai import OpenAI

from config import (
    BASE_URL,
    MAX_STEPS_PER_EPISODE,
    MODEL_NAME,
    OPENAI_API_BASE as CONFIG_OPENAI_BASE,
    OPENAI_API_KEY as CONFIG_OPENAI_KEY,
    OPENROUTER_API_BASE,
    OPENROUTER_DEFAULT_MODEL,
)
from items_env import ItemsEnv, ItemsEnvError
from tools import build_tools_from_links, dispatch_tool_call

SYSTEM_PROMPT = """You are a playtester for the game "Items" (a crafting/inventory game). Your goal is to **maximise the number of achievements reached**.

- Use /actions to get the currently available endpoints
- Use the get_* tools to inspect current state (items, artifacts, upgrades).
- Use the post_* tools to perform actions (e.g. craft an item, purchase an upgrade).
- Do not spam the same request repeatedly; explore systematically.
- **Check achievements first**: Use get_achievements to see which achievements are completed and which are incomplete. Incomplete achievements list their requirement (what you need to do to unlock them).
- **Plan then act**: Use get_items, get_upgrades, get_artifacts (if available) to understand current state. Then use post_* tools to take actions that progress toward incomplete achievements (e.g. craft items with post_make, buy upgrades with post_upgrades_purchase).
- **Iterate**: Keep taking actions that move you toward incomplete achievements until you cannot progress further or have tried the main options.
- **Finish**: When you have maximised achievements (or hit a wall), respond with a short message saying you are done. Summarise how many achievements you reached and what you did. Do not use tools after that.

Do not repeat the same action over and over; vary your approach to unlock different achievements."""

REPORT_PROMPT = """You just completed a playtest session for the game "Items" with the goal of maximising achievements. Below is the transcript of the session (state snapshots and tool calls/results).

Write a structured feedback report with these sections:

1. **Achievements**: How many were reached; which ones; which incomplete ones you could not unlock and why.
2. **What worked well**: Actions or sequences that reliably unlocked achievements; clear requirements; good feedback.
3. **What did not work well**: Unclear requirements, actions that did not progress achievements, balance or pacing issues, confusing feedback.
4. **Bugs or edge cases**: Odd behaviour, soft locks, inconsistent state.
5. **Suggestions**: Concrete ideas to make achievement progression clearer or more satisfying.

Format as markdown. Be concise."""


def run_episode(
    env: ItemsEnv,
    client: OpenAI,
    model: str,
    max_steps: int,
    stop_event: threading.Event | None = None,
) -> tuple[list[dict[str, Any]], str]:
    """
    Run one playtest episode. Returns (message_history, final_report_text).
    If stop_event is set (e.g. by the user typing "stop"), the loop exits and the report is generated from the current transcript.
    """
    env.fetch_actions()
    links = env._links
    tools_schema = build_tools_from_links(links)
    if not tools_schema:
        return [], "Error: no actions discovered from GET /actions."

    messages: list[dict[str, Any]] = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {
            "role": "user",
            "content": (
                "Current game state:\n\n"
                + env.get_state_summary()
                + "\n\nYour goal: maximise the number of achievements reached. "
                "Use get_* tools (especially get_achievements) whenever you need to inspect state."
            ),
        },
    ]
    step = 0
    while step < max_steps:
        if stop_event and stop_event.is_set():
            break
        step += 1
        response = client.chat.completions.create(
            model=model,
            messages=messages,
            tools=tools_schema,
            tool_choice="auto",
        )
        choice = response.choices[0]
        msg = choice.message
        if not msg:
            break
        raw_tool_calls = getattr(msg, "tool_calls", None) or []
        tool_calls_serialized = [
            {
                "id": getattr(tc, "id", None) or (tc.get("id") if isinstance(tc, dict) else ""),
                "type": "function",
                "function": {
                    "name": getattr(getattr(tc, "function", None) or {}, "name", None) or (tc.get("function") or {}).get("name", ""),
                    "arguments": getattr(getattr(tc, "function", None) or {}, "arguments", None) or (tc.get("function") or {}).get("arguments", "{}"),
                },
            }
            for tc in raw_tool_calls
        ]
        messages.append({"role": "assistant", "content": msg.content or "", "tool_calls": tool_calls_serialized})

        if not raw_tool_calls:
            break

        for tc in raw_tool_calls:
            name = tc.function.name if hasattr(tc.function, "name") else tc.get("function", {}).get("name")
            args_raw = tc.function.arguments if hasattr(tc.function, "arguments") else tc.get("function", {}).get("arguments", "{}")
            try:
                args = json.loads(args_raw) if isinstance(args_raw, str) else (args_raw or {})
            except json.JSONDecodeError:
                args = {}
            result = dispatch_tool_call(env, name, args)
            messages.append({
                "role": "tool",
                "tool_call_id": tc.id if hasattr(tc, "id") else tc.get("id"),
                "content": result,
            })

        messages.append(
            {
                "role": "user",
                "content": (
                    "Continue. Use get_* tools to inspect state when needed, and say you're done "
                    "when you have finished maximising achievements."
                ),
            }
        )

    if stop_event and stop_event.is_set():
        print("Stop requested; generating report from current transcript.", file=sys.stderr)

    transcript = _format_transcript(messages)
    report = _request_report(client, model, transcript)
    return messages, report


def _tool_call_repr(tc: Any) -> dict[str, Any]:
    """Normalize tool call (object or dict) to {name, args} for transcript."""
    if hasattr(tc, "function"):
        fn = tc.function
        name = getattr(fn, "name", "")
        args = getattr(fn, "arguments", "{}")
    else:
        fn = (tc or {}).get("function") or {}
        name = fn.get("name", "")
        args = fn.get("arguments", "{}")
    return {"name": name, "args": args}


def _format_transcript(messages: list[dict[str, Any]]) -> str:
    """Format message history into a readable transcript for the report prompt."""
    lines = []
    for m in messages:
        role = m.get("role", "")
        if role == "user":
            lines.append("[User]\n" + (m.get("content") or ""))
        elif role == "assistant":
            content = m.get("content") or ""
            if m.get("tool_calls"):
                content += "\n(Tool calls: " + json.dumps([_tool_call_repr(tc) for tc in m["tool_calls"]], default=str) + ")"
            lines.append("[Assistant]\n" + content)
        elif role == "tool":
            lines.append("[Tool result]\n" + (m.get("content") or ""))
        lines.append("")
    return "\n".join(lines)


def _request_report(client: OpenAI, model: str, transcript: str) -> str:
    """Ask the LLM for a structured feedback report given the transcript."""
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "user", "content": REPORT_PROMPT + "\n\n---\n\n" + transcript},
            ],
        )
        msg = response.choices[0].message
        return (msg.content or "").strip()
    except Exception as e:
        return f"Failed to generate report: {e}"


def _stdin_stop_listener(stop_event: threading.Event) -> None:
    """Daemon thread: read stdin; set stop_event when user types 'stop', 'quit', or Enter."""
    try:
        while True:
            line = sys.stdin.readline()
            if not line:
                break
            if line.strip().lower() in ("stop", "quit", "q", ""):
                stop_event.set()
                break
    except (EOFError, OSError):
        pass


def main() -> None:
    import os
    base_url = os.environ.get("ITEMS_DEBUGGER_URL", BASE_URL)
    max_steps = int(os.environ.get("ITEMS_MAX_STEPS", str(MAX_STEPS_PER_EPISODE)))
    api_base = os.environ.get("OPENAI_API_BASE")
    api_key = os.environ.get("OPENAI_API_KEY")
    openrouter_key = os.environ.get("OPENROUTER_API_KEY")

    if openrouter_key:
        api_base = OPENROUTER_API_BASE
        api_key = openrouter_key
        model = os.environ.get("ITEMS_PLAYTEST_MODEL") or OPENROUTER_DEFAULT_MODEL
        system_name = "OpenRouter"
    else:
        model = os.environ.get("ITEMS_PLAYTEST_MODEL", MODEL_NAME)
        api_base = api_base or CONFIG_OPENAI_BASE
        api_key = api_key or CONFIG_OPENAI_KEY
        system_name = "OpenAI" if not api_base else "Local"

    if not api_base and not api_key:
        print(
            "Set OPENAI_API_KEY for OpenAI, OPENROUTER_API_KEY for free OpenRouter models, or OPENAI_API_BASE for a local server (e.g. Ollama).",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"System: {system_name}  Model: {model}", file=sys.stderr)

    env = ItemsEnv(base_url=base_url)
    try:
        env.fetch_actions()
    except ItemsEnvError as e:
        print(f"Fatal: {e}", file=sys.stderr)
        sys.exit(1)

    client_kwargs: dict[str, str] = {}
    if api_base:
        client_kwargs["base_url"] = api_base
    if api_key:
        client_kwargs["api_key"] = api_key
    elif api_base:
        client_kwargs["api_key"] = "ollama"
    client = OpenAI(**client_kwargs)

    stop_event: threading.Event | None = None
    if sys.stdin.isatty():
        stop_event = threading.Event()
        t = threading.Thread(target=_stdin_stop_listener, args=(stop_event,), daemon=True)
        t.start()
        print("Type 'stop' or press Enter to finish early and generate report.", file=sys.stderr)

    print("Starting playtest episode...", file=sys.stderr)
    messages, report = run_episode(env, client, model, max_steps, stop_event=stop_event)
    print("\n--- Feedback report ---\n")
    print(report)
    print("\n--- End report ---")


if __name__ == "__main__":
    main()
