"""Login + token capture against the gateway."""
from __future__ import annotations

from dataclasses import dataclass

import httpx


@dataclass
class AuthSession:
    access_token: str
    cookies: httpx.Cookies

    def auth_headers(self) -> dict[str, str]:
        return {"Authorization": f"Bearer {self.access_token}"}


async def login(
    client: httpx.AsyncClient, gateway: str, email: str, password: str,
) -> AuthSession:
    url = f"{gateway.rstrip('/')}/api-auth/auth/login"
    resp = await client.post(url, json={"email": email, "password": password})
    if resp.status_code != 200:
        raise RuntimeError(f"login failed: {resp.status_code} {resp.text[:300]}")
    body = resp.json()
    # Langfens API envelope: {"isSuccess": bool, "message": str, "data": <token-str>}
    token = body.get("data") if isinstance(body.get("data"), str) else None
    # Fallback for other shapes (forward compatibility)
    if not token:
        token = (
            body.get("accessToken")
            or body.get("token")
            or body.get("access_token")
        )
    if not token:
        raise RuntimeError(
            f"login response missing access token; keys={list(body.keys())[:5]}"
        )
    return AuthSession(access_token=token, cookies=resp.cookies)
