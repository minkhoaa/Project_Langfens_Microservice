BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-space-travel-and-health-1411'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-space-travel-and-health-1411';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-space-travel-and-health-1411';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-space-travel-and-health-1411';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a65142a8-b047-527f-b89e-ec6a46567a79', 'ielts-reading-space-travel-and-health-1411', $t$Space Travel and Health$t$, $md$## Space Travel and Health

Nguồn:
- Test: https://mini-ielts.com/1411/reading/space-travel-and-health
- Solution: https://mini-ielts.com/1411/view-solution/reading/space-travel-and-health$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('a060a7dd-d7d8-572e-88c8-374f66cb2cef', 'a65142a8-b047-527f-b89e-ec6a46567a79', 1, $t$Reading — Space Travel and Health$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Space Travel and Health

A. Space biomedicine is a relatively new area of research both in the USA and in Europe. Its main objectives are to study the effects of space travel on the human body, identifying the most critical medical problems, and finding solutions to those problems. Space biomedicine centers are receiving increasing direct support from NASA and/or the European Space Agency (ESA).

B. This involvement of NASA and the ESA reflects growing concern that the feasibility of travel to other planets, and beyond, is no longer limited by engineering constraints but by what the human body can actually withstand. The discovery of ice on Mars, for instance, means that there is now no necessity to design and develop a spacecraft large and powerful enough to transport the vast amounts of water needed to sustain the crew throughout journeys that may last many years. Without the necessary protection and medical treatment, however, their bodies would be devastated by the unremittingly hostile environment of space.

C. The most obvious physical changes undergone by people in zero gravity are essentially harmless; in some cases, they are even amusing. The blood and other fluids are no longer dragged down towards the feet by the gravity of Earth, so they accumulate higher up in the body, creating what is sometimes called ‘fat face`, together with the contrasting ‘chicken legs’ syndrome as the lower limbs become thinner.

D. Much more serious are the unseen consequences after months or years in space. With no gravity, there is less need for a sturdy skeleton to support the body, with the result that the bones weaken, releasing calcium into the bloodstream. This extra calcium can overload the kidneys, leading ultimately to renal failure. Muscles too lose strength through lack of use. The heart becomes smaller, losing the power to pump oxygenated blood to all parts of the body, while the lungs lose the capacity to breathe fully. The digestive system becomes less efficient, a weakened immune system is increasingly unable to prevent diseases and the high levels of solar and cosmic radiation can cause various forms of cancer.

E. To make matters worse, a wide range of medical difficulties can arise in the case of an accident or serious illness when the patient is millions of kilometers from Earth. There is simply not enough room available inside a space vehicle to include all the equipment from a hospital’s casualty unit, some of which would not work properly in space anyway. Even basic things such as a drip depend on gravity to function, while standard resuscitation techniques become ineffective if sufficient weight cannot be applied. The only solution seems to be to create extremely small medical tools and ‘smart` devices that can, for example, diagnose and treat internal injuries using ultrasound. The cost of designing and producing this kind of equipment is bound to be, well, astronomical.

F. Such considerations have led some to question the ethics of investing huge sums of money to help a handful of people who, after all, are willingly risking their own health in outer space, when so much needs to be done a lot closer to home. It is now clear, however, that every problem of space travel has a parallel problem on Earth that will benefit from the knowledge gained and the skills developed from space biomedical research. For instance, the very difficulty of treating astronauts in space has led to rapid progress in the field of telemedicine, which in turn has brought about developments that enable surgeons to communicate with patients in inaccessible parts of the world. To take another example, systems invented to sterilize wastewater onboard spacecraft could be used by emergency teams to filter contaminated water at the scene of natural disasters such as floods and earthquakes. In the same way, miniature monitoring equipment, developed to save weight in space capsules, will eventually become tiny monitors that patients on Earth can wear without discomfort wherever they go.

G. Nevertheless, there is still one major obstacle to carrying out studies into the effects of space travel: how to do so without going to the enormous expense of actually working in space. To simulate conditions in zero gravity, one tried and tested method is to work underwater, but the space biomedicine centers are also looking at other ideas. In one experiment, researchers study the weakening of bones that results from prolonged inactivity. This would involve volunteers staying in bed for three months, but the center concerned is confident there should be no great difficulty in finding people willing to spend twelve weeks lying down.AII in the name of science, of course.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage 1 has seven paragraphs A-G. Choose the correct heading for paragraphs B-E and G from the list of headings below. Write the correct member (i-x) in boxes 1—5 on your answer sheet.
List of Headings
i. The problem of dealing with emergencies in space
ii. How space biomedicine can help patients on Earth
iii. Why accidents are so common in outer space
iv. What is space biomedicine?
v. The psychological problems of astronauts
vi. Conducting space biomedical research on Earth
vii. The internal damage caused to the human body by space travel
viii. How space biomedicine First began
ix. The visible effects of space travel on the human body
x. Why space biomedicine is now necessary
Example Paragraph A Answer iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
Example Paragraph F Answer ii
5
Paragraph G

Example Paragraph A Answer iv 1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E Example Paragraph F Answer ii 5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fa31c49-9ba2-5063-8e21-6edb8b7ab1d0', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f02062f1-4849-536f-8f00-a482a03fb69c', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa8d7414-3970-53ad-b59e-7d7293ea8551', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aab4fc0-16f6-5c4f-a6e6-7760d1e2d0a1', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e1fe37b-397e-5cc9-b267-7e6b89b27196', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1654dbff-e5e2-541c-b66e-005c19e259b9', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fd357db-6eb0-526f-aa31-1a52b07bb500', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9681502-ec40-57b2-aae0-d7f786811ac7', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91edd8c8-f6bb-51cb-8029-dc7bafe6caae', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3812e504-a875-5cd1-8619-ac7e00d3cfd4', '38a842ac-0e24-5c98-bd47-6efdf0e9e67f', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage 1 has seven paragraphs A-G. Choose the correct heading for paragraphs B-E and G from the list of headings below. Write the correct member (i-x) in boxes 1—5 on your answer sheet.
List of Headings
i. The problem of dealing with emergencies in space
ii. How space biomedicine can help patients on Earth
iii. Why accidents are so common in outer space
iv. What is space biomedicine?
v. The psychological problems of astronauts
vi. Conducting space biomedical research on Earth
vii. The internal damage caused to the human body by space travel
viii. How space biomedicine First began
ix. The visible effects of space travel on the human body
x. Why space biomedicine is now necessary
Example Paragraph A Answer iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
Example Paragraph F Answer ii
5
Paragraph G

Example Paragraph A Answer iv 1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E Example Paragraph F Answer ii 5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd64ab15-5826-5cb6-9695-9988beb4dcb2', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68648773-d44c-54cd-b7cd-bf2f5846050f', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c68a5729-5c32-5587-bb5a-09a149bf07c1', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('486a6027-8236-5fdd-b0fa-339b17b52f79', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('507338e6-ad76-5b8a-a4cb-aee687d00c3a', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53ef93dc-7da6-5fb5-9b8e-e0954ccfa514', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('986804f2-20b1-59bd-b156-2f0cb813587c', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1e45bdd-eada-505e-accd-60d4dec9a92d', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6f65d55-4372-5f95-b4db-c9051a4d9e85', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('715b5e31-5103-5860-8e63-0f76a92d1490', 'c1dea934-f838-5ea4-bdcc-0ea2a1f05306', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af44f1d4-eeb1-5398-b097-f952870b2aca', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage 1 has seven paragraphs A-G. Choose the correct heading for paragraphs B-E and G from the list of headings below. Write the correct member (i-x) in boxes 1—5 on your answer sheet.
List of Headings
i. The problem of dealing with emergencies in space
ii. How space biomedicine can help patients on Earth
iii. Why accidents are so common in outer space
iv. What is space biomedicine?
v. The psychological problems of astronauts
vi. Conducting space biomedical research on Earth
vii. The internal damage caused to the human body by space travel
viii. How space biomedicine First began
ix. The visible effects of space travel on the human body
x. Why space biomedicine is now necessary
Example Paragraph A Answer iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
Example Paragraph F Answer ii
5
Paragraph G

Example Paragraph A Answer iv 1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E Example Paragraph F Answer ii 5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce41d6c8-089d-5d75-8a83-ea1b2ba9867b', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c83877d-46e0-5424-a7dc-a3709e21355f', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('097bbc63-8ee0-5f34-825d-3f113554f7ca', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d03a4e5-bd43-578d-9ca4-2e5fa4945eaa', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('155e5fdb-7288-5713-b470-ae73dac4a4c6', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d25ee84d-b234-51cb-83c8-85c8249fee03', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8b9ce37-bda2-555c-ba40-796682c7be2e', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3cded8f-8e3f-5a7d-84c1-ad97599ec87e', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1066d0df-70f7-54f7-9df1-eaf044f84c37', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e6d858f-a87d-59e0-9795-9f50d6062982', 'af44f1d4-eeb1-5398-b097-f952870b2aca', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a51cf779-fca8-5d81-a04b-39b585ee4ba2', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage 1 has seven paragraphs A-G. Choose the correct heading for paragraphs B-E and G from the list of headings below. Write the correct member (i-x) in boxes 1—5 on your answer sheet.
List of Headings
i. The problem of dealing with emergencies in space
ii. How space biomedicine can help patients on Earth
iii. Why accidents are so common in outer space
iv. What is space biomedicine?
v. The psychological problems of astronauts
vi. Conducting space biomedical research on Earth
vii. The internal damage caused to the human body by space travel
viii. How space biomedicine First began
ix. The visible effects of space travel on the human body
x. Why space biomedicine is now necessary
Example Paragraph A Answer iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
Example Paragraph F Answer ii
5
Paragraph G

Example Paragraph A Answer iv 1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E Example Paragraph F Answer ii 5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fe36724-8bb8-5971-b397-465a7c09ad1b', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2725c1cd-9de7-50fc-801a-d5e4e6b070ca', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dbae54d-b9a2-5bf8-bfec-a91fe58506a2', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e37cc2ea-2cd8-546f-952d-6972a924dd08', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29a15dde-bc11-541d-8978-8290a4091049', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e850cf54-31ba-5ffb-82c0-df264be53097', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e04eef9-d0dc-5664-955b-dbf95ca46df6', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e7fa7f8-6837-5faf-a216-663bc04fb8b8', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcfc2548-eada-58f0-a818-2d7f7f9ff97b', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7a23601-974d-5f92-a072-87181685ffc4', 'a51cf779-fca8-5d81-a04b-39b585ee4ba2', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('323441d0-cecc-592d-a7f2-2f3123c701c6', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage 1 has seven paragraphs A-G. Choose the correct heading for paragraphs B-E and G from the list of headings below. Write the correct member (i-x) in boxes 1—5 on your answer sheet.
List of Headings
i. The problem of dealing with emergencies in space
ii. How space biomedicine can help patients on Earth
iii. Why accidents are so common in outer space
iv. What is space biomedicine?
v. The psychological problems of astronauts
vi. Conducting space biomedical research on Earth
vii. The internal damage caused to the human body by space travel
viii. How space biomedicine First began
ix. The visible effects of space travel on the human body
x. Why space biomedicine is now necessary
Example Paragraph A Answer iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
Example Paragraph F Answer ii
5
Paragraph G

Example Paragraph A Answer iv 1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E Example Paragraph F Answer ii 5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('776e28b0-5ffc-5a14-a7e1-af142464c50f', '323441d0-cecc-592d-a7f2-2f3123c701c6', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eefee63-fffd-5084-8068-f5a65d29cf8d', '323441d0-cecc-592d-a7f2-2f3123c701c6', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d64a8bfa-d77f-5222-9b14-563632546d19', '323441d0-cecc-592d-a7f2-2f3123c701c6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('631dc371-38a9-5060-a668-364f0caa74d0', '323441d0-cecc-592d-a7f2-2f3123c701c6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1968e2c2-e3dc-5745-b159-a8004c97205b', '323441d0-cecc-592d-a7f2-2f3123c701c6', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d044e96-271f-5376-8e19-cac04ef81fc6', '323441d0-cecc-592d-a7f2-2f3123c701c6', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44ce1b87-0231-5bad-888a-82c7314cc860', '323441d0-cecc-592d-a7f2-2f3123c701c6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56a6b561-4976-52c1-936d-79fc2aef9b79', '323441d0-cecc-592d-a7f2-2f3123c701c6', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76e16a3f-53ef-5485-9ae8-290674421e96', '323441d0-cecc-592d-a7f2-2f3123c701c6', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2027e199-7528-52e1-b138-63a7850e33f2', '323441d0-cecc-592d-a7f2-2f3123c701c6', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fc86ffd6-6e4c-521b-a285-afaf30cbcd53', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 6-7
Questions 6-7
Answer the questions below using
NO MORE THAN THREE WORDS
for each answer.
6. Where, apart from Earth, can space travelers find water?
6
7. What happens to human legs during space travel?
7

Answer the questions below using NO MORE THAN THREE WORDS for each answer. 6. Where, apart from Earth, can space travelers find water? 6 ____ 7. What happens to human legs during space travel? 7 ____$md$, NULL, ARRAY['.*on.*','.*from.*mars.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b1f8bfdd-b807-5f3e-8ec9-e85eb7f5ebd4', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 6-7
Questions 6-7
Answer the questions below using
NO MORE THAN THREE WORDS
for each answer.
6. Where, apart from Earth, can space travelers find water?
6
7. What happens to human legs during space travel?
7

Answer the questions below using NO MORE THAN THREE WORDS for each answer. 6. Where, apart from Earth, can space travelers find water? 6 ____ 7. What happens to human legs during space travel? 7 ____$md$, NULL, ARRAY['.*on.*','.*from.*mars.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eff3d75c-d378-56a3-bcc0-7852565f5769', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Do the following statements agree with the writer’s views in Reading Passage?
Write
YES if the statement agrees with the views of the writer
NO, if the state does not agree with the views of the writer
NOT GIVEN if there is no information about this in the passage
8
The obstacles to going far into space are now medical, not technological.
9
Astronauts cannot survive more than two years in space.
10
It is morally wrong to spend so much money on space biomedicine.
11
Some kinds of surgery are more successful when performed in space.
12
Space biomedical research can only be done in space.

8 ____ The obstacles to going far into space are now medical, not technological. 9 ____ Astronauts cannot survive more than two years in space. 10 ____ It is morally wrong to spend so much money on space biomedicine. 11 ____ Some kinds of surgery are more successful when performed in space. 12 ____ Space biomedical research can only be done in space.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c315df46-4b08-569f-abde-7a18bba7d66a', 'eff3d75c-d378-56a3-bcc0-7852565f5769', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3530bd0c-ff02-5cf4-9b1a-90718fef917f', 'eff3d75c-d378-56a3-bcc0-7852565f5769', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c0a0054-e1f7-54cf-b4e4-f4097a329a67', 'eff3d75c-d378-56a3-bcc0-7852565f5769', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59257554-caae-5896-ab26-5b26c8b35433', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Do the following statements agree with the writer’s views in Reading Passage?
Write
YES if the statement agrees with the views of the writer
NO, if the state does not agree with the views of the writer
NOT GIVEN if there is no information about this in the passage
8
The obstacles to going far into space are now medical, not technological.
9
Astronauts cannot survive more than two years in space.
10
It is morally wrong to spend so much money on space biomedicine.
11
Some kinds of surgery are more successful when performed in space.
12
Space biomedical research can only be done in space.

8 ____ The obstacles to going far into space are now medical, not technological. 9 ____ Astronauts cannot survive more than two years in space. 10 ____ It is morally wrong to spend so much money on space biomedicine. 11 ____ Some kinds of surgery are more successful when performed in space. 12 ____ Space biomedical research can only be done in space.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08703dc4-e6c0-54f8-9a4d-a9bdb17d18d3', '59257554-caae-5896-ab26-5b26c8b35433', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('add624ba-29f1-5ced-a5c9-4c89d0a2b300', '59257554-caae-5896-ab26-5b26c8b35433', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a75dfac-41ac-5f95-b1d5-3aaef6c52449', '59257554-caae-5896-ab26-5b26c8b35433', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('95072552-6b0e-57cd-8ea6-da2759ad2e61', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Do the following statements agree with the writer’s views in Reading Passage?
Write
YES if the statement agrees with the views of the writer
NO, if the state does not agree with the views of the writer
NOT GIVEN if there is no information about this in the passage
8
The obstacles to going far into space are now medical, not technological.
9
Astronauts cannot survive more than two years in space.
10
It is morally wrong to spend so much money on space biomedicine.
11
Some kinds of surgery are more successful when performed in space.
12
Space biomedical research can only be done in space.

8 ____ The obstacles to going far into space are now medical, not technological. 9 ____ Astronauts cannot survive more than two years in space. 10 ____ It is morally wrong to spend so much money on space biomedicine. 11 ____ Some kinds of surgery are more successful when performed in space. 12 ____ Space biomedical research can only be done in space.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fc358f7-384b-597a-b19c-c5fb5fd915d2', '95072552-6b0e-57cd-8ea6-da2759ad2e61', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc0f0866-e0cd-58f0-8bf8-fff6290dc6ec', '95072552-6b0e-57cd-8ea6-da2759ad2e61', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('267518fa-8951-59d0-b536-5b276cdb4987', '95072552-6b0e-57cd-8ea6-da2759ad2e61', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('672d5164-4cb6-5041-b126-51e77863f1e0', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Do the following statements agree with the writer’s views in Reading Passage?
Write
YES if the statement agrees with the views of the writer
NO, if the state does not agree with the views of the writer
NOT GIVEN if there is no information about this in the passage
8
The obstacles to going far into space are now medical, not technological.
9
Astronauts cannot survive more than two years in space.
10
It is morally wrong to spend so much money on space biomedicine.
11
Some kinds of surgery are more successful when performed in space.
12
Space biomedical research can only be done in space.

8 ____ The obstacles to going far into space are now medical, not technological. 9 ____ Astronauts cannot survive more than two years in space. 10 ____ It is morally wrong to spend so much money on space biomedicine. 11 ____ Some kinds of surgery are more successful when performed in space. 12 ____ Space biomedical research can only be done in space.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f73aade7-be6c-51ee-bb16-dd23444ea8fb', '672d5164-4cb6-5041-b126-51e77863f1e0', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8663bd0-082b-5677-b60c-5f62dd5dc4d8', '672d5164-4cb6-5041-b126-51e77863f1e0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e15a7a32-123d-57a0-a01f-6008a2ddbbfb', '672d5164-4cb6-5041-b126-51e77863f1e0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1199b6df-8ca1-50a0-9e3e-f77aea61a316', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Do the following statements agree with the writer’s views in Reading Passage?
Write
YES if the statement agrees with the views of the writer
NO, if the state does not agree with the views of the writer
NOT GIVEN if there is no information about this in the passage
8
The obstacles to going far into space are now medical, not technological.
9
Astronauts cannot survive more than two years in space.
10
It is morally wrong to spend so much money on space biomedicine.
11
Some kinds of surgery are more successful when performed in space.
12
Space biomedical research can only be done in space.

8 ____ The obstacles to going far into space are now medical, not technological. 9 ____ Astronauts cannot survive more than two years in space. 10 ____ It is morally wrong to spend so much money on space biomedicine. 11 ____ Some kinds of surgery are more successful when performed in space. 12 ____ Space biomedical research can only be done in space.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d55dbd5e-c2e1-55e2-8952-7ff5bbbca066', '1199b6df-8ca1-50a0-9e3e-f77aea61a316', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c077675-9f4a-5725-8689-554b25c43461', '1199b6df-8ca1-50a0-9e3e-f77aea61a316', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aedd21ce-7272-5ca7-9458-a53fd5799b84', '1199b6df-8ca1-50a0-9e3e-f77aea61a316', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a5ca77b2-5d3e-5cfd-ae85-73750d5aae91', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Complete the table below. Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Research area
Application in space
Application on Earth
Telemedicine
treating astronauts
13
in remote areas
Sterilization
sterilizing wastewater
14
in disaster zones
Miniaturization
saving weight
wearing small monitors comfortably

13 ____ in remote areas$md$, NULL, ARRAY['.*communicate.*with.*patients.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('24d59879-8d17-5c06-8cd6-593189910ce3', 'a060a7dd-d7d8-572e-88c8-374f66cb2cef', 14, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Complete the table below. Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Research area
Application in space
Application on Earth
Telemedicine
treating astronauts
13
in remote areas
Sterilization
sterilizing wastewater
14
in disaster zones
Miniaturization
saving weight
wearing small monitors comfortably

14 ____ in disaster zones$md$, NULL, ARRAY['.*filter.*contaminated.*water.*']);

COMMIT;
