"""Orchestrator: runs playtest episodes using the LLM agent and ItemsEnv, then requests a structured feedback report."""

from __future__ import annotations

import json
import sys
from typing import Any

from openai import OpenAI

from config import BASE_URL, MAX_STEPS_PER_EPISODE, MODEL_NAME
from items_env import ItemsEnv, ItemsEnvError
from tools import build_tools_from_links, dispatch_tool_call

SYSTEM_PROMPT = """You are a QA playtester for the game "Items" (a crafting/inventory game). Your job is to explore the game via the available tools, try different actions, and gather information about balance, progression, and possible bugs.

- Use the get_* tools to inspect current state (items, artifacts, upgrades).
- Use the post_* tools to perform actions (e.g. craft an item, purchase an upgrade).
- Do not spam the same action repeatedly; explore systematically.
- After you have explored enough (e.g. tried several actions and seen the state), respond with a short message saying you are done testing this run, and summarize what you did in 1-2 sentences. Do not use tools after that."""

REPORT_PROMPT = """You just completed a playtest session for the game "Items". Below is the transcript of the session (state snapshots and tool calls/results).

Write a structured feedback report with these sections:

1. **Overall impression**: 2-3 sentences on how the session went.
2. **Balance issues**: Bullet list; for each: title, severity (minor/major/blocker), what happened, suspected cause if any.
3. **Progression & pacing**: Any issues with unlock pace or clarity of goals.
4. **UX / clarity**: Confusing wording, unclear goals, or unclear feedback.
5. **Bugs or edge cases**: Odd behavior, soft locks, inconsistent state.
6. **Suggestions**: Concrete ideas for tweaks.

Format as markdown. Be concise."""


def run_episode(env: ItemsEnv, client: OpenAI, model: str, max_steps: int) -> tuple[list[dict[str, Any]], str]:
    """
    Run one playtest episode. Returns (message_history, final_report_text).
    """
    env.fetch_actions()
    links = env._links
    tools_schema = build_tools_from_links(links)
    if not tools_schema:
        return [], "Error: no actions discovered from GET /actions."

    messages: list[dict[str, Any]] = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": "Current game state:\n\n" + env.get_state_summary() + "\n\nExplore the game and report when done."},
    ]
    step = 0
    while step < max_steps:
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

        messages.append({
            "role": "user",
            "content": "Updated state:\n\n" + env.get_state_summary() + "\n\nContinue or say you're done.",
        })

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


def main() -> None:
    import os
    base_url = os.environ.get("ITEMS_DEBUGGER_URL", BASE_URL)
    max_steps = int(os.environ.get("ITEMS_MAX_STEPS", str(MAX_STEPS_PER_EPISODE)))
    model = os.environ.get("ITEMS_PLAYTEST_MODEL", MODEL_NAME)
    api_base = os.environ.get("OPENAI_API_BASE") or OPENAI_API_BASE
    api_key = os.environ.get("OPENAI_API_KEY") or OPENAI_API_KEY

    if not api_base and not api_key:
        print("Set OPENAI_API_KEY for OpenAI, or OPENAI_API_BASE for a free local server (e.g. Ollama).", file=sys.stderr)
        sys.exit(1)

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
    print("Starting playtest episode...")
    messages, report = run_episode(env, client, model, max_steps)
    print("\n--- Feedback report ---\n")
    print(report)
    print("\n--- End report ---")


if __name__ == "__main__":
    main()
