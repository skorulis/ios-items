"""Build LLM tool schemas from _links and dispatch tool calls to ItemsEnv."""

from __future__ import annotations

import json
from typing import Any

from items_env import ItemsEnv, ItemsEnvError, Link


def link_to_openai_tool(link: Link) -> dict[str, Any]:
    """Convert a HATEOAS link to an OpenAI function/tool definition."""
    params: dict[str, Any] = {}
    for q in link.query_params_from_href():
        params[q] = {"type": "string", "description": f"Query parameter: {q}"}

    if link.description and link.description.strip():
        description = link.description.strip()
        if params:
            description += f" Parameters: {', '.join(params)}."
    elif link.action == "GET":
        description = f"Fetch data from {link.href}."
    else:
        desc_extra = f" Parameters: {', '.join(params)}." if params else ""
        description = f"Perform action at {link.href}.{desc_extra}"

    tool: dict[str, Any] = {
        "type": "function",
        "function": {
            "name": link.tool_name,
            "description": description,
        },
    }
    if params:
        tool["function"]["parameters"] = {
            "type": "object",
            "properties": params,
            "required": list(params),
        }
    return tool


def build_tools_from_links(links: list[Link]) -> list[dict[str, Any]]:
    """Build the list of OpenAI tool definitions from the discovered links.

    In addition to tools for each link, we always expose a synthetic `get_actions`
    tool that refreshes the list of available endpoints from GET /actions.
    """
    tools = [link_to_openai_tool(link) for link in links]
    tools.append(
        {
            "type": "function",
            "function": {
                "name": "get_actions",
                "description": (
                    "Refresh the list of available game actions and data endpoints "
                    "from GET /actions. Returns their tool names, hrefs, methods, "
                    "and descriptions."
                ),
            },
        }
    )
    return tools


def dispatch_tool_call(env: ItemsEnv, tool_name: str, arguments: dict[str, Any] | None) -> str:
    """
    Execute a tool by name. Arguments are passed to POST when the link has query params.
    Returns a string result (JSON or error message) for the LLM.
    """
    arguments = arguments or {}

    # Synthetic utility tool: get_actions
    if tool_name == "get_actions":
        env.fetch_actions()
        links = env._links
        payload = [
            {
                "tool_name": link.tool_name,
                "href": link.href,
                "method": link.action,
                "description": link.description,
            }
            for link in links
        ]
        return json.dumps(payload, default=str)

    links = env._links
    if not links:
        env.fetch_actions()
        links = env._links

    for link in links:
        if link.tool_name != tool_name:
            continue
        try:
            if link.action == "GET":
                path = link.href.split("{")[0]
                data = env.get(path)
                return json.dumps(data, default=str)
            else:
                path = link.href
                params = {k: arguments.get(k) for k in link.query_params_from_href() if k in arguments}
                data = env.post(path, params=params if params else None)
                return json.dumps(data, default=str)
        except ItemsEnvError as e:
            return json.dumps({"error": str(e)})

    return json.dumps({"error": f"Unknown tool: {tool_name}"})
