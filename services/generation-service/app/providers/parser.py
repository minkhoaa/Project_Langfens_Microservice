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
    decoder = json.JSONDecoder(parse_constant=_reject_constant)
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
            raise InvalidJsonError(
                "Ambiguous multiple top-level JSON objects detected", raw_text=content
            )
        except (json.JSONDecodeError, ValueError) as err:
            if "Ambiguous" in str(err) or "prohibited" in str(err):
                raise
            raise InvalidJsonError(
                f"Unexpected trailing content after top-level JSON: {remainder[:60]}",
                raw_text=content,
            )

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
        if "Ambiguous" in str(err) or "prohibited" in str(err) or "trailing" in str(err):
            # Strict fail-closed: do not repair multiple objects, NaN/Infinity, or trailing prose
            raise
        if not allow_repair:
            raise

    # 2. Bounded repair: Look for fenced code blocks
    fenced_matches = list(re.finditer(r"```(?:json)?\s*([\s\S]*?)\s*```", text))
    if len(fenced_matches) > 1:
        raise InvalidJsonError(
            f"Ambiguous multiple fenced blocks detected ({len(fenced_matches)} blocks)",
            raw_text=text,
        )
    if len(fenced_matches) == 1:
        match = fenced_matches[0]
        trailing = text[match.end():].strip()
        if trailing:
            raise InvalidJsonError(
                f"Unexpected trailing prose after fenced JSON: {trailing[:60]}",
                raw_text=text,
            )
        fenced_candidate = match.group(1).strip()
        parsed = _raw_decode_strict(fenced_candidate)
        return validate_schema(parsed, target_model=target_model, response_schema=response_schema)

    # 3. Bounded repair: Extract outermost single object or array ONLY if no trailing prose
    first_brace = text.find("{")
    last_brace = text.rfind("}")
    first_bracket = text.find("[")
    last_bracket = text.rfind("]")

    if first_brace != -1 and last_brace != -1 and (first_bracket == -1 or first_brace < first_bracket):
        trailing_after = text[last_brace + 1:].strip()
        if trailing_after:
            raise InvalidJsonError(
                f"Unexpected trailing prose after JSON object: {trailing_after[:60]}",
                raw_text=text,
            )
        candidate = text[first_brace : last_brace + 1].strip()
        parsed = _raw_decode_strict(candidate)
        return validate_schema(parsed, target_model=target_model, response_schema=response_schema)

    if first_bracket != -1 and last_bracket != -1:
        trailing_after = text[last_bracket + 1:].strip()
        if trailing_after:
            raise InvalidJsonError(
                f"Unexpected trailing prose after JSON array: {trailing_after[:60]}",
                raw_text=text,
            )
        candidate = text[first_bracket : last_bracket + 1].strip()
        parsed = _raw_decode_strict(candidate)
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
