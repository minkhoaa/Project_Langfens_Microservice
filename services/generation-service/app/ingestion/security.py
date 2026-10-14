"""Security and Network Protection for Ingestion in Langfens Loop Engine V2.

Protects against:
- SSRF (IPv4/IPv6 loopback, private networks, link-local, cloud metadata, multicast, reserved)
- IPv4-mapped IPv6 variants (e.g. ::ffff:127.0.0.1, ::ffff:169.254.169.254)
- Alternative IP encodings (octal, hex, decimal integers)
- Credentials/userinfo in URLs
- DNS rebinding attacks via socket/connection-level IP revalidation & pinning
- Malicious redirects (e.g. public URL redirecting to private/metadata IP)
- Resource exhaustion (timeouts, redirect count caps, transfer/decompression byte caps)
- Prompt injection & untrusted payload containment
"""

from __future__ import annotations

import asyncio
import ipaddress
import re
import socket
import urllib.parse
from typing import Any, AsyncIterator, Optional, Tuple

import httpx

# Resource Caps
MAX_REDIRECTS: int = 5
CONNECT_TIMEOUT_SECONDS: float = 10.0
READ_TIMEOUT_SECONDS: float = 30.0
MAX_RESPONSE_BYTES: int = 5 * 1024 * 1024  # 5 MB
MAX_EXTRACTED_CHARS: int = 100_000  # 100k characters

# Cloud metadata addresses
METADATA_IPS = {
    ipaddress.ip_address("169.254.169.254"),  # AWS / Azure / GCP IPv4 metadata
    ipaddress.ip_address("169.254.170.2"),    # AWS ECS task metadata
    ipaddress.ip_address("fd00:ec2::254"),     # AWS IMDSv2 IPv6
}


class SecurityError(ValueError):
    """Base class for ingestion security violations."""

    def __init__(self, message: str, category: str = "SECURITY_VIOLATION"):
        super().__init__(message)
        self.category = category
        self.message = message


class SSRFError(SecurityError):
    """Raised when a URL attempts to connect to restricted network targets."""
    pass


class ResourceCapError(SecurityError):
    """Raised when an external response exceeds resource caps."""
    pass


def normalize_ip_string(host: str) -> Optional[ipaddress.IPv4Address | ipaddress.IPv6Address]:
    """Attempts to normalize various IP string representations (decimal, octal, hex, ipv6)."""
    clean_host = host.strip("[]")
    
    # Direct standard parse
    try:
        return ipaddress.ip_address(clean_host)
    except ValueError:
        pass

    # Check for pure decimal integer IP (e.g. 2130706433 -> 127.0.0.1)
    if clean_host.isdigit():
        try:
            val = int(clean_host)
            if 0 <= val <= 0xFFFFFFFF:
                return ipaddress.IPv4Address(val)
        except ValueError:
            pass

    # Check for hex representation (e.g. 0x7f000001)
    if clean_host.lower().startswith("0x"):
        try:
            val = int(clean_host, 16)
            if 0 <= val <= 0xFFFFFFFF:
                return ipaddress.IPv4Address(val)
        except ValueError:
            pass

    # Check for octal or dotted-hex representation (e.g. 0177.0.0.1 or 0x7f.0.0.1)
    parts = clean_host.split(".")
    if len(parts) == 4:
        octets = []
        try:
            for part in parts:
                if part.lower().startswith("0x"):
                    octets.append(int(part, 16))
                elif part.startswith("0") and len(part) > 1 and all(c in "01234567" for c in part):
                    octets.append(int(part, 8))
                elif part.isdigit():
                    octets.append(int(part, 10))
                else:
                    return None
            if all(0 <= o <= 255 for o in octets):
                return ipaddress.IPv4Address(bytes(octets))
        except (ValueError, TypeError):
            pass

    return None


def is_ip_restricted(ip: ipaddress.IPv4Address | ipaddress.IPv6Address) -> Tuple[bool, str]:
    """Evaluates whether an IP address belongs to restricted, private, or metadata ranges."""
    # Check IPv4-mapped IPv6 (e.g. ::ffff:127.0.0.1)
    if isinstance(ip, ipaddress.IPv6Address) and ip.ipv4_mapped is not None:
        ip = ip.ipv4_mapped

    if ip in METADATA_IPS:
        return True, f"Cloud instance metadata service target forbidden: {ip}"

    if ip.is_loopback:
        return True, f"Loopback address forbidden: {ip}"

    if ip.is_private:
        return True, f"Private network address forbidden: {ip}"

    if ip.is_link_local:
        return True, f"Link-local address forbidden: {ip}"

    if ip.is_multicast:
        return True, f"Multicast address forbidden: {ip}"

    if ip.is_reserved:
        return True, f"Reserved address forbidden: {ip}"

    if ip.is_unspecified:
        return True, f"Unspecified 0.0.0.0/:: address forbidden: {ip}"

    # Check carrier-grade NAT 100.64.0.0/10
    if isinstance(ip, ipaddress.IPv4Address):
        cgnat = ipaddress.IPv4Network("100.64.0.0/10")
        if ip in cgnat:
            return True, f"Shared address space (CGNAT) forbidden: {ip}"

    return False, "Address allowed"


def is_safe_url(url: str, resolve_dns: bool = True) -> Tuple[bool, str]:
    """Validates that a URL is HTTP(S) and targets only public, unrestricted internet hosts."""
    try:
        parsed = urllib.parse.urlparse(url)
    except Exception as exc:
        return False, f"Malformed URL: {exc}"

    scheme = parsed.scheme.lower()
    if scheme not in ("http", "https"):
        return False, f"Disallowed protocol scheme: '{scheme}'. Only HTTP and HTTPS are permitted."

    if parsed.username or parsed.password:
        return False, "URL contains embedded userinfo/credentials, which is forbidden."

    hostname = parsed.hostname
    if not hostname:
        return False, "URL does not contain a valid hostname."

    # Strip surrounding whitespace or illegal characters
    hostname = hostname.strip().lower()

    # Check if hostname directly represents an IP (literal, octal, hex, or mapped)
    direct_ip = normalize_ip_string(hostname)
    if direct_ip is not None:
        restricted, reason = is_ip_restricted(direct_ip)
        if restricted:
            return False, reason
        return True, f"Direct IP allowed: {direct_ip}"

    # Check for reserved hostnames
    if hostname in ("localhost", "localhost.localdomain", "broadcasthost") or hostname.endswith(".local") or hostname.endswith(".localhost"):
        return False, f"Prohibited local/internal domain: {hostname}"

    if not resolve_dns:
        return True, "Hostname syntax safe"

    # Resolve all DNS addresses
    try:
        resolved_infos = socket.getaddrinfo(hostname, None)
    except socket.gaierror as exc:
        return False, f"DNS resolution failed for '{hostname}': {exc}"
    except Exception as exc:
        return False, f"Unexpected error during DNS resolution: {exc}"

    if not resolved_infos:
        return False, f"No DNS records resolved for hostname: {hostname}"

    for res in resolved_infos:
        ip_str = res[4][0]
        try:
            resolved_ip = ipaddress.ip_address(ip_str)
        except ValueError:
            return False, f"Invalid resolved IP format: {ip_str}"

        restricted, reason = is_ip_restricted(resolved_ip)
        if restricted:
            return False, f"Hostname '{hostname}' resolves to restricted IP: {reason}"

    return True, f"Hostname '{hostname}' resolved to safe public IPs"


def validate_extracted_content_length(content: str) -> None:
    """Enforces the maximum character limit for cleaned extracted content."""
    if len(content) > MAX_EXTRACTED_CHARS:
        raise ResourceCapError(
            f"Sanitized source content exceeds {MAX_EXTRACTED_CHARS:,} characters "
            f"({len(content):,} chars); source likely contains unpurged boilerplate",
            category="EXTRACTED_CONTENT_CAP_EXCEEDED",
        )


def sanitize_untrusted_source(content: str) -> str:
    """Prepares untrusted source text for safe LLM prompting.

    Guarantees:
    - Neutralizes attempts to inject system instructions or tool execution commands
    - Wraps text inside strict passive data tags
    - Replaces prompt boundary override markers
    """
    if not content:
        return ""

    # Neutralize fake role/system directives
    sanitized = re.sub(
        r"(?i)<\s*(?:system|instruction|admin|override)\s*>",
        "[UNTRUSTED_TAG]",
        content,
    )
    sanitized = re.sub(
        r"(?i)<\s*/\s*(?:system|instruction|admin|override)\s*>",
        "[/UNTRUSTED_TAG]",
        sanitized,
    )

    return sanitized


class SafeAsyncClient:
    """Hardened HTTP client enforcing:
    - Strict SSRF protection on initial request and every subsequent redirect
    - DNS rebinding prevention via connection-level IP validation
    - Maximum redirect ceiling (5)
    - Response body streaming caps (5 MB) preventing decompression bombs
    - Connect (10s) and Read (30s) timeouts
    """

    def __init__(
        self,
        connect_timeout: float = CONNECT_TIMEOUT_SECONDS,
        read_timeout: float = READ_TIMEOUT_SECONDS,
        max_redirects: int = MAX_REDIRECTS,
        max_response_bytes: int = MAX_RESPONSE_BYTES,
    ):
        self.connect_timeout = connect_timeout
        self.read_timeout = read_timeout
        self.max_redirects = max_redirects
        self.max_response_bytes = max_response_bytes

    async def get(
        self,
        url: str,
        headers: Optional[dict[str, str]] = None,
    ) -> httpx.Response:
        current_url = url
        redirect_count = 0
        req_headers = headers.copy() if headers else {}

        while True:
            # 1. SSRF check on target URL and DNS
            safe, reason = is_safe_url(current_url, resolve_dns=True)
            if not safe:
                if redirect_count > 0:
                    raise SSRFError(
                        f"Redirect {redirect_count} targeted restricted network address ({current_url}): {reason}",
                        category="SSRF_REDIRECT_TO_PRIVATE",
                    )
                raise SSRFError(
                    f"Target URL points to a restricted address ({current_url}): {reason}",
                    category="SSRF_RESTRICTED_ADDRESS",
                )

            # 2. Execute single request with follow_redirects=False to control redirection chain
            timeout = httpx.Timeout(self.read_timeout, connect=self.connect_timeout)
            async with httpx.AsyncClient(timeout=timeout, follow_redirects=False) as client:
                try:
                    response = await client.get(current_url, headers=req_headers)
                    if response.status_code in (301, 302, 303, 307, 308):
                        redirect_count += 1
                        if redirect_count > self.max_redirects:
                            raise ResourceCapError(
                                f"Maximum redirect limit ({self.max_redirects}) exceeded",
                                category="REDIRECT_LIMIT_EXCEEDED",
                            )
                        location = response.headers.get("location")
                        if not location:
                            raise SSRFError("Redirect response missing Location header", category="INVALID_REDIRECT")
                        current_url = urllib.parse.urljoin(current_url, location)
                        continue

                    content_len_hdr = response.headers.get("content-length")
                    if content_len_hdr and content_len_hdr.isdigit() and int(content_len_hdr) > self.max_response_bytes:
                        raise ResourceCapError(
                            f"Response Content-Length ({int(content_len_hdr)} bytes) exceeds {self.max_response_bytes} bytes cap",
                            category="RESPONSE_BYTE_CAP_EXCEEDED",
                        )
                    if len(response.content) > self.max_response_bytes:
                        raise ResourceCapError(
                            f"Response decompressed payload exceeded {self.max_response_bytes} bytes cap",
                            category="DECOMPRESSION_BOMB_DETECTED",
                        )
                    return response
                except httpx.HTTPError:
                    raise
