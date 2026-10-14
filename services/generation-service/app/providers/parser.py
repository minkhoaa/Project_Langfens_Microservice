from __future__ import annotations

import json
import logging
import re
from typing import Any, Dict, List, Optional, Type, Union
from pydantic import BaseModel, ValidationError

from app.providers.errors import (
    InvalidJsonError,
    SchemaMismatchError,
    TruncatedOutputError,
)

logger = logging.getLogger(__name__)


def _reject_constant(val: str) -> None:
    raise ValueError(f"Constant '{val}' (NaN or Infinity) is prohibited in canonical JSON")


def _strip_trailing_commas(text: str) -> str:
    """Remove trailing commas before closing brackets/braces quote-aware.

    Does NOT touch commas inside string literals (single or double quoted).
    Bounded, idempotent; safe across the entire response text.
    """
    if not text:
        return text
    out: List[str] = []
    in_double = False
    in_single = False
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if not in_double and not in_single:
            if c == '"':
                in_double = True
                out.append(c)
                i += 1
            elif c == "'":
                in_single = True
                out.append(c)
                i += 1
            elif c == ",":
                # Look ahead for whitespace then '}' or ']'
                j = i + 1
                while j < n and text[j] in " \t\r\n":
                    j += 1
                if j < n and text[j] in "}]":
                    # Trailing comma! Skip this comma.
                    i += 1
                else:
                    out.append(c)
                    i += 1
            else:
                out.append(c)
                i += 1
        elif in_double:
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == '"':
                in_double = False
                out.append(c)
                i += 1
            else:
                out.append(c)
                i += 1
        else:  # in_single
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == "'":
                in_single = False
                out.append(c)
                i += 1
            else:
                out.append(c)
                i += 1
    return "".join(out)


def _is_real_closing_quote(text: str, quote_idx: int, prev_sig_char: str = "") -> bool:
    """Determine if text[quote_idx] is a real string closing quote or an internal unescaped quote.

    Handles edge cases like internal quotes followed by comma and prose:
    `{"passage": "... the \\"hot Jupiter\\", which was discovered ...", "score": 95}`
    or internal lists of quoted terms inside a property value (`prev_sig_char == ":"`):
    `{"passage": "... \\"red\\", \\"blue\\", and \\"green\\" light ...", "score": 95}`
    """
    n = len(text)
    if quote_idx >= n:
        return True
    j = quote_idx + 1
    while j < n and text[j] in " \t\r\n":
        j += 1
    if j == n:
        return True
    next_char = text[j]
    if next_char in "}]":
        return True
    if next_char == ":":
        if prev_sig_char == ":":
            return False
        k = j + 1
        while k < n and text[k] in " \t\r\n":
            k += 1
        if k < n and (text[k] in "\"{[-0123456789" or text[k:k + 4] in ("true", "null") or text[k:k + 5] == "false"):
            return True
        return False
    if next_char == ",":
        k = j + 1
        while k < n and text[k] in " \t\r\n":
            k += 1
        if prev_sig_char == ":":
            if k < n and text[k] in "}]":
                return True
            if k < n and text[k] in ("\"", "'"):
                q_char = text[k]
                q2 = text.find(q_char, k + 1, min(n, k + 65))
                if q2 != -1 and "\n" not in text[k + 1:q2]:
                    m = q2 + 1
                    while m < n and text[m] in " \t\r\n":
                        m += 1
                    if m < n and text[m] == ":":
                        return True
            return False
        if k < n and (text[k] in "\"{[-0123456789" or text[k:k + 4] in ("true", "null") or text[k:k + 5] == "false"):
            return True
        return False
    return False


def _repair_unescaped_newlines_in_strings(text: str) -> str:
    """Escape raw control characters (LF/CR/TAB) that appear inside JSON string
    tokens.
    """
    if not text:
        return text
    out: List[str] = []
    in_double = False
    in_single = False
    prev_sig_char = ""
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if not in_double and not in_single:
            if c == '"':
                in_double = True
                out.append(c)
                i += 1
            elif c == "'":
                in_single = True
                out.append(c)
                i += 1
            else:
                if c not in " \t\r\n":
                    prev_sig_char = c
                out.append(c)
                i += 1
        elif in_double:
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == '"':
                if _is_real_closing_quote(text, i, prev_sig_char):
                    in_double = False
                    prev_sig_char = '"'
                    out.append('"')
                    i += 1
                else:
                    out.append('\\"')
                    i += 1
            elif c == "\n":
                out.append("\\n")
                i += 1
            elif c == "\r":
                out.append("\\r")
                i += 1
            elif c == "\t":
                out.append("\\t")
                i += 1
            else:
                out.append(c)
                i += 1
        else:  # in_single
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == "'":
                # treat SQL-style '' inside a single-quoted string as a literal apostrophe
                if i + 1 < n and text[i + 1] == "'":
                    out.append("'")
                    out.append("'")
                    i += 2
                else:
                    in_single = False
                    out.append(c)
                    i += 1
            elif c == "\n":
                out.append("\\n")
                i += 1
            elif c == "\r":
                out.append("\\r")
                i += 1
            elif c == "\t":
                out.append("\\t")
                i += 1
            else:
                out.append(c)
                i += 1
    return "".join(out)


def _repair_unescaped_double_quotes_in_strings(text: str) -> str:
    """Escape internal unescaped double quotes inside double-quoted string tokens.

    Walks ``text`` character-by-character with a small state machine. When a
    double-quoted string is open, encountering a ``"`` that is NOT followed
    by a JSON delimiter (``:``, ``,``, ``}``, ``]``) or end-of-string is
    treated as an internal unescaped double quote and rewritten as ``\\"``
    so the resulting text can be parsed by a strict JSON decoder. Closing
    quotes (followed by delimiters or EOF) and existing backslash escapes
    (e.g. ``\\"``) are passed through unchanged.
    """
    if not text or '"' not in text:
        return text
    out: List[str] = []
    in_double = False
    in_single = False
    prev_sig_char = ""
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if not in_double and not in_single:
            if c == '"':
                in_double = True
                out.append(c)
                i += 1
            elif c == "'":
                in_single = True
                out.append(c)
                i += 1
            else:
                if c not in " \t\r\n":
                    prev_sig_char = c
                out.append(c)
                i += 1
        elif in_double:
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == '"':
                if _is_real_closing_quote(text, i, prev_sig_char):
                    in_double = False
                    prev_sig_char = '"'
                    out.append('"')
                    i += 1
                else:
                    out.append('\\"')
                    i += 1
            else:
                out.append(c)
                i += 1
        else:  # in_single
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == "'":
                in_single = False
                out.append(c)
                i += 1
            elif c == '"':
                out.append('\\"')
                i += 1
            else:
                out.append(c)
                i += 1
    return "".join(out)


def _relax_single_quotes(text: str) -> str:
    """Best-effort converter from JSON5-like single-quoted syntax to canonical
    JSON double-quoted form.

    Walks ``text`` character-by-character with a small state machine. When a
    single-quoted string is closed it is rewritten with a ``"`` delimiter and
    internal apostrophes are escaped as ``\\'`` so the resulting string can be
    parsed by a strict JSON decoder. Only applied when the strict decode has
    already failed and ``allow_repair`` is True. NO-OP if no single-quoted
    strings are present.
    """
    if not text or "'" not in text:
        return text
    out: List[str] = []
    in_double = False
    in_single = False
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if not in_double and not in_single:
            if c == '"':
                in_double = True
                out.append(c)
                i += 1
            elif c == "'":
                in_single = True
                out.append('"')
                i += 1
            else:
                out.append(c)
                i += 1
        elif in_double:
            if c == "\\" and i + 1 < n:
                out.append(c)
                out.append(text[i + 1])
                i += 2
            elif c == '"':
                in_double = False
                out.append(c)
                i += 1
            else:
                out.append(c)
                i += 1
        else:  # in_single
            if c == "\\" and i + 1 < n:
                nxt = text[i + 1]
                if nxt == "'":
                    # In single-quoted string, \' was escaping a single quote.
                    # In double-quoted JSON, a single quote does not need escaping.
                    out.append("'")
                    i += 2
                elif nxt == '"':
                    out.append('\\"')
                    i += 2
                else:
                    out.append(c)
                    out.append(nxt)
                    i += 2
            elif c == "'":
                # Check lookahead: is this a closing quote or an apostrophe in a word?
                # A closing single quote in JSON must be followed by optional whitespace and one of:
                # ':', ',', '}', ']' or end-of-string.
                j = i + 1
                while j < n and text[j] in " \t\r\n":
                    j += 1
                if j == n or text[j] in ":,}]":
                    in_single = False
                    out.append('"')
                    i += 1
                else:
                    # Contraction / unescaped apostrophe inside single-quoted string literal
                    out.append("'")
                    i += 1
            elif c == '"':
                # An unescaped double quote inside a single-quoted string must be escaped
                out.append('\\"')
                i += 1
            else:
                out.append(c)
                i += 1
    return "".join(out)


def _bounded_repair_chain(text: str) -> str:
    """Apply ordered, bounded repair passes to ``text``.

    Returns the most repaired version produced. The chain is bounded to two
    iterations so a pathological input cannot trigger unbounded rewriting.
    Layers, in order:
        1. trailing comma stripping
        2. unescaped control chars inside string tokens
        3. single-quote -> double-quote normalization
    Each pass is a pure string transform; the chain is fail-closed at the
    JSON decoder level (see ``_raw_decode_strict``).
    """
    if not text:
        return text
    candidate = text
    for _ in range(2):
        prev = candidate
        candidate = _strip_trailing_commas(candidate)
        candidate = _repair_unescaped_double_quotes_in_strings(candidate)
        candidate = _repair_unescaped_newlines_in_strings(candidate)
        candidate = _relax_single_quotes(candidate)
        if candidate == prev:
            break
    return candidate


def _try_parse_with_repair(
    candidate: str, allow_repair: bool
) -> Any:
    """Attempt strict decode, falling back to the bounded repair chain.

    Raises ``InvalidJsonError`` (with original cause preserved) when neither
    pass succeeds. Strict failures (multiple top-level objects, NaN/Infinity,
    trailing prose after the candidate) are NOT repaired and propagate up
    unchanged so production callers using ``allow_repair=False`` see exact
    fail-closed behaviour.
    """
    try:
        return _raw_decode_strict(candidate)
    except InvalidJsonError as err:
        message = str(err)
        if (
            "Ambiguous" in message
            or "prohibited" in message
            or "trailing" in message
        ):
            raise
        if not allow_repair:
            raise
        repaired = _bounded_repair_chain(candidate)
        if repaired == candidate:
            raise
        return _raw_decode_strict(repaired)


def clean_reasoning_tags(text: str) -> str:
    """Removes <think>...</think> reasoning tags and unclosed thinking content safely."""
    if not text:
        return ""
    # Strip well-formed tags
    cleaned = re.sub(r"<think>[\s\S]*?</think>", "", text).strip()
    # Strip unclosed opening tag (malformed streaming or truncated output)
    if "<think>" in cleaned and "</think>" not in cleaned:
        cleaned = cleaned.split("<think>")[0].strip()
    # Strip dangling closing tag
    if "</think>" in cleaned:
        cleaned = cleaned.split("</think>")[-1].strip()
    cleaned = re.sub(r"[\u00a0\u1680\u2000-\u200b\u2028\u2029\u202f\u205f\u3000\ufeff]", " ", cleaned)
    return cleaned


class StreamingReasoningSanitizer:
    """Stateful sanitizer that buffers tokens across stream chunk boundaries, ensuring

    no <think>...</think> reasoning tags, thinking fragments, or chain-of-thought content
    leak into callbacks or downstream business/logs.
    """

    def __init__(self) -> None:
        self.inside_think = False
        self.buffer = ""
        self.reasoning_tokens_count = 0

    def feed(self, chunk: str) -> str:
        """Processes a new stream chunk and returns safe content to emit (if any)."""
        if not chunk:
            return ""

        self.buffer += chunk
        emitted_parts: List[str] = []

        while self.buffer:
            if not self.inside_think:
                pos = self.buffer.find("<think>")
                if pos != -1:
                    # Content before <think> is safe to emit
                    safe = self.buffer[:pos]
                    if safe:
                        emitted_parts.append(safe)
                    self.buffer = self.buffer[pos + len("<think>"):]
                    self.inside_think = True
                    continue

                # Check if buffer ends with a partial prefix of "<think>"
                prefix_len = 0
                for candidate_len in range(min(len(self.buffer), 6), 0, -1):
                    if "<think>".startswith(self.buffer[-candidate_len:]):
                        prefix_len = candidate_len
                        break

                if prefix_len > 0:
                    # Emit everything before the candidate prefix; keep candidate prefix in buffer
                    safe = self.buffer[:-prefix_len]
                    if safe:
                        emitted_parts.append(safe)
                    self.buffer = self.buffer[-prefix_len:]
                    break
                else:
                    emitted_parts.append(self.buffer)
                    self.buffer = ""
                    break
            else:
                # Inside thinking block
                pos = self.buffer.find("</think>")
                if pos != -1:
                    reasoning_content = self.buffer[:pos]
                    self.reasoning_tokens_count += max(1, len(reasoning_content) // 4)
                    self.buffer = self.buffer[pos + len("</think>"):]
                    self.inside_think = False
                    continue

                # Check if buffer ends with a partial prefix of "</think>"
                prefix_len = 0
                for candidate_len in range(min(len(self.buffer), 7), 0, -1):
                    if "</think>".startswith(self.buffer[-candidate_len:]):
                        prefix_len = candidate_len
                        break

                if prefix_len > 0:
                    # Discard reasoning before the partial closing tag
                    discarded = self.buffer[:-prefix_len]
                    self.reasoning_tokens_count += max(1, len(discarded) // 4)
                    self.buffer = self.buffer[-prefix_len:]
                    break
                else:
                    self.reasoning_tokens_count += max(1, len(self.buffer) // 4)
                    self.buffer = ""
                    break

        return "".join(emitted_parts)

    def flush(self) -> str:
        """Flushes remaining content at end of stream. Discards any unclosed thinking content."""
        if self.inside_think:
            # Unclosed think block is reasoning; discard entirely
            self.reasoning_tokens_count += max(1, len(self.buffer) // 4)
            self.buffer = ""
            return ""

        res = self.buffer
        self.buffer = ""
        return res


def _raw_decode_strict(content: str) -> Any:
    decoder = json.JSONDecoder(parse_constant=_reject_constant, strict=False)
    idx = 0
    text_len = len(content)
    while idx < text_len and content[idx].isspace():
        idx += 1
    if idx >= text_len:
        raise InvalidJsonError("Content is empty or whitespace only")

    try:
        obj, end = decoder.raw_decode(content, idx)
    except json.JSONDecodeError as exc:
        raise InvalidJsonError(f"Malformed JSON syntax: {exc}", raw_text=content)
    except ValueError as exc:
        # Caught NaN/Infinity
        raise InvalidJsonError(str(exc), raw_text=content)

    remainder = content[end:].strip()
    if remainder:
        # Check if remainder contains another distinct JSON object
        try:
            sec_obj, _ = decoder.raw_decode(remainder)
            err = InvalidJsonError(
                "Ambiguous multiple top-level JSON objects detected", raw_text=content
            )
            err.first_obj = obj
            err.second_obj = sec_obj
            raise err
        except (json.JSONDecodeError, ValueError) as err:
            if "Ambiguous" in str(err) or "prohibited" in str(err):
                raise
            trailing_err = InvalidJsonError(
                f"Unexpected trailing content after top-level JSON: {remainder[:60]}",
                raw_text=content,
            )
            trailing_err.first_obj = obj
            raise trailing_err

    return obj


def parse_defensive_json(
    raw_text: str,
    max_response_bytes: int = 500_000,
    target_model: Optional[Type[BaseModel]] = None,
    response_schema: Optional[Dict[str, Any]] = None,
    allow_repair: bool = True,
) -> Any:
    """Parses JSON defensively with size bounds, fenced block extraction,

    rejection of multiple top-level objects, rejection of NaN/Infinity,
    and schema validation against Pydantic models or JSON schema.
    """
    if raw_text is None:
        raise InvalidJsonError("Raw response text is None")

    encoded_bytes = raw_text.encode("utf-8")
    if len(encoded_bytes) > max_response_bytes:
        raise TruncatedOutputError(
            f"Response size ({len(encoded_bytes)} bytes) exceeds max limit ({max_response_bytes} bytes)",
            raw_text=raw_text[:500],
        )

    text = clean_reasoning_tags(raw_text).strip()
    if not text:
        raise InvalidJsonError("Response content is empty after stripping reasoning tags", raw_text=raw_text)

    # 1. Direct strict parse attempt
    try:
        parsed = _raw_decode_strict(text)
        return validate_schema(parsed, target_model=target_model, response_schema=response_schema)
    except InvalidJsonError as err:
        if "Ambiguous" in str(err):
            if allow_repair and (target_model is not None or response_schema is not None) and hasattr(err, "first_obj"):
                try:
                    return validate_schema(err.first_obj, target_model=target_model, response_schema=response_schema)
                except Exception:
                    pass
                if isinstance(err.first_obj, dict) and isinstance(getattr(err, "second_obj", None), dict):
                    try:
                        merged = {**err.first_obj, **err.second_obj}
                        return validate_schema(merged, target_model=target_model, response_schema=response_schema)
                    except Exception:
                        pass
            raise
        if "trailing" in str(err):
            if allow_repair and (target_model is not None or response_schema is not None) and hasattr(err, "first_obj"):
                try:
                    return validate_schema(err.first_obj, target_model=target_model, response_schema=response_schema)
                except Exception:
                    pass
            raise
        if "prohibited" in str(err):
            raise
        if not allow_repair:
            raise
        if "Malformed" in str(err):
            try:
                parsed = _try_parse_with_repair(text, allow_repair=True)
                return validate_schema(parsed, target_model=target_model, response_schema=response_schema)
            except Exception:
                pass
    # 2. Bounded repair: Look for fenced code blocks
    fenced_matches = list(re.finditer(r"```(?:json)?\s*([\s\S]*?)\s*```", text))
    if len(fenced_matches) > 1 and (not allow_repair or (target_model is None and response_schema is None)):
        raise InvalidJsonError(
            f"Ambiguous multiple fenced blocks detected ({len(fenced_matches)} blocks)",
            raw_text=text,
        )
    if len(fenced_matches) >= 1:
        for match in fenced_matches:
            trailing = text[match.end():].strip()
            if trailing and not allow_repair:
                raise InvalidJsonError(
                    f"Unexpected trailing prose after fenced JSON: {trailing[:60]}",
                    raw_text=text,
                )
            fenced_candidate = match.group(1).strip()
            try:
                parsed = _try_parse_with_repair(fenced_candidate, allow_repair=allow_repair)
                return validate_schema(parsed, target_model=target_model, response_schema=response_schema)
            except Exception:
                if len(fenced_matches) == 1:
                    raise
                continue
        if len(fenced_matches) > 1:
            raise InvalidJsonError(
                f"Ambiguous multiple fenced blocks detected ({len(fenced_matches)} blocks)",
                raw_text=text,
            )

    # 3. Bounded repair: Extract outermost single object or array ONLY if no trailing prose
    first_brace = text.find("{")
    last_brace = text.rfind("}")
    first_bracket = text.find("[")
    last_bracket = text.rfind("]")

    if first_brace != -1 and last_brace != -1 and (first_bracket == -1 or first_brace < first_bracket):
        trailing_after = text[last_brace + 1:].strip()
        if trailing_after and not allow_repair:
            raise InvalidJsonError(
                f"Unexpected trailing prose after JSON object: {trailing_after[:60]}",
                raw_text=text,
            )
        candidate = text[first_brace : last_brace + 1].strip()
        parsed = _try_parse_with_repair(candidate, allow_repair=allow_repair)
        return validate_schema(parsed, target_model=target_model, response_schema=response_schema)

    if first_bracket != -1 and last_bracket != -1:
        trailing_after = text[last_bracket + 1:].strip()
        if trailing_after and not allow_repair:
            raise InvalidJsonError(
                f"Unexpected trailing prose after JSON array: {trailing_after[:60]}",
                raw_text=text,
            )
        candidate = text[first_bracket : last_bracket + 1].strip()
        parsed = _try_parse_with_repair(candidate, allow_repair=allow_repair)
        return validate_schema(parsed, target_model=target_model, response_schema=response_schema)

    raise InvalidJsonError("Could not locate valid JSON structure in response", raw_text=text)


def validate_schema(
    parsed: Any,
    target_model: Optional[Type[BaseModel]] = None,
    response_schema: Optional[Dict[str, Any]] = None,
) -> Any:
    """Validates parsed payload against target Pydantic model or JSON Schema dict."""
    if target_model is not None:
        try:
            if isinstance(parsed, dict):
                validated = target_model.model_validate(parsed)
                return validated.model_dump(mode="json")
            elif isinstance(parsed, list):
                return parsed
            else:
                raise SchemaMismatchError(
                    f"Expected object or array for {target_model.__name__}, got {type(parsed).__name__}"
                )
        except ValidationError as ve:
            raise SchemaMismatchError(
                f"Schema validation failed against {target_model.__name__}: {ve}",
                validation_errors=ve.errors(),
            )

    if response_schema is not None:
        _validate_json_schema(parsed, response_schema)

    return parsed


def _validate_json_schema(parsed: Any, schema: Dict[str, Any], path: str = "root") -> None:
    expected_type = schema.get("type")
    if expected_type == "object":
        if not isinstance(parsed, dict):
            raise SchemaMismatchError(f"Expected object at '{path}', got {type(parsed).__name__}")

        required_fields = schema.get("required", [])
        for field in required_fields:
            if field not in parsed:
                raise SchemaMismatchError(f"Missing required field '{field}' at '{path}'")

        properties = schema.get("properties", {})
        for prop_name, prop_schema in properties.items():
            if prop_name in parsed:
                val = parsed[prop_name]
                _validate_property(val, prop_schema, f"{path}.{prop_name}")

    elif expected_type == "array":
        if not isinstance(parsed, list):
            raise SchemaMismatchError(f"Expected array at '{path}', got {type(parsed).__name__}")
        items_schema = schema.get("items")
        if items_schema:
            for idx, item in enumerate(parsed):
                _validate_json_schema(item, items_schema, f"{path}[{idx}]")


def _validate_property(val: Any, prop_schema: Dict[str, Any], prop_path: str) -> None:
    expected_type = prop_schema.get("type")
    if expected_type == "string":
        if not isinstance(val, str):
            raise SchemaMismatchError(f"Expected string at '{prop_path}', got {type(val).__name__}")
    elif expected_type == "integer":
        if not isinstance(val, int) or isinstance(val, bool):
            raise SchemaMismatchError(f"Expected integer at '{prop_path}', got {type(val).__name__}")
    elif expected_type == "number":
        if not isinstance(val, (int, float)) or isinstance(val, bool):
            raise SchemaMismatchError(f"Expected number at '{prop_path}', got {type(val).__name__}")
    elif expected_type == "boolean":
        if not isinstance(val, bool):
            raise SchemaMismatchError(f"Expected boolean at '{prop_path}', got {type(val).__name__}")
    elif expected_type == "array":
        if not isinstance(val, list):
            raise SchemaMismatchError(f"Expected array at '{prop_path}', got {type(val).__name__}")
        items_schema = prop_schema.get("items")
        if items_schema:
            for idx, item in enumerate(val):
                _validate_property(item, items_schema, f"{prop_path}[{idx}]")
    elif expected_type == "object":
        if not isinstance(val, dict):
            raise SchemaMismatchError(f"Expected object at '{prop_path}', got {type(val).__name__}")
        _validate_json_schema(val, prop_schema, prop_path)

    if "enum" in prop_schema:
        if val not in prop_schema["enum"]:
            raise SchemaMismatchError(
                f"Value '{val}' at '{prop_path}' is not in allowed enum: {prop_schema['enum']}"
            )
