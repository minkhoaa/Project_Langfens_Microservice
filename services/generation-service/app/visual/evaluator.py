import re
import xml.etree.ElementTree as ET
from typing import List, Optional, Set
from app.visual.models import VisualValidationResult

# Regex patterns for fast sanitization pre-check
SCRIPT_PATTERN = re.compile(r"<\s*script\b", re.IGNORECASE)
EVENT_ATTR_PATTERN = re.compile(r"\bon[a-z]+\s*=", re.IGNORECASE)
ENTITY_PATTERN = re.compile(r"<!ENTITY\b", re.IGNORECASE)
DOCTYPE_PATTERN = re.compile(r"<!DOCTYPE\b", re.IGNORECASE)
JAVASCRIPT_URL_PATTERN = re.compile(r"(href|xlink:href)\s*=\s*['\"]\s*javascript:", re.IGNORECASE)
EXTERNAL_URL_PATTERN = re.compile(r"(href|xlink:href)\s*=\s*['\"]\s*(https?:|//)", re.IGNORECASE)
FOREIGN_OBJECT_PATTERN = re.compile(r"<\s*foreignObject\b", re.IGNORECASE)


class SvgVisualEvaluator:
    """
    Evaluator that rigorously validates SVG syntax, security, responsive viewBox,
    accessibility labels, callout badge alignment, and answer leakage prevention.
    """

    def evaluate(
        self,
        svg_text: str,
        expected_callouts: List[int],
        prohibited_answers: Optional[List[str]] = None,
    ) -> VisualValidationResult:
        errors: List[str] = []
        has_title = False
        has_viewbox = False
        detected_callouts: List[int] = []

        # 1. Security & Sanitization pre-checks
        if SCRIPT_PATTERN.search(svg_text):
            errors.append("Sanitization violation: <script> tags are strictly prohibited.")

        if EVENT_ATTR_PATTERN.search(svg_text):
            errors.append("Sanitization violation: inline event handlers (on* attributes) are prohibited.")

        if ENTITY_PATTERN.search(svg_text) or DOCTYPE_PATTERN.search(svg_text):
            errors.append("Sanitization violation: DOCTYPE and ENTITY declarations (XXE risk) are prohibited.")

        if JAVASCRIPT_URL_PATTERN.search(svg_text):
            errors.append("Sanitization violation: javascript: URLs are prohibited.")

        if EXTERNAL_URL_PATTERN.search(svg_text):
            errors.append("Sanitization violation: external href URLs are prohibited.")

        if FOREIGN_OBJECT_PATTERN.search(svg_text):
            errors.append("Sanitization violation: <foreignObject> elements are prohibited.")

        # If critical injection attempt, do not parse XML with malicious entities
        if any("DOCTYPE" in err or "ENTITY" in err for err in errors):
            return VisualValidationResult(
                is_valid=False,
                errors=errors,
                detected_callouts=[],
                has_title=False,
                has_viewbox=False,
            )

        # 2. XML Well-formedness
        try:
            root = ET.fromstring(svg_text)
        except ET.ParseError as e:
            errors.append(f"XML parse error: {str(e)}")
            return VisualValidationResult(
                is_valid=False,
                errors=errors,
                detected_callouts=[],
                has_title=False,
                has_viewbox=False,
            )

        # Verify root tag is svg
        tag_name = root.tag.split("}")[-1] if "}" in root.tag else root.tag
        if tag_name.lower() != "svg":
            errors.append(f"Root element must be <svg>, found <{tag_name}>.")

        # 3. ViewBox Verification
        viewbox = root.attrib.get("viewBox") or root.attrib.get("viewbox")
        if not viewbox:
            errors.append("Missing viewBox attribute on root <svg> element.")
        else:
            vb_parts = viewbox.strip().split()
            if len(vb_parts) == 4:
                try:
                    min_x, min_y, vb_w, vb_h = [float(p) for p in vb_parts]
                    if vb_w <= 0 or vb_h <= 0:
                        errors.append(f"Invalid viewBox dimensions: width={vb_w}, height={vb_h} must be positive.")
                    else:
                        has_viewbox = True
                except ValueError:
                    errors.append(f"Invalid non-numeric viewBox attribute: '{viewbox}'.")
            else:
                errors.append(f"viewBox must contain 4 space-separated numbers: '{viewbox}'.")

        # 4. Accessibility check: <title>
        titles = [
            elem.text
            for elem in root.iter()
            if (elem.tag.split("}")[-1] if "}" in elem.tag else elem.tag).lower() == "title"
            and elem.text
            and elem.text.strip()
        ]
        if titles:
            has_title = True
        else:
            errors.append("Accessibility violation: Missing non-empty <title> element.")

        # 5. Callout Alignment Check
        # Extract callout IDs from data-callout-id attributes or badge text
        callout_set: Set[int] = set()
        for elem in root.iter():
            cid_attr = elem.attrib.get("data-callout-id")
            if cid_attr and cid_attr.isdigit():
                callout_set.add(int(cid_attr))

        detected_callouts = sorted(list(callout_set))
        expected_set = set(expected_callouts)

        missing = expected_set - callout_set
        unexpected = callout_set - expected_set

        if missing:
            errors.append(f"Missing expected callouts: {sorted(list(missing))}.")
        if unexpected:
            errors.append(f"Unexpected callouts present in SVG: {sorted(list(unexpected))}.")

        # 6. Zero Answer Leakage
        if prohibited_answers:
            all_text_elements = [
                elem.text.strip() for elem in root.iter() if elem.text and elem.text.strip()
            ]
            combined_text = " ".join(all_text_elements).lower()

            for answer in prohibited_answers:
                clean_ans = answer.strip().lower()
                if clean_ans and clean_ans in combined_text:
                    errors.append(f"Answer leakage detected: Prohibited answer '{answer}' is rendered in SVG text.")

        is_valid = len(errors) == 0
        return VisualValidationResult(
            is_valid=is_valid,
            errors=errors,
            detected_callouts=detected_callouts,
            has_title=has_title,
            has_viewbox=has_viewbox,
        )
