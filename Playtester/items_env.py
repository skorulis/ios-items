"""HTTP client for the ItemsDebugger service. Discovers actions via GET /actions and exposes GET/POST helpers."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from typing import Any

import httpx

from config import BASE_URL, REQUEST_TIMEOUT_SECONDS


@dataclass
class Link:
    """A HATEOAS link from GET /actions."""

    href: str
    action: str  # "GET" or "POST"
    description: str = ""  # Optional: human-readable description from the API

    @property
    def tool_name(self) -> str:
        """Derive a stable tool name from href (e.g. /items -> get_items, /upgrades/purchase -> post_upgrades_purchase)."""
        path = self.href.split("{")[0].strip("/")
        if not path:
            path = "root"
        safe = path.replace("/", "_")
        prefix = "get" if self.action == "GET" else "post"
        return f"{prefix}_{safe}"

    def query_params_from_href(self) -> list[str]:
        """Extract query parameter names from URI template, e.g. /upgrades/purchase{?id} -> ['id']."""
        match = re.search(r"\{\?([^}]+)\}", self.href)
        if not match:
            return []
        return [p.strip() for p in match.group(1).split(",")]


class ItemsEnvError(Exception):
    """Raised when a request to the debugger fails."""

    pass


class ItemsEnv:
    """Environment wrapper: discovers links from GET /actions and performs GET/POST against the debugger."""

    def __init__(self, base_url: str = BASE_URL, timeout: float = REQUEST_TIMEOUT_SECONDS) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self._links: list[Link] = []

    def fetch_actions(self) -> list[Link]:
        """GET /actions, parse _links, cache and return them."""
        try:
            with httpx.Client(timeout=self.timeout) as client:
                r = client.get(f"{self.base_url}/actions")
                r.raise_for_status()
                data = r.json()
        except httpx.HTTPError as e:
            raise ItemsEnvError(f"Failed to fetch actions from {self.base_url}/actions: {e}") from e

        raw = data.get("_links", [])
        self._links = [
            Link(
                href=item["href"],
                action=item.get("action", "GET"),
                description=item.get("description") or "",
            )
            for item in raw
            if isinstance(item.get("href"), str)
        ]
        return self._links

    def _get(self, path: str) -> Any:
        """GET a path (e.g. /items) and return parsed JSON."""
        url = f"{self.base_url}{path}" if path.startswith("/") else f"{self.base_url}/{path}"
        try:
            with httpx.Client(timeout=self.timeout) as client:
                r = client.get(url)
                r.raise_for_status()
                return r.json()
        except httpx.HTTPError as e:
            raise ItemsEnvError(f"GET {path} failed: {e}") from e

    def _post(self, path: str, params: dict[str, Any] | None = None) -> Any:
        """POST to a path. Resolves URI template in path with params (e.g. {?id} -> ?id=value)."""
        params = params or {}
        # Resolve template: /upgrades/purchase{?id} + params id=foo -> /upgrades/purchase?id=foo
        base_path = re.sub(r"\{\?[^}]+\}", "", path).rstrip("?")
        query_parts = Link(href=path, action="POST").query_params_from_href()
        query = "&".join(f"{k}={params.get(k)}" for k in query_parts if params.get(k) is not None)
        if query:
            path_with_query = f"{base_path}?{query}"
        else:
            path_with_query = base_path
        url = f"{self.base_url}{path_with_query}" if path_with_query.startswith("/") else f"{self.base_url}/{path_with_query}"
        try:
            with httpx.Client(timeout=self.timeout) as client:
                r = client.post(url)
                r.raise_for_status()
                return r.json()
        except httpx.HTTPError as e:
            raise ItemsEnvError(f"POST {path_with_query} failed: {e}") from e

    def get(self, path: str) -> Any:
        """Fetch data from a GET link. Returns JSON."""
        return self._get(path)

    def post(self, path: str, params: dict[str, Any] | None = None) -> Any:
        """Perform a POST action. Params are used to fill URI template query (e.g. id for purchase)."""
        return self._post(path, params)

    def get_state_summary(self) -> str:
        """Call all current GET links (from last fetch_actions), merge and return a short text summary for the LLM."""
        if not self._links:
            self.fetch_actions()
        get_links = [l for l in self._links if l.action == "GET"]
        parts: list[str] = []
        for link in get_links:
            path = link.href.split("{")[0]
            try:
                data = self._get(path)
                parts.append(f"{link.tool_name}: {json.dumps(data, default=str)}")
            except ItemsEnvError as e:
                parts.append(f"{link.tool_name}: error — {e}")
        return "\n".join(parts) if parts else "No data endpoints available."
