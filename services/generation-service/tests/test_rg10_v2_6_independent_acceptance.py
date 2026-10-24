"""Independent acceptance test suite for Evaluator v2.6 (RG10 Verification).

Evaluates Evaluator v2.6 against 25 independently labeled DEV acceptance cases
across 5 grammatical structures:
1. Negative / Restrictive Adverbial Inversion (5 items)
2. Mandative Subjunctive (5 items)
3. It-Cleft Focus Structures (5 items)
4. Inverted and Unreal Conditionals (5 items)
5. Past Modal Deduction (5 items)

Invariants:
- Evaluator predictions are evaluated against independently labeled gold.
- Denominators are explicit:
  * Gold VALID = 15 (denominator for False Rejection Rate)
  * Gold INVALID = 10 (denominator for False Acceptance Rate)
  * Total items = 25 (denominator for Coverage and Accuracy)
- References are never relabeled to inflate metrics.
- Known evaluator limitations (e.g. '-ss' base verbs, conditional 'if' stem matching,
  subjunctive trigger scope) are explicitly tested and accounted for.
"""
from __future__ import annotations

import pytest

from app.contracts.research import GrammarRulePack, SourceRef
from app.evaluators.independent import NeutralEvaluatorV2_6
from app.evaluators.rubric import EvaluationVerdict


def make_test_rule_pack(topic: str, rule_id: str, example: str) -> GrammarRulePack:
    return GrammarRulePack(
        rule_pack_id=f"pack-{rule_id}",
        source=SourceRef(
            source_id=f"src-{rule_id}",
            source_family=f"fam-{rule_id}",
            source_version="v1.0",
            source_sha256="0" * 64,
            license="test",
            provenance_uri="internal://test",
        ),
        topic=topic,
        level="C1",
        rule_ids=[rule_id],
        applicability=[f"Rules for {topic}."],
        examples=[example],
    )


# 25 Independently Labeled DEV Acceptance Cases (not used in v2.6 development)
DEV_ACCEPTANCE_CASES = [
    # ── Family 1: Inversion (5 items: 3 Valid, 2 Invalid) ──
    {
        "id": "INV-DEV-01",
        "family": "Inversion",
        "topic": "Negative and Restrictive Adverbial Inversion",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Negative and Restrictive Adverbial Inversion",
            "inv-01",
            "Seldom have researchers observed such anomalies."
        ),
        "passage": "Seldom have researchers observed such anomalies in high-pressure volcanic chambers during baseline monitoring.",
        "question": {
            "question_id": "INV-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which of the following sentences correctly uses subject-auxiliary inversion after a negative adverbial?",
            "options": [
                "A) Seldom have geologists witnessed such rapid cooling rates.",
                "B) Seldom geologists have witnessed such rapid cooling rates.",
                "C) Seldom have witnessed geologists such rapid cooling rates.",
                "D) Seldom do geologists has witnessed such rapid cooling rates."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "INV-DEV-02",
        "family": "Inversion",
        "topic": "Negative and Restrictive Adverbial Inversion",
        "gold": "VALID",  # Evaluator exhibits FR due to 'bypass' ending in '-ss'
        "rule_pack": make_test_rule_pack(
            "Negative and Restrictive Adverbial Inversion",
            "inv-02",
            "Under no circumstances should the valve be opened."
        ),
        "passage": "Under no circumstances should the emergency venting valve be opened without prior depressurization protocols.",
        "question": {
            "question_id": "INV-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly demonstrates negative adverbial inversion?",
            "options": [
                "A) Under no circumstances we should bypass the interlock.",
                "B) Under no circumstances should we bypass the interlock.",
                "C) Under no circumstances we do bypass the interlock.",
                "D) Under no circumstances should bypass we the interlock."
            ],
            "proposed_answer": "B"
        }
    },
    {
        "id": "INV-DEV-03",
        "family": "Inversion",
        "topic": "Negative and Restrictive Adverbial Inversion",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Negative and Restrictive Adverbial Inversion",
            "inv-03",
            "Not only did the team succeed, but they set a record."
        ),
        "passage": "Not only did the engineering team succeed in containing the eruption, but they also preserved baseline data.",
        "question": {
            "question_id": "INV-03",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly forms negative inversion with 'Not only'?",
            "options": [
                "A) Not only the sensor detected the fracture, but it alerted the crew.",
                "B) Not only detected the sensor the fracture, but it alerted the crew.",
                "C) Not only did the sensor detect the fracture, but it alerted the crew.",
                "D) Not only the sensor did detect the fracture, but it alerted the crew."
            ],
            "proposed_answer": "C"
        }
    },
    {
        "id": "INV-DEV-04",
        "family": "Inversion",
        "topic": "Negative and Restrictive Adverbial Inversion",
        "gold": "INVALID",  # Ambiguous MCQ: options A and B are both valid inversion sentences
        "rule_pack": make_test_rule_pack(
            "Negative and Restrictive Adverbial Inversion",
            "inv-04",
            "Rarely has such precision been achieved."
        ),
        "passage": "Rarely has such precision been achieved in benthic autonomous sampling missions under extreme pressure.",
        "question": {
            "question_id": "INV-04",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses negative inversion?",
            "options": [
                "A) Rarely have oceanographers mapped the trench so accurately.",
                "B) Seldom have oceanographers mapped the trench so accurately.",
                "C) Rarely oceanographers have mapped the trench so accurately.",
                "D) Seldom oceanographers have mapped the trench so accurately."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "INV-DEV-05",
        "family": "Inversion",
        "topic": "Negative and Restrictive Adverbial Inversion",
        "gold": "INVALID",  # Stem-answer constraint conflict (stem asks for 'do', answer uses 'can')
        "rule_pack": make_test_rule_pack(
            "Negative and Restrictive Adverbial Inversion",
            "inv-05",
            "Little did they know what lay ahead."
        ),
        "passage": "Little did the exploratory team know what lay ahead beneath the abyssal plain during their first dive.",
        "question": {
            "question_id": "INV-05",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses 'do' to form inversion when there is no auxiliary?",
            "options": [
                "A) In no way can we authorize the mission.",
                "B) In no way we can authorize the mission.",
                "C) In no way can authorize we the mission.",
                "D) In no way we authorize the mission."
            ],
            "proposed_answer": "A"
        }
    },

    # ── Family 2: Subjunctive (5 items: 3 Valid, 2 Invalid) ──
    {
        "id": "SUB-DEV-01",
        "family": "Subjunctive",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Mandative and Formulaic Subjunctive Clauses",
            "sub-01",
            "The supervisor insists that the technician wear goggles."
        ),
        "passage": "The laboratory safety supervisor insists that each technician wear full protective gear in the cleanroom.",
        "question": {
            "question_id": "SUB-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses the mandative subjunctive?",
            "options": [
                "A) The protocol requires that the operator submits the log hourly.",
                "B) The protocol requires that the operator submit the log hourly.",
                "C) The protocol requires that the operator will submit the log hourly.",
                "D) The protocol requires that the operator is submitting the log hourly."
            ],
            "proposed_answer": "B"
        }
    },
    {
        "id": "SUB-DEV-02",
        "family": "Subjunctive",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Mandative and Formulaic Subjunctive Clauses",
            "sub-02",
            "It is essential that she be present at the hearing."
        ),
        "passage": "It is essential that every delegate be present during the ratification vote of the international treaty.",
        "question": {
            "question_id": "SUB-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses the mandative subjunctive with an adjective?",
            "options": [
                "A) It is vital that the specimen remain refrigerated.",
                "B) It is vital that the specimen remains refrigerated.",
                "C) It is vital that the specimen is refrigerated.",
                "D) It is vital that the specimen will remain refrigerated."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "SUB-DEV-03",
        "family": "Subjunctive",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Mandative and Formulaic Subjunctive Clauses",
            "sub-03",
            "The board recommended that he resign immediately."
        ),
        "passage": "The executive ethics committee recommended that the director resign prior to the external audit.",
        "question": {
            "question_id": "SUB-03",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence demonstrates incorrect use of the mandative subjunctive?",
            "options": [
                "A) The committee recommended that she abstain from voting.",
                "B) The committee recommended that she abstains from voting.",
                "C) The committee recommended that she should abstain from voting.",
                "D) The committee recommended that she must abstain from voting."
            ],
            "proposed_answer": "B"
        }
    },
    {
        "id": "SUB-DEV-04",
        "family": "Subjunctive",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "gold": "INVALID",  # Ambiguous subjunctive MCQ
        "rule_pack": make_test_rule_pack(
            "Mandative and Formulaic Subjunctive Clauses",
            "sub-04",
            "The court ordered that the witness appear in person."
        ),
        "passage": "The court ordered that the expert witness appear in person before the special tribunal on Monday.",
        "question": {
            "question_id": "SUB-04",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly applies the mandative subjunctive?",
            "options": [
                "A) The decree demands that the defendant pays the restitution.",
                "B) The decree demands that the defendant pay the restitution.",
                "C) The decree demands that the respondent appear before the judge.",
                "D) The decree demands that the defendant will pay the restitution."
            ],
            "proposed_answer": "B"
        }
    },
    {
        "id": "SUB-DEV-05",
        "family": "Subjunctive",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "gold": "INVALID",  # Defective subjunctive MCQ: no base forms
        "rule_pack": make_test_rule_pack(
            "Mandative and Formulaic Subjunctive Clauses",
            "sub-05",
            "The law stipulates that employers provide safe equipment."
        ),
        "passage": "The federal statute stipulates that all commercial employers provide certified protective equipment.",
        "question": {
            "question_id": "SUB-05",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly applies the mandative subjunctive?",
            "options": [
                "A) The statute stipulates that each facility maintains backup power.",
                "B) The statute stipulates that each facility will maintain backup power.",
                "C) The statute stipulates that each facility has maintained backup power.",
                "D) The statute stipulates that each facility is maintaining backup power."
            ],
            "proposed_answer": "A"
        }
    },

    # ── Family 3: It-Cleft (5 items: 3 Valid, 2 Invalid) ──
    {
        "id": "CLF-DEV-01",
        "family": "It-Cleft",
        "topic": "It-Cleft Focus Structures",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "It-Cleft Focus Structures",
            "clf-01",
            "It was the senior analyst who detected the security breach."
        ),
        "passage": "It was the senior forensic analyst who detected the unauthorized data extraction during routine audits.",
        "question": {
            "question_id": "CLF-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an it-cleft focus structure?",
            "options": [
                "A) It was the lead investigator that found the missing logs.",
                "B) The lead investigator it was that found the missing logs.",
                "C) It were the lead investigator that found the missing logs.",
                "D) That found the missing logs was the lead investigator."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CLF-DEV-02",
        "family": "It-Cleft",
        "topic": "It-Cleft Focus Structures",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "It-Cleft Focus Structures",
            "clf-02",
            "It is careful calibration that ensures measurement accuracy."
        ),
        "passage": "It is meticulous calibration of sensor arrays that ensures empirical accuracy in oceanographic surveys.",
        "question": {
            "question_id": "CLF-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly emphasizes the instrument using an it-cleft?",
            "options": [
                "A) It is the spectrophotometer that provides the definitive reading.",
                "B) It are the spectrophotometer that provides the definitive reading.",
                "C) The spectrophotometer it is that provides the definitive reading.",
                "D) What it is the spectrophotometer that provides the reading."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CLF-DEV-03",
        "family": "It-Cleft",
        "topic": "It-Cleft Focus Structures",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "It-Cleft Focus Structures",
            "clf-03",
            "It was in 1977 that oceanographers first observed hydrothermal vents."
        ),
        "passage": "It was in 1977 that marine geophysicists first observed hydrothermal vent ecosystems along the Galapagos Rift.",
        "question": {
            "question_id": "CLF-03",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly focuses an adverbial phrase using an it-cleft?",
            "options": [
                "A) It was during the second expedition that the team located the vent.",
                "B) It were during the second expedition that the team located the vent.",
                "C) During the second expedition it was that the team located the vent.",
                "D) Was during the second expedition that the team located the vent."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CLF-DEV-04",
        "family": "It-Cleft",
        "topic": "It-Cleft Focus Structures",
        "gold": "INVALID",  # Tense agreement discord
        "rule_pack": make_test_rule_pack(
            "It-Cleft Focus Structures",
            "clf-04",
            "It was the team that resolved the issue."
        ),
        "passage": "It was the crisis management team that resolved the power disruption at the remote station.",
        "question": {
            "question_id": "CLF-04",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an it-cleft construction?",
            "options": [
                "A) It was the lead researcher that discovers the new hydrothermal vent.",
                "B) The researcher it was that discovers the vent.",
                "C) What discovered the vent was the researcher.",
                "D) It were the researcher that discovers the vent."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CLF-DEV-05",
        "family": "It-Cleft",
        "topic": "It-Cleft Focus Structures",
        "gold": "INVALID",  # Defective cleft: proposed answer is not a cleft
        "rule_pack": make_test_rule_pack(
            "It-Cleft Focus Structures",
            "clf-05",
            "It was the seismic sensor that triggered the alarm."
        ),
        "passage": "It was the high-frequency seismic transducer that triggered the automatic shutdown mechanism.",
        "question": {
            "question_id": "CLF-05",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an it-cleft construction?",
            "options": [
                "A) The alarm was triggered by the seismic sensor immediately.",
                "B) Triggering the alarm was the seismic sensor.",
                "C) What triggered the alarm was the seismic sensor.",
                "D) The seismic sensor it was triggering the alarm."
            ],
            "proposed_answer": "A"
        }
    },

    # ── Family 4: Conditionals (5 items: 3 Valid, 2 Invalid) ──
    {
        "id": "CND-DEV-01",
        "family": "Conditionals",
        "topic": "Inverted and Unreal Conditionals",
        "gold": "VALID",  # Evaluator exhibits FR because 'if' option is matched
        "rule_pack": make_test_rule_pack(
            "Inverted and Unreal Conditionals",
            "cnd-01",
            "Had the team detected the rupture earlier, they would have averted the leak."
        ),
        "passage": "Had the inspection team detected the casing rupture earlier, they would have averted the chemical leak.",
        "question": {
            "question_id": "CND-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted third conditional?",
            "options": [
                "A) Had the crew checked the seals, they would have prevented the flood.",
                "B) The crew had checked the seals, they would have prevented the flood.",
                "C) If the crew had checked the seals, they would have prevented the flood.",
                "D) Did the crew check the seals, they would have prevented the flood."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CND-DEV-02",
        "family": "Conditionals",
        "topic": "Inverted and Unreal Conditionals",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Inverted and Unreal Conditionals",
            "cnd-02",
            "Were the pressure to rise further, the safety valve would release steam."
        ),
        "passage": "Were the internal chamber pressure to rise further, the primary relief valve would release excess steam.",
        "question": {
            "question_id": "CND-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted second conditional with 'were'?",
            "options": [
                "A) Were the temperature to exceed limits, the reactor would shut down.",
                "B) Were the temperature will exceed limits, the reactor would shut down.",
                "C) The temperature were to exceed limits, the reactor would shut down.",
                "D) If the temperature were exceeding limits, the reactor will shut down."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CND-DEV-03",
        "family": "Conditionals",
        "topic": "Inverted and Unreal Conditionals",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Inverted and Unreal Conditionals",
            "cnd-03",
            "Should you require further assistance, please contact the laboratory."
        ),
        "passage": "Should the research staff require additional consumables, please submit a formal requisition form.",
        "question": {
            "question_id": "CND-03",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted conditional with 'should'?",
            "options": [
                "A) Should any anomalies arise during testing, notify the lead engineer.",
                "B) Should any anomalies arose during testing, notify the lead engineer.",
                "C) Any anomalies should arise during testing, notify the lead engineer.",
                "D) If should any anomalies arise during testing, notify the engineer."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CND-DEV-04",
        "family": "Conditionals",
        "topic": "Inverted and Unreal Conditionals",
        "gold": "INVALID",  # Ambiguous conditional
        "rule_pack": make_test_rule_pack(
            "Inverted and Unreal Conditionals",
            "cnd-04",
            "Had we known the risk, we would have acted."
        ),
        "passage": "Had the operations director known the environmental risk, the team would have acted immediately.",
        "question": {
            "question_id": "CND-04",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses an unreal past condition?",
            "options": [
                "A) Had we reviewed the data, we would have revised the protocol.",
                "B) If we had reviewed the data, we would have revised the protocol.",
                "C) Had we reviewed the data, we will revise the protocol.",
                "D) If we reviewed the data, we would have revise the protocol."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "CND-DEV-05",
        "family": "Conditionals",
        "topic": "Inverted and Unreal Conditionals",
        "gold": "INVALID",  # Defective conditional: no valid conditional structure
        "rule_pack": make_test_rule_pack(
            "Inverted and Unreal Conditionals",
            "cnd-05",
            "Had the valve closed, disaster would have been averted."
        ),
        "passage": "Had the safety interlock closed automatically, the catastrophic blowout would have been averted.",
        "question": {
            "question_id": "CND-05",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses an inverted condition?",
            "options": [
                "A) The valve had closed, disaster would have been averted.",
                "B) Closed the valve had, disaster would have been averted.",
                "C) Had the valve close, disaster will be averted.",
                "D) Was the valve closed, disaster had been averted."
            ],
            "proposed_answer": "A"
        }
    },

    # ── Family 5: Modal Structures (5 items: 3 Valid, 2 Invalid) ──
    {
        "id": "MOD-DEV-01",
        "family": "Modals",
        "topic": "Past Modal Deduction and Speculation",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Past Modal Deduction and Speculation",
            "mod-01",
            "The seismic sensors must have recorded the initial tremor."
        ),
        "passage": "The regional seismic monitoring array must have recorded the initial benthic tremor before the tsunami warning.",
        "question": {
            "question_id": "MOD-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses high-certainty deduction about the past?",
            "options": [
                "A) The geophysicists must have noticed the signal anomaly.",
                "B) The geophysicists must have notice the signal anomaly.",
                "C) The geophysicists must to have noticed the signal anomaly.",
                "D) The geophysicists must having noticed the signal anomaly."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "MOD-DEV-02",
        "family": "Modals",
        "topic": "Past Modal Deduction and Speculation",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Past Modal Deduction and Speculation",
            "mod-02",
            "The submarine could not have survived the extreme crushing pressure."
        ),
        "passage": "The unreinforced submersible could not have survived the hydrostatic pressure at that depth.",
        "question": {
            "question_id": "MOD-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses negative past impossibility?",
            "options": [
                "A) The expedition cannot have reached the hydrothermal ridge without sonar.",
                "B) The expedition cannot have reach the hydrothermal ridge without sonar.",
                "C) The expedition cannot to have reached the ridge without sonar.",
                "D) The expedition cannot having reached the ridge without sonar."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "MOD-DEV-03",
        "family": "Modals",
        "topic": "Past Modal Deduction and Speculation",
        "gold": "VALID",
        "rule_pack": make_test_rule_pack(
            "Past Modal Deduction and Speculation",
            "mod-03",
            "The volcanic plume might have disrupted atmospheric transmission."
        ),
        "passage": "The ash-laden volcanic eruption plume might have disrupted satellite communications during the morning hours.",
        "question": {
            "question_id": "MOD-03",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses past possibility using a modal?",
            "options": [
                "A) The research vessel might have encountered rough seas near the cape.",
                "B) The research vessel might have encounter rough seas near the cape.",
                "C) The research vessel might to have encountered rough seas.",
                "D) The research vessel might having encountered rough seas."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "MOD-DEV-04",
        "family": "Modals",
        "topic": "Past Modal Deduction and Speculation",
        "gold": "INVALID",  # Ambiguous modal MCQ
        "rule_pack": make_test_rule_pack(
            "Past Modal Deduction and Speculation",
            "mod-04",
            "The technician should have checked the pressure gauge."
        ),
        "passage": "The maintenance engineer should have inspected the secondary containment seal before launching the trial.",
        "question": {
            "question_id": "MOD-04",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly expresses a past deduction or obligation?",
            "options": [
                "A) The technician must have verified the pressure reading.",
                "B) The technician should have verified the pressure reading.",
                "C) The technician must have verify the pressure reading.",
                "D) The technician should to have verified the pressure reading."
            ],
            "proposed_answer": "A"
        }
    },
    {
        "id": "MOD-DEV-05",
        "family": "Modals",
        "topic": "Past Modal Deduction and Speculation",
        "gold": "INVALID",  # Defective modal MCQ: no valid options
        "rule_pack": make_test_rule_pack(
            "Past Modal Deduction and Speculation",
            "mod-05",
            "The power grid must have collapsed under peak surge."
        ),
        "passage": "The regional high-voltage transmission grid must have collapsed under the unforeseen lightning surge.",
        "question": {
            "question_id": "MOD-05",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses past modal deduction?",
            "options": [
                "A) The generator must have fail during the storm.",
                "B) The generator must to have failed during the storm.",
                "C) The generator must having failed during the storm.",
                "D) The generator must has failed during the storm."
            ],
            "proposed_answer": "A"
        }
    }
]


def test_dev_acceptance_suite_metrics():
    """Verify that Evaluator v2.6 achieves expected error metrics on the 25 DEV acceptance items."""
    evaluator = NeutralEvaluatorV2_6()
    results = []

    for c in DEV_ACCEPTANCE_CASES:
        res = evaluator.evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        pred_str = "PASS" if res.verdict == EvaluationVerdict.PASS else "FAIL"
        results.append({
            "id": c["id"],
            "family": c["family"],
            "gold": c["gold"],
            "pred": pred_str,
            "verdict": res.verdict,
            "reason": res.abstention_reason,
        })

    # Assert totals
    total = len(results)
    assert total == 25

    gold_valid_count = sum(1 for r in results if r["gold"] == "VALID")
    gold_invalid_count = sum(1 for r in results if r["gold"] == "INVALID")
    assert gold_valid_count == 15
    assert gold_invalid_count == 10

    # Counts
    tp = sum(1 for r in results if r["gold"] == "VALID" and r["pred"] == "PASS")
    fn = sum(1 for r in results if r["gold"] == "VALID" and r["pred"] == "FAIL")
    tn = sum(1 for r in results if r["gold"] == "INVALID" and r["pred"] == "FAIL")
    fp = sum(1 for r in results if r["gold"] == "INVALID" and r["pred"] == "PASS")

    # Metrics with explicit denominators
    assert tp == 13
    assert fn == 2  # False Rejections: INV-DEV-02 (bypass -ss), CND-DEV-01 (if stem clash)
    assert tn == 8
    assert fp == 2  # False Acceptances: SUB-DEV-04, SUB-DEV-05

    fr_rate = fn / gold_valid_count  # 2 / 15 = 13.3%
    fa_rate = fp / gold_invalid_count  # 2 / 10 = 20.0%
    accuracy = (tp + tn) / total  # 21 / 25 = 84.0%
    coverage = total / total  # 25 / 25 = 100.0%
    abstention_count = sum(1 for r in results if r["verdict"] == EvaluationVerdict.UNCERTAIN)

    assert abstention_count == 0
    assert coverage == 1.0
    assert pytest.approx(fr_rate, 0.01) == 0.133
    assert pytest.approx(fa_rate, 0.01) == 0.200
    assert pytest.approx(accuracy, 0.01) == 0.840


@pytest.mark.parametrize("item", DEV_ACCEPTANCE_CASES)
def test_individual_dev_acceptance_item_execution(item: dict):
    """Verify that every individual DEV acceptance case executes without exception in Evaluator v2.6."""
    evaluator = NeutralEvaluatorV2_6()
    res = evaluator.evaluate_item(
        dataset_item_id=item["id"],
        passage_text=item["passage"],
        question_data=item["question"],
        context_metadata={"rule_pack": item["rule_pack"]},
    )
    assert res.verdict in (EvaluationVerdict.PASS, EvaluationVerdict.FAIL)
    assert res.evaluable is True
    assert res.evaluator_version == "neutral-eval-v2.6"
