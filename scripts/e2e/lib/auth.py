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
    url = f"{gateway.rstrip('/')}/api-auth/api/auth/login"
    resp = await client.post(url, json={"email": email, "password": password})
    if resp.status_code != 200:
        raise RuntimeError(f"login failed: {resp.status_code} {resp.text[:300]}")
    body = resp.json()
    # Token field may live under different keys depending on auth-service shape;
    # accept several common spellings for forward compatibility.
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
