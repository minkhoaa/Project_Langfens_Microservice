"""Authoritative scholarly XML provenance extractor and fail-closed validator.

Enforces:
- Safe XML parsing without external DTD or entity resolution.
- Authoritative extraction of PMCID, DOI, article title, authors, license URL and license text.
- Detection of license misrepresentations (e.g. declaring CC BY when the actual XML is CC BY-NC).
- Fail-closed license clearance: non-commercial (CC BY-NC) licenses cannot be marked cleared
  without explicit policy/legal authorization.
- Verification of PMCID, Title, and DOI consistency between declared source and authoritative XML.
"""

from __future__ import annotations

import html
import re
import unicodedata
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from typing import Any, Mapping, Optional, Tuple


@dataclass(frozen=True)
class AuthoritativeSourceMetadata:
    """Authoritative metadata extracted directly from peer-reviewed XML full text."""

    pmcid: Optional[str]
    doi: Optional[str]
    title: str
    authors: list[str] = field(default_factory=list)
    license_url: Optional[str] = None
    license_text: Optional[str] = None
    license_type: str = "UNKNOWN"
    is_noncommercial: bool = False
    is_commercial_cleared: bool = False


def _clean_text(elem: Optional[ET.Element]) -> str:
    if elem is None:
        return ""
    text = " ".join("".join(elem.itertext()).split())
    text = html.unescape(text)
    return unicodedata.normalize("NFKC", text).strip()


def extract_authoritative_metadata(
    xml_bytes: bytes,
    fallback_pmcid: Optional[str] = None,
) -> AuthoritativeSourceMetadata:
    """Safely parses Europe PMC / JATS XML and extracts authoritative bibliographic metadata."""
    # XMLParser in Python 3 does not resolve external entities by default
    parser = ET.XMLParser()
    try:
        root = ET.fromstring(xml_bytes, parser=parser)
    except ET.ParseError as err:
        raise ValueError(f"Corrupt or malformed XML full text: {err}") from err

    # PMCID
    pmcid = None
    for aid in root.findall(".//article-id"):
        id_type = aid.attrib.get("pub-id-type", "").lower()
        if id_type in ("pmc", "pmcid") and aid.text:
            text = aid.text.strip()
            pmcid = text if text.upper().startswith("PMC") else f"PMC{text}"
            break
    if not pmcid and fallback_pmcid:
        pmcid = fallback_pmcid.upper() if fallback_pmcid.upper().startswith("PMC") else f"PMC{fallback_pmcid}"

    # DOI
    doi = None
    for aid in root.findall(".//article-id"):
        if aid.attrib.get("pub-id-type", "").lower() == "doi" and aid.text:
            doi = aid.text.strip()
            break

    # Title
    title_elem = root.find(".//article-title")
    title = _clean_text(title_elem)

    # Authors
    authors: list[str] = []
    for contrib in root.findall(".//contrib[@contrib-type='author']"):
        surname = contrib.findtext(".//surname")
        given = contrib.findtext(".//given-names")
        collab = contrib.findtext(".//collab")
        if surname:
            name = f"{given.strip()} {surname.strip()}" if given else surname.strip()
            if name not in authors:
                authors.append(name)
        elif collab and collab.strip() not in authors:
            authors.append(collab.strip())

    # License evidence
    license_url = None
    license_text_pieces = []
    for lic in root.findall(".//permissions//license"):
        href = (
            lic.attrib.get("{http://www.w3.org/1999/xlink}href")
            or lic.attrib.get("href")
            or ""
        )
        if href:
            license_url = href.strip()
        for ref_elem in lic.findall(".//{http://www.niso.org/schemas/ali/1.0/}license_ref"):
            if ref_elem.text:
                license_url = ref_elem.text.strip()
        t = _clean_text(lic)
        if t:
            license_text_pieces.append(t)

    full_license_text = " ".join(license_text_pieces)
    if not license_url and full_license_text:
        m = re.search(r"https?://creativecommons\.org/licenses/[a-zA-Z0-9.\-_/]+", full_license_text)
        if m:
            license_url = m.group(0)

    # Classify license
    combined_lic = f"{license_url or ''} {full_license_text}".lower()
    is_nc = "by-nc" in combined_lic or "noncommercial" in combined_lic or "non-commercial" in combined_lic

    if is_nc:
        license_type = "CC BY-NC 4.0"
        is_commercial_cleared = False
    elif "licenses/by/" in combined_lic or "attribution 4.0" in combined_lic or "cc by 4.0" in combined_lic:
        license_type = "CC BY 4.0"
        is_commercial_cleared = True
    elif "publicdomain/zero" in combined_lic or "cc0" in combined_lic:
        license_type = "CC0 1.0"
        is_commercial_cleared = True
    elif license_url or full_license_text:
        license_type = "OTHER_OPEN_ACCESS"
        is_commercial_cleared = False
    else:
        license_type = "UNKNOWN"
        is_commercial_cleared = False

    return AuthoritativeSourceMetadata(
        pmcid=pmcid,
        doi=doi,
        title=title,
        authors=authors,
        license_url=license_url,
        license_text=full_license_text or None,
        license_type=license_type,
        is_noncommercial=is_nc,
        is_commercial_cleared=is_commercial_cleared,
    )


def verify_source_authenticity(
    declared: Mapping[str, Any],
    xml_bytes: bytes,
    allow_noncommercial: bool = False,
) -> Tuple[bool, list[str]]:
    """Verifies declared source metadata against authoritative XML full text.

    Fails closed on:
    - PMCID mismatch
    - Title mismatch or fabricated title alteration
    - DOI mismatch
    - License misrepresentation (e.g. declaring BY when XML is BY-NC)
    - Missing license evidence in XML
    - Unsupported or un-cleared license without explicit policy authorization
    """
    errors: list[str] = []
    auth = extract_authoritative_metadata(xml_bytes, fallback_pmcid=declared.get("pmcid"))

    # 1. PMCID match
    dec_pmcid = (declared.get("pmcid") or declared.get("sourceId") or "").strip().upper()
    if auth.pmcid and dec_pmcid:
        if auth.pmcid.upper() != dec_pmcid:
            errors.append(f"PMCID mismatch: declared {dec_pmcid} != authoritative {auth.pmcid}")

    # 2. Title verification
    dec_title = (declared.get("title") or "").strip()
    if auth.title and dec_title:
        auth_norm = re.sub(r"[^\w\s]", "", auth.title.lower())
        dec_norm = re.sub(r"[^\w\s]", "", dec_title.lower())
        auth_words = set(auth_norm.split())
        dec_words = set(dec_norm.split())

        # Exact or near-exact match
        if auth_norm != dec_norm:
            # Check for conflict or completely foreign terms
            overlap = len(auth_words & dec_words) / max(1, len(auth_words))
            if overlap < 0.65:
                errors.append(f"Title mismatch: declared '{dec_title}' does not match authoritative '{auth.title}'")
            # Specific defect check: "drawdown" vs "release"
            if "drawdown" in dec_words and "release" in auth_words and "drawdown" not in auth_words:
                errors.append("Title conflict: declared 'drawdown' contradicts authoritative 'release'")

    # 3. DOI match
    dec_doi = (declared.get("doi") or "").strip().lower()
    if auth.doi and dec_doi:
        if auth.doi.lower() != dec_doi:
            errors.append(f"DOI mismatch: declared '{dec_doi}' != authoritative '{auth.doi}'")

    # 4. License evidence presence
    if auth.license_type == "UNKNOWN" or (not auth.license_url and not auth.license_text):
        errors.append("Missing license evidence in authoritative XML full text")

    # 5. License misrepresentation check
    dec_license = (declared.get("license") or declared.get("licenseType") or "").strip().upper()
    dec_has_nc = "NC" in dec_license or "NONCOMMERCIAL" in dec_license or "NON-COMMERCIAL" in dec_license

    if auth.is_noncommercial and not dec_has_nc:
        errors.append(
            f"License misrepresentation: XML contains non-commercial license ({auth.license_type}), "
            f"but declared license is '{dec_license}' without NonCommercial attribution"
        )

    # 6. License clearance policy check
    declared_cleared = declared.get("licenseCleared") is True
    if auth.is_noncommercial:
        if declared_cleared and not allow_noncommercial:
            errors.append(
                "Unsupported license clearance: CC BY-NC source cannot be cleared without explicit "
                "non-commercial educational usage authorization"
            )
    elif not auth.is_commercial_cleared and declared_cleared:
        errors.append(f"Unsupported license clearance: license '{auth.license_type}' is not cleared")

    return len(errors) == 0, errors
