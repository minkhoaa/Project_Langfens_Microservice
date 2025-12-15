BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-changes-in-air-1487'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-changes-in-air-1487';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-changes-in-air-1487';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-changes-in-air-1487';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e0a50076-1c16-5fd1-86e5-3a008cf553f7', 'ielts-reading-changes-in-air-1487', $t$Changes in Air$t$, $md$## Changes in Air

Nguồn:
- Test: https://mini-ielts.com/1487/reading/changes-in-air
- Solution: https://mini-ielts.com/1487/view-solution/reading/changes-in-air$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 'e0a50076-1c16-5fd1-86e5-3a008cf553f7', 1, $t$Reading — Changes in Air$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Changes in Air

A A federal ban on ozone-depleting chlorofluorocarbons (CFCs), to conform with the Clean Air Act, is, ironically, affecting 22.9 million people in the U.S. who suffer from asthma. Generic inhaled albuterol, which is the most commonly prescribed short-acting asthma medication and requires CFCs to propel it into the lungs, will no longer be legally sold after December 31, 2008. Physicians and patients are questioning the wisdom of the ban, which will have an insignificant effect on ozone but a measurable impact on wallets: the reformulated brand-name alternatives can be three times as expensive, raising the cost to about $40 per inhaler. The issue is even more disconcerting considering that asthma disproportionately affects the poor and that, according to recent surveys, an estimated 20 percent of asthma patients are uninsured.

B “The decision to make the change was political, not medical or scientific,” says pharmacist Leslie Hendeles of the University of Florida, who co-authored a 2007 paper in the New England Journal of Medicine explaining the withdrawal and transition. In 1987 Congress signed on to the Montreal Protocol on Substances That Deplete the Ozone Layer, an international treaty requiring the phasing out of all nonessential uses of CFCs. At that time, medical inhalers were considered an essential use because no viable alternative propellant existed. In 1989 pharmaceutical companies banded together and eventually, in 1996, reformulated albuterol with hydrofluoroalkane.

C The transition began quietly, but as more patients see their prescriptions change and costs go up, many question why this ban must begin before generics become available. At least one member of the FDA advisory committee, Nicholas J. Gross of the Stritch-Loyola School of Medicine, has publicly regretted the decision, recanting his support and requesting that the ban be pushed back until 2010, when the first patent expfres.

D Gross notes that the decision had nothing to do with the envfronment. Albuterol inhalers contributed less than 0.1 percent of the CFCs released when the treaty was signed. “It’s a symbolic issue,” Gross remarks. Some skeptics instead point to the billions of dollars to be gained by the three companies holding the patents on the available HFA-albuterol inhalers, namely Glaxo-SmithKline, Schering-Plough and Teva. Although the FDA advisory committee recognized that the expenses would go up, Hendeles says, it also believed that the companies would help defray the added costs for individuals. Firms, for instance, had committed to donating a million HFA inhalers to clinics around the country. According to Hendeles, GlaxoSmithKline did not follow through, although Schering-Plough and Teva did. GlaxoSmithKline did not respond to requests for comment.

E The issue now, Hendeles says, is that pharmaceutical-grade CFCs are in short supply, and the public faces the risk of a shortage of albuterol inhalers if the FDA does not continue promoting the production of HFA inhalers. He posits that even costs of generics would go up as CFCs become scarcer. Gross disagrees, saying that the inhaler shortage and the closure of CFC manufacturing plants are a result of the ban.

F The HFA inhalers also have encountered resistance because some asthmatics insist that they do not work as well as the CFC variety. But, Hendeles says, the differences are in the mechanics and maintenance—unlike CFC inhalers, the HFA versions must be primed more diligently and rinsed to accommodate the stickier HFA formulation. They also run out suddenly without the warning with a CFC inhaler, that the device is running low. “Pharmacists may not tell people of these things, and the doctors don’t know,” Hendeles says.

G The main public health issue in this decision may be the side effects of the economics, not the drug chemistry. Multiple studies have shown that raising costs leads to poorer adherence to treatment. One study discovered that patients took 30 percent less antiasthma medication when thefr co-pay doubled. In the case of a chronic disease such as asthma, it is particularly difficult to get people to follow regular treatment plans. “Generally speaking, for any reason you don’t take medication, cost makes it more likely” that you do not, comments Michael Chemew, a health policy expert at Harvard Medical School.

H Such choices to forgo medication could affect more than just the patients themselves. “For example,” Hendeles points out, “in a pregnant mother with untreated asthma, less oxygen is delivered to the fetus, which can lead to congenital problems and premature birth.” And considering that the disease disproportionately strike s the poor, what seemed to be a good, responsible environmental decision might in the end exact an unexpected human toll.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f47e6d5-2bae-5772-922d-3a9e19f6776d', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
A. Nicolas J Gross
B. Michael Chernew
C. Leslie Hendeles
1
Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.
2
Spoke out a secret that the druggists try to hold back.
3
Pointed out that the protocol itself is not concerning the environment.
4
Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.
5
In public repented of his previous backing up of the prohibition proposal.

1 ____ Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18034fb8-20e5-558f-8261-7797c9cc2e5a', '5f47e6d5-2bae-5772-922d-3a9e19f6776d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('558e1ea5-aa6b-5e77-bf6a-92730f62f33d', '5f47e6d5-2bae-5772-922d-3a9e19f6776d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77d6efc0-a1ad-5bbe-83bc-4a2ad0fa98e5', '5f47e6d5-2bae-5772-922d-3a9e19f6776d', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5276ee07-41ce-514e-9494-482db978003c', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
A. Nicolas J Gross
B. Michael Chernew
C. Leslie Hendeles
1
Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.
2
Spoke out a secret that the druggists try to hold back.
3
Pointed out that the protocol itself is not concerning the environment.
4
Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.
5
In public repented of his previous backing up of the prohibition proposal.

2 ____ Spoke out a secret that the druggists try to hold back.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08c58f3f-6258-5f68-be16-e3bcc8a0e133', '5276ee07-41ce-514e-9494-482db978003c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1af621e9-6668-5e9a-babc-47f4f0dfc856', '5276ee07-41ce-514e-9494-482db978003c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d49669e8-92bb-5fb3-9e30-5998e488cc0e', '5276ee07-41ce-514e-9494-482db978003c', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2da8402f-cbc6-5a5f-b9de-c36477aa22d4', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
A. Nicolas J Gross
B. Michael Chernew
C. Leslie Hendeles
1
Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.
2
Spoke out a secret that the druggists try to hold back.
3
Pointed out that the protocol itself is not concerning the environment.
4
Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.
5
In public repented of his previous backing up of the prohibition proposal.

3 ____ Pointed out that the protocol itself is not concerning the environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('133e7326-e838-5a2c-a27c-8f775b0e27a9', '2da8402f-cbc6-5a5f-b9de-c36477aa22d4', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29164434-538a-5a23-932e-b8099c2a9605', '2da8402f-cbc6-5a5f-b9de-c36477aa22d4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a69dc17c-6c34-50be-9001-a8ee0299d7a0', '2da8402f-cbc6-5a5f-b9de-c36477aa22d4', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6b4cbed-d391-5160-af7a-d166f0b90468', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
A. Nicolas J Gross
B. Michael Chernew
C. Leslie Hendeles
1
Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.
2
Spoke out a secret that the druggists try to hold back.
3
Pointed out that the protocol itself is not concerning the environment.
4
Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.
5
In public repented of his previous backing up of the prohibition proposal.

4 ____ Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d5a2f71-28ce-57e0-8a73-76a0469fd091', 'd6b4cbed-d391-5160-af7a-d166f0b90468', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dca803ac-e1b7-5965-b647-951c1108723f', 'd6b4cbed-d391-5160-af7a-d166f0b90468', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9abef712-2f0f-5d99-a1ce-c900c6749a2c', 'd6b4cbed-d391-5160-af7a-d166f0b90468', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7fa18ce-1877-5a6f-a59c-fb49e46555f2', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
A. Nicolas J Gross
B. Michael Chernew
C. Leslie Hendeles
1
Put forward that the increase in the price of drugs would contribute to the patients’ negative decision on the treatment.
2
Spoke out a secret that the druggists try to hold back.
3
Pointed out that the protocol itself is not concerning the environment.
4
Demonstrated that the stop of providing alternatives for CFCs would worsen rather than help with the situation.
5
In public repented of his previous backing up of the prohibition proposal.

5 ____ In public repented of his previous backing up of the prohibition proposal.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22f9d77e-1ac0-5cba-ba07-97782d804714', 'e7fa18ce-1877-5a6f-a59c-fb49e46555f2', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('425ed5af-36e5-5105-81ca-003bbddc699a', 'e7fa18ce-1877-5a6f-a59c-fb49e46555f2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9201d1f-d0f2-59ae-a2fb-39ce0b17c89d', 'e7fa18ce-1877-5a6f-a59c-fb49e46555f2', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c09513d-b95f-5972-bec8-dddf8ac5227b', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage? In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
It took almost a decade before the replacement drug for the asthma therapy was ultimately developed by the joint effort of several drug companies.
7
One of the FDA committee members had a decisive impact on the implementation of the ban on chlorofluorocarbons.
8
as a matter of fact, the emitted chlorofluorocarbons in asthma treatment took up quite an insignificant amount at the time when the pact was reached.
9
The HFA and CFC inhalers have something different regarding the therapeutic effect.

6 ____ It took almost a decade before the replacement drug for the asthma therapy was ultimately developed by the joint effort of several drug companies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93d2a5f2-59f6-509b-9d24-82155b1c209c', '2c09513d-b95f-5972-bec8-dddf8ac5227b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('893346c4-9495-5723-8a4e-a1a2d6e5e8a9', '2c09513d-b95f-5972-bec8-dddf8ac5227b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('850ba595-555c-5e81-9e2f-071fec1fc18b', '2c09513d-b95f-5972-bec8-dddf8ac5227b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc701eec-f3b0-5060-a522-d71d566101f1', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage? In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
It took almost a decade before the replacement drug for the asthma therapy was ultimately developed by the joint effort of several drug companies.
7
One of the FDA committee members had a decisive impact on the implementation of the ban on chlorofluorocarbons.
8
as a matter of fact, the emitted chlorofluorocarbons in asthma treatment took up quite an insignificant amount at the time when the pact was reached.
9
The HFA and CFC inhalers have something different regarding the therapeutic effect.

7 ____ One of the FDA committee members had a decisive impact on the implementation of the ban on chlorofluorocarbons.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88808295-77ec-5761-9305-6bfe211bf3b9', 'fc701eec-f3b0-5060-a522-d71d566101f1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc6f6ff8-00d5-51dc-a6b1-e292d6fbafeb', 'fc701eec-f3b0-5060-a522-d71d566101f1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('301b171d-b215-53d5-9826-19e7ef5d4917', 'fc701eec-f3b0-5060-a522-d71d566101f1', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1675fe8d-29f4-5c75-ae40-2266d408bb0a', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage? In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
It took almost a decade before the replacement drug for the asthma therapy was ultimately developed by the joint effort of several drug companies.
7
One of the FDA committee members had a decisive impact on the implementation of the ban on chlorofluorocarbons.
8
as a matter of fact, the emitted chlorofluorocarbons in asthma treatment took up quite an insignificant amount at the time when the pact was reached.
9
The HFA and CFC inhalers have something different regarding the therapeutic effect.

8 ____ as a matter of fact, the emitted chlorofluorocarbons in asthma treatment took up quite an insignificant amount at the time when the pact was reached.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('235da3c7-c834-5e4b-bd19-76161a3756b3', '1675fe8d-29f4-5c75-ae40-2266d408bb0a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c172f0d-2e86-504f-b120-53e0f47a08ab', '1675fe8d-29f4-5c75-ae40-2266d408bb0a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('053af04a-f998-5a42-95b3-aff1c2b5d3bc', '1675fe8d-29f4-5c75-ae40-2266d408bb0a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0877dbd-14ad-5f6a-82c5-a81c29ef36c2', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage? In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
It took almost a decade before the replacement drug for the asthma therapy was ultimately developed by the joint effort of several drug companies.
7
One of the FDA committee members had a decisive impact on the implementation of the ban on chlorofluorocarbons.
8
as a matter of fact, the emitted chlorofluorocarbons in asthma treatment took up quite an insignificant amount at the time when the pact was reached.
9
The HFA and CFC inhalers have something different regarding the therapeutic effect.

9 ____ The HFA and CFC inhalers have something different regarding the therapeutic effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820826fa-1e09-525c-9246-31a947e9ef18', 'f0877dbd-14ad-5f6a-82c5-a81c29ef36c2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('013a0c5d-35ba-570c-ad87-d4d8582691b6', 'f0877dbd-14ad-5f6a-82c5-a81c29ef36c2', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5cc60ab-d538-5134-be64-d6db6d973e9b', 'f0877dbd-14ad-5f6a-82c5-a81c29ef36c2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f6583fa9-a660-5e49-aef5-dc1e663149c6', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
American people with asthma would be impacted by
10
about chlorofluorocarbons which would consume the ozone layer. The usually used
11
would be considered illegal because it needs the propelment of
12
. The
13
would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in
14
condition.

American people with asthma would be impacted by 10 ____ about chlorofluorocarbons which would consume the ozone layer. The usually used 11 ____ would be considered illegal because it needs the propelment of 12 ____ . The 13 ____ would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in 14 ____ condition.$md$, NULL, ARRAY['.*a.*federal.*ban.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ef7c5097-3a49-5de9-ba2a-c34e0f0d4267', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
American people with asthma would be impacted by
10
about chlorofluorocarbons which would consume the ozone layer. The usually used
11
would be considered illegal because it needs the propelment of
12
. The
13
would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in
14
condition.

American people with asthma would be impacted by 10 ____ about chlorofluorocarbons which would consume the ozone layer. The usually used 11 ____ would be considered illegal because it needs the propelment of 12 ____ . The 13 ____ would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in 14 ____ condition.$md$, NULL, ARRAY['.*a.*federal.*ban.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f145f6cd-180a-56fe-8e3a-5a69b8309d16', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
American people with asthma would be impacted by
10
about chlorofluorocarbons which would consume the ozone layer. The usually used
11
would be considered illegal because it needs the propelment of
12
. The
13
would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in
14
condition.

American people with asthma would be impacted by 10 ____ about chlorofluorocarbons which would consume the ozone layer. The usually used 11 ____ would be considered illegal because it needs the propelment of 12 ____ . The 13 ____ would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in 14 ____ condition.$md$, NULL, ARRAY['.*a.*federal.*ban.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2d06a7ed-81d4-5c90-b251-a192bb919068', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
American people with asthma would be impacted by
10
about chlorofluorocarbons which would consume the ozone layer. The usually used
11
would be considered illegal because it needs the propelment of
12
. The
13
would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in
14
condition.

American people with asthma would be impacted by 10 ____ about chlorofluorocarbons which would consume the ozone layer. The usually used 11 ____ would be considered illegal because it needs the propelment of 12 ____ . The 13 ____ would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in 14 ____ condition.$md$, NULL, ARRAY['.*a.*federal.*ban.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('afca53a4-7e5c-53f3-9d94-855db5cb0c05', '11efa5e2-cdba-5d1b-99c0-2b5c452be48e', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
American people with asthma would be impacted by
10
about chlorofluorocarbons which would consume the ozone layer. The usually used
11
would be considered illegal because it needs the propelment of
12
. The
13
would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in
14
condition.

American people with asthma would be impacted by 10 ____ about chlorofluorocarbons which would consume the ozone layer. The usually used 11 ____ would be considered illegal because it needs the propelment of 12 ____ . The 13 ____ would cost the patients considerably more money. Impoverished people are far more likely to suffer from asthma and what makes it even worse is that some of them are in 14 ____ condition.$md$, NULL, ARRAY['.*a.*federal.*ban.*']);

COMMIT;
