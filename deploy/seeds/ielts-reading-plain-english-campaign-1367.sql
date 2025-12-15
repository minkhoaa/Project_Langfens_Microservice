BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-plain-english-campaign-1367'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-plain-english-campaign-1367';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-plain-english-campaign-1367';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-plain-english-campaign-1367';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ab5f2465-cb2f-5ad6-b436-e9874fe9477f', 'ielts-reading-plain-english-campaign-1367', $t$Plain English Campaign$t$, $md$## Plain English Campaign

Nguồn:
- Test: https://mini-ielts.com/1367/reading/plain-english-campaign
- Solution: https://mini-ielts.com/1367/view-solution/reading/plain-english-campaign$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('bc5126c4-1fbc-521b-8515-12d1f7e80371', 'ab5f2465-cb2f-5ad6-b436-e9874fe9477f', 1, $t$Reading — Plain English Campaign$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Plain English Campaign

A

We launched Plain English Campaign in 1979 with a ritual shredding of appalling government and municipal council forms in Parliament Square, London. We had become so fed up of people visiting our advice centre in Salford, Greater Manchester, to complain about incomprehensible forms that we thought we ought to take action. At the time the shredding seemed like merely throwing sand in the eyes of the charging lion, but it briefly caught the public imagination and left an impression on government and business. Although we’re pleased with the new plain English awareness in government departments, many local councils and businesses maintain a stout resistance to change. One council began a letter to its tenants about a rent increase with two sentences averaging 95 words, full of bizarre housing finance jargon and waffle about Acts of Parliament. The London Borough of Ealing sent such an incomprehensible letter to ISO residents that 40 of them wrote or telephoned to complain and ask for clarification. Many were upset and frightened that the council was planning to imprison them if they didn’t fill in the accompanying form. In fact, the letter meant nothing of the sort, and the council had to send another letter to explain.

B

Plain legal English can be used as a marketing tactic. Provincial Insurance issued their plain English Home Cover policy in 1983 and sold it heavily as such. In the first 18 months, its sales rocketed, drawing in about an extra £1.5 million of business. Recently, the Eagle Star Group launched a plain English policy to a chorus of congratulatory letters from policyholders. People, it seems, prefer to buy a policy they can understand.

C

Two kinds of instructions give us a lot of concern – medical labels and do-it-yourself products. With medical labels, there is a serious gap between what the professionals think is clear and what is really clear to patients. A survey by pharmacists Raynor and Sillito found that 31% of patients misunderstood the instruction on eye drops ‘To be instilled’, while 33% misunderstood ‘Use sparingly’. The instruction ‘Take two tablets 4 hourly’ is so prone to misunderstanding (for example, as 8 tablets an hour) that we think it should be banned. Unclear instructions on do-it-yourself products cause expense and frustration to customers. Writing the necessary instructions for these products is usually entrusted to someone who knows the product inside out, yet the best qualification for writing instructions is ignorance. The writer is then like a first-time user, discovering how to use the product in a step-by-step way. Instructions never seem to be tested with first-time users before being issued. So vital steps are missed out or components are mislabeled or not labelled at all. For example, the instructions for assembling a sliding door gear say: ‘The pendant bolt centres are fixed and should be at an equal distance from the centre of the door.’ This neglects to explain who should do the fixing and how the bolt centres will get into the correct position. By using an imperative and an active verb the instruction becomes much clearer: ‘Make sure you fix the centres of the pendant bolts at an equal distance from the centre of the door.’

D

Effectively, the Plain English movement in the US began with President Jimmy Carter’s Executive Order 12044 of 23 March 1978, that required regulations to be written in plain language. There were earlier government efforts to inform consumers about their rights and obligations, such as the Truth in Lending Act (1969) and the Fair Credit Billing Act (1975), which emphasized a body of information that consumers need in simple language. But President Carter’s executive order gave the prestige and force of a president to the movement. All over the country isolated revolts or efforts against legalistic gobbledygook at the federal, state and corporate levels seemed to grow into a small revolution. These efforts and advances between the years 1978 and 1985 are described in the panel ‘The Plain English Scorecard’.

E

The Bastille has not fallen yet. The forces of resistance are strong, as one can see from the case of Pennsylvania as cited in the Scorecard. In addition, President Ronald Reagan’s executive order of 19 February 1981, revoking President Carter’s earlier executive order, has definitely slowed the pace of plain English legislation in the United States. There are there main objections to the idea of plain English. They are given below, with the campaign’s answer to them:

F

The statute would cause unending litigation and clog the courts. Simply not true in all the ten states with plain English laws for consumer contracts and the 34 states with laws or regulations for insurance policies. Since 1978 when plain English law went into effect in New York there have been only four litigations and only two decisions. Massachusetts had zero cases. The cost of compliance would be enormous. Translation of legal contracts into non-legal everyday language would be a waster of time and money. The experience of several corporations has proved that the cost of compliance is often outweighed by solid benefits and litigation savings. Citibank of New York made history in 1975 by introducing a simplified promissory note and afterwards simplified all their forms. Citibank counsel Carl Falsenfield says: ‘We have lost no money and there has been no litigation as a result of simplification.’ The cost-effectiveness of clarity is demonstrable. A satisfied customer more readily signs on the bottom line and thus contributes to the corporation’s bottom line. Some documents simply can’t be simplified. The only legal language that has been tested for centuries in the courts is precise enough to deal with a mortgage, a deed, a lease, or an insurance policy. Here, too, the experience of several corporations and insurance companies has proved that contracts and policies can be made more understandable without sacrificing legal effectiveness.

G

What does the future hold for the Plain English movement? Today, American consumers are buffeted by an assortment of pressures. Never before have consumers had as many choices in areas like financial services, travel, telephone services, and supermarket products. There are about 300 long-distance phone companies in the US. Not long ago, the average supermarket carried 9,000 items; today, it carries 22,000. More importantly, this expansion of options – according to a recent report – is faced by a staggering 30 million Americans lacking the reading skills to handle the minimal demands of daily living. The consumer’s need, therefore, for information expressed in plain English is more critical than ever.

H

What is needed today is not a brake on the movement’s momentum but another push toward plain English contracts from consumers. I still hear plain English on the TV and in the streets, and read plain English in popular magazines and best-sellers, but not yet in many functional documents. Despite some victories, the was against gobbledygook is not over yet. We do well to remember, the warning of Chrissie Maher, organizer of Plain English Campaign in the UK: ‘People are not just injured when medical labels are written in gobbledygook – they die. Drivers are not just hurt when their medicines don’t tell them they could fall asleep at the wheel – they are killed.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8895bd35-4fa0-50fc-a8aa-009b29b49251', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

1 ____ In marketing area, the spread of Plain English can generate economic benefit.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e63af906-4ac4-569a-bc44-64fd54bb9c17', '8895bd35-4fa0-50fc-a8aa-009b29b49251', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fadd94e-2075-5742-896c-27c2da748d84', '8895bd35-4fa0-50fc-a8aa-009b29b49251', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73b6da41-df74-5255-9d4c-96065ffa4dd9', '8895bd35-4fa0-50fc-a8aa-009b29b49251', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c22400a-1a73-58c0-986d-d83f6784ce4a', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

2 ____ Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bb915f9-48a4-504f-97e7-5ed19862e96e', '1c22400a-1a73-58c0-986d-d83f6784ce4a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2205e32e-11f8-5cba-a18e-7aeb4cf1b1d3', '1c22400a-1a73-58c0-986d-d83f6784ce4a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9aacd566-e706-505e-b075-c4c2daf625a4', '1c22400a-1a73-58c0-986d-d83f6784ce4a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3f3eb13-c641-556e-8c75-25d21bf0008c', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

3 ____ After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73e09b7b-9b89-5a68-8263-1f754ec269a7', 'c3f3eb13-c641-556e-8c75-25d21bf0008c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d01264a-4826-5f34-a761-1080f0be02d6', 'c3f3eb13-c641-556e-8c75-25d21bf0008c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8564ab35-7ea5-54e1-8551-e1f400eb1860', 'c3f3eb13-c641-556e-8c75-25d21bf0008c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91fd8ca4-6fcb-5933-bcd6-ee9c2ce3a09f', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

4 ____ The Plain English campaigner has a problem of talking with the officials.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c9f7e21-0f52-5526-8436-0235e0b5e722', '91fd8ca4-6fcb-5933-bcd6-ee9c2ce3a09f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5d2263e-b8e9-5a17-962c-6b1b0e821b5c', '91fd8ca4-6fcb-5933-bcd6-ee9c2ce3a09f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49d0c0f2-60a0-5163-9ac9-f7aa6cde7c63', '91fd8ca4-6fcb-5933-bcd6-ee9c2ce3a09f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('caf2a381-8b31-5d75-bbb5-abd7ac87bdbc', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

5 ____ Work check is made regularly by the judge in the court scenario.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d30d1706-23c1-50ae-82c9-e34ddae03c81', 'caf2a381-8b31-5d75-bbb5-abd7ac87bdbc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d57a9d82-cbbf-5664-971b-a3c90c8a661d', 'caf2a381-8b31-5d75-bbb5-abd7ac87bdbc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('544fd71e-c12a-5057-902b-246e595d8d00', 'caf2a381-8b31-5d75-bbb5-abd7ac87bdbc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83acad58-fdb3-559e-b829-501fe0579fcd', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
In marketing area, the spread of Plain English can generate economic benefit.
2
Because doctors tend to use jargon when they talk with patients, thereafter many patients usually get confused with medicine dose.
3
After successive election over U.S president Jimmy Carter, the effect of Plain English Campaign is less distinctive than that of the previous one.
4
The Plain English campaigner has a problem of talking with the officials.
5
Work check is made regularly by the judge in the court scenario.
6
Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.

6 ____ Compared with the situation of the past, consumers are now facing less intensity of label reading pressure in a supermarket in America.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85522200-e986-50a4-9ede-fdfbc6b23283', '83acad58-fdb3-559e-b829-501fe0579fcd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('913eeadb-ca22-55ad-9b1d-baadf9b825fb', '83acad58-fdb3-559e-b829-501fe0579fcd', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a0e3516-4be7-5fd0-9b04-c52e70ffc1cd', '83acad58-fdb3-559e-b829-501fe0579fcd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e16a75d2-3dd4-582c-b34a-cbdb84fb5d7b', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Campaigners experienced a council renting document full of strange 7 ____ of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious 8 ____ for patients.$md$, NULL, ARRAY['.*jargon.*and.*waffle.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0a1d6546-0633-5e9e-87a8-ad9d9237ef13', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 8, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Campaigners experienced a council renting document full of strange 7 ____ of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious 8 ____ for patients.$md$, NULL, ARRAY['.*jargon.*and.*waffle.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('95313aff-e275-5097-8701-47f02a72f8cf', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2db8214e-789c-5c47-9b14-8e97174c5649', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('813e6c3b-2afb-538b-b563-83e70a8becbb', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b543cdbc-b257-59b8-be4d-2643e3f76df9', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9e187657-102c-518e-9690-3f852f1f11a6', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2053c2de-afee-598a-9d88-90ebb08b9039', 'bc5126c4-1fbc-521b-8515-12d1f7e80371', 14, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 7-14
Questions 7-14
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Campaigners experienced a council renting document full of strange
7
of housing in terms of an Act. They are anxious in some other field, for instance, when reading a label of medicine, there was an obvious
8
for patients.
Another notable field was on
9
products, it not only additionally cost buyers but caused
10
, thus writer should regard himself as a
11
. However, oppositions against the Plain English Campaign under certain circumstances, e.g.
12
language had been embellished as an accurate language used in the
13
The author suggested that nowadays new compelling force is needed from
14
.

Another notable field was on 9 ____ products, it not only additionally cost buyers but caused 10 ____ , thus writer should regard himself as a 11 ____ . However, oppositions against the Plain English Campaign under certain circumstances, e.g. 12 ____ language had been embellished as an accurate language used in the 13 ____ The author suggested that nowadays new compelling force is needed from 14 ____ .$md$, NULL, ARRAY['.*do.*it.*yourself.*']);

COMMIT;
