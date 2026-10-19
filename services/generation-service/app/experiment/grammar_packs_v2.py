"""Authoritative Grammar RulePacks and CEFR Taxonomy for RQ2_DATASET_V2 (Sprint V2-S03).

Provides 7 reference-grounded GrammarRulePack instances conforming to
app.contracts.research.GrammarRulePack. All 7 packs are grounded in standard
descriptive reference grammars (Quirk et al., Biber et al., Huddleston & Pullum,
Hewings, Murphy) with authentic ISBN catalog identifiers under publisher All Rights
Reserved status.

Includes exactly 21 sub-rules, documented syntactic exceptions, and 56 original
academic example sentences (8 per family) authored specifically for Langfens research.
"""

from __future__ import annotations

import hashlib
import json
import re
from typing import Any, Dict, List, Optional

from app.contracts.research import GrammarRulePack, SourceRef
from app.experiment.grammar_validator_v2 import (
    V2_GRAMMAR_ERROR_TAXONOMY,
    validate_syntactic_construction,
)

# Authoritative ISBN Catalog Identifiers for Reference Grammars
QUIRK_1985_ISBN = "urn:isbn:978-0582517349"
HUDDLESTON_2002_ISBN = "urn:isbn:978-0521431460"
BIBER_1999_ISBN = "urn:isbn:978-0582045620"
HEWINGS_2013_ISBN = "urn:isbn:978-1107690691"
MURPHY_2019_ISBN = "urn:isbn:978-1108457651"

PUBLISHER_RIGHTS_ALL_RESERVED = "ALL_RIGHTS_RESERVED"


def compute_rulepack_content_sha256(
    rule_pack_id: str,
    topic: str,
    level: str,
    rule_ids: List[str],
    applicability: List[str],
    exceptions: List[str],
    examples: List[str],
    reference_citation: str,
) -> str:
    """Computes a deterministic SHA-256 fingerprint over the canonical rule pack content."""
    payload = {
        "rule_pack_id": rule_pack_id,
        "topic": topic,
        "level": level,
        "rule_ids": sorted(rule_ids),
        "applicability": applicability,
        "exceptions": exceptions,
        "examples": examples,
        "reference_citation": reference_citation,
    }
    canonical_bytes = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(canonical_bytes).hexdigest()


# ---------------------------------------------------------------------------
# Family 1: fam-v2-grammar-inversion (Negative & Restrictive Adverbial Inversion)
# ---------------------------------------------------------------------------
INV_TOPIC = "Negative and Restrictive Adverbial Inversion"
INV_LEVEL = "C1"
INV_RULE_IDS = ["INV-01", "INV-02", "INV-03"]
INV_CITATION = "Quirk, Greenbaum, Leech, & Svartvik (1985) §18.24–39; Huddleston & Pullum (2002) Ch. 11 §7"
INV_APPLICABILITY = [
    "Fronted negative or restrictive adverbial adjunct modifying the matrix clause triggers mandatory subject-operator inversion.",
    "Dummy auxiliary 'do' insertion is mandatory when the matrix predicate lacks an auxiliary or modal verb.",
    "Negative time adverbials ('hardly', 'scarcely') in initial position trigger inversion in the main clause, typically followed by a 'when'-clause.",
    "Correlative coordinating constructions beginning with 'not only' trigger subject-auxiliary inversion in the first coordinate.",
]
INV_EXCEPTIONS = [
    "Inversion does NOT occur when 'only' modifies a subject noun phrase rather than an adverbial adjunct (e.g. 'Only senior researchers attended the symposium').",
    "Inversion does NOT occur when the negative or restrictive adverbial remains in its default post-verbal or non-fronted position (e.g. 'The team realized this only after reviewing the telemetry').",
    "Prepositional phrases beginning with 'with' containing negative words (e.g. 'with no hesitation') do not trigger subject-operator inversion in standard academic English.",
]
INV_EXAMPLES = [
    "Under no circumstances should researchers alter experimental parameters after protocol preregistration has been finalized.",
    "Rarely does a single randomized controlled trial provide sufficient empirical evidence to overturn an established scientific consensus.",
    "Seldom have ecological restoration projects demonstrated such rapid recovery of native macroinvertebrate biodiversity within urban riparian corridors.",
    "Only after extensive cross-validation against independent astronomical surveys did astrophysicists confirm the periodic nature of the gamma-ray burst.",
    "Hardly had the catalytic reactor reached equilibrium when unanticipated pressure spikes disrupted the automated synthesis sequence.",
    "Scarcely had the thermal imaging array stabilized when anomalous fluctuations in infrared emission were detected across the sensor grid.",
    "Not only did the high-throughput sequencing platform lower per-base sequencing costs, but it also substantially improved long-read assembly fidelity.",
    "Not only did the paleoclimate team recover intact ice core samples from the subglacial ridge, but they also identified unoxidized tephra layers spanning three distinct volcanic episodes.",
]
INV_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-inversion",
    INV_TOPIC,
    INV_LEVEL,
    INV_RULE_IDS,
    INV_APPLICABILITY,
    INV_EXCEPTIONS,
    INV_EXAMPLES,
    INV_CITATION,
)

RULE_PACK_INVERSION = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-inversion",
    source=SourceRef(
        source_id="src-v2-grammar-ref-quirk-1985",
        source_family="fam-v2-grammar-inversion",
        source_version="v2.0",
        source_sha256=INV_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=QUIRK_1985_ISBN,
    ),
    topic=INV_TOPIC,
    level=INV_LEVEL,
    rule_ids=INV_RULE_IDS,
    applicability=INV_APPLICABILITY,
    exceptions=INV_EXCEPTIONS,
    examples=INV_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 2: fam-v2-grammar-conditionals (Mixed Time-Reference & Inverted Conditionals)
# ---------------------------------------------------------------------------
COND_TOPIC = "Mixed Time-Reference and Inverted Conditionals"
COND_LEVEL = "B2 / C1"
COND_RULE_IDS = ["COND-01", "COND-02", "COND-03"]
COND_CITATION = "Quirk et al. (1985) §14.23; Huddleston & Pullum (2002) Ch. 8 §2"
COND_APPLICABILITY = [
    "Mixed Type A conditionals combine an unfulfilled past condition (pluperfect) with an ongoing or present counterfactual outcome (modal would + bare infinitive).",
    "Mixed Type B conditionals combine an enduring present or general counterfactual state (subjunctive were or simple past) with a completed past outcome (modal would + have + past participle).",
    "Inverted conditionals omit the subordinator 'if' and front the auxiliary operator ('had', 'were', or 'should') to clause-initial position in formal academic register.",
]
COND_EXCEPTIONS = [
    "Inversion is strictly limited to auxiliary operators 'had', 'were', and 'should'; lexical main verbs cannot invert directly without operator periphrasis (e.g. 'Had we known the results', never *'Knew we'*).",
    "Mixed conditionals require genuine temporal asymmetry; they must not be conflated with standard third conditionals where both condition and result refer entirely to the past.",
    "Negative inverted conditionals require uncontracted 'not' immediately following the subject noun phrase (e.g. 'Had the investigators not intervened', never *'Hadn't the investigators'* in formal register).",
]
COND_EXAMPLES = [
    "If the agricultural research institute had secured sustainable grant funding in 2020, its vertical farming laboratory would now be operating at full capacity.",
    "If ancient Mesopotamian engineers had not constructed sophisticated irrigation canals, modern archaeologists would not now find sedimented levees along the floodbasin.",
    "If the clinical trial protocol had included longitudinal biomarker tracking, epidemiologists would now possess definitive evidence of immunological durability.",
    "If the regional power grid were more interconnected, last winter's severe subzero storm would not have triggered widespread rolling blackouts.",
    "If marine conservation policies were strictly enforced worldwide, coral reef degradation from destructive trawling would not have accelerated so drastically over the past decade.",
    "Had the geology team accurately calibrated the borehole pressure transducer, the unexpected subterranean gas release would have been contained immediately.",
    "Had climate modellers incorporated deep-ocean thermal inertia twenty years ago, their projected atmospheric warming trajectories would now correspond more closely to observed satellite data.",
    "Were the cryogenic storage chambers to lose cooling capability during power outages, irreplaceable bacterial culture specimens would suffer irreversible cellular damage.",
]
COND_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-conditionals",
    COND_TOPIC,
    COND_LEVEL,
    COND_RULE_IDS,
    COND_APPLICABILITY,
    COND_EXCEPTIONS,
    COND_EXAMPLES,
    COND_CITATION,
)

RULE_PACK_CONDITIONALS = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-conditionals",
    source=SourceRef(
        source_id="src-v2-grammar-ref-huddleston-2002",
        source_family="fam-v2-grammar-conditionals",
        source_version="v2.0",
        source_sha256=COND_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=HUDDLESTON_2002_ISBN,
    ),
    topic=COND_TOPIC,
    level=COND_LEVEL,
    rule_ids=COND_RULE_IDS,
    applicability=COND_APPLICABILITY,
    exceptions=COND_EXCEPTIONS,
    examples=COND_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 3: fam-v2-grammar-clefts (It-Clefts & Wh-Pseudo-Clefts)
# ---------------------------------------------------------------------------
CLEFT_TOPIC = "It-Clefts and Wh-Pseudo-Clefts"
CLEFT_LEVEL = "C1"
CLEFT_RULE_IDS = ["CLEFT-01", "CLEFT-02", "CLEFT-03"]
CLEFT_CITATION = "Biber et al. (1999) §11.4; Quirk et al. (1985) §18.25–32"
CLEFT_APPLICABILITY = [
    "It-clefts partition a single proposition into a matrix clause with dummy pronoun 'it' and copula 'be', followed by the focused constituent and a relative clause introduced by 'that' or 'who'.",
    "Wh-pseudo-clefts position a nominal relative clause introduced by 'what' as subject, followed by copular 'be' and the focused constituent, shifting focus to sentence-final position.",
    "Reversed wh-pseudo-clefts place the focused element initially as subject, followed by copular 'be' and a nominal relative clause, emphasizing thematic prominence.",
]
CLEFT_EXCEPTIONS = [
    "The introductory pronoun in it-clefts is strictly non-referential dummy 'it'; substituting demonstrative pronouns ('this' or 'that') alters the information structure and produces a non-cleft copular construction.",
    "In formal academic register, the cleft clause in it-clefts is standardly introduced by 'that' (or 'who' for persons); subordinators like 'when', 'where', or 'which' are generally dispreferred.",
    "Pseudo-clefts standardly use 'what' as a fused relative pronoun; expressions introduced by 'who' or 'which' require a generic nominal head in formal academic English (e.g. 'The person who led...').",
]
CLEFT_EXAMPLES = [
    "It was the sudden deceleration of the North Atlantic subpolar gyre that caused the pronounced cooling anomaly across northwestern Europe during the early Holocene.",
    "It was through systematic microstructural electron microscopy that metallurgists finally identified the micro-crack propagation mechanism in the turbine blades.",
    "It was primarily in the third experimental trial that the bioinspired superhydrophobic coating demonstrated sustained ice-shedding capability under freezing drizzle.",
    "It was the pioneering archaeological excavations at Blombos Cave that fundamentally reshaped our understanding of early modern human symbolic behavior in southern Africa.",
    "What evolutionary anthropologists discovered during sediment sifting was an exceptionally well-preserved set of Middle Pleistocene bone tools.",
    "What the high-altitude atmospheric balloon payload recorded was an unprecedented concentration of chlorofluorocarbon breakdown products above the polar vortex.",
    "Substantial attenuation of viral replication in human bronchial epithelium was what the synthetic peptide clinical trial definitively demonstrated.",
    "A profound shift in prevailing oceanic circulation patterns was what ultimately precipitated the rapid onset of the Younger Dryas climatic reversal.",
]
CLEFT_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-clefts",
    CLEFT_TOPIC,
    CLEFT_LEVEL,
    CLEFT_RULE_IDS,
    CLEFT_APPLICABILITY,
    CLEFT_EXCEPTIONS,
    CLEFT_EXAMPLES,
    CLEFT_CITATION,
)

RULE_PACK_CLEFTS = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-clefts",
    source=SourceRef(
        source_id="src-v2-grammar-ref-biber-1999",
        source_family="fam-v2-grammar-clefts",
        source_version="v2.0",
        source_sha256=CLEFT_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=BIBER_1999_ISBN,
    ),
    topic=CLEFT_TOPIC,
    level=CLEFT_LEVEL,
    rule_ids=CLEFT_RULE_IDS,
    applicability=CLEFT_APPLICABILITY,
    exceptions=CLEFT_EXCEPTIONS,
    examples=CLEFT_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 4: fam-v2-grammar-subjunctive (Mandative & Formulaic Subjunctive)
# ---------------------------------------------------------------------------
SUBJ_TOPIC = "Mandative and Formulaic Subjunctive"
SUBJ_LEVEL = "B2 / C1"
SUBJ_RULE_IDS = ["SUBJ-01", "SUBJ-02", "SUBJ-03"]
SUBJ_CITATION = "Quirk et al. (1985) §3.58–62; Huddleston & Pullum (2002) Ch. 3 §1.4"
SUBJ_APPLICABILITY = [
    "Mandative subjunctive requires the uninflected base form of the verb in subordinate that-clauses governed by predicates expressing recommendation, demand, resolution, or necessity.",
    "The base form remains invariant regardless of person or number, showing zero 3rd-person singular '-s' inflection and invariant 'be' for copular predicates.",
    "Negative mandative subjunctive places the negative particle 'not' immediately before the base verb without auxiliary 'do' periphrasis.",
    "Formulaic subjunctive preserves archaic independent clauses with invariant base verbs in conventionalized academic and rhetorical discourse.",
]
SUBJ_EXCEPTIONS = [
    "Indicative complements are used when the governing predicate asserts a statement of factual truth rather than a demand or obligation (e.g. 'The witness insisted that he was innocent' [indicative fact] vs 'The panel insisted that he attend' [subjunctive requirement]).",
    "Negative mandative subjunctive strictly forbids do-support in formal academic register (e.g. 'recommended that she not publish', never *'recommended that she does not publish'*).",
    "Formulaic expressions are lexically frozen set phrases; syntactic alteration or tense-shifting destroys their formulaic status (e.g. *'sufficed it to say'* is ungrammatical).",
]
SUBJ_EXAMPLES = [
    "The bioethics supervisory committee recommended that the principal investigator submit a revised data governance framework before enrolling human participants.",
    "International maritime environmental conventions require that every cargo vessel decontaminate its ballast water storage tanks prior to entering territorial waters.",
    "It is essential that each field sample remain frozen at minus eighty degrees Celsius to prevent degradation of labile messenger RNA transcripts.",
    "Atmospheric science safety guidelines mandate that all sensor calibration logs be archived in duplicate on immutable cryptographic storage nodes.",
    "The clinical trial oversight panel insisted that the pharmaceutical sponsor not unblind patient outcome data until all statistical verification pipelines had completed.",
    "Institutional ethics protocols stipulate that laboratory supervisors not allow uncertified research personnel into high-containment biosafety suites.",
    "Suffice it to say that early hypotheses regarding passive lunar mantle cooling proved fundamentally incompatible with contemporary seismological readings.",
    "Be that as it may, subsequent petrological analyses confirmed that volatile exsolution had already initiated prior to the major caldera collapse.",
]
SUBJ_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-subjunctive",
    SUBJ_TOPIC,
    SUBJ_LEVEL,
    SUBJ_RULE_IDS,
    SUBJ_APPLICABILITY,
    SUBJ_EXCEPTIONS,
    SUBJ_EXAMPLES,
    SUBJ_CITATION,
)

RULE_PACK_SUBJUNCTIVE = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-subjunctive",
    source=SourceRef(
        source_id="src-v2-grammar-ref-quirk-1985",
        source_family="fam-v2-grammar-subjunctive",
        source_version="v2.0",
        source_sha256=SUBJ_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=QUIRK_1985_ISBN,
    ),
    topic=SUBJ_TOPIC,
    level=SUBJ_LEVEL,
    rule_ids=SUBJ_RULE_IDS,
    applicability=SUBJ_APPLICABILITY,
    exceptions=SUBJ_EXCEPTIONS,
    examples=SUBJ_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 5: fam-v2-grammar-participles (Participle Clauses & Reduced Relatives)
# ---------------------------------------------------------------------------
PART_TOPIC = "Participle Clauses and Reduced Relatives"
PART_LEVEL = "B2"
PART_RULE_IDS = ["PART-01", "PART-02", "PART-03"]
PART_CITATION = "Quirk et al. (1985) §15.56–62; Biber et al. (1999) §9.4"
PART_APPLICABILITY = [
    "Adverbial participle clauses condense adverbial clauses of time, reason, or condition, using non-finite verbal forms whose covert subject is coreferential with the overt subject of the matrix clause.",
    "Present participles ('-ing') denote contemporaneous or ongoing actions, circumstances, or immediate consequences.",
    "Perfect participles ('having' + past participle) explicitly emphasize that the action in the non-finite clause was completed prior to the action of the main verb.",
    "Past participles condense passive relative clauses or passive adverbial clauses into postmodifying non-finite phrases or fronted circumstantial clauses.",
]
PART_EXCEPTIONS = [
    "Dangling or unattached participles are strictly ungrammatical in formal academic register: the implied subject of the non-finite participial clause MUST be identical to the grammatical subject of the matrix clause (e.g. *'Having reviewed the literature, the hypothesis was formulated'* is dangling; *'Having reviewed the literature, the authors formulated the hypothesis'* is well-formed).",
    "Participles of stative verbs denoting mental states or relations generally resist progressive aspect in participial adverbial clauses unless explicitly describing a temporary condition.",
    "Absolute participle clauses possessing their own overt nominative subject (e.g. 'Weather permitting, the launch will proceed') are distinct from standard reduced participle clauses and do not require matrix coreference.",
]
PART_EXAMPLES = [
    "Utilizing deep convolutional neural networks for automated satellite image segmentation, cartographers mapped seasonal deforestation boundaries with ninety-four percent spatial accuracy.",
    "Analyzing fossilized diatom assemblages extracted from sub-Antarctic sediment cores, paleoceanographers reconstructed sea-surface temperature variations spanning sixty thousand years.",
    "Operating under autonomous guidance algorithms, the deep-sea submersible navigated complex hydrothermal ridge topography without tethered operator intervention.",
    "Having synthesized the novel organometallic compound, the organic chemistry team conducted comprehensive nuclear magnetic resonance spectroscopy to confirm its isomeric structure.",
    "Having established an ultra-high vacuum environment within the particle beamline, physicists observed coherent synchrotron radiation across the extreme ultraviolet spectrum.",
    "Having completed thirty-six months of continuous automated observations, the robotic telescope array released its first comprehensive celestial transit catalog.",
    "Treated with a specialized hydrophobic fluoropolymer spray, the micro-textured copper substrate exhibited sustained droplet roll-off under intense simulated rainfall.",
    "Artifacts discovered within the lower sedimentary layer provide compelling chronological evidence for metallurgical bronze casting in Southeast Asia by the second millennium BCE.",
]
PART_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-participles",
    PART_TOPIC,
    PART_LEVEL,
    PART_RULE_IDS,
    PART_APPLICABILITY,
    PART_EXCEPTIONS,
    PART_EXAMPLES,
    PART_CITATION,
)

RULE_PACK_PARTICIPLES = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-participles",
    source=SourceRef(
        source_id="src-v2-grammar-ref-biber-1999",
        source_family="fam-v2-grammar-participles",
        source_version="v2.0",
        source_sha256=PART_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=BIBER_1999_ISBN,
    ),
    topic=PART_TOPIC,
    level=PART_LEVEL,
    rule_ids=PART_RULE_IDS,
    applicability=PART_APPLICABILITY,
    exceptions=PART_EXCEPTIONS,
    examples=PART_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 6: fam-v2-grammar-modals (Past Speculation & Logical Deduction)
# ---------------------------------------------------------------------------
MOD_TOPIC = "Past Speculation and Logical Deduction"
MOD_LEVEL = "B2"
MOD_RULE_IDS = ["MOD-01", "MOD-02", "MOD-03"]
MOD_CITATION = "Quirk et al. (1985) §4.49–66; Murphy (2019) Units 27–29"
MOD_APPLICABILITY = [
    "Modal perfect constructions combine a modal auxiliary verb with 'have' and a past participle to express degrees of epistemic probability or deduction regarding past events or states.",
    "'Must have' + past participle expresses strong positive logical deduction based on available empirical evidence.",
    "'Cannot have' or 'could not have' + past participle expresses strong negative deduction, asserting that a past event was logically impossible given current facts.",
    "'May have', 'might have', or 'could have' + past participle expresses tentative possibility or speculative hypothesis regarding past occurrences.",
]
MOD_EXCEPTIONS = [
    "Epistemic past deduction ('must have been' = logical certainty) is strictly distinct from past deontic obligation ('had to be' / 'was obliged to be'); modal 'must' has no past deontic form in standard English.",
    "In formal academic English, strong negative deduction is expressed via 'cannot have' or 'could not have', NEVER 'must not have' (which denotes assumed non-occurrence or prohibitive intention, not impossibility).",
    "'Could have' in counterfactual contexts (describing an unfulfilled ability: 'The team could have prevented the anomaly but failed to act') is distinct from epistemic speculation regarding unknown facts.",
]
MOD_EXAMPLES = [
    "Given the extensive calcification patterns observed in the fossilized arterial walls, the adult sauropod specimen must have suffered from chronic cardiovascular pathology.",
    "Because the ancient metallurgical slag contains unusually elevated concentrations of arsenic and nickel, early smelters must have mined ore deposits from the nearby polymetallic belt.",
    "Judging from the severe surface erosion patterns on the outer turbine blades, microscopic airborne abrasive particulates must have infiltrated the intake filtration system.",
    "The sudden depletion of localized freshwater aquifers cannot have resulted solely from seasonal precipitation deficits, given that historical rainfall records show average annual precipitation.",
    "Early Polynesian navigators could not have reached isolated eastern Pacific archipelagos without utilizing sophisticated celestial navigation methods and deep-sea outrigger voyaging canoes.",
    "The sudden power grid frequency collapse could not have originated from transmission line thermal expansion alone, as supervisory telemetry confirmed immediate substation tripping.",
    "The unexplained attenuation of the seismic shear wave may have originated from a partially molten basaltic lens situated twenty kilometers beneath the caldera.",
    "Microbial communities inhabiting deep subglacial volcanic lakes might have adapted to extreme chemotrophic nutrient regimes over millions of years of complete photosynthetic isolation.",
]
MOD_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-modals",
    MOD_TOPIC,
    MOD_LEVEL,
    MOD_RULE_IDS,
    MOD_APPLICABILITY,
    MOD_EXCEPTIONS,
    MOD_EXAMPLES,
    MOD_CITATION,
)

RULE_PACK_MODALS = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-modals",
    source=SourceRef(
        source_id="src-v2-grammar-ref-murphy-2019",
        source_family="fam-v2-grammar-modals",
        source_version="v2.0",
        source_sha256=MOD_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=MURPHY_2019_ISBN,
    ),
    topic=MOD_TOPIC,
    level=MOD_LEVEL,
    rule_ids=MOD_RULE_IDS,
    applicability=MOD_APPLICABILITY,
    exceptions=MOD_EXCEPTIONS,
    examples=MOD_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Family 7: fam-v2-grammar-passives (Impersonal & Reporting Passives)
# ---------------------------------------------------------------------------
PASS_TOPIC = "Impersonal and Reporting Passives"
PASS_LEVEL = "B1 / B2"
PASS_RULE_IDS = ["PASS-01", "PASS-02", "PASS-03"]
PASS_CITATION = "Quirk et al. (1985) §16.64–68; Hewings (2013) Unit 24; Biber et al. (1999) §11.3"
PASS_APPLICABILITY = [
    "Impersonal reporting passives utilize dummy pronoun 'it', followed by a passive reporting verb (e.g. 'is believed', 'was thought', 'has been estimated') and a finite 'that'-clause to report claims neutrally without personal attribution.",
    "Personal reporting passives raise the subject of the embedded clause to matrix subject position, followed by a passive reporting verb and a 'to'-infinitive, foregrounding the topical entity.",
    "Personal reporting passives with perfect infinitive ('to have' + past participle) explicitly convey that the reported action occurred prior to the time of reporting.",
]
PASS_EXCEPTIONS = [
    "Certain reporting verbs (e.g. 'suggest', 'explain', 'announce', 'insist') strictly disallow the personal reporting passive construction with a to-infinitive (e.g. *'He is suggested to be'* is ungrammatical; *'It is suggested that he is'* is well-formed).",
    "Reporting passives must preserve semantic neutrality and epistemic distancing; attributing direct certainty through factive matrix predicates (e.g. *'It is proved that'* vs *'It is suggested that'*) changes the modal status of the reported claim.",
    "Personal reporting with stative verbs requires simple infinitive ('is understood to possess'), whereas completed actions require perfect infinitive ('is reported to have survived').",
]
PASS_EXAMPLES = [
    "It is widely believed that the transition from foraging to sedentary agrarian cultivation originated independently across multiple geographic centers during the early Holocene.",
    "It has been estimated that approximately thirty percent of global anthropogenic carbon dioxide emissions are absorbed annually by marine and terrestrial carbon sinks.",
    "It is generally accepted that quantum entanglement across macroscopic distances enables theoretically unhackable cryptographic key distribution protocols.",
    "The deep-sea hydrothermal vent biome is reported to host previously undiscovered thermophilic archaebacterial strains capable of chemosynthesis without sunlight.",
    "The ancient palace complex at Knossos is believed to comprise both a centralized administrative labyrinth and an elaborate ritual sanctuary.",
    "Subterranean fungal mycelial networks are now known to facilitate inter-plant nutrient and chemical signal transport across entire temperate forest ecosystems.",
    "The asteroid impact at the Cretaceous-Paleogene boundary is understood to have triggered protracted atmospheric dust loading and global catastrophic wildfire surges.",
    "Early metallurgical smelting furnaces excavated in the eastern Mediterranean basin are believed to have attained operational temperatures exceeding twelve hundred degrees Celsius.",
]
PASS_SHA256 = compute_rulepack_content_sha256(
    "fam-v2-grammar-passives",
    PASS_TOPIC,
    PASS_LEVEL,
    PASS_RULE_IDS,
    PASS_APPLICABILITY,
    PASS_EXCEPTIONS,
    PASS_EXAMPLES,
    PASS_CITATION,
)

RULE_PACK_PASSIVES = GrammarRulePack(
    rule_pack_id="fam-v2-grammar-passives",
    source=SourceRef(
        source_id="src-v2-grammar-ref-hewings-2013",
        source_family="fam-v2-grammar-passives",
        source_version="v2.0",
        source_sha256=PASS_SHA256,
        license=PUBLISHER_RIGHTS_ALL_RESERVED,
        provenance_uri=HEWINGS_2013_ISBN,
    ),
    topic=PASS_TOPIC,
    level=PASS_LEVEL,
    rule_ids=PASS_RULE_IDS,
    applicability=PASS_APPLICABILITY,
    exceptions=PASS_EXCEPTIONS,
    examples=PASS_EXAMPLES,
)


# ---------------------------------------------------------------------------
# Master Registry & Validator
# ---------------------------------------------------------------------------
V2_GRAMMAR_RULE_PACKS: Dict[str, GrammarRulePack] = {
    "fam-v2-grammar-inversion": RULE_PACK_INVERSION,
    "fam-v2-grammar-conditionals": RULE_PACK_CONDITIONALS,
    "fam-v2-grammar-clefts": RULE_PACK_CLEFTS,
    "fam-v2-grammar-subjunctive": RULE_PACK_SUBJUNCTIVE,
    "fam-v2-grammar-participles": RULE_PACK_PARTICIPLES,
    "fam-v2-grammar-modals": RULE_PACK_MODALS,
    "fam-v2-grammar-passives": RULE_PACK_PASSIVES,
}

V2_SUB_RULE_REGISTRY: Dict[str, Dict[str, Any]] = {
    "INV-01": {
        "family_id": "fam-v2-grammar-inversion",
        "syntactic_target": "Fronted negative adjunct inversion",
        "reference": "Quirk et al. §18.24–28; Huddleston Ch. 11 §7.1",
        "egp_target": "INVERSION",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "INV-02": {
        "family_id": "fam-v2-grammar-inversion",
        "syntactic_target": "Restrictive only-adjunct inversion",
        "reference": "Quirk et al. §18.29–33; Huddleston Ch. 11 §7.1",
        "egp_target": "INVERSION",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "INV-03": {
        "family_id": "fam-v2-grammar-inversion",
        "syntactic_target": "Correlative not only... but also inversion",
        "reference": "Quirk et al. §18.34–36",
        "egp_target": "INVERSION / CONJUNCTIONS",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "COND-01": {
        "family_id": "fam-v2-grammar-conditionals",
        "syntactic_target": "Mixed past counterfactual to present state",
        "reference": "Quirk et al. §14.23; Huddleston Ch. 8 §2.2",
        "egp_target": "CONDITIONALS",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "COND-02": {
        "family_id": "fam-v2-grammar-conditionals",
        "syntactic_target": "Mixed ongoing state to past counterfactual outcome",
        "reference": "Quirk et al. §14.23; Huddleston Ch. 8 §2.2",
        "egp_target": "CONDITIONALS",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "COND-03": {
        "family_id": "fam-v2-grammar-conditionals",
        "syntactic_target": "Inverted conditional with operator fronting (had, were, should)",
        "reference": "Quirk et al. §14.23 Note b, §15.35; Huddleston Ch. 8 §2.4",
        "egp_target": "INVERSION / CONDITIONALS",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "CLEFT-01": {
        "family_id": "fam-v2-grammar-clefts",
        "syntactic_target": "It-cleft focused adjunct or noun phrase",
        "reference": "Quirk et al. §18.25–30; Biber et al. §11.4",
        "egp_target": "CLEFT SENTENCES",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "CLEFT-02": {
        "family_id": "fam-v2-grammar-clefts",
        "syntactic_target": "Wh-pseudo-cleft with nominal relative clause",
        "reference": "Quirk et al. §18.31–32; Biber et al. §11.4",
        "egp_target": "CLEFT SENTENCES",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "CLEFT-03": {
        "family_id": "fam-v2-grammar-clefts",
        "syntactic_target": "Reversed wh-pseudo-cleft",
        "reference": "Quirk et al. §18.32; Biber et al. §11.4",
        "egp_target": "CLEFT SENTENCES",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "SUBJ-01": {
        "family_id": "fam-v2-grammar-subjunctive",
        "syntactic_target": "Mandative subjunctive base form after suasion predicates",
        "reference": "Quirk et al. §3.58–59; Huddleston Ch. 3 §1.4",
        "egp_target": "SUBJUNCTIVE / MODALITY",
        "provisional_cefr": "B2 / C1",
        "cefr_evidence_status": "FLAGGED_AS_UNSUPPORTED_CLAIM_PENDING_CURATOR_ADJUDICATION",
    },
    "SUBJ-02": {
        "family_id": "fam-v2-grammar-subjunctive",
        "syntactic_target": "Negative mandative subjunctive (not + base)",
        "reference": "Quirk et al. §3.59; Huddleston Ch. 3 §1.4",
        "egp_target": "SUBJUNCTIVE / NEGATION",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "SUBJ-03": {
        "family_id": "fam-v2-grammar-subjunctive",
        "syntactic_target": "Formulaic subjunctive archaic set expressions",
        "reference": "Quirk et al. §3.61; Huddleston Ch. 3 §1.4",
        "egp_target": "FIXED PHRASES",
        "provisional_cefr": "C1",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "PART-01": {
        "family_id": "fam-v2-grammar-participles",
        "syntactic_target": "Present adverbial participle clauses (V-ing)",
        "reference": "Quirk et al. §15.56–58; Biber et al. §9.4",
        "egp_target": "CLAUSES (NON-FINITE)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "PART-02": {
        "family_id": "fam-v2-grammar-participles",
        "syntactic_target": "Perfect participle clauses (Having + past participle)",
        "reference": "Quirk et al. §15.59–60; Biber et al. §9.4",
        "egp_target": "CLAUSES (NON-FINITE)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "PART-03": {
        "family_id": "fam-v2-grammar-participles",
        "syntactic_target": "Passive participle clauses and reduced relatives",
        "reference": "Quirk et al. §15.61–62; Biber et al. §9.4",
        "egp_target": "RELATIVE CLAUSES / PASSIVES",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "MOD-01": {
        "family_id": "fam-v2-grammar-modals",
        "syntactic_target": "Epistemic high-certainty affirmative past deduction (must have + PP)",
        "reference": "Quirk et al. §4.53–54; Murphy Units 27–29",
        "egp_target": "MODALITY (PAST)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "MOD-02": {
        "family_id": "fam-v2-grammar-modals",
        "syntactic_target": "Epistemic high-certainty negative past deduction (cannot / could not have + PP)",
        "reference": "Quirk et al. §4.55; Murphy Units 27–29",
        "egp_target": "MODALITY (PAST)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "MOD-03": {
        "family_id": "fam-v2-grammar-modals",
        "syntactic_target": "Epistemic tentative possibility past speculation (may / might / could have + PP)",
        "reference": "Quirk et al. §4.56–60; Murphy Units 27–29",
        "egp_target": "MODALITY (PAST)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "PASS-01": {
        "family_id": "fam-v2-grammar-passives",
        "syntactic_target": "Impersonal reporting passives with dummy it (It is believed / reported that)",
        "reference": "Quirk et al. §16.64; Hewings Unit 24; Biber §11.3",
        "egp_target": "PASSIVES (REPORTING)",
        "provisional_cefr": "B1 / B2",
        "cefr_evidence_status": "FLAGGED_FOR_CURATOR_ADJUDICATION",
    },
    "PASS-02": {
        "family_id": "fam-v2-grammar-passives",
        "syntactic_target": "Personal reporting passives (Subject + be + passive + to-infinitive)",
        "reference": "Quirk et al. §16.65; Hewings Unit 24; Huddleston Ch. 14 §3.2",
        "egp_target": "PASSIVES (REPORTING)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
    "PASS-03": {
        "family_id": "fam-v2-grammar-passives",
        "syntactic_target": "Personal reporting passives with perfect infinitive (to have + PP)",
        "reference": "Quirk et al. §16.65; Hewings Unit 24; Biber §11.3",
        "egp_target": "PASSIVES (REPORTING)",
        "provisional_cefr": "B2",
        "cefr_evidence_status": "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID",
    },
}


def get_v2_grammar_rule_pack(rule_pack_id: str) -> GrammarRulePack:
    """Retrieves an authoritative GrammarRulePack by its identifier."""
    if rule_pack_id not in V2_GRAMMAR_RULE_PACKS:
        raise KeyError(f"Unknown V2 GrammarRulePack identifier: '{rule_pack_id}'")
    return V2_GRAMMAR_RULE_PACKS[rule_pack_id]


def list_v2_grammar_rule_packs() -> List[GrammarRulePack]:
    """Returns the ordered list of all 7 authoritative GrammarRulePack instances."""
    return list(V2_GRAMMAR_RULE_PACKS.values())


def validate_grammar_rule_pack_integrity(pack: GrammarRulePack) -> Dict[str, Any]:
    """Validates structural and provenance invariants of a GrammarRulePack."""
    issues: List[str] = []

    # 1. Example cardinality
    if len(pack.examples) != 8:
        issues.append(f"Expected exactly 8 examples, got {len(pack.examples)}")

    # 2. Sub-rules presence
    if len(pack.rule_ids) < 3:
        issues.append(f"Expected at least 3 sub-rules, got {len(pack.rule_ids)}")

    # 3. SourceRef licensing
    if pack.source.license != PUBLISHER_RIGHTS_ALL_RESERVED:
        issues.append(
            f"Expected license='{PUBLISHER_RIGHTS_ALL_RESERVED}', got '{pack.source.license}'"
        )

    # 4. ISBN catalog URI
    if not pack.source.provenance_uri.startswith("urn:isbn:"):
        issues.append(f"Expected ISBN URN, got '{pack.source.provenance_uri}'")

    # 5. Digest validity
    if not re.match(r"^[0-9a-f]{64}$", pack.source.source_sha256):
        issues.append("source_sha256 is not a valid 64-hex SHA-256 digest")

    # 6. Applicability and exceptions
    if len(pack.applicability) < 3:
        issues.append("Expected >= 3 applicability constraints")
    if len(pack.exceptions) < 3:
        issues.append("Expected >= 3 documented exceptions")

    return {
        "rule_pack_id": pack.rule_pack_id,
        "is_valid": len(issues) == 0,
        "issues": issues,
        "examples_count": len(pack.examples),
        "rule_ids_count": len(pack.rule_ids),
    }


# ---------------------------------------------------------------------------
# Sub-Rule Example Mapping & Error Taxonomy
# ---------------------------------------------------------------------------
V2_EXAMPLE_SUB_RULE_MAP: Dict[str, List[str]] = {
    "fam-v2-grammar-inversion": [
        "INV-01", "INV-01", "INV-01",
        "INV-02", "INV-02", "INV-02",
        "INV-03", "INV-03",
    ],
    "fam-v2-grammar-conditionals": [
        "COND-01", "COND-01", "COND-01",
        "COND-02", "COND-02",
        "COND-03", "COND-03", "COND-03",
    ],
    "fam-v2-grammar-clefts": [
        "CLEFT-01", "CLEFT-01", "CLEFT-01", "CLEFT-01",
        "CLEFT-02", "CLEFT-02",
        "CLEFT-03", "CLEFT-03",
    ],
    "fam-v2-grammar-subjunctive": [
        "SUBJ-01", "SUBJ-01", "SUBJ-01", "SUBJ-01",
        "SUBJ-02", "SUBJ-02",
        "SUBJ-03", "SUBJ-03",
    ],
    "fam-v2-grammar-participles": [
        "PART-01", "PART-01", "PART-01",
        "PART-02", "PART-02", "PART-02",
        "PART-03", "PART-03",
    ],
    "fam-v2-grammar-modals": [
        "MOD-01", "MOD-01", "MOD-01",
        "MOD-02", "MOD-02", "MOD-02",
        "MOD-03", "MOD-03",
    ],
    "fam-v2-grammar-passives": [
        "PASS-01", "PASS-01", "PASS-01",
        "PASS-02", "PASS-02", "PASS-02",
        "PASS-03", "PASS-03",
    ],
}

