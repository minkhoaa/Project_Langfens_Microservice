BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-eco-resort-management-1184'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-eco-resort-management-1184';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-eco-resort-management-1184';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-eco-resort-management-1184';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4dfe47cd-dc01-580c-bbd0-e4156f071e0a', 'ielts-reading-eco-resort-management-1184', $t$Eco-Resort Management$t$, $md$## Eco-Resort Management

Nguồn:
- Test: https://mini-ielts.com/1184/reading/eco-resort-management
- Solution: https://mini-ielts.com/1184/view-solution/reading/eco-resort-management$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', '4dfe47cd-dc01-580c-bbd0-e4156f071e0a', 1, $t$Reading — Eco-Resort Management$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Eco-Resort Management

A Ecotourism is often regarded as a form of nature-based tourism and has become an important alternative source of tourists. In addition to providing the traditional resort-leisure product, it has been argued that ecotourism resort management should have a particular focus on best-practice environmental management, an educational and interpretive component, and direct and indirect contributions to the conservation of the natural and cultural environment (Ayala, 1996).

B Couran Cove Island Resort is a large integrated ecotourism-based resort located south of Brisbane on the Gold Coast, Queensland, Australia. As the world’s population becomes increasingly urbanised, the demand for tourist attractions which are environmentally friendly, serene and offer amenities of a unique nature, has grown rapidly. Couran Cove Resort, which is one such tourist attractions, is located on South Stradbroke Island, occupying approximately 150 hectares of the island. South Stradbroke Island is separated from the mainland by the Broadwater, a stretch of sea 3 kilometers wide. More than a century ago, there was only one Stradbroke Island, and there were at least four aboriginal tribes living and hunting on the island. Regrettably, most of the original island dwellers were eventually killed by diseases such as tuberculosis, smallpox and influenza by the end of the 19 th The second ship wreak on the island in 1894, and the subsequent destruction of the ship (the Cambus Wallace) because it contained dynamite , caused a large crater in the sandhills on Stradbroke Island. Eventually, the ocean broke through the weakened land form and Stradbroke became two islands. Couran Cove Island Resort is built on one of the world’s few naturally-occurring sand lands, which is home to a wide range of plant communities and one of the largest remaining remnants of the rare livistona rainforest left on the Gold Coast. Many mangrove and rainforest areas, and Malaleuca Wetlands on South Stradbroke Island (and in Queensland), have been cleared, drained or filled for residential, industrial, agricultural or urban development in the first half of the 20th century. Farmer and graziers finally abandoned South Stradbroke Island in 1939 because the vegetation and the soil conditions there were not suitable for agricultural activities.

SUSTAINABLE PRACTICES OF COURAN COVE RESORT

Being located on an offshore island, the resort is only accessible by means of water transportation . The resort provides hourly ferry service from the marina on the mainland to and from the island. Within the resort, transport modes include walking trails, bicycle tracks and the beach train. The reception area is the counter of the shop which has not changed in 8 years at least. The accommodation is an octagonal “Bure”. These are large rooms that are clean but! The equipment is tired and in some cases just working. Our ceiling fan only worked on high speed for example. Beds are hard but clean, there is television, radio, an old air conditioner and a small fridge. These “Bures” are right on top of each other and night noises do carry so be careful what you say and do. The only thing is the mosquitos but if you forget to bring mosquito repellant they sell some on the island.

As an ecotourism-based resort, most of the planning and development of the attraction has been concentrated on the need to co-exist with the fragile natural environment of South Stradbroke Island to achieve sustainable development.

WATER AND ENERGY MANAGEMENT

C South Stradbroke Island has groundwater at the centre of the island, which has a maximum height of 3 metres above sea level. The water supply is recharged by rainfall and is commonly known as an unconfined freshwater aquifer. Couran Cove Island Resort obtains its water supply by tapping into this aquifer and extracting it via a bore system . Some of the problems which have threatened the island’s freshwater supply include pollution, contamination and over-consumption. In order to minimise some of these problems, all laundry activities are carried out on the mainland . The resort considers washing machines as onerous to the island’s freshwater supply, and that the detergents contain a high level of phosphates which are a major source of water pollution. The resort uses LPG-power generation rather than a diesel-powered plant for its energy supply, supplemented by wind turbine, which has reduced greenhouse emissions by 70% of diesel-equivalent generation methods. Excess heat recovered from the generator is used to heat the swimming pool. Hot water in the -cabins and for some of the resort’s vehicles are solar-powered . Water efficient fittings are also installed in showers and toilets. However, not all the appliances used by the resort are energy efficient, such as refrigerators. Visitors who stay at the resort are encouraged to monitor their water and energy usage via the in-house television system, and are rewarded with prizes (such as a free return trip to the resort) accordingly if their usage level is low.

CONCLUDING REMARKS

D We examined a case study of good management practice and a pro-active sustainable tourism stance of an eco-resort. In three years of operation, Couran Cove Island Resort has won 23 international and national awards, including the 2001 Australian Tourism Award in the 4-Star Accommodation category. The resort has embraced and has effectively implemented contemporary environmental management practices . It has been argued that the successful implementation of the principles of sustainability should promote long-term social, economic and environmental benefits , while ensuring and enhancing the prospects of continued viability for the tourism enterprise. Couran Cove Island Resort does not conform to the characteristics of the ResortDevelopmentSpectrum, as proposed by Prideaux (2000). According to Prideaux, the resort should be at least at Phase 3 of the model (the National tourism phase), which describes an integrated resort providing 3-4 star hotel-type accommodation. The primary tourist market in Phase 3 of the model consists mainly of interstate visitors. However, the number of interstate and international tourists visiting the resort is small, with the principal visitor markets comprising locals and residents from nearby towns and the Gold Coast region. The carrying capacity of Couran Cove does not seem to be of any concern to the Resort management. Given that it is a private commercial ecotourist enterprise, regulating the number of visitors to the resort to minimize damage done to the natural environment on South Stradbroke Island is not a binding constraint. However, the Resort’s growth will eventually be constrained by its carrying capacity, and quantity control should be incorporated in the management strategy of the resort .$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cd3c80ae-c198-5bc8-a96d-796f132765ee', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes 27
-31
on your answers sheet.
1
The Stradbroke became two islands
A
by an intended destruction of the ship of the Cambus Wallace
B
by an explosion of dynamite on a ship and following nature erosion
C
by the movement sandhills on Stradbroke Island
D
by the volcanic eruption on island
Locate
2
Why are laundry activities for the resort carried out on the mainland
A
In order to obtain its water supply via a bore system
B
In order to preserve the water and anti-pollution
C
In order to save the cost of installing onerous washing machines
D
In order to reduce the level of phosphates in water around
Locate
3
What is the major water supplier in South Stradbroke Island is by
A
desalinizing the sea water
B
collecting the rainfall
C
transporting from the mainland
D
boring ground water
Locate
4
What is applied for heating water on Couran Cove Island Resort
A
the LPG-power
B
a diesel-powered plant
C
the wind power
D
the solar-power
Locate
5
What does, as the managers of resorts believe, the prospective future focus on
A
more awards of for resort’s accommodation
B
sustainable administration and development in a long run
C
Economic and environmental benefits for the tourism enterprise
D
successful implementation the Resort Development Spectrum
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d36205a7-f3a7-570b-8350-75d4173ed21f', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes 27
-31
on your answers sheet.
1
The Stradbroke became two islands
A
by an intended destruction of the ship of the Cambus Wallace
B
by an explosion of dynamite on a ship and following nature erosion
C
by the movement sandhills on Stradbroke Island
D
by the volcanic eruption on island
Locate
2
Why are laundry activities for the resort carried out on the mainland
A
In order to obtain its water supply via a bore system
B
In order to preserve the water and anti-pollution
C
In order to save the cost of installing onerous washing machines
D
In order to reduce the level of phosphates in water around
Locate
3
What is the major water supplier in South Stradbroke Island is by
A
desalinizing the sea water
B
collecting the rainfall
C
transporting from the mainland
D
boring ground water
Locate
4
What is applied for heating water on Couran Cove Island Resort
A
the LPG-power
B
a diesel-powered plant
C
the wind power
D
the solar-power
Locate
5
What does, as the managers of resorts believe, the prospective future focus on
A
more awards of for resort’s accommodation
B
sustainable administration and development in a long run
C
Economic and environmental benefits for the tourism enterprise
D
successful implementation the Resort Development Spectrum
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0aab282f-d036-5099-9be9-a51d9bf29713', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes 27
-31
on your answers sheet.
1
The Stradbroke became two islands
A
by an intended destruction of the ship of the Cambus Wallace
B
by an explosion of dynamite on a ship and following nature erosion
C
by the movement sandhills on Stradbroke Island
D
by the volcanic eruption on island
Locate
2
Why are laundry activities for the resort carried out on the mainland
A
In order to obtain its water supply via a bore system
B
In order to preserve the water and anti-pollution
C
In order to save the cost of installing onerous washing machines
D
In order to reduce the level of phosphates in water around
Locate
3
What is the major water supplier in South Stradbroke Island is by
A
desalinizing the sea water
B
collecting the rainfall
C
transporting from the mainland
D
boring ground water
Locate
4
What is applied for heating water on Couran Cove Island Resort
A
the LPG-power
B
a diesel-powered plant
C
the wind power
D
the solar-power
Locate
5
What does, as the managers of resorts believe, the prospective future focus on
A
more awards of for resort’s accommodation
B
sustainable administration and development in a long run
C
Economic and environmental benefits for the tourism enterprise
D
successful implementation the Resort Development Spectrum
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1e194ce-4580-59ae-a368-e1757cc2b521', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes 27
-31
on your answers sheet.
1
The Stradbroke became two islands
A
by an intended destruction of the ship of the Cambus Wallace
B
by an explosion of dynamite on a ship and following nature erosion
C
by the movement sandhills on Stradbroke Island
D
by the volcanic eruption on island
Locate
2
Why are laundry activities for the resort carried out on the mainland
A
In order to obtain its water supply via a bore system
B
In order to preserve the water and anti-pollution
C
In order to save the cost of installing onerous washing machines
D
In order to reduce the level of phosphates in water around
Locate
3
What is the major water supplier in South Stradbroke Island is by
A
desalinizing the sea water
B
collecting the rainfall
C
transporting from the mainland
D
boring ground water
Locate
4
What is applied for heating water on Couran Cove Island Resort
A
the LPG-power
B
a diesel-powered plant
C
the wind power
D
the solar-power
Locate
5
What does, as the managers of resorts believe, the prospective future focus on
A
more awards of for resort’s accommodation
B
sustainable administration and development in a long run
C
Economic and environmental benefits for the tourism enterprise
D
successful implementation the Resort Development Spectrum
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f24fc390-e7ca-509c-af00-1a04d8e38f77', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes 27
-31
on your answers sheet.
1
The Stradbroke became two islands
A
by an intended destruction of the ship of the Cambus Wallace
B
by an explosion of dynamite on a ship and following nature erosion
C
by the movement sandhills on Stradbroke Island
D
by the volcanic eruption on island
Locate
2
Why are laundry activities for the resort carried out on the mainland
A
In order to obtain its water supply via a bore system
B
In order to preserve the water and anti-pollution
C
In order to save the cost of installing onerous washing machines
D
In order to reduce the level of phosphates in water around
Locate
3
What is the major water supplier in South Stradbroke Island is by
A
desalinizing the sea water
B
collecting the rainfall
C
transporting from the mainland
D
boring ground water
Locate
4
What is applied for heating water on Couran Cove Island Resort
A
the LPG-power
B
a diesel-powered plant
C
the wind power
D
the solar-power
Locate
5
What does, as the managers of resorts believe, the prospective future focus on
A
more awards of for resort’s accommodation
B
sustainable administration and development in a long run
C
Economic and environmental benefits for the tourism enterprise
D
successful implementation the Resort Development Spectrum
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c83aa05b-c5ce-500a-99d0-8451b7273eb6', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Complete the following summary of the Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Being located away from the mainland, tourists can attain the resort only by
6
in a regular service. Within the resort, transports include trails for walking or tracks for both
7
and the beach train. The on-island equipment is old-fashioned which is barely working such as the
8
overhead. There is television, radio, an old
9
and a small fridge. And you can buy the repellant for
10
if you forget to bring some.
Locate
Locate
Locate
Locate
Locate

Being located away from the mainland, tourists can attain the resort only by 6 ____ in a regular service. Within the resort, transports include trails for walking or tracks for both 7 ____ and the beach train. The on-island equipment is old-fashioned which is barely working such as the 8 ____ overhead. There is television, radio, an old 9 ____ and a small fridge. And you can buy the repellant for 10 ____ if you forget to bring some.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('368718d4-eb4b-508c-962f-e34cbfa01efc', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Complete the following summary of the Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Being located away from the mainland, tourists can attain the resort only by
6
in a regular service. Within the resort, transports include trails for walking or tracks for both
7
and the beach train. The on-island equipment is old-fashioned which is barely working such as the
8
overhead. There is television, radio, an old
9
and a small fridge. And you can buy the repellant for
10
if you forget to bring some.
Locate
Locate
Locate
Locate
Locate

Being located away from the mainland, tourists can attain the resort only by 6 ____ in a regular service. Within the resort, transports include trails for walking or tracks for both 7 ____ and the beach train. The on-island equipment is old-fashioned which is barely working such as the 8 ____ overhead. There is television, radio, an old 9 ____ and a small fridge. And you can buy the repellant for 10 ____ if you forget to bring some.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b65a504-6789-5147-9ec9-4afe19cf0f24', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Complete the following summary of the Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Being located away from the mainland, tourists can attain the resort only by
6
in a regular service. Within the resort, transports include trails for walking or tracks for both
7
and the beach train. The on-island equipment is old-fashioned which is barely working such as the
8
overhead. There is television, radio, an old
9
and a small fridge. And you can buy the repellant for
10
if you forget to bring some.
Locate
Locate
Locate
Locate
Locate

Being located away from the mainland, tourists can attain the resort only by 6 ____ in a regular service. Within the resort, transports include trails for walking or tracks for both 7 ____ and the beach train. The on-island equipment is old-fashioned which is barely working such as the 8 ____ overhead. There is television, radio, an old 9 ____ and a small fridge. And you can buy the repellant for 10 ____ if you forget to bring some.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a90d19f2-e268-5fa1-af60-5023b45cc6e4', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Complete the following summary of the Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Being located away from the mainland, tourists can attain the resort only by
6
in a regular service. Within the resort, transports include trails for walking or tracks for both
7
and the beach train. The on-island equipment is old-fashioned which is barely working such as the
8
overhead. There is television, radio, an old
9
and a small fridge. And you can buy the repellant for
10
if you forget to bring some.
Locate
Locate
Locate
Locate
Locate

Being located away from the mainland, tourists can attain the resort only by 6 ____ in a regular service. Within the resort, transports include trails for walking or tracks for both 7 ____ and the beach train. The on-island equipment is old-fashioned which is barely working such as the 8 ____ overhead. There is television, radio, an old 9 ____ and a small fridge. And you can buy the repellant for 10 ____ if you forget to bring some.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc957813-19e9-583c-9b20-c31a94f2c05e', '4fe97af6-c65f-57bd-b3ac-bfb95b6ee8ed', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Complete the following summary of the Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Being located away from the mainland, tourists can attain the resort only by
6
in a regular service. Within the resort, transports include trails for walking or tracks for both
7
and the beach train. The on-island equipment is old-fashioned which is barely working such as the
8
overhead. There is television, radio, an old
9
and a small fridge. And you can buy the repellant for
10
if you forget to bring some.
Locate
Locate
Locate
Locate
Locate

Being located away from the mainland, tourists can attain the resort only by 6 ____ in a regular service. Within the resort, transports include trails for walking or tracks for both 7 ____ and the beach train. The on-island equipment is old-fashioned which is barely working such as the 8 ____ overhead. There is television, radio, an old 9 ____ and a small fridge. And you can buy the repellant for 10 ____ if you forget to bring some.$md$, NULL);

COMMIT;
