BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-carbon-capture-and-storage-1419'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-carbon-capture-and-storage-1419';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-carbon-capture-and-storage-1419';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-carbon-capture-and-storage-1419';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('19626b57-4d1d-5997-9596-f2d780faf109', 'ielts-reading-carbon-capture-and-storage-1419', $t$Carbon Capture and Storage$t$, $md$## Carbon Capture and Storage

Nguồn:
- Test: https://mini-ielts.com/1419/reading/carbon-capture-and-storage
- Solution: https://mini-ielts.com/1419/view-solution/reading/carbon-capture-and-storage$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d9a05fcf-0f24-5aad-a0d2-e832fd2b385b', '19626b57-4d1d-5997-9596-f2d780faf109', 1, $t$Reading — Carbon Capture and Storage$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Carbon Capture and Storage

High coal dependence

Renewable energy is much discussed, but coal still plays the greatest role in the generation of electricity, with recent figures from the International Energy Agency showing that China relies on it for 79% of its power, Australia for 78%, and the US for 45%. Germany has less reliance at 41%, which is also the global average. Furthermore, many countries have large, easily accessible deposits of coal, and numerous highly skilled miners, chemists, and engineers. Meanwhile, 70% of the world’s steel production requires coal, and plastic and rayon are usually coal derivatives.

Currently, coal-fired power plants fed voracious appetites, but they produce carbon dioxide (CO2) in staggering amounts. Urbanites may grumble about an average monthly electricity bill of $113, yet they steadfastly ignore the fact that they are not billed for the 6-7 million metric tons of CO2 their local plant belches out, which contribute to the 44% of global CO2 levels from fossil-fuel emissions. Yet, as skies fill with smog and temperatures soar, people crave clean air and cheap power.

The Intergovernmental Panel on Climate Change that advises the United Nations has testified that the threshold of serious harm to the Earth’s temperature is a mere 2° Celsius above current levels, so it is essential to reduce carbon emissions by 80% over the next 30 years, even as demand for energy will rise by 50%, and one proposal for this is the adoption of carbon capture and storage (CCS).

Underground carbon storage

Currently, CO2 storage, or sequestration as it is known, is practised by the oil and gas industry, where CO2 is pumped into oil fields to maintain pressure and ease extraction – one metric ton dissolves out about three barrels, or separated from natural gas and pumped out of exhausted coal fields or other deep seams. The CO2 remains underground or is channelled into disused sandstone reservoirs. However, the sale of oil and natural gas is profitable, so the $17-per-ton sequestration cost is easily borne. There is also a plan for the injection of CO2 into saline aquifers, 1,000 metres beneath the seabed, to prevent its release into the atmosphere.

Carbon capture

While CO2 storage has been accomplished, its capture from power plants remains largely hypothetical, although CCS plants throughout Western Europe and North America are on the drawing board.

There are three main forms of CCS: pre-combustion, post-combustion, and oxy-firing. In a 2012 paper from the US Congressional Budget Office (CBO), post-combustion capture was viewed most favourably since existing power plants can be retrofitted with it, whereas pre-combustion and oxy-firing mean the construction of entirely new plants. However, pre-combustion and oxy-firing remove more CO2 than post-combustion and generate more electricity.

Post-combustion capture means CO2 is separated from gas after coal is burnt but before electricity is generated, while in oxy-firing, coal is combusted in pure oxygen. In pre-combustion, as in an Integrated Gasification Combined Cycle system (IGCC), oxygen, coal, and water ae burnt together to produce a synthetic gas called Syngas – mainly hydrogen – which drives two sets of turbines, firstly gas-driven ones, then, as the cooling Syngas travel through water, steam-driven ones. Emissions from this process contain around ten percent of the CO2 that burning coal produces.

The pros and cons of CCS

Several countries are keen to scale up CCS as it may reduce carbon emissions quickly, and powerful lobby groups for CCS exist among professionals in mining and engineering. Foundries and refineries that produce steel and emit carbon may also benefit, and the oil and gas industry is interested because power-plant equipment consumes their products. In addition, recent clean energy acts in many countries mandate that a percentage of electricity be generated by renewables or by more energy-efficient systems, like CCS.

As with desalination, where powerful lobbies wield influence, states sometimes find it easier to engage in large projects involving a few players rather than change behaviours on a more scattered household scale. Furthermore, replacing coal with zero-emission photovoltaic (PV) cells to produce solar energy would require covering an area nearly 20,720 square kilometres, roughly twice the size of Lebanon or half of Denmark.

Still, there are many reservations about CCS. Principally, it is enormously expensive: conservative estimates put the electricity it generates at more than five times the current retail price. As consumers are unlikely to want to bear this price hike, massive state subsidies would be necessary for CCS to work.

The capital outlay of purchasing equipment for retrofitting existing power plants is high enough, but the energy needed to capture CO2 means one third more coal must be burnt, and building new CCS plants is at least 75% more expensive than retro-fitting.

Some CCS technology is untried, for example, the Syngas-driven turbines in an IGCC system have not been used on an industrial scale. Post capture, CO2 must be compressed into a supercritical liquid for transport and storage, which is also costly. The Qatar Carbonates and Carbon Storage Research Centre predicts 700 million barrels per day of this liquid would be produced if CCS were adopted modestly. It is worth noting that current oil production is around 85 million barrels per day, so CCS would produce eleven times more waste for burial than oil that was simultaneously being extracted.

Sequestration has been used successfully, but there are limited coal and oil fields where optimal conditions exist. In rock that is too brittle, earthquakes could release the CO2. Moreover, proposals to store CO2 in saline aquifers are just that – proposals: sequestration has never been attempted in aquifers.

Most problematic of all, CCS reduces carbon emissions but does not end them, rendering it a medium-term solution.

Alternatives

There are at least four reasonably-priced alternatives to CCS. Firstly, conventional pulverised coal power plants are undergoing redesign so more electricity can be produced from less coal. Before coal is phased out – as ultimately it will have to be – these plants could be more cost-eﬀective. Secondly, hybrid plants using natural gas and coal could be built. Thirdly, natural gas could be used on its own. Lastly, solar power is fast gaining credibility.

In all this, an agreed measure of cost for electricity generation must be used. This is called a levelized cost of energy (LCOE) – an average cost of producing electricity over the lifetime of a power plant, including construction, financing, and operation, although pollution is not counted. In 2012, the CBO demonstrated that a new CCS plant had an LCOE of about $0.09-0.15 per kilowatt-hour (kWh), but according to the US Energy Information Administration, the LCOE from a conventional natural gas power plant without CCS is $0.0686/kWh, making it the cheapest way to produce clean energy.

Solar power costs are falling rapidly. In 2013, the Los Angeles Department of Water and Power reported that energy via a purchase agreement from a large solar plant was $0.095/kWh, and Greentech Media, a company that reviews environmental projects, found a 2014 New Mexico solar project that generates power for $0.0849/kWh.

Still, while so much coal and so many coal-fired plants exist, decommissioning them all may not be realistic. Whatever happens, the conundrum of cheap power and clean air may remain unsolved for some time.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('173aa814-9fe8-5e2f-a238-9fdc6148db7e', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-2
Questions 1-2
Choose the correct letter
A
,
B
,
C
, or
D
.
Write the correct letter in boxes
1-2
on your answer sheet.
1.
What is the global average for electricity generated from coal?
A
41%
B
44%
C
49%
D
70%
2.
What does the average American pay each month for CO2 produced by a local power plant?
A
$17
B
$80
C
$113
D
Nothing

Choose the correct letter A , B , C , or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('885bea73-ad27-5471-a3fd-b167df724ec9', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-2
Questions 1-2
Choose the correct letter
A
,
B
,
C
, or
D
.
Write the correct letter in boxes
1-2
on your answer sheet.
1.
What is the global average for electricity generated from coal?
A
41%
B
44%
C
49%
D
70%
2.
What does the average American pay each month for CO2 produced by a local power plant?
A
$17
B
$80
C
$113
D
Nothing

Choose the correct letter A , B , C , or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

3 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5664a7d0-c422-59e3-9908-06cd9d2373b3', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2732a0e2-c782-502b-b2a3-f03d60c2a350', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8348d715-3911-5025-b101-19d1f9c80fbc', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daa735b7-7601-5e25-9fdd-a9825376791f', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('935fbc80-f7b1-5015-8807-6f97b682a594', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eb08109-b9db-53bf-9c5d-591cf217e3fa', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8f8f1d8-0532-50f7-8f32-149c285d6f69', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d3c25ab-50b8-5856-bd3a-770a12c78f51', 'ad484ea0-d913-5ca9-83c7-4b9bc38bee80', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25273a15-8621-5356-8e4a-5ed78dc70fa7', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f6bae18-9956-5d00-a12f-99d4e31a554b', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f12bc22b-cafd-53f7-a62c-d11e894cfa1b', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bff5099-223b-5f59-afef-f167c8ad40e8', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc841699-7294-5e65-9b8f-77f047a7e708', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bad1d9c-d60e-5a3f-b058-a27ac748971d', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63f49c5f-40bd-5cb1-aaa3-4223d95af323', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91f81ecc-9674-528e-9d09-69eb19450717', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1b69970-a2a1-5ff8-a29d-7e8d98f01dad', '25273a15-8621-5356-8e4a-5ed78dc70fa7', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c6cd8c8-f2f9-527c-9e97-bff356874c8d', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fec229f8-cd54-5583-a53d-13d388920a9b', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('936a4010-c249-5805-b453-bc712e6d8ba1', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23e0728e-7556-5068-ae56-d742a01a85c2', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b714af76-b21d-5c9d-a602-2c8092450b04', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4408368d-6a16-5187-a85f-c52e2013a9a4', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e02a3a6c-5ea5-5c0f-ba6d-40ca0690abe7', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6bf2045-34ff-52f3-a787-b032d3f855bb', '4e0e10bd-5670-51be-ad22-8d41d7b1d50c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

6 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3f2fdfa-62aa-5a08-a12e-d6312f9487dd', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96ab1c1e-fa10-5ba5-97f5-d0c2bb22d16e', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f41361b-6a95-5240-8b31-a308489ec9f4', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c91492e-1604-5137-b368-f871148e7678', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1321cf31-7d69-5833-8f38-cb51e418d2ef', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d09d9953-73b0-5b7e-90da-6a74fe3a67aa', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d81563cd-c529-56fb-8573-030c8128541a', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfe6501a-1b90-5219-8486-7c250e2e5687', '0a5c9c42-1891-58b6-90e3-0b7134ab5c76', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d2996ab-c1c9-5a22-b371-93bf571517ee', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

7 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e1bc92b-bcf0-5089-94a3-3623631efd54', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31a68234-79ac-5091-b9e5-44e716803907', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('988ee6d7-e11a-56cd-a572-e6eec387dba5', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fcf853e-4eea-5b5b-9cc4-97b805f2e571', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9be8b51-72af-500e-967c-072759ecd77a', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26dc4c6-a7e9-579d-9092-daa5ea0b6914', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1163d8ff-d3db-5d38-a256-5d88d131694f', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e9d49f-ab00-5531-a80e-6150c5eb135c', '3d2996ab-c1c9-5a22-b371-93bf571517ee', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53780bfb-d443-58cf-89e7-042275b12e2f', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 3-8
Questions 3-8
Label the diagrams on the following page.
Write the correct letter,
A-H
, in boxes 3-8 (IMAGE
29-34)
on your answer sheet.
A
CO2
B
Coal
C
Natural gas
D
Oil
E
Saline aquifer
F
Steam-driven turbines
G
Syngas
H
Syngas-driven turbines
3
4
5
6
7
8
Carbon dioxide sequestration

8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6285a62-5805-5b8c-a98c-c499ebe7ed5a', '53780bfb-d443-58cf-89e7-042275b12e2f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08a1a4c3-8584-5501-878f-bbe93ef438bf', '53780bfb-d443-58cf-89e7-042275b12e2f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b74939b1-5f6e-5ea5-8e85-a6b9c1b49e46', '53780bfb-d443-58cf-89e7-042275b12e2f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92db03f6-b59b-527c-8fcd-666dad1fa437', '53780bfb-d443-58cf-89e7-042275b12e2f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6137fbad-d336-50bc-8093-0dd1105b9a83', '53780bfb-d443-58cf-89e7-042275b12e2f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ac50c76-e1eb-56b9-8b72-9f41c27dfd6f', '53780bfb-d443-58cf-89e7-042275b12e2f', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42d1ce60-8dc8-5092-96e9-cc95d18179e7', '53780bfb-d443-58cf-89e7-042275b12e2f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0ea405e-d5f7-5016-86e7-55d5347c0ece', '53780bfb-d443-58cf-89e7-042275b12e2f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2597a227-1773-5dc8-93e4-e647fae6fcf2', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

Sequestration is already used in the oil and gas sector. CCS may cut 9 ____ in a short time. 10 ____ in labour, industry, and states already support CCS. Alternatives, like 11 ____ energy, take up vast amounts of space.$md$, NULL, ARRAY['.*carbon.*emissions.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('33b4b515-4a4b-5e52-a91a-da8df1a1a9c6', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

Sequestration is already used in the oil and gas sector. CCS may cut 9 ____ in a short time. 10 ____ in labour, industry, and states already support CCS. Alternatives, like 11 ____ energy, take up vast amounts of space.$md$, NULL, ARRAY['.*carbon.*emissions.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2b8f507f-691b-569d-9aeb-8a6361086834', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

Sequestration is already used in the oil and gas sector. CCS may cut 9 ____ in a short time. 10 ____ in labour, industry, and states already support CCS. Alternatives, like 11 ____ energy, take up vast amounts of space.$md$, NULL, ARRAY['.*carbon.*emissions.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d1cde5e5-ae0c-5a39-bd6c-0f6e11889f4a', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need 12 ____ . Some CCS technology is 13 ____ . Gas-driven turbines for IGCC have not been used on an industrial scale. Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions. Natural gas and solar PVs are cheaper. LCOE estimates for CCS = $0.09-15/kWh; for natural gas= 14 ____ ; and, for solar PV = $0.0849/kWh.$md$, NULL, ARRAY['.*massive.*state.*subsidies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fa5dec58-a19a-525a-87c0-668ec9936095', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need 12 ____ . Some CCS technology is 13 ____ . Gas-driven turbines for IGCC have not been used on an industrial scale. Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions. Natural gas and solar PVs are cheaper. LCOE estimates for CCS = $0.09-15/kWh; for natural gas= 14 ____ ; and, for solar PV = $0.0849/kWh.$md$, NULL, ARRAY['.*massive.*state.*subsidies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ac17454c-f110-5305-abaa-45cadd1ebb47', 'd9a05fcf-0f24-5aad-a0d2-e832fd2b385b', 14, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Complete the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes
9-14
on your answer sheet.
Advantages of CCS
Disadvantages of CCS
Sequestration is already used in the oil and gas sector.
CCS may cut
9
in a short time.
10
in labour,
industry, and states already support CCS.
Alternatives, like
11
energy, take up vast amounts of space.
The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need
12
.
Some CCS technology is
13
. Gas-driven
turbines for IGCC have not been used on an industrial scale.
Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions.
Natural gas and solar PVs are cheaper. LCOE estimates for
CCS = $0.09-15/kWh; for natural gas=
14
;
and, for solar PV = $0.0849/kWh.

The construction of new and the conversion of existing power plants and the liquefaction and transport of CO2 are very costly. While sequestration is possible, the scale would be enormous. Therefore, CCS would need 12 ____ . Some CCS technology is 13 ____ . Gas-driven turbines for IGCC have not been used on an industrial scale. Shallow underground storage may be limited; deep ocean storage is currently impossible. Geologists fear leaks in quake-prone regions. Natural gas and solar PVs are cheaper. LCOE estimates for CCS = $0.09-15/kWh; for natural gas= 14 ____ ; and, for solar PV = $0.0849/kWh.$md$, NULL, ARRAY['.*massive.*state.*subsidies.*']);

COMMIT;
