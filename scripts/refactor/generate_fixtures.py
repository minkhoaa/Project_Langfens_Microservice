#!/usr/bin/env python3
"""Generate complete, deterministic regression fixtures for Phase 00 (Loop Engine V2)."""
import hashlib
import json
import os
import re
from pathlib import Path

FIXTURES_DIR = Path("artifacts/refactor/phase-00/fixtures")
FIXTURES_DIR.mkdir(parents=True, exist_ok=True)

WORD = re.compile(r"\b[\w'-]+\b")

def word_count(text: str) -> int:
    return len(WORD.findall(text))

def pad_words(base_text: str, target: int, filler_sentence: str) -> str:
    current = word_count(base_text)
    paragraphs = [base_text.strip()]
    while current < target:
        paragraphs.append(filler_sentence.strip())
        current = word_count("\n\n".join(paragraphs))
    return "\n\n".join(paragraphs)

# ── 1. Eligible Sources (>= 6 covering 3 profiles, > 600 words, CC BY / CC0) ──
def build_eligible_sources():
    sources = [
        {
            "id": "PMC8910001",
            "pmcid": "PMC8910001",
            "title": "Trophic Interactions and Benthic Resilience in Tropical Coral Reefs",
            "authors": "Dr. Helena Rostova, Dr. Marcus Thorne",
            "doi": "10.1016/j.ecol.2023.1001",
            "url": "https://europepmc.org/articles/PMC8910001",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 1,
            "topic": "marine biology",
            "content": pad_words(
                "Tropical coral reefs represent vital marine ecosystems that harbor extensive taxonomic diversity. "
                "Herbivorous fish species graze aggressively on macroalgae, thereby maintaining open substrate for scleractinian coral recruits. "
                "Over a four-year observational study across thirty oceanic sites, researchers monitored seasonal recruitment rates and algal turf canopy heights. "
                "The findings revealed that localized herbivore biomass was strongly associated with juvenile coral colony density. "
                "When grazing pressure remained elevated, coral spat established robust calcified bases prior to seasonal thermal stress events.",
                680,
                "Regular benthic photography and diver surveys provided consistent longitudinal measurements across all designated ocean stations."
            )
        },
        {
            "id": "PMC8910002",
            "pmcid": "PMC8910002",
            "title": "Early Hydraulic Engineering in Mesopotamian Irrigation Networks",
            "authors": "Prof. Arthur Pendelton",
            "doi": "10.1016/j.arch.2023.1002",
            "url": "https://europepmc.org/articles/PMC8910002",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 1,
            "topic": "ancient technology",
            "content": pad_words(
                "Archaeological excavations in southern Mesopotamia have unearthed extensive canal systems dating back to the third millennium BCE. "
                "Early agrarian communities constructed clay diversion weirs and reinforced sluice gates to manage turbulent seasonal floods from the Tigris and Euphrates. "
                "Sediment accumulation posed an enduring challenge, requiring systematic dredging regimes by coordinated municipal workforces. "
                "Grain yields corresponded closely with the reliability of gravity-fed arterial channels.",
                670,
                "Excavated cuneiform tablets detail administrative work quotas assigned to canal maintenance during low-water autumn months."
            )
        },
        {
            "id": "PMC8910003",
            "pmcid": "PMC8910003",
            "title": "Pyrometallurgical and Hydrometallurgical Pathways for Lithium-Ion Battery Recycling",
            "authors": "Klara Lindqvist, Sven Vanhove",
            "doi": "10.1016/j.clean.2023.1003",
            "url": "https://europepmc.org/articles/PMC8910003",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 2,
            "topic": "materials recycling",
            "content": pad_words(
                "The rapid expansion of electric vehicle adoption necessitates closed-loop recovery processes for cathode active materials. "
                "Pyrometallurgical smelting processes operate at high temperatures to recover nickel and cobalt alloys while slagging lithium into aluminosilicate matrices. "
                "Conversely, hydrometallurgical leaching utilizing mild organic acids demonstrates high selectivity and exceeds ninety-eight percent recovery for lithium carbonate. "
                "Energy balance assessments indicate that hydrometallurgical routes significantly lower cumulative carbon footprints compared to primary mining.",
                700,
                "Analytical titration and mass spectrometry verify elemental purity throughout multi-stage solvent extraction circuits."
            )
        },
        {
            "id": "PMC8910004",
            "pmcid": "PMC8910004",
            "title": "Subglacial Hydrology and Basal Sliding Velocities in Greenland Ice Streams",
            "authors": "Ingrid Haakon, Dr. Peter MacIntyre",
            "doi": "10.1016/j.glacio.2023.1004",
            "url": "https://europepmc.org/articles/PMC8910004",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 2,
            "topic": "glaciology",
            "content": pad_words(
                "Meltwater lubrication at the bed of outlet glaciers controls seasonal velocity variations across the Greenland ice sheet. "
                "Supraglacial lakes drain rapidly via hydrofracturing moulins, delivering pulsed volumes of surface runoff directly to the subglacial environment. "
                "Early in the summer melt season, inefficient distributed drainage cavities become pressurized, accelerating basal sliding. "
                "As channels mature into efficient conduits, subglacial water pressure decreases, resulting in observed mid-summer deceleration of ice flow.",
                690,
                "Continuous GPS receivers and borehole pressure sensors recorded diurnal discharge and ice displacement dynamics."
            )
        },
        {
            "id": "PMC8910005",
            "pmcid": "PMC8910005",
            "title": "Cross-Linguistic Perspectives on Spatial Metaphors for Temporal Sequencing",
            "authors": "Dr. Miriam Al-Hashimi, Jean-Paul Dubois",
            "doi": "10.1016/j.cogling.2023.1005",
            "url": "https://europepmc.org/articles/PMC8910005",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 3,
            "topic": "cognitive linguistics",
            "content": pad_words(
                "Cognitive linguistic frameworks have long debated whether spatial conceptualizations of time are universal or culture-specific. "
                "While English speakers predominantly map the future forward and the past backward along a sagittal axis, speakers of Aymara demonstrate the reverse orientation, "
                "treating the known past as visible before them and the unknown future behind. "
                "Furthermore, Mandarin speakers frequently deploy vertical spatial metaphors, associating earlier events with upper planes. "
                "Experimental eye-tracking and gesture elicitation tasks reveal that spatial representations actively modulate reaction times during temporal reasoning tasks.",
                720,
                "Empirical reaction time datasets corroborate the hypothesis that linguistic framing subtly shapes non-linguistic mental timelines."
            )
        },
        {
            "id": "PMC8910006",
            "pmcid": "PMC8910006",
            "title": "Cognitive Heuristics and Probability Distortions Under Systemic Financial Stress",
            "authors": "Prof. David Klein, Dr. Beatrice Rossi",
            "doi": "10.1016/j.econpsych.2023.1006",
            "url": "https://europepmc.org/articles/PMC8910006",
            "license": "https://creativecommons.org/licenses/by/4.0/",
            "sectionProfile": 3,
            "topic": "behavioral economics",
            "content": pad_words(
                "Prospect theory posits that economic agents evaluate potential gains and losses through non-linear probability weighting functions. "
                "Under acute volatility, market participants disproportionately overweight low-probability catastrophic scenarios, leading to sudden liquidity contractions. "
                "Experimental lottery choices administered during market downturns demonstrated significant shifts in risk aversion parameters compared to baseline calm conditions. "
                "Neurological fMRI imaging highlighted heightened activation in the anterior insula, consistent with visceral fear conditioning rather than rational Bayesian updating.",
                730,
                "Controlled laboratory trading environments simulated endogenous shock propagation across interconnected participant networks."
            )
        }
    ]
    for s in sources:
        s["wordCount"] = word_count(s["content"])
    return sources

# ── 2. Ineligible Sources (Boundary rejects, license, SSRF, oversized) ────────
def build_ineligible_sources():
    valid_source = build_eligible_sources()[0]["content"]
    words_list = WORD.findall(valid_source)
    short_599 = " ".join(words_list[:599])

    return [
        {
            "id": "INEL_01_SHORT_599",
            "reason": "Source has exactly 599 words (minimum required is 600 words)",
            "expectedStatus": 422,
            "wordCount": 599,
            "payload": short_599,
            "type": "text",
            "license": "https://creativecommons.org/licenses/by/4.0/"
        },
        {
            "id": "INEL_02_PROPRIETARY_LICENSE",
            "reason": "Source has non-open license (All Rights Reserved)",
            "expectedStatus": 422,
            "wordCount": 650,
            "payload": "All content copyright Protected Media Corp. " + pad_words("Scientists studied forests.", 650, "Data collection occurred annually."),
            "type": "text",
            "license": "All Rights Reserved"
        },
        {
            "id": "INEL_03_SSRF_PRIVATE_IP",
            "reason": "Target URL points to RFC 1918 private network address (10.0.0.1)",
            "expectedStatus": 422,
            "payload": "http://10.0.0.1:8080/internal/article.html",
            "type": "url"
        },
        {
            "id": "INEL_04_SSRF_LOOPBACK_IP",
            "reason": "Target URL points to IPv4 loopback (127.0.0.1)",
            "expectedStatus": 422,
            "payload": "http://127.0.0.1:5000/internal-secret",
            "type": "url"
        },
        {
            "id": "INEL_05_OVERSIZED_CONTENT",
            "reason": "Sanitized content exceeds 100,000 characters limit",
            "expectedStatus": 422,
            "payload": "A" * 105_000,
            "type": "text"
        },
        {
            "id": "INEL_06_EMPTY_PAYLOAD",
            "reason": "Payload is empty or whitespace only",
            "expectedStatus": 422,
            "payload": "   \n\t   ",
            "type": "text"
        }
    ]

# ── 3. Fidelity Pairs (Valid and Invalid Pairs for 5 Issue Families) ──────────
def build_fidelity_pairs():
    return [
        {
            "id": "FID_01_CONTRADICTED",
            "issueType": "contradicted_claim",
            "valid": False,
            "sourceText": "Coral cover declined by 17% across surveyed locations over the six-year observation window.",
            "generatedText": "Coral cover expanded by 17% across all surveyed locations during the six-year study.",
            "reason": "Reverses the direction of measured change from decline to expansion."
        },
        {
            "id": "FID_02_UNSUPPORTED",
            "issueType": "unsupported_claim",
            "valid": False,
            "sourceText": "Autonomous acoustic sensors monitored avian biodiversity in temperate rainforests across 45 field stations.",
            "generatedText": "Autonomous acoustic sensors tracked humpback whale vocalizations in the North Atlantic.",
            "reason": "Introduces whale tracking and oceanic setting completely absent from the source."
        },
        {
            "id": "FID_03_CAUSAL_OVERSTATEMENT",
            "issueType": "causal_overstatement",
            "valid": False,
            "sourceText": "Herbivore abundance was positively correlated with juvenile coral spat density (r = 0.68, p < 0.01).",
            "generatedText": "High herbivore density directly caused juvenile coral spat numbers to triple within days.",
            "reason": "Transforms an empirical correlation into an unproven direct causal claim with exaggerated speed."
        },
        {
            "id": "FID_04_OVERSTATED_CERTAINTY",
            "issueType": "overstated_certainty",
            "valid": False,
            "sourceText": "Preliminary flume models suggest that rugose colony morphologies may alter localized fluid dynamics.",
            "generatedText": "Rugose colony morphologies undeniably and completely eliminate all turbulence in marine currents.",
            "reason": "Eliminates scientific uncertainty and asserts absolute elimination of turbulence."
        },
        {
            "id": "FID_05_UNMEASURED_OUTCOME",
            "issueType": "unmeasured_outcome",
            "valid": False,
            "sourceText": "The authors measured photosynthetic efficiency and skeletal calcification rates in Acropora millepora.",
            "generatedText": "The study conclusively demonstrated a 40% rise in tourism revenue for coastal dive resorts.",
            "reason": "Asserts economic tourism findings that were never measured by the biological study."
        },
        {
            "id": "FID_06_POPULATION_MISMATCH",
            "issueType": "population_or_method_mismatch",
            "valid": False,
            "sourceText": "The experiment tested juvenile Acropora millepora recruits in controlled closed-circuit laboratory flumes.",
            "generatedText": "Field trials across adult Porites colonies in open pelagic zones confirmed the hypothesis.",
            "reason": "Substitutes laboratory juvenile Acropora with wild adult Porites."
        },
        {
            "id": "FID_07_VALID_PARAPHRASE_1",
            "issueType": "none",
            "valid": True,
            "sourceText": "Coral reefs support approximately twenty-five percent of all marine organisms despite occupying less than one percent of the ocean floor.",
            "generatedText": "Although covering under one percent of benthic marine territory, coral reefs provide habitat for nearly a quarter of all sea creatures.",
            "reason": "Faithful academic paraphrase preserving proportions and scope."
        },
        {
            "id": "FID_08_VALID_PARAPHRASE_2",
            "issueType": "none",
            "valid": True,
            "sourceText": "Sediment accumulation posed an enduring challenge, requiring systematic dredging regimes by coordinated municipal workforces.",
            "generatedText": "Managing silt buildup remained a persistent operational hurdle that demanded regular clearing by organized civic labor teams.",
            "reason": "Faithful academic paraphrase preserving meaning and nuance."
        },
        {
            "id": "FID_09_VALID_PARAPHRASE_3",
            "issueType": "none",
            "valid": True,
            "sourceText": "Subglacial water pressure decreases as channels mature into efficient conduits, resulting in observed mid-summer deceleration of ice flow.",
            "generatedText": "When meltwater channels evolve into effective drainage tunnels, subglacial pressures decline and ice movement decelerates later in summer.",
            "reason": "Accurate physical explanation maintaining causal sequence."
        },
        {
            "id": "FID_10_VALID_PARAPHRASE_4",
            "issueType": "none",
            "valid": True,
            "sourceText": "Under acute volatility, market participants disproportionately overweight low-probability catastrophic scenarios.",
            "generatedText": "During periods of intense market fluctuations, traders tend to assign excessive importance to unlikely disastrous events.",
            "reason": "Accurate behavioral economics terminology preservation."
        }
    ]

# ── 4. Questions Corpus (6 Question Types x >= 5 Valid & >= 5 Invalid) ────────
def build_questions_corpus():
    passage = (
        "In recent decades, marine ecologists have documented widespread changes across coral reef systems. "
        "Scientists found species in the forest and measured changes over time. "
        "Coral reefs support approximately twenty-five percent of all marine organisms despite occupying less than one percent of the ocean floor. "
        "Researchers observed seasonal migration patterns through coastal woodlands and nearby wetlands. "
        "Ocean temperatures have risen steadily across tropical latitudes, resulting in recurrent thermal stress events and mass bleaching. "
        "Herbivorous grazing pressure plays a pivotal ecological role in maintaining coral dominance over macroalgae. "
        "When herbivore populations decline, fast-growing macroalgae can rapidly outcompete juvenile corals for benthic space and solar irradiance. "
        "Systematic surveys across sixty permanent monitoring stations revealed significant spatial variation in coral recruit survivorship following disturbance events. "
        "Coral cover declined by seventeen percent across surveyed locations over the six-year observation window, while turf algae abundance showed a corresponding fifteen percent increase. "
        "Field measurements demonstrated that structural complexity buffered localized temperature anomalies by up to 0.8 degrees Celsius within shaded microhabitats. "
        "Controlled laboratory flume experiments further confirmed that rugose colony morphologies alter boundary layer fluid dynamics, enhancing nutrient uptake under low ambient flow conditions. "
        "Marine protected zones with strictly enforced non-extraction mandates retained significantly higher apex predator biomass and structural rugosity than surrounding fished areas."
    )

    corpus = {
        "passage": passage,
        "types": {
            "TRUE_FALSE_NOT_GIVEN": {
                "valid": [
                    {
                        "number": 1,
                        "prompt": "Coral reefs occupy less than one percent of the ocean floor.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "occupying less than one percent of the ocean floor.",
                        "explanation": "The passage confirms that coral reefs occupy less than one percent of the ocean floor."
                    },
                    {
                        "number": 2,
                        "prompt": "Coral cover increased by seventeen percent during the study.",
                        "answer": "FALSE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "Coral cover declined by seventeen percent across surveyed locations",
                        "explanation": "The text states that coral cover declined by seventeen percent, contradicting this statement."
                    },
                    {
                        "number": 3,
                        "prompt": "Macroalgae growth is stimulated by moon phases.",
                        "answer": "NOT GIVEN",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "fast-growing macroalgae can rapidly outcompete juvenile corals for benthic space",
                        "explanation": "The passage discusses macroalgae competing for space, but says nothing about moon phases."
                    },
                    {
                        "number": 4,
                        "prompt": "Herbivore decline allows macroalgae to outcompete young corals.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "When herbivore populations decline, fast-growing macroalgae can rapidly outcompete juvenile corals",
                        "explanation": "The text directly confirms that reduced herbivore numbers allow macroalgae to outcompete juvenile corals."
                    },
                    {
                        "number": 5,
                        "prompt": "Turf algae abundance decreased by fifteen percent.",
                        "answer": "FALSE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "while turf algae abundance showed a corresponding fifteen percent increase.",
                        "explanation": "The text notes a fifteen percent increase in turf algae, which contradicts the prompt."
                    }
                ],
                "invalid": [
                    {
                        "number": 1,
                        "prompt": "Coral reefs occupy less than one percent of the ocean floor.",
                        "answer": "TRUE",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "occupying less than one percent of the ocean floor.",
                        "explanation": "Invalid options set: uses YES/NO instead of TRUE/FALSE.",
                        "rejectReason": "invalid_options_set"
                    },
                    {
                        "number": 2,
                        "prompt": "Coral cover declined significantly over the survey window.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "Artificial sensors in Arctic waters detected melting ice.",
                        "explanation": "Evidence quote is absent from the passage.",
                        "rejectReason": "evidence_absent_from_passage"
                    },
                    {
                        "number": 3,
                        "prompt": "Herbivores prevent macroalgae dominance.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "Herbivorous grazing pressure plays a pivotal ecological role",
                        "explanation": "Short",
                        "rejectReason": "explanation_too_short"
                    },
                    {
                        "number": 4,
                        "prompt": "Marine protected zones retained apex predator biomass.",
                        "answer": "SUPPORTED",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "retained significantly higher apex predator biomass",
                        "explanation": "Answer SUPPORTED is not one of the allowed options.",
                        "rejectReason": "answer_not_in_options"
                    },
                    {
                        "number": 5,
                        "prompt": "Survey stations recorded temperature anomalies.",
                        "answer": "TRUE",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "Field data",
                        "explanation": "Evidence quote is under fifteen characters in length.",
                        "rejectReason": "evidence_too_short"
                    }
                ]
            },
            "SENTENCE_COMPLETION": {
                "valid": [
                    {
                        "number": 8,
                        "prompt": "Structural complexity buffered localized temperature anomalies by up to [8] within shaded areas.",
                        "answer": "0.8 degrees Celsius",
                        "options": [],
                        "evidenceQuote": "temperature anomalies by up to 0.8 degrees Celsius within shaded microhabitats.",
                        "explanation": "The passage states that structural complexity buffered anomalies by up to 0.8 degrees Celsius."
                    },
                    {
                        "number": 9,
                        "prompt": "Scientists found [9] in the forest during ecological monitoring.",
                        "answer": "species",
                        "options": [],
                        "evidenceQuote": "Scientists found species in the forest and measured changes over time.",
                        "explanation": "The text states that scientists found species in the forest."
                    },
                    {
                        "number": 10,
                        "prompt": "Herbivorous [10] plays a pivotal role in preventing macroalgal takeover.",
                        "answer": "grazing pressure",
                        "options": [],
                        "evidenceQuote": "Herbivorous grazing pressure plays a pivotal ecological role in maintaining coral dominance",
                        "explanation": "The text directly names herbivorous grazing pressure."
                    },
                    {
                        "number": 11,
                        "prompt": "The study observed changes over a [11] window.",
                        "answer": "six-year",
                        "options": [],
                        "evidenceQuote": "across surveyed locations over the six-year observation window",
                        "explanation": "The observation window is specified as six-year."
                    },
                    {
                        "number": 12,
                        "prompt": "Surveys were conducted across sixty permanent [12] following disturbances.",
                        "answer": "monitoring stations",
                        "options": [],
                        "evidenceQuote": "Systematic surveys across sixty permanent monitoring stations revealed",
                        "explanation": "The passage confirms surveys across sixty permanent monitoring stations."
                    }
                ],
                "invalid": [
                    {
                        "number": 8,
                        "prompt": "Structural complexity buffered temperature anomalies in shaded areas.",
                        "answer": "0.8 degrees Celsius",
                        "options": [],
                        "evidenceQuote": "temperature anomalies by up to 0.8 degrees Celsius within shaded microhabitats.",
                        "explanation": "Missing [8] blank marker in prompt string.",
                        "rejectReason": "missing_blank_marker"
                    },
                    {
                        "number": 9,
                        "prompt": "Scientists found [9] in the forest during ecological monitoring.",
                        "answer": "unexpected unknown rare species",
                        "options": [],
                        "evidenceQuote": "Scientists found species in the forest and measured changes over time.",
                        "explanation": "Answer exceeds the maximum three words limit.",
                        "rejectReason": "answer_exceeds_three_words"
                    },
                    {
                        "number": 10,
                        "prompt": "Herbivorous grazing pressure [10] plays a pivotal role.",
                        "answer": "grazing pressure",
                        "options": [],
                        "evidenceQuote": "Herbivorous grazing pressure plays a pivotal ecological role",
                        "explanation": "Answer 'grazing pressure' is leaked in the prompt.",
                        "rejectReason": "answer_leakage"
                    },
                    {
                        "number": 11,
                        "prompt": "The study observed changes over a [11] window.",
                        "answer": "ten-year",
                        "options": [],
                        "evidenceQuote": "across surveyed locations over the six-year observation window",
                        "explanation": "Answer 'ten-year' does not occur anywhere in the passage.",
                        "rejectReason": "answer_absent_from_passage"
                    },
                    {
                        "number": 12,
                        "prompt": "Surveys were conducted across sixty [12] stations [12] in the sea.",
                        "answer": "monitoring",
                        "options": [],
                        "evidenceQuote": "surveys across sixty permanent monitoring stations revealed",
                        "explanation": "Contains two [12] blank markers instead of exactly one.",
                        "rejectReason": "multiple_blank_markers"
                    }
                ]
            },
            "MULTIPLE_CHOICE_SINGLE": {
                "valid": [
                    {
                        "number": 14,
                        "prompt": "What percentage of marine life is supported by coral reef ecosystems?",
                        "answer": "B. approximately twenty-five percent",
                        "options": [
                            "A. less than one percent",
                            "B. approximately twenty-five percent",
                            "C. sixty percent",
                            "D. eighty-five percent"
                        ],
                        "evidenceQuote": "Coral reefs support approximately twenty-five percent of all marine organisms",
                        "explanation": "The passage confirms that coral reefs support approximately twenty-five percent of marine life."
                    },
                    {
                        "number": 15,
                        "prompt": "What consequence of rising ocean temperatures is noted in the text?",
                        "answer": "A. mass bleaching",
                        "options": [
                            "A. mass bleaching",
                            "B. river flooding",
                            "C. increased snowfall",
                            "D. volcanic eruptions"
                        ],
                        "evidenceQuote": "resulting in recurrent thermal stress events and mass bleaching.",
                        "explanation": "The text directly states that rising temperatures cause mass bleaching."
                    },
                    {
                        "number": 16,
                        "prompt": "How much did turf algae abundance increase over the observation window?",
                        "answer": "C. fifteen percent",
                        "options": [
                            "A. eight percent",
                            "B. twelve percent",
                            "C. fifteen percent",
                            "D. seventeen percent"
                        ],
                        "evidenceQuote": "turf algae abundance showed a corresponding fifteen percent increase.",
                        "explanation": "The text explicitly states that turf algae abundance showed a fifteen percent increase."
                    },
                    {
                        "number": 17,
                        "prompt": "What buffered localized temperature anomalies by up to 0.8 degrees Celsius?",
                        "answer": "D. structural complexity",
                        "options": [
                            "A. deep trenches",
                            "B. strong currents",
                            "C. seasonal storms",
                            "D. structural complexity"
                        ],
                        "evidenceQuote": "structural complexity buffered localized temperature anomalies by up to 0.8 degrees Celsius",
                        "explanation": "The passage attributes the buffering effect directly to structural complexity."
                    },
                    {
                        "number": 18,
                        "prompt": "Which zones retained significantly higher apex predator biomass?",
                        "answer": "B. Marine protected zones",
                        "options": [
                            "A. Commercial fishing ports",
                            "B. Marine protected zones",
                            "C. Shallow coastal lagoons",
                            "D. Estuarine mangroves"
                        ],
                        "evidenceQuote": "Marine protected zones with strictly enforced non-extraction mandates retained significantly higher apex predator biomass",
                        "explanation": "The text confirms that strictly protected marine zones retained higher predator biomass."
                    }
                ],
                "invalid": [
                    {
                        "number": 14,
                        "prompt": "What percentage of marine life is supported by coral reef ecosystems?",
                        "answer": "B. approximately twenty-five percent",
                        "options": [
                            "A. less than one percent",
                            "B. approximately twenty-five percent",
                            "C. sixty percent"
                        ],
                        "evidenceQuote": "Coral reefs support approximately twenty-five percent of all marine organisms",
                        "explanation": "Multiple choice must have exactly 4 options; has 3.",
                        "rejectReason": "invalid_option_count"
                    },
                    {
                        "number": 15,
                        "prompt": "What consequence of rising ocean temperatures is noted in the text?",
                        "answer": "mass bleaching",
                        "options": [
                            "1. mass bleaching",
                            "2. river flooding",
                            "3. increased snowfall",
                            "4. volcanic eruptions"
                        ],
                        "evidenceQuote": "resulting in recurrent thermal stress events and mass bleaching.",
                        "explanation": "Options must be prefixed with A., B., C., D.",
                        "rejectReason": "missing_letter_prefix"
                    },
                    {
                        "number": 16,
                        "prompt": "How much did turf algae abundance increase over the observation window?",
                        "answer": "E. twenty percent",
                        "options": [
                            "A. eight percent",
                            "B. twelve percent",
                            "C. fifteen percent",
                            "D. seventeen percent"
                        ],
                        "evidenceQuote": "turf algae abundance showed a corresponding fifteen percent increase.",
                        "explanation": "Answer is not present in the options list.",
                        "rejectReason": "answer_not_in_options"
                    },
                    {
                        "number": 17,
                        "prompt": "What buffered localized temperature anomalies by up to 0.8 degrees Celsius?",
                        "answer": "A. structural complexity",
                        "options": [
                            "A. structural complexity",
                            "B. shallow depths",
                            "X. seasonal storms",
                            "D. deep trenches"
                        ],
                        "evidenceQuote": "structural complexity buffered localized temperature anomalies",
                        "explanation": "Option X has invalid letter prefix (expected C.).",
                        "rejectReason": "invalid_option_prefix_letter"
                    },
                    {
                        "number": 18,
                        "prompt": "Which zones retained significantly higher apex predator biomass?",
                        "answer": "B. Marine protected zones",
                        "options": "A. Marine protected zones, B. Other zones",
                        "evidenceQuote": "Marine protected zones with strictly enforced non-extraction mandates",
                        "explanation": "Options is a string rather than a list of options.",
                        "rejectReason": "options_not_a_list"
                    }
                ]
            },
            "SUMMARY_COMPLETION": {
                "valid": [
                    {
                        "number": 20,
                        "prompt": "Reef systems provide critical habitats for many organisms despite occupying under [20] of ocean floors.",
                        "answer": "one percent",
                        "options": [],
                        "evidenceQuote": "despite occupying less than one percent of the ocean floor.",
                        "explanation": "The summary notes that reefs occupy less than one percent of ocean floors."
                    },
                    {
                        "number": 21,
                        "prompt": "Elevated ocean temperatures frequently trigger mass [21] events across tropical latitudes.",
                        "answer": "bleaching",
                        "options": [],
                        "evidenceQuote": "resulting in recurrent thermal stress events and mass bleaching.",
                        "explanation": "The text confirms that thermal stress causes mass bleaching."
                    },
                    {
                        "number": 22,
                        "prompt": "In the absence of herbivores, fast-growing [22] can dominate benthic surfaces.",
                        "answer": "macroalgae",
                        "options": [],
                        "evidenceQuote": "fast-growing macroalgae can rapidly outcompete juvenile corals for benthic space",
                        "explanation": "The passage confirms macroalgae outcompetes corals for benthic space."
                    },
                    {
                        "number": 23,
                        "prompt": "Researchers surveyed sixty permanent [23] to evaluate coral recruit survival.",
                        "answer": "monitoring stations",
                        "options": [],
                        "evidenceQuote": "surveys across sixty permanent monitoring stations revealed significant spatial variation",
                        "explanation": "Surveys were conducted across sixty monitoring stations."
                    },
                    {
                        "number": 24,
                        "prompt": "Over six years, surveyed locations experienced a seventeen percent decline in [24] across sites.",
                        "answer": "coral cover",
                        "options": [],
                        "evidenceQuote": "Coral cover declined by seventeen percent across surveyed locations",
                        "explanation": "The text confirms that coral cover declined by seventeen percent."
                    }
                ],
                "invalid": [
                    {
                        "number": 20,
                        "prompt": "Reef systems provide critical habitats despite occupying under ocean floors.",
                        "answer": "one percent",
                        "options": [],
                        "evidenceQuote": "despite occupying less than one percent of the ocean floor.",
                        "explanation": "Missing [20] placeholder.",
                        "rejectReason": "missing_blank_marker"
                    },
                    {
                        "number": 21,
                        "prompt": "Elevated temperatures trigger mass bleaching [21] events across tropical latitudes.",
                        "answer": "bleaching",
                        "options": [],
                        "evidenceQuote": "resulting in recurrent thermal stress events and mass bleaching.",
                        "explanation": "Answer 'bleaching' leaked in summary prompt.",
                        "rejectReason": "answer_leakage"
                    },
                    {
                        "number": 22,
                        "prompt": "Fast-growing macroalgae [22] outcompete corals.",
                        "answer": "unidentified sea plants and ferns",
                        "options": [],
                        "evidenceQuote": "fast-growing macroalgae can rapidly outcompete juvenile corals",
                        "explanation": "Answer exceeds three words limit.",
                        "rejectReason": "answer_exceeds_three_words"
                    },
                    {
                        "number": 23,
                        "prompt": "Researchers surveyed sixty permanent [23] to evaluate survival.",
                        "answer": "observatories",
                        "options": [],
                        "evidenceQuote": "surveys across sixty permanent monitoring stations revealed",
                        "explanation": "Answer 'observatories' does not appear in passage.",
                        "rejectReason": "answer_absent_from_passage"
                    },
                    {
                        "number": 24,
                        "prompt": "Over six years, surveyed locations experienced a decline in [24].",
                        "answer": "coral cover",
                        "options": [],
                        "evidenceQuote": "Unrelated text not found.",
                        "explanation": "Evidence quote does not exist in passage.",
                        "rejectReason": "evidence_absent_from_passage"
                    }
                ]
            },
            "YES_NO_NOT_GIVEN": {
                "valid": [
                    {
                        "number": 27,
                        "prompt": "The author suggests that grazing pressure is essential for coral dominance.",
                        "answer": "YES",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "Herbivorous grazing pressure plays a pivotal ecological role in maintaining coral dominance over macroalgae.",
                        "explanation": "The text directly states grazing pressure plays a pivotal ecological role."
                    },
                    {
                        "number": 28,
                        "prompt": "The writer argues that macroalgae should be artificially cultivated on reef flats.",
                        "answer": "NO",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "When herbivore populations decline, fast-growing macroalgae can rapidly outcompete juvenile corals",
                        "explanation": "The text frames macroalgal proliferation as harmful to coral recruits."
                    },
                    {
                        "number": 29,
                        "prompt": "The author advocates subsidizing commercial fishing vessels in protected zones.",
                        "answer": "NOT GIVEN",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "Marine protected zones with strictly enforced non-extraction mandates retained significantly higher apex predator biomass",
                        "explanation": "The author discusses non-extraction mandates but expresses no view on subsidies."
                    },
                    {
                        "number": 30,
                        "prompt": "The author believes that structural complexity can mitigate microhabitat temperatures.",
                        "answer": "YES",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "structural complexity buffered localized temperature anomalies by up to 0.8 degrees Celsius",
                        "explanation": "The author notes that complexity buffered temperature anomalies."
                    },
                    {
                        "number": 31,
                        "prompt": "The author claims that warmer oceans prevent turf algae from expanding.",
                        "answer": "NO",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "while turf algae abundance showed a corresponding fifteen percent increase.",
                        "explanation": "The author reports a 15% increase in turf algae, contradicting this claim."
                    }
                ],
                "invalid": [
                    {
                        "number": 27,
                        "prompt": "The author suggests that grazing pressure is essential.",
                        "answer": "TRUE",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "Herbivorous grazing pressure plays a pivotal ecological role",
                        "explanation": "Answer TRUE is invalid for YES/NO/NOT GIVEN.",
                        "rejectReason": "invalid_answer_for_type"
                    },
                    {
                        "number": 28,
                        "prompt": "The writer argues that macroalgae should be cultivated.",
                        "answer": "NO",
                        "options": ["TRUE", "FALSE", "NOT GIVEN"],
                        "evidenceQuote": "When herbivore populations decline",
                        "explanation": "Options use TRUE/FALSE instead of YES/NO.",
                        "rejectReason": "invalid_options_set"
                    },
                    {
                        "number": 29,
                        "prompt": "The author advocates subsidizing fishing vessels.",
                        "answer": "NOT GIVEN",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "retained higher apex predator biomass",
                        "explanation": "Too short",
                        "rejectReason": "explanation_too_short"
                    },
                    {
                        "number": 30,
                        "prompt": "The author believes that structural complexity buffers temperatures.",
                        "answer": "MAYBE",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "structural complexity buffered localized temperature anomalies",
                        "explanation": "Answer MAYBE is not one of the allowed options.",
                        "rejectReason": "answer_not_in_options"
                    },
                    {
                        "number": 31,
                        "prompt": "The author claims that warmer oceans prevent turf algae from expanding.",
                        "answer": "NO",
                        "options": ["YES", "NO", "NOT GIVEN"],
                        "evidenceQuote": "turf algae abundance increased significantly across tropical Pacific islands.",
                        "explanation": "Evidence quote does not appear in passage.",
                        "rejectReason": "evidence_absent_from_passage"
                    }
                ]
            },
            "SHORT_ANSWER": {
                "valid": [
                    {
                        "number": 34,
                        "prompt": "What do herbivorous fish control to maintain coral dominance?",
                        "answer": "macroalgae",
                        "options": [],
                        "evidenceQuote": "maintaining coral dominance over macroalgae.",
                        "explanation": "The text states that herbivores maintain coral dominance over macroalgae."
                    },
                    {
                        "number": 35,
                        "prompt": "What maximum temperature anomaly did structural complexity buffer in microhabitats?",
                        "answer": "0.8 degrees Celsius",
                        "options": [],
                        "evidenceQuote": "buffered localized temperature anomalies by up to 0.8 degrees Celsius within shaded microhabitats.",
                        "explanation": "The text specifies up to 0.8 degrees Celsius."
                    },
                    {
                        "number": 36,
                        "prompt": "What kind of biomass was significantly higher in marine protected zones?",
                        "answer": "apex predator",
                        "options": [],
                        "evidenceQuote": "retained significantly higher apex predator biomass and structural rugosity",
                        "explanation": "The passage confirms higher apex predator biomass."
                    },
                    {
                        "number": 37,
                        "prompt": "What type of experiments confirmed that rugose colony morphologies alter fluid dynamics?",
                        "answer": "flume experiments",
                        "options": [],
                        "evidenceQuote": "Controlled laboratory flume experiments further confirmed that rugose colony morphologies alter boundary layer fluid dynamics",
                        "explanation": "Controlled laboratory flume experiments confirmed this."
                    },
                    {
                        "number": 38,
                        "prompt": "How many permanent stations were monitored during systematic surveys?",
                        "answer": "sixty",
                        "options": [],
                        "evidenceQuote": "surveys across sixty permanent monitoring stations revealed",
                        "explanation": "The text mentions sixty permanent monitoring stations."
                    }
                ],
                "invalid": [
                    {
                        "number": 34,
                        "prompt": "What do herbivorous fish control to maintain coral dominance over macroalgae?",
                        "answer": "macroalgae",
                        "options": [],
                        "evidenceQuote": "maintaining coral dominance over macroalgae.",
                        "explanation": "Answer 'macroalgae' is leaked directly in the question prompt.",
                        "rejectReason": "answer_leakage"
                    },
                    {
                        "number": 35,
                        "prompt": "What maximum temperature anomaly did structural complexity buffer in microhabitats?",
                        "answer": "up to approximately 0.8 degrees Celsius in shade",
                        "options": [],
                        "evidenceQuote": "buffered localized temperature anomalies by up to 0.8 degrees Celsius",
                        "explanation": "Answer exceeds the maximum three words limit.",
                        "rejectReason": "answer_exceeds_three_words"
                    },
                    {
                        "number": 36,
                        "prompt": "What kind of biomass was significantly higher in marine protected zones?",
                        "answer": "blue whale",
                        "options": [],
                        "evidenceQuote": "retained significantly higher apex predator biomass",
                        "explanation": "Answer 'blue whale' does not appear in the passage text.",
                        "rejectReason": "answer_absent_from_passage"
                    },
                    {
                        "number": 37,
                        "prompt": "What experiments confirmed that rugose colony morphologies alter fluid dynamics?",
                        "answer": "",
                        "options": [],
                        "evidenceQuote": "flume experiments further confirmed",
                        "explanation": "Answer is empty string.",
                        "rejectReason": "empty_answer"
                    },
                    {
                        "number": 38,
                        "prompt": "How many permanent stations were monitored?",
                        "answer": "sixty",
                        "options": [],
                        "evidenceQuote": "sixty stations",
                        "explanation": "Evidence quote is under fifteen characters in length.",
                        "rejectReason": "evidence_too_short"
                    }
                ]
            }
        }
    }
    return corpus

# ── 5. Network Stream Fixtures ───────────────────────────────────────────────
def build_network_stream_fixtures():
    return {
        "mid_utf8_split": {
            "description": "Stream split across chunk boundaries in the middle of a 3-byte UTF-8 quote character (U+201C)",
            "chunk1_base64": "eyJ0eXBlIjoibG9nIiwibWVzc2FnZSI6IkV2aWRlbmNlOiDig",  # partial UTF-8 \xe2\x80
            "chunk2_base64": "nGNvcmFsIHJlZWZz4oCdIn0K",                          # rest \x9c + content
        },
        "mid_json_split": {
            "description": "Stream split across chunk boundaries in the middle of a JSON line",
            "chunk1": '{"type":"log","timestamp":"2026-09-30T10:00:00Z","message":"Passage 1 gen',
            "chunk2": 'eration stream opened."}\n{"type":"log","message":"Next step"}\n'
        },
        "missing_terminal_eof": {
            "description": "NDJSON stream that closes without sending result or error event",
            "stream": '{"type":"log","level":"Information","message":"Working..."}\n{"type":"log","level":"Information","message":"Still working..."}\n'
        },
        "error_terminal_422": {
            "description": "NDJSON stream that terminates with an unprocessable entity error (422)",
            "stream": '{"type":"log","level":"Information","message":"Validating..."}\n{"type":"error","httpStatus":422,"message":"Source content is too short (599 words)","traceback":""}\n'
        },
        "error_terminal_502": {
            "description": "NDJSON stream that terminates with a pipeline generation failure (502)",
            "stream": '{"type":"log","level":"Information","message":"Generating..."}\n{"type":"error","httpStatus":502,"message":"LLM model output malformed","traceback":"Traceback..."}\n'
        }
    }

def main():
    eligible = build_eligible_sources()
    ineligible = build_ineligible_sources()
    fidelity = build_fidelity_pairs()
    questions = build_questions_corpus()
    network = build_network_stream_fixtures()

    files = {
        "sources_eligible.json": eligible,
        "sources_ineligible.json": ineligible,
        "fidelity_pairs.json": fidelity,
        "questions_corpus.json": questions,
        "network_stream_fixtures.json": network,
    }

    hashes = {}
    for filename, data in files.items():
        path = FIXTURES_DIR / filename
        content = json.dumps(data, indent=2, ensure_ascii=False)
        path.write_text(content, encoding="utf-8")
        h = hashlib.sha256(content.encode("utf-8")).hexdigest()
        hashes[filename] = {
            "sha256": h,
            "bytes": len(content.encode("utf-8")),
            "itemCount": len(data) if isinstance(data, (list, dict)) else 1
        }
        print(f"Generated {filename}: {len(content)} chars, SHA256={h[:16]}...")

    hash_path = Path("artifacts/refactor/phase-00/fixtures-hashes.json")
    hash_path.write_text(json.dumps(hashes, indent=2), encoding="utf-8")
    print(f"Saved fixture hashes to {hash_path}")

if __name__ == "__main__":
    main()
