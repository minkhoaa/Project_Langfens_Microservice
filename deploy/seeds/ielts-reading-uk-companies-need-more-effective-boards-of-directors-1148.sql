BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-uk-companies-need-more-effective-boards-of-directors-1148'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-uk-companies-need-more-effective-boards-of-directors-1148';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-uk-companies-need-more-effective-boards-of-directors-1148';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-uk-companies-need-more-effective-boards-of-directors-1148';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('70311381-af6c-519c-828d-964e05ba7cce', 'ielts-reading-uk-companies-need-more-effective-boards-of-directors-1148', $t$UK companies need more effective boards of directors$t$, $md$## UK companies need more effective boards of directors

Nguồn:
- Test: https://mini-ielts.com/1148/reading/uk-companies-need-more-effective-boards-of-directors
- Solution: https://mini-ielts.com/1148/view-solution/reading/uk-companies-need-more-effective-boards-of-directors$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', '70311381-af6c-519c-828d-964e05ba7cce', 1, $t$Reading — UK companies need more effective boards of directors$t$, $md$Read the passage and answer questions **1–14**.

### Passage: UK companies need more effective boards of directors

A After a number of serious failures of governance (that is, how they are managed at the highest level), companies in Britain, as well as elsewhere, should consider radical changes to their directors’ roles. It is clear that the role of a board director today is not an easy one. Following the 2008 financial meltdown, which resulted in a deeper and more prolonged period of economic downturn than anyone expected, the search for explanations in the many post- of the crisis has meant blame has been spread far and wide . Governments, regulators, central banks and auditors have all been in the frame. The role of bank directors and management and their widely publicised failures have been extensively picked over and examined in reports, inquiries and commentaries.

B The knock-on t of this scrutiny has been to make the governance of companies in general an issue of intense public debate and has significantly increased the pressures on, and the responsibilities of, directors . At the simplest and most practical level, the time involved in fulfilling the demands of a board directorship has increased significantly, calling into question the effectiveness of the classic model of corporate governance by part-time, independent non-executive directors. Where once a board schedule may have consisted of between eight and ten meetings a year, in many companies the number of events requiring board input and decisions has dramatically risen. Furthermore, the amount of reading and preparation required for each meeting is increasing. Agendas can become overloaded and this can mean the time for constructive debate must necessarily be restricted in favour of getting through the business.

C Often, board business is devolved to committees in order to cope with the workload , which may be more efficient but can mean that the board as a whole is less involved in fully addressing some of the most important issues. It is not uncommon for the audit committee meeting to last longer than the main board meeting itself. Process may take the place of discussion and be at the expense of real collaboration, so that boxes are ticked rather than issues tackled.

D A radical solution, which may work for some very large companies whose businesses are extensive and complex, is the professional board , whose members would work up to three or four days a week, supported by their own dedicated staff and advisers. There are obvious risks to this and it would be important to establish clear guidelines for such a board to ensure that it did not step on the toes of management by becoming too engaged in the day-to-day running of the company. Problems of recruitment, remuneration and independence could also arise and this structure would not be appropriate for all companies . However, more professional and better-informed boards would have been particularly appropriate for banks where the executives had access to information that part-time non-executive directors lacked, leaving the latter unable to comprehend or anticipate the 2008 crash.

E One of the main criticisms of boards and their directors is that they do not focus sufficiently on longer-term matters of strategy, sustainability and governance , but instead concentrate too much on short-term financial metrics. Regulatory requirements and the structure of the market encourage this behaviour. The tyranny of quarterly reporting can distort board decision-making, as directors have to ‘make the numbers’ every four months to meet the insatiable appetite of the market for more data. This serves to encourage the trading methodology of a certain kind of investor who moves in and out of a stock without engaging in constructive dialogue with the company about strategy or performance, and is simply seeking a short¬ term financial gain. This effect has been made worse by the changing profile of investors due to the globalisation of capital and the increasing use of automated trading systems. Corporate culture adapts and management teams are largely incentivised to meet financial goals.

F Compensation for chief executives has become a combat zone where pitched battles between investors , management and board members are fought, often behind closed doors but increasingly frequently in the full glare of press attention. Many would argue that this is in the interest of transparency and good governance as shareholders use their muscle in the area of pay to pressure boards to remove underperforming chief executives. Their powers to vote down executive remuneration policies increased when binding votes came into force. The chair of the remuneration committee can be an exposed and lonely role, as Alison Carnwath, chair of Barclays Bank’s remuneration committee, found when she had to resign, having been roundly criticised for trying to defend the enormous bonus to be paid to the chief executive; the irony being that she was widely understood to have spoken out against it in the privacy of the committee.

G The financial crisis stimulated a debate about the role and purpose of the company and a heightened awareness of corporate ethics. Trust in the corporation has been eroded and academics such as Michael Sandel, in his thoughtful and bestselling book What Money Can’t Buy, are questioning the morality of capitalism and the market economy. Boards of companies in all sectors will need to widen their perspective to encompass these issues and this may involve a realignment of corporate goals . We live in challenging times.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bac82869-683a-51e2-9a55-9805285923e3', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

1 ____ Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab112cb8-d4e5-5337-92e1-d9fe38020fdc', 'bac82869-683a-51e2-9a55-9805285923e3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55cf46f8-aaff-5bf6-8dee-eb687fe9fc80', 'bac82869-683a-51e2-9a55-9805285923e3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46e64c6a-f4ce-5a4d-8c58-a2e2aee7e69f', 'bac82869-683a-51e2-9a55-9805285923e3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('789154cb-e336-5875-b02c-5f367d7f8b73', 'bac82869-683a-51e2-9a55-9805285923e3', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a872adc-b6c4-53f8-b385-a0e99b7a8668', 'bac82869-683a-51e2-9a55-9805285923e3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a33f5f1b-ab70-5926-9f12-873091dd0883', 'bac82869-683a-51e2-9a55-9805285923e3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e09232d9-a03f-57de-9bc3-af26fb6c21e3', 'bac82869-683a-51e2-9a55-9805285923e3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0f5c1c6-bf31-5f20-917c-89055ca231ea', 'bac82869-683a-51e2-9a55-9805285923e3', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6c587cf2-3836-5b08-91d4-cce2d3fc3c95', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

2 ____ Paragraph B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3674f54-4212-5722-b4a0-7b0f8d13e14a', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('772cdae8-c647-57d9-a2f0-0efc91e3554a', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17980a5d-6f95-5364-8070-5fe6b19e6061', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28419ce1-347a-52a6-b853-28300fc2011f', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25b040d9-df7d-5c63-97c2-d97a013f66b8', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aa25668-ce4b-5d29-bb54-f1e48c5c9aff', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2d6c881-9d33-59c0-aebd-cb74306bc45c', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a07b8ccf-e463-5432-a431-6597d29b3e9a', '6c587cf2-3836-5b08-91d4-cce2d3fc3c95', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e37ad3b1-896f-58e6-88f5-8430631f8e21', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

3 ____ Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20f16c11-e319-5ab0-b009-5e551fa28bee', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8666608b-175f-5c80-bc1c-0bc37d5e33ed', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59a0740e-c2fb-5500-a606-810aba0513c7', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0a19a8f-361f-5181-bbd4-807aca5bc2bf', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab8d55dc-5752-5d5c-816b-f706b27cd900', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be78045b-c2d3-50ba-b235-cb6b20aa41fb', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a76a069d-e166-5570-86b4-72b21a7570d3', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a1d780-64d1-5066-a133-ea6d02d6fff9', 'e37ad3b1-896f-58e6-88f5-8430631f8e21', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c75cabe1-d05d-5708-949f-aebe8ac2707e', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

4 ____ Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a84460f5-a63c-53c7-bdcd-8852563906d0', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c76d140-1b9f-571f-840f-69574fb13f37', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a7ca43-2390-5cb0-97a7-f5bb488d7554', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd7dd2a7-3617-5111-aa5d-12e8e024074e', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a0f2766-2270-5ae1-ac19-5d67790098f9', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1441883-661b-530f-8c5e-ec6388f237ae', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7252cd7c-bd03-5efb-a5cd-47f8e24c6e97', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74ef8ee8-f959-5fa1-b03a-da92c3562e3d', 'c75cabe1-d05d-5708-949f-aebe8ac2707e', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2258b783-cb0a-5399-a77b-904113a4c174', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

5 ____ Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef27d3be-f04c-52cb-b3aa-b79f66297c5d', '2258b783-cb0a-5399-a77b-904113a4c174', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0d56123-6a60-519d-82b1-4427addc46e4', '2258b783-cb0a-5399-a77b-904113a4c174', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8248f283-6f7f-5b21-babe-ba2c26b36124', '2258b783-cb0a-5399-a77b-904113a4c174', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e55e8647-bb99-56d4-99d7-b7757ee5449d', '2258b783-cb0a-5399-a77b-904113a4c174', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a862e9e-ea72-5ec5-ae98-835a7d5f90cd', '2258b783-cb0a-5399-a77b-904113a4c174', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b989cbf-5a8e-5b81-a4ff-6768a5d01f80', '2258b783-cb0a-5399-a77b-904113a4c174', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a7388ab-ed21-5d7c-9e39-741a1c0cb1eb', '2258b783-cb0a-5399-a77b-904113a4c174', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92ef64b3-0665-588a-8967-7fddc0879ad6', '2258b783-cb0a-5399-a77b-904113a4c174', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d3f624b-f92d-58ce-b3ac-e5352342a6e2', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

6 ____ Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0365f94-a5ae-5376-bfc2-0a363d583a56', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('490814a0-833d-5552-9fa9-ff3472a156f4', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cbfbc16-0313-5569-b661-5db89166e968', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8059951d-e71c-5cf4-8782-c728697b28f1', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b730d2e8-9e4f-5a58-948a-8a2cadbf283d', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09990aee-1ba4-5e1a-b31a-f96533348a92', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26899417-3faf-5692-8c64-fd7e68da3227', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2830897-d38c-5d7d-86c5-bef354a83228', '1d3f624b-f92d-58ce-b3ac-e5352342a6e2', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e694a64d-a53e-5315-9343-6fcdeff15972', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Disputes over financial arrangements regarding senior managers
ii
The impact on companies of being subjected to close examination
iii
The possible need for fundamental change in every area of business
iv
Many external bodies being held responsible for problems
v
The falling number of board members with broad enough experience
vi
A risk that not all directors take part in solving major problems
vii
Boards not looking far enough ahead
viii
A proposal to change the way the board operates

7 ____ Paragraph G Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('384efbfd-55a8-5e4b-a420-30d1bd673e9b', 'e694a64d-a53e-5315-9343-6fcdeff15972', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7272ca9d-aef7-5182-8b48-f4103643209d', 'e694a64d-a53e-5315-9343-6fcdeff15972', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5866259d-4e7a-56b7-80b2-7e113ed14e13', 'e694a64d-a53e-5315-9343-6fcdeff15972', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20fe6530-79d1-563a-a82c-4b4266fe5714', 'e694a64d-a53e-5315-9343-6fcdeff15972', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e85998bf-3631-5811-b85a-f9c5ccdf801d', 'e694a64d-a53e-5315-9343-6fcdeff15972', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65b53ac8-8481-5f50-97e1-457f6560b3b2', 'e694a64d-a53e-5315-9343-6fcdeff15972', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15dad69b-c994-56e4-9a56-654a922eb738', 'e694a64d-a53e-5315-9343-6fcdeff15972', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa6b82d5-f6a2-5a2b-91cb-44aaca895bd5', 'e694a64d-a53e-5315-9343-6fcdeff15972', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba26e573-334a-5fea-8de0-955a7f186c81', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 8-11
Question 8-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
8-11
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
8
Close scrutiny of the behaviour of boards has increased since the economic downturn.
Locate
9
Banks have been mismanaged to a greater extent than other businesses.
10
Board meetings normally continue for as long as necessary to debate matters in full.
Locate
11
Using a committee structure would ensure that board members are fully informed about significant issues.
Locate

8 ____ Close scrutiny of the behaviour of boards has increased since the economic downturn. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('819c4da1-c3da-58bd-9b8b-cca84d8f3e79', 'ba26e573-334a-5fea-8de0-955a7f186c81', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2217b13a-85cb-59c2-a215-db16b2112f0a', 'ba26e573-334a-5fea-8de0-955a7f186c81', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e6275cf-f9db-5ac2-b3e0-bbf550d82d1f', 'ba26e573-334a-5fea-8de0-955a7f186c81', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4abc6b0-4896-5c5f-b484-6656a34579f7', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 8-11
Question 8-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
8-11
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
8
Close scrutiny of the behaviour of boards has increased since the economic downturn.
Locate
9
Banks have been mismanaged to a greater extent than other businesses.
10
Board meetings normally continue for as long as necessary to debate matters in full.
Locate
11
Using a committee structure would ensure that board members are fully informed about significant issues.
Locate

9 ____ Banks have been mismanaged to a greater extent than other businesses.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a218b70-4f58-5583-b035-57424b1a4c28', 'b4abc6b0-4896-5c5f-b484-6656a34579f7', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63a70817-8c05-52cd-b142-c250f66c69d7', 'b4abc6b0-4896-5c5f-b484-6656a34579f7', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a4add3f-0806-5fa1-b475-988f9d58f8f9', 'b4abc6b0-4896-5c5f-b484-6656a34579f7', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f65ad445-1a69-5ea7-b1a6-4811c1f438c4', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Question 8-11
Question 8-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
8-11
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
8
Close scrutiny of the behaviour of boards has increased since the economic downturn.
Locate
9
Banks have been mismanaged to a greater extent than other businesses.
10
Board meetings normally continue for as long as necessary to debate matters in full.
Locate
11
Using a committee structure would ensure that board members are fully informed about significant issues.
Locate

10 ____ Board meetings normally continue for as long as necessary to debate matters in full. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8334f845-833f-5d4e-99b1-ef7a10ea7085', 'f65ad445-1a69-5ea7-b1a6-4811c1f438c4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('197a664f-2a0f-5d30-8029-abd68273e8bb', 'f65ad445-1a69-5ea7-b1a6-4811c1f438c4', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea942be-7f3c-5990-a29b-42b93fe20bf8', 'f65ad445-1a69-5ea7-b1a6-4811c1f438c4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('836dff71-0d31-540e-a747-4f14dbb7775f', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Question 8-11
Question 8-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
8-11
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
8
Close scrutiny of the behaviour of boards has increased since the economic downturn.
Locate
9
Banks have been mismanaged to a greater extent than other businesses.
10
Board meetings normally continue for as long as necessary to debate matters in full.
Locate
11
Using a committee structure would ensure that board members are fully informed about significant issues.
Locate

11 ____ Using a committee structure would ensure that board members are fully informed about significant issues. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b77547-088f-59a0-bbb6-b411ba04b7d6', '836dff71-0d31-540e-a747-4f14dbb7775f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bebf27a-0c57-5605-8eed-7137d5abc31e', '836dff71-0d31-540e-a747-4f14dbb7775f', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0357e92e-8c00-520b-9e96-ebb9d8654c8a', '836dff71-0d31-540e-a747-4f14dbb7775f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0c24aeb8-76b5-54b8-906b-dd659da1235f', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12
Before 2008, non-executive directors were at a disadvantage because of their lack of
.
Locate
13
Boards tend to place too much emphasis on
considerations that are only of short-term relevance.
Locate
14
On certain matters, such as pay, the board may have to accept the views of
.
Locate

12 Before 2008, non-executive directors were at a disadvantage because of their lack of ____ . Locate$md$, NULL, ARRAY['.*information.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c1bf1b0f-9c56-5f53-a872-351a303e3958', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12
Before 2008, non-executive directors were at a disadvantage because of their lack of
.
Locate
13
Boards tend to place too much emphasis on
considerations that are only of short-term relevance.
Locate
14
On certain matters, such as pay, the board may have to accept the views of
.
Locate

13 Boards tend to place too much emphasis on ____ considerations that are only of short-term relevance. Locate$md$, NULL, ARRAY['.*financial.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e2b71ec7-9634-5f7a-bd95-5b64241c82f5', '2f0280c4-f0e4-5c6a-8770-d4a3a613eff8', 14, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12
Before 2008, non-executive directors were at a disadvantage because of their lack of
.
Locate
13
Boards tend to place too much emphasis on
considerations that are only of short-term relevance.
Locate
14
On certain matters, such as pay, the board may have to accept the views of
.
Locate

14 On certain matters, such as pay, the board may have to accept the views of ____ . Locate$md$, NULL, ARRAY['.*shareholders.*','.*investors.*']);

COMMIT;
