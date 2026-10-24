from typing import List, Literal, Optional
from pydantic import BaseModel, Field


class VisualCallout(BaseModel):
    """Callout badge placed on a diagram or flowchart step."""
    id: int
    x: float
    y: float
    label: str = ""


class DiagramElement(BaseModel):
    """Basic SVG primitive shape within a diagram."""
    id: str
    shape: Literal["rect", "circle", "ellipse", "path", "text"]
    x: float = 0.0
    y: float = 0.0
    width: Optional[float] = None
    height: Optional[float] = None
    radius: Optional[float] = None
    rx: Optional[float] = None
    ry: Optional[float] = None
    d: Optional[str] = None
    label: Optional[str] = None
    stroke: Optional[str] = "#334155"
    fill: Optional[str] = "#f8fafc"
    stroke_width: Optional[float] = 2.0


class DiagramLayoutSpec(BaseModel):
    """Layout specification for DIAGRAM_LABEL question types."""
    title: str
    description: Optional[str] = None
    width: float = 800.0
    height: float = 600.0
    elements: List[DiagramElement] = Field(default_factory=list)
    callouts: List[VisualCallout] = Field(default_factory=list)


class FlowChartStep(BaseModel):
    """Step node in a flowchart sequence."""
    id: str
    step_number: int
    title: str
    description: Optional[str] = None
    callout_id: Optional[int] = None
    x: Optional[float] = None
    y: Optional[float] = None
    width: Optional[float] = 180.0
    height: Optional[float] = 80.0


class FlowChartConnection(BaseModel):
    """Directed connection / arrow between steps."""
    from_step_id: str
    to_step_id: str
    label: Optional[str] = None


class FlowChartLayoutSpec(BaseModel):
    """Layout specification for FLOW_CHART question types."""
    title: str
    description: Optional[str] = None
    width: float = 800.0
    height: float = 400.0
    orientation: Literal["horizontal", "vertical"] = "horizontal"
    steps: List[FlowChartStep] = Field(default_factory=list)
    connections: List[FlowChartConnection] = Field(default_factory=list)
    callouts: List[VisualCallout] = Field(default_factory=list)


class VisualValidationResult(BaseModel):
    """Result of structural, visual, and sanitization validation of an SVG."""
    is_valid: bool
    errors: List[str] = Field(default_factory=list)
    detected_callouts: List[int] = Field(default_factory=list)
    has_title: bool = False
    has_viewbox: bool = False
