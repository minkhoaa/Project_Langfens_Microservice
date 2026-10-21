import html
from typing import Dict, List, Tuple, Union
from app.visual.models import (
    DiagramElement,
    DiagramLayoutSpec,
    FlowChartConnection,
    FlowChartLayoutSpec,
    FlowChartStep,
    VisualCallout,
)


def _escape(text: str) -> str:
    """Safely escape text for inclusion in SVG."""
    return html.escape(text or "", quote=True)


def _render_styles() -> str:
    return """  <style>
    .diagram-bg { fill: #ffffff; }
    .shape { stroke-linejoin: round; stroke-linecap: round; }
    .label { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 14px; fill: #1e293b; text-anchor: middle; dominant-baseline: middle; }
    .step-box { rx: 8px; ry: 8px; fill: #f8fafc; stroke: #3b82f6; stroke-width: 2px; }
    .step-title { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 14px; font-weight: 600; fill: #0f172a; text-anchor: middle; }
    .step-desc { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 12px; fill: #64748b; text-anchor: middle; }
    .connector { stroke: #64748b; stroke-width: 2px; fill: none; }
    .callout-badge circle { fill: #ef4444; stroke: #ffffff; stroke-width: 2px; }
    .callout-badge text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 13px; font-weight: bold; fill: #ffffff; text-anchor: middle; dominant-baseline: central; }
  </style>"""


def _render_defs() -> str:
    return """  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="#64748b" />
    </marker>
  </defs>"""


def _render_callout(callout: VisualCallout) -> str:
    badge_x = callout.x
    badge_y = callout.y
    badge_id = callout.id
    escaped_label = _escape(callout.label)
    return (
        f'  <g class="callout-badge" data-callout-id="{badge_id}">\n'
        f'    <circle cx="{badge_x}" cy="{badge_y}" r="16" />\n'
        f'    <text x="{badge_x}" y="{badge_y}">{badge_id}</text>\n'
        + (f'    <title>{escaped_label}</title>\n' if escaped_label else '')
        + f'  </g>'
    )


def _render_diagram_element(elem: DiagramElement) -> str:
    stroke = _escape(elem.stroke or "#334155")
    fill = _escape(elem.fill or "#f8fafc")
    sw = elem.stroke_width or 2.0
    shape_lines = []

    if elem.shape == "rect":
        w = elem.width or 100.0
        h = elem.height or 60.0
        rx = f' rx="{elem.rx}"' if elem.rx is not None else ""
        ry = f' ry="{elem.ry}"' if elem.ry is not None else ""
        shape_lines.append(
            f'  <rect id="{_escape(elem.id)}" class="shape" x="{elem.x}" y="{elem.y}" width="{w}" height="{h}"{rx}{ry} fill="{fill}" stroke="{stroke}" stroke-width="{sw}" />'
        )
        if elem.label:
            cx = elem.x + (w / 2.0)
            cy = elem.y + (h / 2.0)
            shape_lines.append(f'  <text class="label" x="{cx}" y="{cy}">{_escape(elem.label)}</text>')

    elif elem.shape == "circle":
        r = elem.radius or 30.0
        shape_lines.append(
            f'  <circle id="{_escape(elem.id)}" class="shape" cx="{elem.x}" cy="{elem.y}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" />'
        )
        if elem.label:
            shape_lines.append(f'  <text class="label" x="{elem.x}" y="{elem.y}">{_escape(elem.label)}</text>')

    elif elem.shape == "ellipse":
        rx = elem.rx or 40.0
        ry = elem.ry or 20.0
        shape_lines.append(
            f'  <ellipse id="{_escape(elem.id)}" class="shape" cx="{elem.x}" cy="{elem.y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" />'
        )
        if elem.label:
            shape_lines.append(f'  <text class="label" x="{elem.x}" y="{elem.y}">{_escape(elem.label)}</text>')

    elif elem.shape == "path" and elem.d:
        shape_lines.append(
            f'  <path id="{_escape(elem.id)}" class="shape" d="{_escape(elem.d)}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" />'
        )
        if elem.label:
            shape_lines.append(f'  <text class="label" x="{elem.x}" y="{elem.y}">{_escape(elem.label)}</text>')

    elif elem.shape == "text" and elem.label:
        shape_lines.append(
            f'  <text id="{_escape(elem.id)}" class="label" x="{elem.x}" y="{elem.y}">{_escape(elem.label)}</text>'
        )

    return "\n".join(shape_lines)


def _layout_flowchart_steps(
    steps: List[FlowChartStep], width: float, height: float, orientation: str
) -> Dict[str, Tuple[float, float, float, float]]:
    """Calculates coordinates for flowchart steps if not explicitly positioned."""
    step_boxes: Dict[str, Tuple[float, float, float, float]] = {}
    n = len(steps)
    if n == 0:
        return step_boxes

    if orientation == "horizontal":
        step_w = steps[0].width or 180.0
        step_h = steps[0].height or 80.0
        margin_x = 50.0
        available_w = max(width - (2 * margin_x), 100.0)
        gap_x = (available_w - (n * step_w)) / max(n - 1, 1) if n > 1 else 0.0
        if gap_x < 20.0:
            # Compress width if too many steps
            step_w = max((available_w - (n - 1) * 30.0) / n, 80.0)
            gap_x = 30.0

        for i, step in enumerate(steps):
            x = step.x if step.x is not None else margin_x + i * (step_w + gap_x)
            y = step.y if step.y is not None else (height - step_h) / 2.0
            w = step.width or step_w
            h = step.height or step_h
            step_boxes[step.id] = (x, y, w, h)
    else:
        step_w = steps[0].width or 220.0
        step_h = steps[0].height or 70.0
        margin_y = 40.0
        available_h = max(height - (2 * margin_y), 80.0)
        gap_y = (available_h - (n * step_h)) / max(n - 1, 1) if n > 1 else 0.0
        for i, step in enumerate(steps):
            x = step.x if step.x is not None else (width - step_w) / 2.0
            y = step.y if step.y is not None else margin_y + i * (step_h + gap_y)
            w = step.width or step_w
            h = step.height or step_h
            step_boxes[step.id] = (x, y, w, h)

    return step_boxes


def compile_svg(spec: Union[DiagramLayoutSpec, FlowChartLayoutSpec]) -> str:
    """
    Compiles a diagram or flowchart layout specification into responsive,
    sanitized, accessible SVG XML.
    """
    w = spec.width
    h = spec.height
    title = _escape(spec.title)
    desc = _escape(spec.description or spec.title)

    lines: List[str] = [
        f'<svg viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" role="img">',
        f'  <title>{title}</title>',
        f'  <desc>{desc}</desc>',
        _render_styles(),
        _render_defs(),
        f'  <rect width="{w}" height="{h}" class="diagram-bg" />',
    ]

    rendered_callouts: Dict[int, VisualCallout] = {c.id: c for c in spec.callouts}

    if isinstance(spec, DiagramLayoutSpec):
        for elem in spec.elements:
            lines.append(_render_diagram_element(elem))

        for callout in spec.callouts:
            lines.append(_render_callout(callout))

    elif isinstance(spec, FlowChartLayoutSpec):
        boxes = _layout_flowchart_steps(spec.steps, w, h, spec.orientation)

        # Draw connections first so boxes sit above lines
        for conn in spec.connections:
            if conn.from_step_id in boxes and conn.to_step_id in boxes:
                fx, fy, fw, fh = boxes[conn.from_step_id]
                tx, ty, tw, th = boxes[conn.to_step_id]
                if spec.orientation == "horizontal":
                    start_x = fx + fw
                    start_y = fy + (fh / 2.0)
                    end_x = tx
                    end_y = ty + (th / 2.0)
                else:
                    start_x = fx + (fw / 2.0)
                    start_y = fy + fh
                    end_x = tx + (tw / 2.0)
                    end_y = ty

                lines.append(
                    f'  <line x1="{start_x}" y1="{start_y}" x2="{end_x}" y2="{end_y}" class="connector" marker-end="url(#arrow)" />'
                )
                if conn.label:
                    mx = (start_x + end_x) / 2.0
                    my = ((start_y + end_y) / 2.0) - 8.0
                    lines.append(f'  <text class="step-desc" x="{mx}" y="{my}">{_escape(conn.label)}</text>')

        # Draw step boxes
        for step in spec.steps:
            if step.id in boxes:
                bx, by, bw, bh = boxes[step.id]
                lines.append(f'  <g id="{_escape(step.id)}" class="flowchart-step">')
                lines.append(f'    <rect class="step-box" x="{bx}" y="{by}" width="{bw}" height="{bh}" />')
                
                # Title and description
                cx = bx + (bw / 2.0)
                if step.description:
                    ty = by + 30.0
                    dy = by + 52.0
                    lines.append(f'    <text class="step-title" x="{cx}" y="{ty}">{_escape(step.title)}</text>')
                    lines.append(f'    <text class="step-desc" x="{cx}" y="{dy}">{_escape(step.description)}</text>')
                else:
                    ty = by + (bh / 2.0) + 5.0
                    lines.append(f'    <text class="step-title" x="{cx}" y="{ty}">{_escape(step.title)}</text>')

                lines.append('  </g>')

                # If step has callout_id and it's in spec.callouts, place it at box upper right corner
                if step.callout_id and step.callout_id in rendered_callouts:
                    # Update callout position if default was needed
                    pass

        # Render all callouts
        for callout in spec.callouts:
            lines.append(_render_callout(callout))

    lines.append('</svg>')
    return "\n".join(lines)
