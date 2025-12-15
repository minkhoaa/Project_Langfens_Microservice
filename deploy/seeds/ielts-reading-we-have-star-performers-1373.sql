BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-we-have-star-performers-1373'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-we-have-star-performers-1373';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-we-have-star-performers-1373';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-we-have-star-performers-1373';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ac99d305-5040-5c93-b80d-9ade4f6b2709', 'ielts-reading-we-have-star-performers-1373', $t$We have Star performers!$t$, $md$## We have Star performers!

Nguồn:
- Test: https://mini-ielts.com/1373/reading/we-have-star-performers
- Solution: https://mini-ielts.com/1373/view-solution/reading/we-have-star-performers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c959ae85-1eeb-586b-a166-cf9e2ee691cb', 'ac99d305-5040-5c93-b80d-9ade4f6b2709', 1, $t$Reading — We have Star performers!$t$, $md$Read the passage and answer questions **1–13**.

### Passage: We have Star performers!

A

The difference between companies is people. With capital and technology in plentiful supply, the critical resource for companies in the knowledge era will be human talent. Companies full of achievers will, by definition, outperform organisations of plodders. Ergo, compete ferociously for the best people. Poach and pamper stars; ruthlessly weed out second-raters. This, in essence, has been the recruitment strategy of the ambitious company of the past decade. The ‘talent mindset’ was given definitive form in two reports by the consultancy McKinsey famously entitled The War for Talent. Although the intensity of the warfare subsequently subsided along with the air in the internet bubble, it has been warming up again as the economy tightens: labour shortages, for example, are the reason the government has laid out the welcome mat for immigrants from the new Europe.

B

Yet while the diagnosis – people are important – is evident to the point of platitude, the apparently logical prescription – hire the best – like so much in management is not only not obvious: it is in fact profoundly wrong. The first suspicions dawned with the crash to earth of the dotcom meteors, which showed that dumb is dumb whatever the IQ of those who perpetrate it. The point was illuminated in brilliant relief by Enron, whose leaders, as a New Yorker article called ‘The Talent Myth’ entertainingly related, were so convinced of their own cleverness that they never twigged that collective intelligence is not the sum of a lot of individual intelligence. In fact, in a profound sense, the two are opposites. Enron believed in stars, noted author Malcolm Gladwell, because they didn’t believe in systems. But companies don’t just create: ‘they execute and compete and coordinate the efforts of many people, and the organisations that are most successful at that task are the ones where the system is the star’. The truth is that you can’t win the talent wars by hiring stars – only lose it. New light on why this should be so is thrown by an analysis of star behaviour in this months’ Harvard Business Review. In a study of the careers of 1,000 star-stock analysts in the 1990s, the researchers found that when a company recruited a star performer, three things happened.

C

First, stardom doesn’t easily transfer from one organisation to another. In many cases, performance dropped sharply when high performers switched employers and in some instances never recovered. More of success than commonly supposed is due to the working environment – systems, processes, leadership, accumulated embedded learning that are absent in and can’t be transported to the new firm. Moreover, precisely because of their past stellar performance, stars were unwilling to learn new tricks and antagonised those (on whom they now unwittingly depended) who could teach them. So they moved, upping their salary as they did – 36 per cent moved on within three years, fast even for Wall Street. Second, group performance suffered as a result of tensions and resentment by rivals within the team. One respondent likened hiring a star to an organ transplant. The new organ can damage others by hogging the blood supply, other organs can start aching or threaten to stop working or the body can reject the transplants altogether, he said. ‘You should think about it very carefully before you do a transplant to a healthy body.’ Third, investors punished the offender by selling its stock. This is ironic since the motive for importing stars was often a suffering share price in the first place. Shareholders evidently believe that the company is overpaying, the hiree is cashing in on a glorious past rather than preparing for a glowing present, and a spending spree is in the offing.

D

The result of mass star hirings as well as individual ones seems to confirm such doubts. Look at County NatWest and Barclays de Zoete Wedd, both of which hired teams of stars with loud fanfare to do great things in investment banking in the 1990s. Both failed dismally. Everyone accepts the cliche that people make the organisation – but much more does the organisation make the people. When researchers studied the performance of fund managers in the 1990s, they discovered that just 30 per cent of the variation in fund performance was due to the individual, compared to 70 per cent to the company-specific setting.

E

That will be no surprise to those familiar with systems thinking. W Edwards Deming used to say that there was no point in beating up on people when 90 per cent of performance variation was down to the system within which they worked. Consistent improvement, he said, is a matter not of raising the level of individual intelligence, but of the learning of the organisation as a whole. The star system is glamorous – for the few. But it rarely benefits the company that thinks it is working it. And the knock-on consequences indirectly affect everyone else too. As one internet response to Gladwell’s New Yorker article put it: after Enron, ‘the rest of corporate America is stuck with overpaid, arrogant, underachieving, and relatively useless talent.’

F

Football is another illustration of the star vs systems strategic choice. As with investment banks and stockbrokers, it seems obvious that success should ultimately be down to money. Great players are scarce and expensive. So the club that can afford more of them than anyone else will win. But the performance of Arsenal and Manchester United on one hand and Chelsea and Real Madrid on the other proves that it’s not as easy as that. While Chelsea and Real have the funds to be compulsive star collectors – as with Juan Sebastian Veron – they are less successful than Arsenal and United which, like Liverpool before them, have put much more emphasis on developing a setting within which stars-in-the-making can flourish. Significantly, Thierry Henry, Patrick Veira and Robert Pires are much bigger stars than when Arsenal bought them, their value (in all senses) enhanced by the Arsenal system. At Chelsea, by contrast, the only context is the stars themselves – managers with different outlooks come and go every couple of seasons. There is no settled system for the stars to blend into. The Chelsea context has not only not added value, but it has also subtracted it. The side is less than the sum of its exorbitantly expensive parts. Even Real Madrid’s galacticos, the most extravagantly gifted on the planet, are being outperformed by less talented but better-integrated Spanish sides. In football, too, stars are trumped by systems.

G

So if not by hiring stars, how do you compete in the war for talent? You grow your own. This worked for investment analysts, where some companies were not only better at creating stars but also at retaining them. Because they had a much more sophisticated view of the interdependent relationship between star and system, they kept them longer without resorting to the exorbitant salaries that were so destructive to rivals.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a2c5e24-0411-5fcd-8283-d9097b611d78', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
One example from non-commerce/business settings that better system win bigger stars
2
One failed company that believes stars rather than the system
3
One suggestion that the author made to acquire employees than to win the competition nowadays
4
One metaphor to human medical anatomy that illustrates the problems of hiring stars.

1 ____ One example from non-commerce/business settings that better system win bigger stars$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93352e69-e8f6-5e39-99fe-16e41abbb7c8', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ff7178e-d387-52f0-8e2e-f2dd108694a3', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1213e52-72e2-5941-a360-c01100604ac2', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e4706e8-d3fc-5bb3-910d-8ba9ba93e6ac', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a956fd5e-9e35-58e6-a98e-a7c84644563b', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8941ed8e-db16-56b3-84f0-745b38ff93bd', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c4c83c7-ccbd-575f-a8d3-47287e51c250', '0a2c5e24-0411-5fcd-8283-d9097b611d78', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0cfdf6e-242e-5fba-9ac7-434c1272e150', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
One example from non-commerce/business settings that better system win bigger stars
2
One failed company that believes stars rather than the system
3
One suggestion that the author made to acquire employees than to win the competition nowadays
4
One metaphor to human medical anatomy that illustrates the problems of hiring stars.

2 ____ One failed company that believes stars rather than the system$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aefc4704-8a62-583e-bd75-33647d465f1e', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb37f406-8f8b-5bf0-a981-e9d6c542903e', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36de9df6-9c09-5f69-a3bb-88f1222c8561', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80a3dc19-d348-5e59-bc86-acd09e99b302', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f95022d3-40c3-5c6c-8f54-44cb12a32db6', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('662b0d94-7a6b-5ca3-8b3d-84d85afc3292', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7920c9ff-bdd5-5468-91fc-60c324480c16', 'c0cfdf6e-242e-5fba-9ac7-434c1272e150', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('717241a7-8447-5aa2-bdcc-a23891d3eb33', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
One example from non-commerce/business settings that better system win bigger stars
2
One failed company that believes stars rather than the system
3
One suggestion that the author made to acquire employees than to win the competition nowadays
4
One metaphor to human medical anatomy that illustrates the problems of hiring stars.

3 ____ One suggestion that the author made to acquire employees than to win the competition nowadays$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('910ba4a9-379c-5ed4-aade-bc3dd422940c', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7fae3b5-beaf-525d-a551-312160db3601', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c4bb9d-4eb6-5c8d-8644-c3e6648c957a', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72a8a8ed-8cee-5e3d-8ae1-502e9644ac95', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33b9eaf5-663b-528d-9d46-2e868113b96f', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58ab3b8b-c85c-51ec-b08e-16556ee7ed79', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c0638d7-05f1-5c9c-a82d-a074a437f89f', '717241a7-8447-5aa2-bdcc-a23891d3eb33', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
One example from non-commerce/business settings that better system win bigger stars
2
One failed company that believes stars rather than the system
3
One suggestion that the author made to acquire employees than to win the competition nowadays
4
One metaphor to human medical anatomy that illustrates the problems of hiring stars.

4 ____ One metaphor to human medical anatomy that illustrates the problems of hiring stars.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d45dd3e-ae6c-59cf-87c5-6ed86931d5c2', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89e9547e-6aea-59ba-8bd6-3eb538d3cb4f', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc55cbe9-ca9c-503e-a262-0bdf62d0b4d5', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b56c8b9-b661-5d2e-a8ab-75cafdaa36ce', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('396850bd-9bdf-5e86-b684-42aca6b9e539', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6377835-dadf-58c3-80c7-a08d2624aeb6', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6934c1cc-d73a-5ddd-8ae1-3bafba2f2c02', 'a42b6483-bcaf-5d1d-a9ad-da7d2854d08e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a253c351-74e4-57ba-942a-ac41748b7026', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
McKinsey who wrote The War for Talent had not expected the huge influence made by this book.
6
Economic condition becomes one of the factors which decide whether or not a country would prefer to hire foreign employees.
7
The collapse of Enron is caused totally by an unfortunate incident instead of company’s management mistake.
8
Football clubs that focus making stars in the setting are better than simply collecting stars

5 ____ McKinsey who wrote The War for Talent had not expected the huge influence made by this book.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a447b3e-c840-5899-91fb-61f12a10a25d', 'a253c351-74e4-57ba-942a-ac41748b7026', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6809f2c5-b3f1-50c8-aaf3-99930a36b373', 'a253c351-74e4-57ba-942a-ac41748b7026', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('774cde45-c032-511f-b9bc-460b338904e2', 'a253c351-74e4-57ba-942a-ac41748b7026', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('977b0230-f51e-5028-91e4-7d77bad3ed15', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
McKinsey who wrote The War for Talent had not expected the huge influence made by this book.
6
Economic condition becomes one of the factors which decide whether or not a country would prefer to hire foreign employees.
7
The collapse of Enron is caused totally by an unfortunate incident instead of company’s management mistake.
8
Football clubs that focus making stars in the setting are better than simply collecting stars

6 ____ Economic condition becomes one of the factors which decide whether or not a country would prefer to hire foreign employees.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db790d0c-7f7e-58d1-8785-dbbc0ce4c017', '977b0230-f51e-5028-91e4-7d77bad3ed15', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5a8b581-da7f-5ad5-8ffd-1d3002200c1f', '977b0230-f51e-5028-91e4-7d77bad3ed15', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b627b8f8-79af-51f3-ac0b-dcbaa9f3d8df', '977b0230-f51e-5028-91e4-7d77bad3ed15', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f091fb10-fe22-506a-ab52-8005625bb46e', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
McKinsey who wrote The War for Talent had not expected the huge influence made by this book.
6
Economic condition becomes one of the factors which decide whether or not a country would prefer to hire foreign employees.
7
The collapse of Enron is caused totally by an unfortunate incident instead of company’s management mistake.
8
Football clubs that focus making stars in the setting are better than simply collecting stars

7 ____ The collapse of Enron is caused totally by an unfortunate incident instead of company’s management mistake.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fd812df-a868-5d39-b5f6-6e9e2e6f3f88', 'f091fb10-fe22-506a-ab52-8005625bb46e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86fef3f9-9a01-5d48-b60d-bf88e4646829', 'f091fb10-fe22-506a-ab52-8005625bb46e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('070efe65-bb71-5cb2-bdbd-3cd92e543ea7', 'f091fb10-fe22-506a-ab52-8005625bb46e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2637a0f-67be-58e3-aa04-856b925d83fa', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
McKinsey who wrote The War for Talent had not expected the huge influence made by this book.
6
Economic condition becomes one of the factors which decide whether or not a country would prefer to hire foreign employees.
7
The collapse of Enron is caused totally by an unfortunate incident instead of company’s management mistake.
8
Football clubs that focus making stars in the setting are better than simply collecting stars

8 ____ Football clubs that focus making stars in the setting are better than simply collecting stars$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ace019e1-11e5-5158-955e-04a6c860765c', 'c2637a0f-67be-58e3-aa04-856b925d83fa', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('410868cb-2636-5a16-add9-fc11cf4fbff2', 'c2637a0f-67be-58e3-aa04-856b925d83fa', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b24ad730-dfe1-52ef-b6cb-9d00c30b54a8', 'c2637a0f-67be-58e3-aa04-856b925d83fa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b9ae0f9e-6387-5cc3-8b20-c4c94c4279c4', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
An investigation carried out on 1000
9
. Participants of a survey by Harvard Business Review found a company hire a
10
has negative effects. For instance, they behave considerably worse in a new team than in the
11
that they used to be. They move faster than wall street and increase their
12
. Secondly, they faced rejections or refuse from those
13
within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.

An investigation carried out on 1000 9 ____ . Participants of a survey by Harvard Business Review found a company hire a 10 ____ has negative effects. For instance, they behave considerably worse in a new team than in the 11 ____ that they used to be. They move faster than wall street and increase their 12 ____ . Secondly, they faced rejections or refuse from those 13 ____ within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.$md$, NULL, ARRAY['.*analysts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b3743b41-c505-5c2a-9338-adf3147d14b1', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
An investigation carried out on 1000
9
. Participants of a survey by Harvard Business Review found a company hire a
10
has negative effects. For instance, they behave considerably worse in a new team than in the
11
that they used to be. They move faster than wall street and increase their
12
. Secondly, they faced rejections or refuse from those
13
within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.

An investigation carried out on 1000 9 ____ . Participants of a survey by Harvard Business Review found a company hire a 10 ____ has negative effects. For instance, they behave considerably worse in a new team than in the 11 ____ that they used to be. They move faster than wall street and increase their 12 ____ . Secondly, they faced rejections or refuse from those 13 ____ within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.$md$, NULL, ARRAY['.*analysts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ccf87317-5ca4-5146-9cda-caf1b776f926', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
An investigation carried out on 1000
9
. Participants of a survey by Harvard Business Review found a company hire a
10
has negative effects. For instance, they behave considerably worse in a new team than in the
11
that they used to be. They move faster than wall street and increase their
12
. Secondly, they faced rejections or refuse from those
13
within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.

An investigation carried out on 1000 9 ____ . Participants of a survey by Harvard Business Review found a company hire a 10 ____ has negative effects. For instance, they behave considerably worse in a new team than in the 11 ____ that they used to be. They move faster than wall street and increase their 12 ____ . Secondly, they faced rejections or refuse from those 13 ____ within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.$md$, NULL, ARRAY['.*analysts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9239bb4b-0ae8-5a71-ae63-039c91c5d0c9', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
An investigation carried out on 1000
9
. Participants of a survey by Harvard Business Review found a company hire a
10
has negative effects. For instance, they behave considerably worse in a new team than in the
11
that they used to be. They move faster than wall street and increase their
12
. Secondly, they faced rejections or refuse from those
13
within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.

An investigation carried out on 1000 9 ____ . Participants of a survey by Harvard Business Review found a company hire a 10 ____ has negative effects. For instance, they behave considerably worse in a new team than in the 11 ____ that they used to be. They move faster than wall street and increase their 12 ____ . Secondly, they faced rejections or refuse from those 13 ____ within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.$md$, NULL, ARRAY['.*analysts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('72c4c468-be56-5468-8943-a9df441cce4f', 'c959ae85-1eeb-586b-a166-cf9e2ee691cb', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
An investigation carried out on 1000
9
. Participants of a survey by Harvard Business Review found a company hire a
10
has negative effects. For instance, they behave considerably worse in a new team than in the
11
that they used to be. They move faster than wall street and increase their
12
. Secondly, they faced rejections or refuse from those
13
within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.

An investigation carried out on 1000 9 ____ . Participants of a survey by Harvard Business Review found a company hire a 10 ____ has negative effects. For instance, they behave considerably worse in a new team than in the 11 ____ that they used to be. They move faster than wall street and increase their 12 ____ . Secondly, they faced rejections or refuse from those 13 ____ within the team. Lastly, the one who made mistakes had been punished by selling his/her stock share.$md$, NULL, ARRAY['.*analysts.*']);

COMMIT;
