BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-digital-diet-1482'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-digital-diet-1482';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-digital-diet-1482';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-digital-diet-1482';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4c72aff0-f320-5e25-a177-a47740535f4a', 'ielts-reading-digital-diet-1482', $t$Digital diet$t$, $md$## Digital diet

Nguồn:
- Test: https://mini-ielts.com/1482/reading/digital-diet
- Solution: https://mini-ielts.com/1482/view-solution/reading/digital-diet$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('75d0b74a-0634-56eb-8135-9b85a7c4347b', '4c72aff0-f320-5e25-a177-a47740535f4a', 1, $t$Reading — Digital diet$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Digital diet

{A} Telecommuting, Internet shopping and online meetings may save energy as compared with in-person alternatives, but as the digital age moves on, its green reputation is turning a lot browner. E-mailing, number crunching and Web searches in the U.S. consumed as much as 61 billion kilowatt-hours last year, or 1.5 per cent of the nation’s electricity-half of which comes from coal. In 2005 the computers of the world ate up 123 billion kilowatt-hours of energy, a number that will double by 2010 if present trends continue, according to Jonathan Koomey, a staff scientist at Lawrence Berkeley National Laboratory. As a result, the power bill to run a computer over its lifetime will surpass the cost of buying the machine in the first place giving Internet and computer companies a business reason to cut energy costs, as well as an environmental one.

{B} One of the biggest energy sinks comes not from the computers themselves but from the air-conditioning needed to keep them from overheating. For every kilowatt-hour of energy used for computing in a data centre, another kilowatt-hour is required to cool the furnace-like racks of servers.

{C} For Internet giant Google, this reality has driven efforts such as the installation of a solar array that can provide 30 per cent of the peak power needs of its Mountain View, Calif ., headquarters as well as increased purchases of renewable energy. But to deliver Web pages within seconds, the firm must maintain hundreds of thousands of computer servers in cavernous buildings. “It’s a good thing to worry about server energy efficiency,” remarks Google’s green energy czar Bill Weihl. “We are actively working to maximize the efficiency of our data centres, which account for most of the energy Google consumes worldwide.” Google will funnel some of its profits into a new effort, dubbed RE<C (for renewable energy cheaper than coal, as Google translates it) to make sources such as solar-thermal, high-altitude wind and geothermal cheaper than coal “within years, not decades, according to Weihl. .

{D} In the meantime, the industry as a whole has employed a few tricks to save watts. Efforts include cutting down on the number of transformations the electricity itself must undergo before achieving the correct operating voltage; rearranging the stacks of servers and the mechanics of their cooling; and using software to create multiple “virtual” computers, rather than having to deploy several real ones. Such virtualization has allowed computer maker Hewlett-Packard to consolidate 86 data centers spread throughout the world to just three, with three backups, says Pat Tiernan, the firm’s vice president of social and environmental responsibility.

{E} The industry is also tackling the energy issue at the computer-chip level. With every doubling of processing power in recent years has come a doubling in power consumption. But to save energy, chipmakers such as Intel and AMD have shifted to so-called multicore technology, which packs multiple processors into one circuit rather than separating them. “When we moved to multicore-away from a linear focus on megahertz and gigahertz—and throttled down microprocessors, the energy savings were pretty substantial,” says Allyson Klein, Intel’s marketing manager for its Ecotech Initiative. Chipmakers continue to shrink circuits on the nanoscale as well, which means a chip needs less electricity” to deliver the same performance, she adds.

{F} With such chips, more personal computers will meet various efficiency standards, such as Energy Star compliance (which mandates that a desktop consume no more than 65 watts). The federal government, led by agencies such as NASA and the Department of Defense may soon require all their purchases to meet the Electronic Product Environmental Assessment Tool standard. And Google, Intel and others have formed the Climate Savers Computing Initiative, an effort to cut power consumption from all computers by 50 per cent by 2010.

{G} Sleep modes and other power management tools built into most operating systems can offer savings today. Yet about 90 per cent of computers do not have such settings enabled, according to Klein. Properly activated, they would prevent a computer from leading to the emission of thousands of kilograms of carbon dioxide from power plants every year. But if powering down or unplugging the computer (the only way it uses zero power) is not an option, then perhaps the most environmentally friendly use of all those wasted computing cycles is in helping to model climate change. The University of Oxford’s ClimatePrediction.net offers an opportunity to at least predict the consequences of all that coal burning.

{H} CO2 Stats is a free tool that can be embedded into any Website to calculate the carbon dioxide emissions associated with using it. That estimate is based on an assumption of 300 watts of power consumed by the personal computer, network and server involved- or 16.5 milligrams of CO2 emitted every second of use. “The typical carbon footprint is roughly equivalent to 1.5 people breathing,” says physicist Alexander Wissner-Gross of Harvard University, who co-created the Web tool.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08df5be4-f5fd-5028-9d8d-799df9e1b64b', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

1 ____ Figuring ways to optimize the utilization of energy in certain significant departments in the company$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4b6a054-e637-5db7-8c95-e809d3c0966d', '08df5be4-f5fd-5028-9d8d-799df9e1b64b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca0b5559-01f6-536f-9d5b-24ef9b8ea504', '08df5be4-f5fd-5028-9d8d-799df9e1b64b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc33e731-20f4-59c4-80ba-3e7e621a1a2e', '08df5be4-f5fd-5028-9d8d-799df9e1b64b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f86d648a-8cad-5493-815e-0099f00fc0b6', '08df5be4-f5fd-5028-9d8d-799df9e1b64b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6dab6f6-b551-5099-be8d-290fd93fe048', '08df5be4-f5fd-5028-9d8d-799df9e1b64b', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

2 ____ A revolutionary improvement in a tiny but quite imperative component of the computers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3608ea7a-81a5-5236-a615-5efcb0e75734', '4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc8dd640-d221-5bca-90d0-164906026c78', '4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d1c4846-10b1-5228-bb7e-3b97795e22d7', '4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeaf9ced-6766-5aad-89dc-f4a3738d5270', '4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b685817c-e703-5362-bfc3-14a8a009b193', '4f4243fb-a6cf-5c5c-9df4-e7f3a467e8b2', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0753b78-f8fd-5263-827b-995f1f27fe20', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

3 ____ Targeting at developing alternative sources within the near future$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed9b08cf-41cc-5699-b0cd-146e3ee3b9cf', 'e0753b78-f8fd-5263-827b-995f1f27fe20', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2203c3be-ca53-5057-8bbb-b1501aa051bd', 'e0753b78-f8fd-5263-827b-995f1f27fe20', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dd44443-18a1-5fe7-b94e-bb81dda9a0c1', 'e0753b78-f8fd-5263-827b-995f1f27fe20', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72d2e5b5-b353-5e0e-a64b-4180a3ad1cbf', 'e0753b78-f8fd-5263-827b-995f1f27fe20', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b31724fb-d9c8-5edb-88bd-db7f377ad0e6', 'e0753b78-f8fd-5263-827b-995f1f27fe20', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0b7dd39b-cc02-5e78-8610-3f655bacf1db', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

4 ____ An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a04d1cf-f24d-546c-a22f-c3cabe21024e', '0b7dd39b-cc02-5e78-8610-3f655bacf1db', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff6b8f38-7d13-5e6f-ad1c-590b99429d23', '0b7dd39b-cc02-5e78-8610-3f655bacf1db', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a81e237e-1589-56c2-86d9-ffc4edd83b69', '0b7dd39b-cc02-5e78-8610-3f655bacf1db', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f51140f2-92fd-58c1-818a-96948164dd67', '0b7dd39b-cc02-5e78-8610-3f655bacf1db', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f25231f-4795-5dc2-a16d-829b59a12721', '0b7dd39b-cc02-5e78-8610-3f655bacf1db', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

5 ____ A powerful technique developed for integration of resources$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b99c7de5-161a-5a55-a4e6-713be9a8a968', '17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cefdba6-c62d-55dd-9725-512063d8967a', '17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7ed0115-5c67-55c1-8a62-5b9ba9d8682a', '17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d90687b-5bcc-51d3-a33e-c6375be0c71f', '17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f9d8585-1133-563f-b413-1cc2a6b144f4', '17ca7a90-20e4-59ea-86ab-3eb7dc4dd17b', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1d59d21-5685-50f8-8b92-ced725cd50d2', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters A-E in boxes 1-6 on your answer sheet.
NB you may use any letter
more than once
(A) Jonathan Koomey
(B) Allyson Klein
(C) Pat Tiernan
(D) Bill Weihl
(E) Alexander Wissner-Gross
1
Figuring ways to optimize the utilization of energy in certain significant departments in the company
2
A revolutionary improvement in a tiny but quite imperative component of the computers
3
Targeting at developing alternative sources within the near future
4
An astounding estimate on the energy to be consumed by computers in a short period based on an unchangeable trend
5
A powerful technique developed for integration of resources
6
A failure for the vast majority of computers to activate the use of some internal tools already available in them

6 ____ A failure for the vast majority of computers to activate the use of some internal tools already available in them$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d41fa32e-9969-56ff-ad8d-1771b0e140f2', 'e1d59d21-5685-50f8-8b92-ced725cd50d2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21dbefa8-8619-505c-a417-87965a7f5eb1', 'e1d59d21-5685-50f8-8b92-ced725cd50d2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('082ca39a-6c19-54aa-b310-56aa9c6501c9', 'e1d59d21-5685-50f8-8b92-ced725cd50d2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b60b432a-7cf3-5396-a658-1a9e57a2ca91', 'e1d59d21-5685-50f8-8b92-ced725cd50d2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a4da1f8-25b7-5938-b727-eb472ef7d782', 'e1d59d21-5685-50f8-8b92-ced725cd50d2', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2f2e75b-e429-5a55-90c0-a9fd851eabc5', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage? In boxes 7-10 on your answer sheet, write
True
if the statement is true
False
if the statement is false
NOT GIVEN
if there is no information about this in the passage
7
To chill the server does not take up the considerable amount of energy needed for the computer.
8
It seems that the number of servers has a severe impact on the speed of the internet connection.
9
Several companies from other fields have a joint effort with the internet industry to work on ways to save energy.
10
Actions taken at a governmental level are to be expected to help with savings in energy in the near future.

7 ____ To chill the server does not take up the considerable amount of energy needed for the computer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4ae3254-3bb4-5d0f-a572-a79f0253024b', 'a2f2e75b-e429-5a55-90c0-a9fd851eabc5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c80034b8-eefa-57f0-bb0c-24a3d8aebddc', 'a2f2e75b-e429-5a55-90c0-a9fd851eabc5', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45081dae-97f9-5e6d-b025-208b388550c0', 'a2f2e75b-e429-5a55-90c0-a9fd851eabc5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7621b997-175f-5699-bec6-e3174a62e4fb', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage? In boxes 7-10 on your answer sheet, write
True
if the statement is true
False
if the statement is false
NOT GIVEN
if there is no information about this in the passage
7
To chill the server does not take up the considerable amount of energy needed for the computer.
8
It seems that the number of servers has a severe impact on the speed of the internet connection.
9
Several companies from other fields have a joint effort with the internet industry to work on ways to save energy.
10
Actions taken at a governmental level are to be expected to help with savings in energy in the near future.

8 ____ It seems that the number of servers has a severe impact on the speed of the internet connection.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8dc3ad3-ef40-540c-bc83-d2af7da259ed', '7621b997-175f-5699-bec6-e3174a62e4fb', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04a3239e-7e34-5cd0-94f3-282d1bbb633d', '7621b997-175f-5699-bec6-e3174a62e4fb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5f77f22-c8eb-5301-b871-2006a7618c43', '7621b997-175f-5699-bec6-e3174a62e4fb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd4306da-59b4-50c6-b5ca-32a8183f3e11', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage? In boxes 7-10 on your answer sheet, write
True
if the statement is true
False
if the statement is false
NOT GIVEN
if there is no information about this in the passage
7
To chill the server does not take up the considerable amount of energy needed for the computer.
8
It seems that the number of servers has a severe impact on the speed of the internet connection.
9
Several companies from other fields have a joint effort with the internet industry to work on ways to save energy.
10
Actions taken at a governmental level are to be expected to help with savings in energy in the near future.

9 ____ Several companies from other fields have a joint effort with the internet industry to work on ways to save energy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b5c884c-29fb-57e3-a2e9-34c0e7576c7a', 'fd4306da-59b4-50c6-b5ca-32a8183f3e11', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39f5479d-de5c-5500-9cb3-aff1f30be2b4', 'fd4306da-59b4-50c6-b5ca-32a8183f3e11', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69b824e7-ab28-5f2f-b3a0-a2f96ab67632', 'fd4306da-59b4-50c6-b5ca-32a8183f3e11', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c25b10a-6be6-5811-a8e5-c35d71a71932', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage? In boxes 7-10 on your answer sheet, write
True
if the statement is true
False
if the statement is false
NOT GIVEN
if there is no information about this in the passage
7
To chill the server does not take up the considerable amount of energy needed for the computer.
8
It seems that the number of servers has a severe impact on the speed of the internet connection.
9
Several companies from other fields have a joint effort with the internet industry to work on ways to save energy.
10
Actions taken at a governmental level are to be expected to help with savings in energy in the near future.

10 ____ Actions taken at a governmental level are to be expected to help with savings in energy in the near future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('681b9317-aae1-597c-80a6-b20f3a259663', '8c25b10a-6be6-5811-a8e5-c35d71a71932', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdc2b2c4-5782-58e9-af3b-08271a6214e9', '8c25b10a-6be6-5811-a8e5-c35d71a71932', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46d515b8-54ec-5997-b48a-18d660a08aed', '8c25b10a-6be6-5811-a8e5-c35d71a71932', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ef65400b-2199-5a38-adf8-bd29cab03d0f', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
The
11
has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to
12
which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to
13
on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the
14
.

The 11 ____ has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to 12 ____ which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to 13 ____ on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the 14 ____ .$md$, NULL, ARRAY['.*computer.*chip.*level.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('138aaef8-515a-5d2c-9855-129dc75081e2', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
The
11
has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to
12
which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to
13
on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the
14
.

The 11 ____ has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to 12 ____ which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to 13 ____ on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the 14 ____ .$md$, NULL, ARRAY['.*computer.*chip.*level.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b93f0309-8707-5e78-b65c-2229ad1252c8', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
The
11
has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to
12
which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to
13
on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the
14
.

The 11 ____ has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to 12 ____ which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to 13 ____ on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the 14 ____ .$md$, NULL, ARRAY['.*computer.*chip.*level.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('93c57636-c805-568a-b9c9-6111c523db96', '75d0b74a-0634-56eb-8135-9b85a7c4347b', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
The
11
has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to
12
which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to
13
on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the
14
.

The 11 ____ has also been reached to save up energy in every possible way and the philosophy behind it lies in the fact that there is a positive correlation between the ability to process and the need for energy. In this context, some firms have switched to 12 ____ which means several processors are integrated into one single circuit to make significant energy savings. What is more, they go on to 13 ____ on an even more delicate level for the chips to save more energy while staying at the constant level in terms of the 14 ____ .$md$, NULL, ARRAY['.*computer.*chip.*level.*']);

COMMIT;
