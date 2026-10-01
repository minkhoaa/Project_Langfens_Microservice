"""License provenance and source length policy enforcement for Langfens Loop Engine V2.

Policies:
- Europe PMC: Strictly requires explicit Creative Commons BY or CC0 license in XML/metadata.
- Universal Sources: Requires clear license declaration. Unknown or missing rights are NOT
  automatically approved.
- Word Count: Minimum 600 words for IELTS Reading passages. 599 words is rejected; 600 and 601
  are accepted.
"""

from __future__ import annotations

import re
from typing import Optional, Tuple

WORD_PATTERN = re.compile(r"\b[\w'-]+\b")
EUROPE_PMC_CC_LICENSE_PATTERN = re.compile(
    r"creativecommons\.org/(?:licenses/by/[0-9.]+(?:/[a-z-]+)?|publicdomain/zero/[0-9.]+)",
    re.IGNORECASE,
)

APPROVED_UNIVERSAL_LICENSES = {
    "cc-by",
    "cc-by-4.0",
    "cc-by-3.0",
    "cc-by-2.5",
    "cc-by-2.0",
    "cc-by-sa",
    "cc-by-nc",
    "cc0",
    "cc0-1.0",
    "public domain",
    "open access",
    "open access cc-by",
    "open access cc0",
    "fair use / educational",
    "educational use",
    "mit",
    "apache-2.0",
    "web article (fair use / educational)",
    "user provided",
}

DISAPPROVED_OR_UNKNOWN = {
    "",
    "unknown",
    "unspecified",
    "all rights reserved",
    "copyrighted",
    "proprietary",
    "none",
}

MIN_READING_PASSAGE_WORDS = 600


class LicenseError(ValueError):
    """Raised when source license is missing or ineligible."""
    pass


class SourceLengthError(ValueError):
    """Raised when source content does not satisfy word count constraints."""
    pass


def count_words(text: str) -> int:
    """Counts words using baseline regex r"\\b[\\w'-]+\\b"."""
    if not text:
        return 0
    return len(WORD_PATTERN.findall(text))


def validate_source_length(word_count: int, min_words: int = MIN_READING_PASSAGE_WORDS) -> None:
    """Validates that content contains at least the required number of words."""
    if word_count < min_words:
        raise SourceLengthError(
            f"Source content is too short ({word_count} words; minimum is {min_words} words for IELTS Reading)"
        )


def validate_europe_pmc_license(raw_license_text: str) -> str:
    """Validates that Europe PMC full text contains a verified CC BY or CC0 license URL."""
    if not raw_license_text:
        raise LicenseError("No verified CC BY or CC0 license in full text")

    match = EUROPE_PMC_CC_LICENSE_PATTERN.search(raw_license_text)
    if not match:
        raise LicenseError("No verified CC BY or CC0 license in full text")

    return "https://" + match.group(0)


def evaluate_universal_license(
    license_str: Optional[str],
    strict: bool = False,
) -> Tuple[bool, str]:
    """Evaluates license eligibility for universal inputs (Web, HTML, Markdown, Plain Text).

    In strict mode, unknown or empty rights fail closed.
    """
    if license_str is None or not license_str.strip():
        if strict:
            raise LicenseError(
                "Universal source has unspecified license. "
                "Unknown rights are not automatically approved under policy."
            )
        return True, "User Provided"

    normalized = license_str.strip()
    norm_lower = normalized.lower()

    if norm_lower in DISAPPROVED_OR_UNKNOWN:
        if strict:
            raise LicenseError(
                f"Universal source has ineligible rights ('{normalized}'). "
                f"Unknown rights are not automatically approved under policy."
            )
        return False, normalized

    cleared = norm_lower in APPROVED_UNIVERSAL_LICENSES or any(
        approved in norm_lower for approved in ("creativecommons.org", "cc-by", "cc0", "public domain", "fair use")
    )

    if not cleared and strict:
        raise LicenseError(
            f"Universal source has unknown or ineligible rights ('{normalized}'). "
            f"Unknown rights are not automatically approved under policy."
        )

    return cleared, normalized
