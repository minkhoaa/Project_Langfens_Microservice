import pytest
from app.visual.compiler import compile_svg
from app.visual.evaluator import SvgVisualEvaluator
from app.visual.models import (
    DiagramLayoutSpec,
    DiagramElement,
    FlowChartLayoutSpec,
    FlowChartStep,
    FlowChartConnection,
    VisualCallout,
)


def test_diagram_compilation_and_validation_success():
    spec = DiagramLayoutSpec(
        title="Water Pump Mechanism",
        description="A labeled cross-section diagram of a reciprocating water pump.",
        width=800,
        height=600,
        elements=[
            DiagramElement(
                id="cylinder",
                shape="rect",
                x=150,
                y=100,
                width=300,
                height=400,
                label="Main Cylinder",
                fill="#f1f5f9",
                stroke="#334155",
            ),
            DiagramElement(
                id="piston",
                shape="circle",
                x=300,
                y=300,
                radius=40,
                label="Piston Valve",
                fill="#e2e8f0",
                stroke="#0f172a",
            ),
        ],
        callouts=[
            VisualCallout(id=14, x=150, y=100, label="Cylinder wall"),
            VisualCallout(id=15, x=300, y=300, label="Intake valve"),
        ],
    )

    svg = compile_svg(spec)

    assert "<svg" in svg
    assert 'viewBox="0 0 800.0 600.0"' in svg or 'viewBox="0 0 800 600"' in svg
    assert "<title>Water Pump Mechanism</title>" in svg
    assert "<script" not in svg
    assert "data-callout-id=\"14\"" in svg
    assert "data-callout-id=\"15\"" in svg

    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(svg, expected_callouts=[14, 15])
    assert result.is_valid
    assert result.errors == []
    assert sorted(result.detected_callouts) == [14, 15]
    assert result.has_title
    assert result.has_viewbox


def test_flowchart_compilation_and_validation_success():
    spec = FlowChartLayoutSpec(
        title="Paper Manufacturing Process",
        description="Chronological steps in modern recycled paper manufacturing.",
        width=800,
        height=400,
        orientation="horizontal",
        steps=[
            FlowChartStep(
                id="step-1",
                step_number=1,
                title="Collection & Sorting",
                description="Raw waste paper is collected",
            ),
            FlowChartStep(
                id="step-2",
                step_number=2,
                title="Pulping & De-inking",
                callout_id=21,
            ),
            FlowChartStep(
                id="step-3",
                step_number=3,
                title="Pressing & Drying",
                callout_id=22,
            ),
        ],
        connections=[
            FlowChartConnection(from_step_id="step-1", to_step_id="step-2"),
            FlowChartConnection(from_step_id="step-2", to_step_id="step-3"),
        ],
        callouts=[
            VisualCallout(id=21, x=350, y=150, label="De-inking chemical bath"),
            VisualCallout(id=22, x=600, y=150, label="Heated rollers"),
        ],
    )

    svg = compile_svg(spec)

    assert "<svg" in svg
    assert 'marker id="arrow"' in svg or 'id="arrow"' in svg
    assert "marker-end=\"url(#arrow)\"" in svg
    assert "<script" not in svg

    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(svg, expected_callouts=[21, 22])
    assert result.is_valid
    assert result.errors == []
    assert sorted(result.detected_callouts) == [21, 22]


def test_evaluator_rejects_malformed_xml():
    malformed_svg = "<svg><title>Broken</title><rect></svg>"
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(malformed_svg, expected_callouts=[])

    assert not result.is_valid
    assert any("XML" in err or "syntax" in err or "mismatched" in err for err in result.errors)


def test_evaluator_rejects_scripts_and_events():
    script_svg = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>Exploit</title><desc>Desc</desc>'
        '<script>alert("hacked")</script>'
        '</svg>'
    )
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(script_svg, expected_callouts=[])
    assert not result.is_valid
    assert any("script" in err.lower() for err in result.errors)

    event_svg = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>Exploit 2</title><desc>Desc</desc>'
        '<circle cx="50" cy="50" r="20" onclick="alert(1)" />'
        '</svg>'
    )
    result2 = evaluator.evaluate(event_svg, expected_callouts=[])
    assert not result2.is_valid
    assert any("event" in err.lower() or "onclick" in err.lower() for err in result2.errors)


def test_evaluator_rejects_external_entities_and_urls():
    doctype_svg = (
        '<?xml version="1.0"?>'
        '<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>'
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>&xxe;</title><desc>Desc</desc>'
        '</svg>'
    )
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(doctype_svg, expected_callouts=[])
    assert not result.is_valid
    assert any("doctype" in err.lower() or "entity" in err.lower() for err in result.errors)

    external_link_svg = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>External Link</title><desc>Desc</desc>'
        '<a href="https://malicious.site"><rect width="10" height="10"/></a>'
        '</svg>'
    )
    result2 = evaluator.evaluate(external_link_svg, expected_callouts=[])
    assert not result2.is_valid
    assert any("external" in err.lower() or "href" in err.lower() for err in result2.errors)


def test_evaluator_rejects_missing_viewbox():
    no_viewbox = '<svg width="800" height="600" xmlns="http://www.w3.org/2000/svg"><title>T</title><desc>D</desc></svg>'
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(no_viewbox, expected_callouts=[])
    assert not result.is_valid
    assert any("viewbox" in err.lower() for err in result.errors)


def test_evaluator_callout_alignment_mismatch():
    svg_with_callout_14 = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>Title</title><desc>Desc</desc>'
        '<g class="callout-badge" data-callout-id="14">'
        '<circle cx="100" cy="100" r="16"/>'
        '<text x="100" y="105">14</text>'
        '</g>'
        '</svg>'
    )
    evaluator = SvgVisualEvaluator()
    # Expecting 14 and 15, but only 14 exists
    result_missing = evaluator.evaluate(svg_with_callout_14, expected_callouts=[14, 15])
    assert not result_missing.is_valid
    assert any("missing" in err.lower() and "15" in err for err in result_missing.errors)

    # Expecting 15, but 14 is present
    result_unexpected = evaluator.evaluate(svg_with_callout_14, expected_callouts=[15])
    assert not result_unexpected.is_valid
    assert any("unexpected" in err.lower() and "14" in err for err in result_unexpected.errors)


def test_evaluator_zero_answer_leakage():
    svg_with_leak = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<title>Diagram</title><desc>Desc</desc>'
        '<text x="50" y="50">Centrifugal Impeller Shaft</text>'
        '<g class="callout-badge" data-callout-id="14"><text>14</text></g>'
        '</svg>'
    )
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(
        svg_with_leak,
        expected_callouts=[14],
        prohibited_answers=["Impeller Shaft"],
    )
    assert not result.is_valid
    assert any("leak" in err.lower() and "Impeller Shaft" in err for err in result.errors)


def test_evaluator_requires_accessibility_title():
    no_title_svg = (
        '<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">'
        '<circle cx="50" cy="50" r="20"/>'
        '</svg>'
    )
    evaluator = SvgVisualEvaluator()
    result = evaluator.evaluate(no_title_svg, expected_callouts=[])
    assert not result.is_valid
    assert any("title" in err.lower() for err in result.errors)
