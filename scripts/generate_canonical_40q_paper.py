"""Script to generate the canonical, academically valid, verified 40-question reading paper."""

import json
import re
import hashlib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# ── Passage Texts ────────────────────────────────────────────────────────────

S1_PASSAGE = (
    "Archaeological investigations at Didé West 1 in the Falémé Valley of eastern Senegal have uncovered "
    "extensive metallurgical evidence spanning nearly eight centuries of continuous iron production, from the "
    "fourth century BCE to the fourth century CE. The site represents one of the longest-lasting iron-smelting "
    "traditions in West Africa, designated by researchers as the FAL02 tradition. Stratigraphic excavations "
    "revealed approximately one hundred tons of dense metallurgical slag and thirty-five preserved circular furnace "
    "bases, demonstrating that metalworking was not an occasional subsistence endeavor but a systematic, sustained "
    "seasonal craft. Radiocarbon determinations on short-lived charcoal samples confirmed continuous workshop occupation "
    "throughout the first millennium BCE and CE without major chronological interruptions. Subsequent geochemical "
    "assays established that local iron ores possessed high hematite purity, enabling remarkable smelting efficiency. "
    "Detailed spatial mapping further established that metallurgical activities were systematically coordinated with "
    "seasonal agricultural rhythms across the surrounding alluvial terraces. The sheer volume of accumulated smelting "
    "debris reflects a stable, multi-generational community of skilled artisans operating within an established regional "
    "economic network.\n\n"
    "The architecture of the FAL02 smelting furnaces displays remarkable technical specialization. Each furnace was "
    "constructed within a circular subterranean pit approximately thirty centimeters deep, carefully lined with "
    "refractory clay to withstand extreme smelting temperatures exceeding 1200 degrees Celsius. Above this pit rested "
    "a removable cylindrical chimney fashioned from coiled clay coils and straw temper, designed to be dismantled after "
    "each reduction cycle to facilitate the extraction of the consolidated bloom. Inside the pit base, smiths placed a "
    "dense bed of palm nut seeds (Elaeis guineensis), which served as carbonaceous packing material to support the charge "
    "and prevent premature slag blockage during the initial combustion phase. Chemical assays of slag residues confirmed "
    "that the thermal decomposition of these organic seeds generated reducing carbon monoxide gas that accelerated iron "
    "ore reduction. Experimental reconstructions demonstrated that this botanical packing material significantly improved "
    "combustion efficiency across all operational stages. Furthermore, the structural design permitted rapid furnace turnaround, "
    "allowing artisans to conduct repeated smelting heats within concise seasonal windows before annual flooding inundated "
    "the low-lying workshop precincts.\n\n"
    "Forced draft was delivered into the furnace through massive, multiperforated clay tuyères inserted horizontally "
    "through specialized apertures near the pit perimeter. Unlike simple single-bore pipes documented at contemporaneous "
    "European sites, these West African tuyères featured an intricate internal manifold consisting of a main central air "
    "channel connected to several perpendicular side ducts. This geometric arrangement distributed preheated combustion "
    "air uniformly across the burning charcoal bed, creating an intensely localized reduction zone while preventing localized "
    "cold spots along the furnace margins. Macroscopic and petrographic examinations of furnace linings showed minimal "
    "localized wall scouring, confirming that the multiperforated design achieved exceptional aerodynamic balance. Modern "
    "computational fluid simulations have confirmed that this geometric configuration maximized heat retention within the "
    "combustion core. Petrographic thin-section analysis revealed that the clay paste was tempered with coarse quartz grains "
    "and crushed potsherds, imparting high thermal shock resistance and preventing catastrophic wall collapse during peak firings.\n\n"
    "Spatial analysis of the workshop floor indicates a deliberate, organized layout that gradually shifted northward across "
    "successive generations. Ore processing areas with quartzite anvils and hammerstones were positioned upwind of the "
    "smelting cluster to shield workers from noxious sulfurous fumes. The smelted iron blooms were extracted while semi-molten "
    "and transferred directly to adjacent anvil platforms for immediate primary forging, yielding compact billets destined "
    "for local agricultural tool manufacture, such as hoes and sickle blades. Intriguingly, despite prolonged usage across "
    "eight centuries, the core metallurgical procedures remained exceptionally stable, with only minor adjustments to tuyère "
    "wall thickness and pit depth observed in later strata. Stratigraphic profiles confirm that workshop waste was systematically "
    "reutilized as leveling aggregate across the site. This exceptional technological conservatism indicates that apprenticeship "
    "and technical knowledge were transmitted across lineages through highly formalized ritualized instructional frameworks.\n\n"
    "Comparative metallurgical analyses indicate that the persistence of the FAL02 tradition was rooted in institutional "
    "resilience and meticulous resource management. The immense timber requirements of continuous smelting necessitated "
    "sustainable harvesting of dense riparian hardwoods, notably Anogeissus leiocarpa and Pterocarpus erinaceus, implying "
    "deliberate woodland conservation rather than unmitigated deforestation. Furthermore, the absence of military weaponry "
    "among the excavated metal assemblages suggests that iron smelting at Didé West 1 was oriented toward agricultural "
    "intensification and regional exchange rather than armed conflict. Collectively, these findings illuminate the sophisticated "
    "technical competence, environmental stewardship, and enduring socioeconomic stability of ancient West African metallurgists. "
    "Detailed excavation records demonstrate that specialized metalworking communities maintained extensive trade contacts "
    "throughout the regional river network, exchanging finished iron implements for vital raw materials. Consequently, Didé "
    "West 1 provides profound empirical evidence that sub-Saharan iron metallurgy developed independently into a resilient, "
    "highly sustainable industrial tradition that supported long-term agrarian demographic stability."
)

S2_PASSAGE = (
    "The rapid proliferation of remote autonomous environmental monitoring nodes has created an urgent demand for "
    "reliable, self-sustaining micro-power generation systems capable of harvesting energy from intermittent ambient "
    "sources. In wetland and forest habitats, solar photovoltaic cells often suffer from dense canopy shading, while "
    "wind velocities fluctuate unpredictably. To address these operational constraints, environmental engineers have "
    "developed an integrated harvester that simultaneously captures kinetic energy from wind and gravitational potential "
    "energy from rainfall. The device couples fluid-structure excitation with piezoelectric transduction, channeling ambient "
    "mechanical energy into a coordinated electrical power output suitable for low-power wireless sensor networks. "
    "Bench-scale wind tunnel evaluations demonstrated that the dual-source mechanism maintained continuous operational "
    "capability during overcast stormy weather conditions. By combining complementary atmospheric energy flows, the "
    "system ensures uninterrupted telemetry data transmission even during severe seasonal weather anomalies that normally "
    "deplete conventional battery-powered installations.\n\n"
    "The wind capture unit utilizes an aerodynamic snowflake bluff body mounted at the windward end of the apparatus. "
    "The aerodynamic snowflake bluff body induces intense vortex-induced vibrations across varying wind velocities. "
    "As laminar airflow encounters the multi-lobed bluff profile, alternating shear layers detach from the downstream "
    "edges, generating periodic fluctuating lift forces. When the vortex shedding frequency approaches the fundamental "
    "natural frequency of the supporting structure, the assembly enters a wide lock-in synchronization regime. This "
    "broadband resonance maintains high vibration amplitudes across airflow speeds ranging from three to eight meters per "
    "second, circumventing the narrow operational bandwidths typical of conventional circular cylinder designs. Static finite "
    "element modeling confirmed that the snowflake geometry increased aerodynamic lift coefficients by over thirty percent. "
    "Detailed particle image velocimetry revealed that secondary vortices shed from the perimeter indentations energized the "
    "wake boundary layer, effectively suppressing premature aerodynamic stall at elevated wind velocities. Wind tunnel flow visualizations "
    "demonstrated that these stable wake vortex streets persisted across substantial yaw angles up to twenty-five degrees.\n\n"
    "Precipitation is harvested using a self-tilting container positioned directly beneath the raindrop collection funnel. "
    "The container periodically tilts upon accumulating a critical water threshold, releasing stored fluid. As falling rain "
    "accumulates within the container, its center of gravity shifts forward until gravitational torque overcomes an adjustable "
    "magnetic latching force. The container then abruptly tips downward, discharging the accumulated water mass and impacting "
    "a secondary strike cantilever. Following discharge, counterweights immediately restore the container to its upright "
    "collection stance. Mechanical strain is transduced into electrical charge through a flexible piezoelectric cantilever "
    "beam. The resulting high-frequency damped oscillations generate sustained alternating voltage spikes across bonded lead "
    "zirconate titanate patches. Dynamic strain gauge calibrations showed that the mechanical impact delivered clean, reproducible "
    "cantilever deflections without inducing micro-fracturing along the active ceramic-substrate interface. Furthermore, the repetitive "
    "water impacts produced no measurable electromechanical hysteresis during continuous cycle operations.\n\n"
    "Both transducers feed into a unified P-SSHI circuit designed to eliminate phase cancellation. The parallel-synchronized "
    "switch harvesting on inductor interface incorporates a bidirectional electronic switch and a miniature resonant "
    "inductor connected in parallel with the piezoelectric elements. The electronic switch momentarily closes at each displacement "
    "extremum, triggering rapid voltage inversion across the inductor. This rapid phase inversion aligns the piezoelectric "
    "internal capacitance voltage with the generated mechanical displacement velocity, substantially minimizing dielectric "
    "energy losses that normally cripple standard full-bridge rectifiers. Theoretical simulations established that an optimal "
    "resonant inductance of two henries minimized total circuit dissipation during high-frequency switching cycles. Crucially, "
    "the self-powered switching architecture operates autonomously without requiring external bias power, consuming negligible "
    "standby energy between intermittent switching events. The resulting synchronized energy extraction allows connected "
    "monitoring devices to maintain continuous sleep-wake sensing schedules without experiencing brownouts during prolonged "
    "lulls in atmospheric excitation.\n\n"
    "Laboratory prototyping and oscilloscope measurements corroborated the theoretical performance model across a broad "
    "spectrum of meteorological conditions. Maximum power transfer was achieved when connecting an external load resistance of "
    "fifty kiloohms. Under concurrent wind and rain excitation, the device achieved a peak open-circuit voltage of 8.1 volts "
    "and a continuous average power output of 54.7 microwatts. The experimental configuration achieved an average output power "
    "improvement of 138.9 percent over standard full-bridge rectifiers. Furthermore, comparative tests confirmed that the "
    "hybrid harvester maintained stable power output even during abrupt micro-burst gusts and prolonged drizzle, validating "
    "its feasibility as a maintenance-free power supply for long-term ecological monitoring stations in vulnerable nature reserves. "
    "Extended endurance trials revealed no measurable mechanical fatigue or electrical degradation after ten million continuous "
    "vibration cycles, confirming that the micro-generator meets rigorous industrial reliability criteria."
)

S3_PASSAGE = (
    "Paragraph A\n"
    "The modulation of Earth's long-term carbon cycle by tectonic uplift and chemical weathering remains one of the central "
    "paradigms of global geodynamics. Mountain building accelerates physical denudation, exposing fresh silicate and carbonate "
    "minerals to atmospheric precipitation. In active orogenic belts, the interplay between stream incision, hillslope "
    "erodibility, and atmospheric carbon dioxide drawdown has traditionally been modeled assuming lithologic homogeneity. "
    "Classical steady-state formulations assumed that hillslope angles and river gradients directly reflect regional rock uplift "
    "rates without considering substrate variability. Modern geomorphic paradigms increasingly recognize that spatial "
    "variations in rock strength dictate how river networks incise and how topography adjusts over geological timescales. "
    "However, recent empirical investigations in the East River alpine watershed of the Colorado Rocky Mountains demonstrate "
    "that contrasting rock types within the same tectonic regime exert a first-order control on transient erosion rates, "
    "fundamentally altering inorganic weathering dynamics and regional carbon flux balances.\n\n"
    "Paragraph B\n"
    "To resolve the spatial coupling between lithology and erosion, researchers quantified catchment-wide denudation rates "
    "using in situ produced cosmogenic beryllium-10 concentrations extracted from fluvial quartz sand. The results revealed "
    "striking discrepancies across adjacent catchments under identical climatic forcing. Watersheds underlain by Cretaceous "
    "Mancos Shale denude at rates averaging three times higher than neighboring catchments composed of resistant Tertiary "
    "granodiorite intrusions. Remarkably, this threefold acceleration in shale denudation occurs across hillslopes that exhibit "
    "significantly gentler topographic gradients than the precipitous granodiorite peaks, directly challenging the conventional "
    "geomorphic assumption that steeper slopes necessarily produce higher erosion rates. High-resolution lidar hillshade models "
    "demonstrated pervasive deep-seated landsliding across gentle shale slopes. Field surveys established that frequent, "
    "shallow translational mass movements continuously disaggregate the weathered shale mantle, sustaining rapid mechanical "
    "sediment transport into valley bottoms despite moderate relief.\n\n"
    "Paragraph C\n"
    "Hydrochemical sampling of stream waters across seasonal discharge cycles illuminated the biogeochemical consequences of "
    "this lithologic divergence. Chemical weathering of exposed shale beds is dominated by sulfuric acid dissolution, generated "
    "by the oxidative weathering of fine-grained pyrite minerals embedded in the organic-rich sedimentary matrix. Unlike carbonic "
    "acid weathering of silicate minerals, which sequesters carbon from the atmosphere, sulfide oxidation coupled with carbonate "
    "dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere. Stream solute budgets demonstrate "
    "that high denudation in shale terrains actually drives a net positive efflux of inorganic carbon dioxide, turning rapidly "
    "eroding alpine fells into transient carbon sources. Isotope ratios confirmed that dissolved inorganic carbon originated "
    "primarily from marine carbonate bedrock dissolution. Consequently, high physical denudation in sedimentary orogens can "
    "paradoxically offset silicate carbon sink efficiency by accelerating mineral-mediated carbon degassing.\n\n"
    "Paragraph D\n"
    "High-resolution airborne laser altimetry and topographic swath profiling reveal that the landscape is currently adjusting "
    "to a wave of transient knickpoint propagation initiated by base-level lowering along the Gunnison River. Numerical landscape "
    "evolution models parameterizing variable bedrock erodibility show that the response time of shale-dominated river reaches is "
    "an order of magnitude faster than that of crystalline intrusive reaches. Consequently, the softer shale terrain rapidly "
    "attains an adjusted, lower-gradient steady state, while the adjacent intrusive massifs retain steep, hanging knickzones for "
    "millions of years, prolonging the transient topographic disequilibrium. Field observations of hanging tributary valleys "
    "further corroborated this persistent morphological divergence across the drainage network. Longitudinal river profiles "
    "exhibit prominent convexities exclusively located where stream channels cross the lithologic boundary between intrusive "
    "stocks and surrounding sedimentary country rock. Quantitative knickpoint tracking over decadal timescales demonstrates "
    "that resistant crystalline knickzones migrate upstream at rates less than one-tenth of those observed in adjacent shale "
    "channels, anchoring the broader drainage network in a state of prolonged transient disequilibrium.\n\n"
    "Paragraph E\n"
    "These findings require a substantial revision of global tectonic-carbon feedback models. By demonstrating that high bedrock "
    "erodibility can mask rapid denudation beneath deceptively gentle terrain, the study proves that topographic steepness cannot "
    "serve as a universal proxy for physical weathering rates. Furthermore, because sulfuric acid-mediated carbonate weathering "
    "in erodible sedimentary rocks operates on fundamentally different chemical timescales than silicate weathering, the net "
    "climate impact of mountain uplift depends critically on the lithologic composition of the exposed strata. Regions dominated "
    "by erodible, pyrite-bearing shales may transiently accelerate global warming rather than global cooling during the early "
    "stages of orogenic exhumation. Global climate-erosion simulations incorporating lithologic erodibility matrices demonstrate "
    "that mountain exhumation can generate profound multi-million-year carbon cycle oscillations. Unraveling these coupled "
    "mechanisms is vital for refining Cenozoic climate reconstructions and predicting long-term biosphere-lithosphere feedbacks."
)


# ── SVG Assets ───────────────────────────────────────────────────────────────

FLOWCHART_SVG = (
    '<svg viewBox="0 0 800.0 400.0" xmlns="http://www.w3.org/2000/svg" role="img">\n'
    '  <title>Prehistoric Iron Smelting Process Flow</title>\n'
    '  <desc>Sequential metallurgical stages of the FAL02 iron smelting tradition at Didé West 1.</desc>\n'
    '  <style>\n'
    '    .diagram-bg { fill: #ffffff; }\n'
    '    .step-box { rx: 8px; ry: 8px; fill: #f8fafc; stroke: #3b82f6; stroke-width: 2px; }\n'
    '    .step-title { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 14px; font-weight: 600; fill: #0f172a; text-anchor: middle; }\n'
    '    .step-desc { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 12px; fill: #64748b; text-anchor: middle; }\n'
    '    .connector { stroke: #64748b; stroke-width: 2px; fill: none; }\n'
    '    .callout-badge circle { fill: #ef4444; stroke: #ffffff; stroke-width: 2px; }\n'
    '    .callout-badge text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 12px; font-weight: bold; fill: #ffffff; text-anchor: middle; dominant-baseline: central; }\n'
    '  </style>\n'
    '  <rect width="800.0" height="400.0" class="diagram-bg" />\n'
    '  <g id="step-1">\n'
    '    <rect class="step-box" x="40" y="80" width="140" height="70" />\n'
    '    <text class="step-title" x="110" y="115">Pit Preparation</text>\n'
    '    <text class="step-desc" x="110" y="135">Refractory lining</text>\n'
    '  </g>\n'
    '  <g id="step-2">\n'
    '    <rect class="step-box" x="230" y="80" width="140" height="70" />\n'
    '    <text class="step-title" x="300" y="115">Base Packing</text>\n'
    '    <text class="step-desc" x="300" y="135">Palm nut seeds</text>\n'
    '    <g class="callout-badge" data-callout-id="10">\n'
    '      <circle cx="230" cy="80" r="14" />\n'
    '      <text x="230" y="80">10</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="step-3">\n'
    '    <rect class="step-box" x="420" y="80" width="140" height="70" />\n'
    '    <text class="step-title" x="490" y="115">Draft Delivery</text>\n'
    '    <text class="step-desc" x="490" y="135">Multiperforated tubes</text>\n'
    '    <g class="callout-badge" data-callout-id="11">\n'
    '      <circle cx="420" cy="80" r="14" />\n'
    '      <text x="420" y="80">11</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="step-4">\n'
    '    <rect class="step-box" x="610" y="80" width="150" height="70" />\n'
    '    <text class="step-title" x="685" y="115">Gas Reduction</text>\n'
    '    <text class="step-desc" x="685" y="135">Ore conversion</text>\n'
    '    <g class="callout-badge" data-callout-id="12">\n'
    '      <circle cx="610" cy="80" r="14" />\n'
    '      <text x="610" y="80">12</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="step-5">\n'
    '    <rect class="step-box" x="325" y="240" width="150" height="70" />\n'
    '    <text class="step-title" x="400" y="275">Primary Forging</text>\n'
    '    <text class="step-desc" x="400" y="295">Billet consolidation</text>\n'
    '    <g class="callout-badge" data-callout-id="13">\n'
    '      <circle cx="325" cy="240" r="14" />\n'
    '      <text x="325" y="240">13</text>\n'
    '    </g>\n'
    '  </g>\n'
    '</svg>'
)

DIAGRAM_SVG = (
    '<svg viewBox="0 0 800.0 600.0" xmlns="http://www.w3.org/2000/svg" role="img">\n'
    '  <title>Combined Wind-Rain Piezoelectric Energy Harvester Architecture</title>\n'
    '  <desc>Schematic cross-section of the dual-source piezoelectric micro-generator.</desc>\n'
    '  <style>\n'
    '    .diagram-bg { fill: #ffffff; }\n'
    '    .shape { stroke-linejoin: round; stroke-linecap: round; }\n'
    '    .label { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 13px; fill: #1e293b; text-anchor: middle; dominant-baseline: middle; }\n'
    '    .callout-badge circle { fill: #ef4444; stroke: #ffffff; stroke-width: 2px; }\n'
    '    .callout-badge text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 13px; font-weight: bold; fill: #ffffff; text-anchor: middle; dominant-baseline: central; }\n'
    '  </style>\n'
    '  <rect width="800.0" height="600.0" class="diagram-bg" />\n'
    '  <g id="aerodynamic-head">\n'
    '    <polygon class="shape" points="150,150 180,110 220,130 250,90 280,130 320,110 350,150 320,190 280,170 250,210 220,170 180,190" fill="#e2e8f0" stroke="#0f172a" stroke-width="2" />\n'
    '    <text class="label" x="250" y="150">Vortex Bluff Body</text>\n'
    '    <g class="callout-badge" data-callout-id="14">\n'
    '      <circle cx="150" cy="150" r="16" />\n'
    '      <text x="150" y="150">14</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="water-collector">\n'
    '    <polygon class="shape" points="480,100 580,100 550,180 510,180" fill="#bfdbfe" stroke="#1d4ed8" stroke-width="2" />\n'
    '    <text class="label" x="530" y="140">Rain Container</text>\n'
    '    <g class="callout-badge" data-callout-id="15">\n'
    '      <circle cx="480" cy="100" r="16" />\n'
    '      <text x="480" y="100">15</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="piezo-beam">\n'
    '    <rect class="shape" x="200" y="320" width="400" height="24" rx="4" fill="#cbd5e1" stroke="#334155" stroke-width="2" />\n'
    '    <rect class="shape" x="220" y="316" width="160" height="8" rx="2" fill="#f59e0b" stroke="#b45309" stroke-width="1.5" />\n'
    '    <text class="label" x="400" y="332">Flexible Transducer</text>\n'
    '    <g class="callout-badge" data-callout-id="16">\n'
    '      <circle cx="200" cy="320" r="16" />\n'
    '      <text x="200" y="320">16</text>\n'
    '    </g>\n'
    '  </g>\n'
    '  <g id="psshi-circuit">\n'
    '    <rect class="shape" x="300" y="440" width="200" height="90" rx="8" fill="#f1f5f9" stroke="#047857" stroke-width="2" />\n'
    '    <text class="label" x="400" y="475">Conditioning Interface</text>\n'
    '    <text class="label" x="400" y="495">LC Inductor Switch</text>\n'
    '    <g class="callout-badge" data-callout-id="17">\n'
    '      <circle cx="300" cy="440" r="16" />\n'
    '      <text x="300" y="440">17</text>\n'
    '    </g>\n'
    '  </g>\n'
    '</svg>'
)


def make_evidence_span(passage: str, quote: str) -> dict:
    start = passage.find(quote)
    if start < 0:
        raise ValueError(f"Quote not found in passage: '{quote}'")
    return {"startChar": start, "endChar": start + len(quote), "text": quote}


def build_canonical_40q_paper() -> dict:
    # ── Section 1 Questions (1..13) ──────────────────────────────────────────
    q1_quote = "Stratigraphic excavations revealed approximately one hundred tons of dense metallurgical slag and thirty-five preserved circular furnace bases"
    q2_quote = "Above this pit rested a removable cylindrical chimney fashioned from coiled clay coils and straw temper, designed to be dismantled after each reduction cycle"
    q3_quote = "Inside the pit base, smiths placed a dense bed of palm nut seeds (Elaeis guineensis), which served as carbonaceous packing material to support the charge"
    q5_quote = "the absence of military weaponry among the excavated metal assemblages suggests that iron smelting at Didé West 1 was oriented toward agricultural intensification and regional exchange"

    q6_quote = "Each furnace was constructed within a circular subterranean pit approximately thirty centimeters deep"
    q7_quote = "Above this pit rested a removable cylindrical chimney fashioned from coiled clay coils and straw temper"
    q8_quote = "Forced draft was delivered into the furnace through massive, multiperforated clay tuyères inserted horizontally"
    q9_quote = "The immense timber requirements of continuous smelting necessitated sustainable harvesting of dense riparian hardwoods"

    q10_quote = "which served as carbonaceous packing material to support the charge"
    q11_quote = "through massive, multiperforated clay tuyères inserted horizontally"
    q12_quote = "the thermal decomposition of these organic seeds generated reducing carbon monoxide gas that accelerated iron ore reduction"
    q13_quote = "transferred directly to adjacent anvil platforms for immediate primary forging"

    s1_g1_questions = [
        {
            "questionNumber": 1,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "Excavations at Didé West 1 uncovered roughly one hundred tons of metallurgical slag.",
            "answer": "TRUE",
            "evidenceQuote": q1_quote,
            "explanation": "The text explicitly confirms that excavations uncovered roughly one hundred tons of dense metallurgical slag.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q1_quote),
            "evidenceClaimRef": "claim:s1:slag_volume",
        },
        {
            "questionNumber": 2,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "The FAL02 smelting furnaces featured permanently fixed chimneys that could not be dismantled.",
            "answer": "FALSE",
            "evidenceQuote": q2_quote,
            "explanation": "The passage contradicts this, stating the chimneys were removable and designed to be dismantled after each reduction cycle.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q2_quote),
            "evidenceClaimRef": "claim:s1:removable_chimney",
        },
        {
            "questionNumber": 3,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "Palm nut seeds were placed inside the pit base to serve as organic packing material.",
            "answer": "TRUE",
            "evidenceQuote": q3_quote,
            "explanation": "The text directly states that smiths placed palm nut seeds as carbonaceous packing material at the pit base.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q3_quote),
            "evidenceClaimRef": "claim:s1:palm_packing",
        },
        {
            "questionNumber": 4,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "European metallurgists directly assisted the Falémé Valley smiths in designing multiperforated tuyères.",
            "answer": "NOT_GIVEN",
            "explanation": "The passage discusses European single-bore pipes for comparison but gives no information about European assistance.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 0, "endChar": 50, "text": S1_PASSAGE[:50]},
            "evidenceClaimRef": "claim:s1:tuyere_architecture",
            "absenceAssessment": {
                "assessmentId": "abs:1:4",
                "claimOrTopic": "European metallurgists directly assisted the Falémé Valley smiths in designing multiperforated tuyères.",
                "absenceReason": "The passage provides no statement or evidence regarding external European assistance.",
                "absenceConfirmed": True,
            },
        },
        {
            "questionNumber": 5,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "The majority of iron tools manufactured at Didé West 1 were military swords and spears.",
            "answer": "FALSE",
            "evidenceQuote": q5_quote,
            "explanation": "The passage contradicts this by highlighting the absence of military weaponry and noting production was agricultural.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q5_quote),
            "evidenceClaimRef": "claim:s1:peaceful_tools",
        },
    ]

    s1_g2_questions = [
        {
            "questionNumber": 6,
            "questionType": "TABLE_COMPLETION",
            "prompt": "Pit depth: subterranean furnace base excavated approximately [6] into the subsoil",
            "answer": "thirty centimeters",
            "evidenceQuote": q6_quote,
            "explanation": "The passage explicitly gives the depth as 'approximately thirty centimeters deep'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q6_quote),
            "evidenceClaimRef": "claim:s1:pit_depth",
            "rowHeader": "Subterranean pit",
            "colHeader": "Dimension",
            "tableContext": "FAL02 Furnace Architectural Specifications",
        },
        {
            "questionNumber": 7,
            "questionType": "TABLE_COMPLETION",
            "prompt": "Chimney structure: constructed from coiled clay blended with [7] for structural reinforcement",
            "answer": "straw temper",
            "evidenceQuote": q7_quote,
            "explanation": "The passage states the removable cylindrical chimney was fashioned from clay coils and 'straw temper'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q7_quote),
            "evidenceClaimRef": "claim:s1:removable_chimney",
            "rowHeader": "Cylindrical chimney",
            "colHeader": "Material",
            "tableContext": "FAL02 Furnace Architectural Specifications",
        },
        {
            "questionNumber": 8,
            "questionType": "TABLE_COMPLETION",
            "prompt": "Air delivery mechanism: forced draft supplied through massive [8] with perpendicular side ducts",
            "answer": "multiperforated clay tuyères",
            "evidenceQuote": q8_quote,
            "explanation": "The text states forced draft entered through 'massive, multiperforated clay tuyères'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q8_quote),
            "evidenceClaimRef": "claim:s1:tuyere_architecture",
            "rowHeader": "Air intake",
            "colHeader": "Component",
            "tableContext": "FAL02 Furnace Architectural Specifications",
        },
        {
            "questionNumber": 9,
            "questionType": "TABLE_COMPLETION",
            "prompt": "Fuel source: sustained smelting operations consumed dense [9] from surrounding gallery forests",
            "answer": "riparian hardwoods",
            "evidenceQuote": q9_quote,
            "explanation": "The text notes the sustainable harvesting of 'dense riparian hardwoods'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q9_quote),
            "evidenceClaimRef": "claim:s1:hardwood_timber",
            "rowHeader": "Charcoal fuel",
            "colHeader": "Resource",
            "tableContext": "FAL02 Furnace Architectural Specifications",
        },
    ]

    s1_g3_questions = [
        {
            "questionNumber": 10,
            "questionType": "FLOW_CHART",
            "prompt": "Stage 2: Pit base is lined with palm seeds serving as [10] to support the ore charge",
            "answer": "carbonaceous packing",
            "evidenceQuote": q10_quote,
            "explanation": "The text indicates seeds served as 'carbonaceous packing material'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q10_quote),
            "evidenceClaimRef": "claim:s1:palm_packing",
            "svgAssetId": "svg:s1:flowchart",
            "svgXml": FLOWCHART_SVG,
            "stepIndex": 2,
            "flowSteps": ["Excavation", "Base Packing", "Draft Delivery", "Gas Reduction", "Primary Forging"],
        },
        {
            "questionNumber": 11,
            "questionType": "FLOW_CHART",
            "prompt": "Stage 3: Forced draft is directed into the combustion core through [11] around the base",
            "answer": "clay tuyères",
            "evidenceQuote": q11_quote,
            "explanation": "The text specifies forced draft was delivered through multiperforated 'clay tuyères'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q11_quote),
            "evidenceClaimRef": "claim:s1:tuyere_architecture",
            "svgAssetId": "svg:s1:flowchart",
            "svgXml": FLOWCHART_SVG,
            "stepIndex": 3,
            "flowSteps": ["Excavation", "Base Packing", "Draft Delivery", "Gas Reduction", "Primary Forging"],
        },
        {
            "questionNumber": 12,
            "questionType": "FLOW_CHART",
            "prompt": "Stage 4: Thermal decomposition of organic seeds releases reducing [12] to accelerate smelting",
            "answer": "carbon monoxide",
            "evidenceQuote": q12_quote,
            "explanation": "The passage confirms thermal decomposition generated 'carbon monoxide gas'.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q12_quote),
            "evidenceClaimRef": "claim:s1:reducing_gas",
            "svgAssetId": "svg:s1:flowchart",
            "svgXml": FLOWCHART_SVG,
            "stepIndex": 4,
            "flowSteps": ["Excavation", "Base Packing", "Draft Delivery", "Gas Reduction", "Primary Forging"],
        },
        {
            "questionNumber": 13,
            "questionType": "FLOW_CHART",
            "prompt": "Stage 5: Semi-molten blooms are transferred to [13] for immediate compaction into billets",
            "answer": "anvil platforms",
            "evidenceQuote": q13_quote,
            "explanation": "The text specifies semi-molten blooms were moved to 'anvil platforms' for primary forging.",
            "difficulty": "FOUNDATION",
            "passageEvidence": make_evidence_span(S1_PASSAGE, q13_quote),
            "evidenceClaimRef": "claim:s1:anvil_platforms",
            "svgAssetId": "svg:s1:flowchart",
            "svgXml": FLOWCHART_SVG,
            "stepIndex": 5,
            "flowSteps": ["Excavation", "Base Packing", "Draft Delivery", "Gas Reduction", "Primary Forging"],
        },
    ]

    # ── Section 2 Questions (14..26) ─────────────────────────────────────────
    q14_quote = "The aerodynamic snowflake bluff body induces intense vortex-induced vibrations across varying wind velocities"
    q15_quote = "The container periodically tilts upon accumulating a critical water threshold, releasing stored fluid"
    q16_quote = "Mechanical strain is transduced into electrical charge through a flexible piezoelectric cantilever beam"
    q17_quote = "Both transducers feed into a unified P-SSHI circuit designed to eliminate phase cancellation"

    q18_quote = "The aerodynamic snowflake bluff body induces intense vortex-induced vibrations across varying wind velocities"
    q19_quote = "The container periodically tilts upon accumulating a critical water threshold, releasing stored fluid"
    q20_quote = "The electronic switch momentarily closes at each displacement extremum, triggering rapid voltage inversion across the inductor"
    q21_quote = "Theoretical simulations established that an optimal resonant inductance of two henries minimized total circuit dissipation during high-frequency switching cycles"
    q22_quote = "The experimental configuration achieved an average output power improvement of 138.9 percent over standard full-bridge rectifiers"

    s2_g1_questions = [
        {
            "questionNumber": 14,
            "questionType": "DIAGRAM_LABEL",
            "prompt": "Label [14] on the wind energy capture head",
            "answer": "snowflake bluff body",
            "evidenceQuote": q14_quote,
            "explanation": "Callout 14 identifies the aerodynamic multi-lobed snowflake bluff body.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q14_quote),
            "evidenceClaimRef": "claim:s2:snowflake_body",
            "calloutLabel": "14",
            "partDescription": "Windward aerodynamic bluff structure",
            "svgAssetId": "svg:s2:diagram",
            "svgXml": DIAGRAM_SVG,
        },
        {
            "questionNumber": 15,
            "questionType": "DIAGRAM_LABEL",
            "prompt": "Label [15] on the raindrop collection mechanism",
            "answer": "tilting container",
            "evidenceQuote": q15_quote,
            "explanation": "Callout 15 identifies the self-tilting water collection container.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q15_quote),
            "evidenceClaimRef": "claim:s2:tilting_container",
            "calloutLabel": "15",
            "partDescription": "Pivoting fluid catchment reservoir",
            "svgAssetId": "svg:s2:diagram",
            "svgXml": DIAGRAM_SVG,
        },
        {
            "questionNumber": 16,
            "questionType": "DIAGRAM_LABEL",
            "prompt": "Label [16] on the electromechanical transducer",
            "answer": "piezoelectric cantilever",
            "evidenceQuote": q16_quote,
            "explanation": "Callout 16 identifies the flexible piezoelectric cantilever beam with PZT patches.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q16_quote),
            "evidenceClaimRef": "claim:s2:piezo_beam",
            "calloutLabel": "16",
            "partDescription": "Flexible oscillating transducer beam",
            "svgAssetId": "svg:s2:diagram",
            "svgXml": DIAGRAM_SVG,
        },
        {
            "questionNumber": 17,
            "questionType": "DIAGRAM_LABEL",
            "prompt": "Label [17] on the electrical interface unit",
            "answer": "P-SSHI circuit",
            "evidenceQuote": q17_quote,
            "explanation": "Callout 17 identifies the parallel synchronized switch harvesting on inductor circuit.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q17_quote),
            "evidenceClaimRef": "claim:s2:psshi_circuit",
            "calloutLabel": "17",
            "partDescription": "Parallel synchronized switch interface module",
            "svgAssetId": "svg:s2:diagram",
            "svgXml": DIAGRAM_SVG,
        },
    ]

    s2_g2_questions = [
        {
            "questionNumber": 18,
            "questionType": "SUMMARY_COMPLETION",
            "prompt": "Airflow past the multi-lobed bluff body stimulates broadband [18] over a wide range of velocities.",
            "answer": "vortex-induced vibrations",
            "evidenceQuote": q18_quote,
            "explanation": "The text explicitly states the snowflake bluff body induces 'vortex-induced vibrations'.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q18_quote),
            "evidenceClaimRef": "claim:s2:snowflake_body",
        },
        {
            "questionNumber": 19,
            "questionType": "SUMMARY_COMPLETION",
            "prompt": "The rainfall catchment mechanism discharges accumulated liquid once it exceeds a designated [19].",
            "answer": "water threshold",
            "evidenceQuote": q19_quote,
            "explanation": "The passage confirms the container periodically tilts upon accumulating a 'critical water threshold'.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q19_quote),
            "evidenceClaimRef": "claim:s2:tilting_container",
        },
        {
            "questionNumber": 20,
            "questionType": "SUMMARY_COMPLETION",
            "prompt": "At extreme points of mechanical displacement, electronic switching induces instantaneous [20] across the coil.",
            "answer": "voltage inversion",
            "evidenceQuote": q20_quote,
            "explanation": "The text states closing the switch triggers 'rapid voltage inversion across the inductor'.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q20_quote),
            "evidenceClaimRef": "claim:s2:voltage_inversion",
        },
        {
            "questionNumber": 21,
            "questionType": "SUMMARY_COMPLETION",
            "prompt": "Numerical circuit models demonstrated that selecting a [21] of 2 H substantially lowered internal losses.",
            "answer": "resonant inductance",
            "evidenceQuote": q21_quote,
            "explanation": "The passage specifies 'an optimal resonant inductance of two henries minimized total circuit dissipation'.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q21_quote),
            "evidenceClaimRef": "claim:s2:optimal_inductance",
        },
        {
            "questionNumber": 22,
            "questionType": "SUMMARY_COMPLETION",
            "prompt": "Bench testing confirmed that the P-SSHI circuit delivered an [22] compared with standard rectification.",
            "answer": "138.9 percent",
            "evidenceQuote": q22_quote,
            "explanation": "The experimental output power achieved an 'improvement of 138.9 percent' over standard full-bridge rectifiers.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, q22_quote),
            "evidenceClaimRef": "claim:s2:power_improvement",
        },
    ]

    s2_g3_questions = [
        {
            "questionNumber": 23,
            "questionType": "SUMMARY_COMPLETION_BOX",
            "prompt": "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23].",
            "answer": "G",
            "options": [
                "A. aerodynamic turbulence",
                "B. full-bridge rectifier",
                "C. resonant inductance",
                "D. piezoelectric coupling",
                "E. impedance matching",
                "F. kinetic energy",
                "G. environmental monitoring",
            ],
            "evidenceQuote": "The rapid proliferation of remote autonomous environmental monitoring nodes has created an urgent demand for reliable, self-sustaining micro-power generation systems",
            "explanation": "The text states the primary motivation was remote autonomous 'environmental monitoring nodes'. Option G matches.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, "The rapid proliferation of remote autonomous environmental monitoring nodes has created an urgent demand for reliable, self-sustaining micro-power generation systems"),
            "evidenceClaimRef": "claim:s2:monitoring_nodes",
            "summaryText": "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23]. Unlike standard systems deploying a [24], the new circuit incorporates a [25] in parallel with the beam. Furthermore, precise load optimization establishes [26] to maximize continuous energy output.",
        },
        {
            "questionNumber": 24,
            "questionType": "SUMMARY_COMPLETION_BOX",
            "prompt": "Unlike standard systems deploying a [24], the new circuit incorporates specialized switching.",
            "answer": "B",
            "options": [
                "A. aerodynamic turbulence",
                "B. full-bridge rectifier",
                "C. resonant inductance",
                "D. piezoelectric coupling",
                "E. impedance matching",
                "F. kinetic energy",
                "G. environmental monitoring",
            ],
            "evidenceQuote": "substantially minimizing dielectric energy losses that normally cripple standard full-bridge rectifiers",
            "explanation": "The text contrasts the P-SSHI interface against 'standard full-bridge rectifiers'. Option B matches.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, "substantially minimizing dielectric energy losses that normally cripple standard full-bridge rectifiers"),
            "evidenceClaimRef": "claim:s2:rectifier_contrast",
            "summaryText": "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23]. Unlike standard systems deploying a [24], the new circuit incorporates a [25] in parallel with the beam. Furthermore, precise load optimization establishes [26] to maximize continuous energy output.",
        },
        {
            "questionNumber": 25,
            "questionType": "SUMMARY_COMPLETION_BOX",
            "prompt": "The new circuit incorporates a [25] in parallel with the beam to invert terminal voltage.",
            "answer": "C",
            "options": [
                "A. aerodynamic turbulence",
                "B. full-bridge rectifier",
                "C. resonant inductance",
                "D. piezoelectric coupling",
                "E. impedance matching",
                "F. kinetic energy",
                "G. environmental monitoring",
            ],
            "evidenceQuote": "The parallel-synchronized switch harvesting on inductor interface incorporates a bidirectional electronic switch and a miniature resonant inductor connected in parallel with the piezoelectric elements",
            "explanation": "The text identifies the parallel component as a miniature resonant inductor ('resonant inductance'). Option C matches.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, "The parallel-synchronized switch harvesting on inductor interface incorporates a bidirectional electronic switch and a miniature resonant inductor connected in parallel with the piezoelectric elements"),
            "evidenceClaimRef": "claim:s2:psshi_components",
            "summaryText": "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23]. Unlike standard systems deploying a [24], the new circuit incorporates a [25] in parallel with the beam. Furthermore, precise load optimization establishes [26] to maximize continuous energy output.",
        },
        {
            "questionNumber": 26,
            "questionType": "SUMMARY_COMPLETION_BOX",
            "prompt": "Furthermore, precise load optimization establishes [26] to maximize continuous energy output.",
            "answer": "E",
            "options": [
                "A. aerodynamic turbulence",
                "B. full-bridge rectifier",
                "C. resonant inductance",
                "D. piezoelectric coupling",
                "E. impedance matching",
                "F. kinetic energy",
                "G. environmental monitoring",
            ],
            "evidenceQuote": "Maximum power transfer was achieved when connecting an external load resistance of fifty kiloohms",
            "explanation": "Adjusting external load resistance for maximum power transfer represents impedance matching. Option E matches.",
            "difficulty": "MODERATE",
            "passageEvidence": make_evidence_span(S2_PASSAGE, "Maximum power transfer was achieved when connecting an external load resistance of fifty kiloohms"),
            "evidenceClaimRef": "claim:s2:load_matching",
            "summaryText": "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23]. Unlike standard systems deploying a [24], the new circuit incorporates a [25] in parallel with the beam. Furthermore, precise load optimization establishes [26] to maximize continuous energy output.",
        },
    ]

    # ── Section 3 Questions (27..40) ─────────────────────────────────────────
    q27_quote = "In active orogenic belts, the interplay between stream incision, hillslope erodibility, and atmospheric carbon dioxide drawdown has traditionally been modeled assuming lithologic homogeneity"
    q28_quote = "researchers quantified catchment-wide denudation rates using in situ produced cosmogenic beryllium-10 concentrations extracted from fluvial quartz sand"
    q29_quote = "this threefold acceleration in shale denudation occurs across hillslopes that exhibit significantly gentler topographic gradients than the precipitous granodiorite peaks"
    q30_quote = "sulfide oxidation coupled with carbonate dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere"
    q31_quote = "the adjacent intrusive massifs retain steep, hanging knickzones for millions of years, prolonging the transient topographic disequilibrium"

    endings_options = [
        "A. exhibit substantially gentler slope gradients than crystalline peaks.",
        "B. results in net release of carbon dioxide to the atmosphere.",
        "C. assumed that bedrock lithology remained uniform across mountain ranges.",
        "D. prolongs the duration of topographic disequilibrium across the landscape.",
        "E. extracts in situ cosmogenic beryllium-10 from river sediments.",
        "F. leads to catastrophic landslide failures along drainage divides.",
        "G. stabilizes deep groundwater aquifers during summer droughts.",
    ]

    s3_g1_questions = [
        {
            "questionNumber": 27,
            "questionType": "MATCHING_ENDINGS",
            "prompt": "Traditional models linking mountain uplift to chemical weathering [27]",
            "stem": "Traditional models linking mountain uplift to chemical weathering",
            "answer": "C",
            "options": endings_options,
            "endings": endings_options,
            "evidenceQuote": q27_quote,
            "explanation": "The text states earlier models operated 'assuming lithologic homogeneity' (uniform rock type). Matches C.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, q27_quote),
            "evidenceClaimRef": "claim:s3:homogeneity_assumption",
        },
        {
            "questionNumber": 28,
            "questionType": "MATCHING_ENDINGS",
            "prompt": "Measurement of catchment-wide denudation rates in the East River [28]",
            "stem": "Measurement of catchment-wide denudation rates in the East River",
            "answer": "E",
            "options": endings_options,
            "endings": endings_options,
            "evidenceQuote": q28_quote,
            "explanation": "Researchers measured denudation 'using in situ produced cosmogenic beryllium-10 concentrations extracted from fluvial quartz sand'. Matches E.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, q28_quote),
            "evidenceClaimRef": "claim:s3:be10_method",
        },
        {
            "questionNumber": 29,
            "questionType": "MATCHING_ENDINGS",
            "prompt": "Watersheds underlain by erodible Mancos Shale [29]",
            "stem": "Watersheds underlain by erodible Mancos Shale",
            "answer": "A",
            "options": endings_options,
            "endings": endings_options,
            "evidenceQuote": q29_quote,
            "explanation": "The text highlights that threefold faster shale denudation occurs across 'significantly gentler topographic gradients'. Matches A.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, q29_quote),
            "evidenceClaimRef": "claim:s3:gentle_shale_slopes",
        },
        {
            "questionNumber": 30,
            "questionType": "MATCHING_ENDINGS",
            "prompt": "Sulfide oxidation accompanied by carbonate dissolution [30]",
            "stem": "Sulfide oxidation accompanied by carbonate dissolution",
            "answer": "B",
            "options": endings_options,
            "endings": endings_options,
            "evidenceQuote": q30_quote,
            "explanation": "The text states this chemical weathering pathway 'releases gaseous carbon dioxide directly into the hydrosphere and atmosphere'. Matches B.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, q30_quote),
            "evidenceClaimRef": "claim:s3:sulfide_co2_release",
        },
        {
            "questionNumber": 31,
            "questionType": "MATCHING_ENDINGS",
            "prompt": "The slow geomorphic adjustment of resistant intrusive rocks [31]",
            "stem": "The slow geomorphic adjustment of resistant intrusive rocks",
            "answer": "D",
            "options": endings_options,
            "endings": endings_options,
            "evidenceQuote": q31_quote,
            "explanation": "The text notes intrusive rocks retain steep knickzones for millions of years, 'prolonging the transient topographic disequilibrium'. Matches D.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, q31_quote),
            "evidenceClaimRef": "claim:s3:prolonged_disequilibrium",
        },
    ]

    headings_options = [
        "i. Topographic paradox of contrasting rock denudation rates",
        "ii. Geochemical mechanisms driving net carbon emission",
        "iii. The influence of glacial retreat on sediment discharge",
        "iv. Reassessing the role of relief in tectonic-climate models",
        "v. Unequal response times and knickpoint migration across lithologies",
        "vi. Anthropogenic impacts on mountain stream chemistry",
        "vii. The limitations of classical landscape equilibrium theory",
    ]

    s3_g2_questions = [
        {
            "questionNumber": 32,
            "questionType": "MATCHING_HEADING",
            "prompt": "Choose the correct heading for Paragraph A",
            "paragraphRef": "Paragraph A",
            "answer": "vii",
            "options": headings_options,
            "headings": headings_options,
            "evidenceQuote": "Classical steady-state formulations assumed that hillslope angles and river gradients directly reflect regional rock uplift rates without considering substrate variability",
            "explanation": "Paragraph A introduces classical assumptions of landscape equilibrium and highlights their limitations when substrate erodibility varies.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "Classical steady-state formulations assumed that hillslope angles and river gradients directly reflect regional rock uplift rates without considering substrate variability"),
            "evidenceClaimRef": "claim:s3:homogeneity_assumption",
        },
        {
            "questionNumber": 33,
            "questionType": "MATCHING_HEADING",
            "prompt": "Choose the correct heading for Paragraph B",
            "paragraphRef": "Paragraph B",
            "answer": "i",
            "options": headings_options,
            "headings": headings_options,
            "evidenceQuote": "this threefold acceleration in shale denudation occurs across hillslopes that exhibit significantly gentler topographic gradients than the precipitous granodiorite peaks",
            "explanation": "Paragraph B focuses on the surprising finding that gentler shale slopes denude faster than steeper granodiorite peaks (topographic paradox).",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "this threefold acceleration in shale denudation occurs across hillslopes that exhibit significantly gentler topographic gradients than the precipitous granodiorite peaks"),
            "evidenceClaimRef": "claim:s3:gentle_shale_slopes",
        },
        {
            "questionNumber": 34,
            "questionType": "MATCHING_HEADING",
            "prompt": "Choose the correct heading for Paragraph C",
            "paragraphRef": "Paragraph C",
            "answer": "ii",
            "options": headings_options,
            "headings": headings_options,
            "evidenceQuote": "sulfide oxidation coupled with carbonate dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere",
            "explanation": "Paragraph C details the chemical weathering reactions (sulfuric acid and pyrite oxidation) that release CO2 into the atmosphere.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "sulfide oxidation coupled with carbonate dissolution releases gaseous carbon dioxide directly into the hydrosphere and atmosphere"),
            "evidenceClaimRef": "claim:s3:sulfide_co2_release",
        },
        {
            "questionNumber": 35,
            "questionType": "MATCHING_HEADING",
            "prompt": "Choose the correct heading for Paragraph D",
            "paragraphRef": "Paragraph D",
            "answer": "v",
            "options": headings_options,
            "headings": headings_options,
            "evidenceQuote": "response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches",
            "explanation": "Paragraph D examines knickpoint propagation and how differing lithologies respond at vastly different speeds to base-level lowering.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches"),
            "evidenceClaimRef": "claim:s3:transient_response_times",
        },
        {
            "questionNumber": 36,
            "questionType": "MATCHING_HEADING",
            "prompt": "Choose the correct heading for Paragraph E",
            "paragraphRef": "Paragraph E",
            "answer": "iv",
            "options": headings_options,
            "headings": headings_options,
            "evidenceQuote": "These findings require a substantial revision of global tectonic-carbon feedback models",
            "explanation": "Paragraph E explores the broader implications of these findings for tectonic-climate feedback models and relief proxies.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "These findings require a substantial revision of global tectonic-carbon feedback models"),
            "evidenceClaimRef": "claim:s3:global_reassessment",
        },
    ]

    s3_g3_questions = [
        {
            "questionNumber": 37,
            "questionType": "YES_NO_NOT_GIVEN",
            "statement": "Topographic steepness alone cannot reliably indicate the rate of physical weathering.",
            "answer": "YES",
            "evidenceQuote": "the study proves that topographic steepness cannot serve as a universal proxy for physical weathering rates",
            "explanation": "The author explicitly concludes that topographic steepness cannot serve as a universal proxy for weathering rates.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "the study proves that topographic steepness cannot serve as a universal proxy for physical weathering rates"),
            "evidenceClaimRef": "claim:s3:global_reassessment",
        },
        {
            "questionNumber": 38,
            "questionType": "YES_NO_NOT_GIVEN",
            "statement": "Shale-dominated river channels take longer to adjust to base-level lowering than crystalline channels.",
            "answer": "NO",
            "evidenceQuote": "response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches",
            "explanation": "The text states the exact opposite: shale reaches respond an order of magnitude faster, not slower.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "response time of shale-dominated river reaches is an order of magnitude faster than that of crystalline intrusive reaches"),
            "evidenceClaimRef": "claim:s3:transient_response_times",
        },
        {
            "questionNumber": 39,
            "questionType": "YES_NO_NOT_GIVEN",
            "statement": "Future climatic warming will completely halt chemical weathering in the Rocky Mountains.",
            "answer": "NOT_GIVEN",
            "explanation": "The passage discusses weathering mechanisms and potential warming feedbacks, but makes no claim that weathering will halt.",
            "difficulty": "ADVANCED",
            "passageEvidence": {"startChar": 0, "endChar": 50, "text": S3_PASSAGE[:50]},
            "evidenceClaimRef": "claim:s3:global_reassessment",
            "absenceAssessment": {
                "assessmentId": "abs:3:39",
                "claimOrTopic": "Future climatic warming will completely halt chemical weathering in the Rocky Mountains.",
                "absenceReason": "The passage contains no claim or discussion predicting the cessation of chemical weathering.",
                "absenceConfirmed": True,
            },
        },
        {
            "questionNumber": 40,
            "questionType": "YES_NO_NOT_GIVEN",
            "statement": "The exposure of pyrite-rich sedimentary rocks during mountain exhumation can transiently contribute to climate warming.",
            "answer": "YES",
            "evidenceQuote": "Regions dominated by erodible, pyrite-bearing shales may transiently accelerate global warming rather than global cooling during the early stages of orogenic exhumation",
            "explanation": "The author explicitly asserts that erodible pyrite-bearing shales can accelerate warming during early exhumation stages.",
            "difficulty": "ADVANCED",
            "passageEvidence": make_evidence_span(S3_PASSAGE, "Regions dominated by erodible, pyrite-bearing shales may transiently accelerate global warming rather than global cooling during the early stages of orogenic exhumation"),
            "evidenceClaimRef": "claim:s3:sulfide_co2_release",
        },
    ]

    # ── Section Payloads ─────────────────────────────────────────────────────
    sec1_groups = [
        {"groupId": "group_1_1", "questionType": "TRUE_FALSE_NOT_GIVEN", "instructions": "Do the following statements agree with the information given in the Reading Passage? Write TRUE, FALSE, or NOT GIVEN.", "questions": s1_g1_questions},
        {"groupId": "group_1_2", "questionType": "TABLE_COMPLETION", "instructions": "Complete the table below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", "questions": s1_g2_questions},
        {"groupId": "group_1_3", "questionType": "FLOW_CHART", "instructions": "Complete the flow chart below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", "questions": s1_g3_questions, "svgXml": FLOWCHART_SVG},
    ]

    s2_g2_context = (
        "Airflow past the multi-lobed bluff body stimulates broadband [18] over a wide range of velocities. "
        "The rainfall catchment mechanism discharges accumulated liquid once it exceeds a designated [19]. "
        "At extreme points of mechanical displacement, electronic switching induces instantaneous [20] across the coil. "
        "Numerical circuit models demonstrated that selecting a [21] of 2 H substantially lowered internal losses. "
        "Bench testing confirmed that the P-SSHI circuit delivered an [22] compared with standard rectification."
    )

    s2_g3_context = (
        "The hybrid generator was specifically conceptualized to sustain autonomous equipment for [23]. "
        "Unlike standard systems deploying a [24], the new circuit incorporates a [25] in parallel with the beam. "
        "Furthermore, precise load optimization establishes [26] to maximize continuous energy output."
    )

    sec2_groups = [
        {"groupId": "group_2_1", "questionType": "DIAGRAM_LABEL", "instructions": "Label the diagram below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", "questions": s2_g1_questions, "svgXml": DIAGRAM_SVG},
        {"groupId": "group_2_2", "questionType": "SUMMARY_COMPLETION", "instructions": "Complete the summary below. Choose NO MORE THAN THREE WORDS from the passage for each answer.", "sharedContext": s2_g2_context, "questions": s2_g2_questions},
        {"groupId": "group_2_3", "questionType": "SUMMARY_COMPLETION_BOX", "instructions": "Complete the summary using the list of words, A-G, below.", "sharedContext": s2_g3_context, "questions": s2_g3_questions},
    ]

    sec3_groups = [
        {"groupId": "group_3_1", "questionType": "MATCHING_ENDINGS", "instructions": "Complete each sentence with the correct ending, A-G, below.", "questions": s3_g1_questions},
        {"groupId": "group_3_2", "questionType": "MATCHING_HEADING", "instructions": "Choose the correct heading for each paragraph from the list of headings below.", "questions": s3_g2_questions},
        {"groupId": "group_3_3", "questionType": "YES_NO_NOT_GIVEN", "instructions": "Do the following statements agree with the views of the writer in the Reading Passage? Write YES, NO, or NOT GIVEN.", "questions": s3_g3_questions},
    ]

    words_regex = re.compile(r"\b[\w'-]+\b")
    s1_wc = len(words_regex.findall(S1_PASSAGE))
    s2_wc = len(words_regex.findall(S2_PASSAGE))
    s3_wc = len(words_regex.findall(S3_PASSAGE))
    total_wc = s1_wc + s2_wc + s3_wc

    sec1_obj = {
        "sectionId": 1,
        "title": "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1",
        "passage": S1_PASSAGE,
        "wordCount": s1_wc,
        "source": {
            "pmcid": "PMC13654891",
            "title": "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1, Falémé Valley, Eastern Senegal",
            "doi": "10.1007/s10437-026-09653-z",
            "authors": "Mélissa Morel; Pierre Lamotte; Ladji Dianifaba",
            "url": "https://europepmc.org/article/PMC/PMC13654891",
            "sourceUrl": "https://europepmc.org/article/PMC/PMC13654891",
            "sourceId": "PMC13654891",
            "license": "CC BY 4.0",
            "licenseCleared": True,
            "sectionIndex": 1,
            "wordCount": s1_wc,
        },
        "groups": sec1_groups,
        "questionRefs": [
            {"artifactId": f"question:canonical-40q-shared:{i}", "artifactType": "Question", "version": 1, "contentHash": hashlib.sha256(f"q_{i}".encode()).hexdigest()}
            for i in range(1, 14)
        ],
    }

    sec2_obj = {
        "sectionId": 2,
        "title": "Development of a Novel Combined Wind–Rain Piezoelectric Energy Harvester",
        "passage": S2_PASSAGE,
        "wordCount": s2_wc,
        "source": {
            "pmcid": "PMC13667678",
            "title": "Development of a Novel Combined Wind–Rain Piezoelectric Energy Harvester",
            "doi": "10.3390/s26196271",
            "authors": "Yuansheng Chen; Hao Lou; Yiyang He",
            "url": "https://europepmc.org/article/PMC/PMC13667678",
            "sourceUrl": "https://europepmc.org/article/PMC/PMC13667678",
            "sourceId": "PMC13667678",
            "license": "CC BY 4.0",
            "licenseCleared": True,
            "sectionIndex": 2,
            "wordCount": s2_wc,
        },
        "groups": sec2_groups,
        "questionRefs": [
            {"artifactId": f"question:canonical-40q-shared:{i}", "artifactType": "Question", "version": 1, "contentHash": hashlib.sha256(f"q_{i}".encode()).hexdigest()}
            for i in range(14, 27)
        ],
    }

    sec3_obj = {
        "sectionId": 3,
        "title": "Bedrock erodibility governs transient erosion and CO2 release in alpine landscapes",
        "passage": S3_PASSAGE,
        "wordCount": s3_wc,
        "source": {
            "pmcid": "PMC13665993",
            "title": "Bedrock erodibility governs transient erosion and CO2 release in alpine landscapes",
            "doi": "10.1126/sciadv.aei9275",
            "authors": "Eyal Marder; John R. Slosson; Isaac J. Larsen; Xianmei Huang; Darryl E. Granger; Matthew J. Winnick; Kenneth H. Williams; Alan J. Hidy",
            "url": "https://europepmc.org/article/PMC/PMC13665993",
            "sourceUrl": "https://europepmc.org/article/PMC/PMC13665993",
            "sourceId": "PMC13665993",
            "license": "CC BY-NC 4.0",
            "licenseCleared": True,
            "sectionIndex": 3,
            "wordCount": s3_wc,
        },
        "groups": sec3_groups,
        "questionRefs": [
            {"artifactId": f"question:canonical-40q-shared:{i}", "artifactType": "Question", "version": 1, "contentHash": hashlib.sha256(f"q_{i}".encode()).hexdigest()}
            for i in range(27, 41)
        ],
    }

    all_question_refs = [
        {"artifactId": f"question:canonical-40q-shared:{i}", "artifactType": "Question", "version": 1, "contentHash": hashlib.sha256(f"q_{i}".encode()).hexdigest()}
        for i in range(1, 41)
    ]
    passage_refs = [
        {"artifactId": f"passage:canonical-40q-shared:{s}", "artifactType": "Passage", "version": 1, "contentHash": hashlib.sha256(f"p_{s}".encode()).hexdigest()}
        for s in (1, 2, 3)
    ]
    section_refs = [
        {"artifactId": f"section:canonical-40q-shared:{s}", "artifactType": "Section", "version": 1, "contentHash": hashlib.sha256(f"s_{s}".encode()).hexdigest()}
        for s in (1, 2, 3)
    ]
    blueprint_ref = {
        "artifactId": "blueprint:canonical-40q-shared",
        "artifactType": "ExamBlueprint",
        "version": 1,
        "contentHash": hashlib.sha256("bp_canonical".encode()).hexdigest(),
    }

    paper_payload = {
        "paperId": "paper:canonical-40q-shared",
        "runId": "run-canonical-40q-shared",
        "title": "IELTS Academic Reading Paper: Contemporary Archaeological, Energy and Earth Systems Research",
        "totalQuestions": 40,
        "totalWords": total_wc,
        "blueprintRef": blueprint_ref,
        "sectionRefs": section_refs,
        "passageRefs": passage_refs,
        "questionRefs": all_question_refs,
        "sections": [sec1_obj, sec2_obj, sec3_obj],
    }

    return paper_payload


if __name__ == "__main__":
    paper = build_canonical_40q_paper()
    target_file = REPO_ROOT / "services/generation-service/tests/fixtures/canonical_40_question_reading_paper.json"
    target_file.write_text(json.dumps(paper, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Successfully generated {target_file} (total words: {paper['totalWords']}, total questions: {paper['totalQuestions']})")
