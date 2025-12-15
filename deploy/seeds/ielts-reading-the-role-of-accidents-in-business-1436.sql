BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-role-of-accidents-in-business-1436'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-role-of-accidents-in-business-1436';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-role-of-accidents-in-business-1436';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-role-of-accidents-in-business-1436';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6cbe2a0c-d5ad-5738-8dc3-c4e548d8ba08', 'ielts-reading-the-role-of-accidents-in-business-1436', $t$The role of accidents in business$t$, $md$## The role of accidents in business

Nguồn:
- Test: https://mini-ielts.com/1436/reading/the-role-of-accidents-in-business
- Solution: https://mini-ielts.com/1436/view-solution/reading/the-role-of-accidents-in-business$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2123c7db-13ac-5f57-ba0f-b8a193a39831', '6cbe2a0c-d5ad-5738-8dc3-c4e548d8ba08', 1, $t$Reading — The role of accidents in business$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The role of accidents in business

In 1894 Dr John Kellogg and his brother. Will, were supervising a hospital and health spa in Michigan. The patients were on a restricted diet. One day, the brothers left cooked wheat untended for more than 24 hours. When they returned, they saw what they had done. It was no good to eat, but they decided to run the stale wheat through rollers, just to see how it would turn out. Normally, the process produced long sheets, but they were surprised to discover that this time the rollers created flat flakes. They baked them, and then tried the same thing with corn. From this accidental discovery came the cornflakes that generations have now been eating for breakfast.

Accidents happen; there is nothing predictable and orderly about innovation. Nobel laureate Sir Alan Hodgkin, who discovered how nerve cells transmit electrical impulses between the skin and the brain, commented: 'I believe that the record of my published papers conveys an impression of directedness and planning which does not at all coincide with the actual sequence of events.’

The same rule applies in business. The mistake that gave US cornflakes keeps repeating itself in the history of disruptive innovation, the kind that transforms markets. Louis Daguerre, for, instance, discovered the technique that gave US photography in the 1830s, when drops of mercury from a shattered thermometer produced a photographic image. The microwave was discovered when Peroy Spender, a scientist with Raytheon, was testing a new vacuum tube and discovered that the sweet in his pocket had melted. The artificial sweetener, saccharin, was the unintentional result of a medical scientist’s work on a chemical treatment for gastric ulcers. While working for the firm 3M, researcher Art Fry had no idea he was taking the first steps towards Post- It Notes when he used bits of adhesive office paper that could be easily lifted off the page to replace the scrap paper bookmarks that kept falling out of his hymn book.

Breakthrough and disruptive innovation are rarely driven by orderly process. Usually they come out of a chaotic, haphazard mess, which is why big companies, full of managers schooled in business programmes designed to eliminate random variation and mistakes, struggle with them. In these sorts of environments, accidents are called failures and are discouraged.

It is no surprise then that research from the late British economist Paul Geroski and London Business School’s Constantinos Markides found that companies that were skilled at innovation were usually not that skilled when it came to commercialisation, and vice versa. Their book, Fast Second, divides businesses into 'colonists’ and 'consolidators’. Small and nimble, colonists are adept at creating market niches but are terrible institution builders. Consolidators, with their strong cultures of discipline and cost control, know how to take clever ideas from other firms and turn them into mass­market items. Microsoft is a prime instance of this.

With companies spending hundreds of billions of dollars on research and development, US academics Robert Austin and Lee Devin examined how managers can encourage productive slip-ups. In their article Accident, Intention and Expectation in the Innovation Process, they argue that business processes actually prevent helpful mis-steps from occurring. According to their catalogue of accidents, not all false steps and mishaps are equal. Accidents, they say, come from unlikely mental associations such as memories and vague connections, looking for something and finding it in an unexpected way, looking for one thing and finding something else, and not looking for anything but finding something valuable.

Accident-prone innovation, they say, requires companies to get outside the ‘cone of expectation’. It means throwing together groups from diverse backgrounds, and combining ideas in unpredictable ways, other strategies also include having systems that watch out for accidents and examine them for value, generating them when they do not happen often enough, seizing oil the useful ones, capturing their valuable features, and building on them to add value and give potential for useful accidents.

All this, however, requires thinking that is often counter-intuitive to the way businesses operate. In other words, it is the kind of thinking that goes against the beliefs of most business managers. It runs counter to the notion frequently pushes by consultants that you can ‘harness’ creativity and direct it to line up with intention. ‘The cost of accidents business, people tend to call such efforts failure.’

There are tentative signs that more companies are starting to realise that failure can lead to commercial gain, and that this is part or the risk-talking that underpins innovation. Australia’s largest brewing company, for example, made a bad error when it launched a new beer called Empire Lager, pitched at younger consumers. Having spent a fortune creating a beer with a sweeter taste, designing a great-looking bottle and a television campaign, Foster’s was left with a drink that no-one wanted to buy. The target market was more interested in brands built up by word of mouth.

Instead of wiping the unsuccessfull product launch, Fosters used this lesson learned to go on and develop other brands instead. One of them, Pure Blonde, is now ranked as Australia’s fifth-largest beer brand. Unlike Empire Lager, there has been almost no promotion and its sales are generated more by word of mouth.

Other companies are taking similar steps to study their own slip-ups. Intuit, the company behind financial tools such as Quicken, holds regular ‘When Learning Hurts’ sessions. But this sort of transformation is never easy. In a market that focuses on the short-term, convincing employees and shareholders to tolerate failure and not play it safe is a big thing to ask.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17d4f32a-b759-5c08-9c16-ce2846a2cfb9', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The delay in the process used by the Kellogg brothers affected the final product.
2
Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.
3
Daguerre is an exception to the general rule of innovation.
4
The discovery of saccharin occurred by accident during drug research.
5
The company 3M should have supported Art Fry by funding his idea of Post-It Notes.

1 ____ The delay in the process used by the Kellogg brothers affected the final product.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5997224b-5884-5c2a-8671-7b3fff939ee0', '17d4f32a-b759-5c08-9c16-ce2846a2cfb9', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2acc7db3-a07f-5f20-9eaf-22cf258cc689', '17d4f32a-b759-5c08-9c16-ce2846a2cfb9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79902736-6b87-5154-85a5-eacc2960d4be', '17d4f32a-b759-5c08-9c16-ce2846a2cfb9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('524e1c1f-dfe9-5ac5-9912-6ad87872e37e', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The delay in the process used by the Kellogg brothers affected the final product.
2
Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.
3
Daguerre is an exception to the general rule of innovation.
4
The discovery of saccharin occurred by accident during drug research.
5
The company 3M should have supported Art Fry by funding his idea of Post-It Notes.

2 ____ Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35d2fa08-3bfa-556b-a343-3fe95d907211', '524e1c1f-dfe9-5ac5-9912-6ad87872e37e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29c8c185-6c63-54eb-a3ed-947cabfe8fa6', '524e1c1f-dfe9-5ac5-9912-6ad87872e37e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8af81416-cc8e-5d08-abce-d93fcf97e866', '524e1c1f-dfe9-5ac5-9912-6ad87872e37e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fd605ed-f807-5391-a566-20ec1341678b', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The delay in the process used by the Kellogg brothers affected the final product.
2
Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.
3
Daguerre is an exception to the general rule of innovation.
4
The discovery of saccharin occurred by accident during drug research.
5
The company 3M should have supported Art Fry by funding his idea of Post-It Notes.

3 ____ Daguerre is an exception to the general rule of innovation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b13e27e0-e9cf-5205-984a-44decb75ab3d', '1fd605ed-f807-5391-a566-20ec1341678b', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('854153bd-9d97-57bd-8814-26c7527b4d6f', '1fd605ed-f807-5391-a566-20ec1341678b', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14992c8c-caf4-5acc-ac64-57a8321f78c4', '1fd605ed-f807-5391-a566-20ec1341678b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2132d9e-2cf0-520c-a600-b1010f138ce9', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The delay in the process used by the Kellogg brothers affected the final product.
2
Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.
3
Daguerre is an exception to the general rule of innovation.
4
The discovery of saccharin occurred by accident during drug research.
5
The company 3M should have supported Art Fry by funding his idea of Post-It Notes.

4 ____ The discovery of saccharin occurred by accident during drug research.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7799f4b4-e938-5ea0-8400-2ab402546003', 'c2132d9e-2cf0-520c-a600-b1010f138ce9', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58c83416-434c-5394-b6ca-c9419844f24a', 'c2132d9e-2cf0-520c-a600-b1010f138ce9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1dcc58d-c154-52a3-abf9-9004c151eaf4', 'c2132d9e-2cf0-520c-a600-b1010f138ce9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('972b8e6e-b116-5a94-b68d-89c59a8c4007', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The delay in the process used by the Kellogg brothers affected the final product.
2
Sir Alan Hodgkin is an example of someone whose work proceeded in a logical and systematic way.
3
Daguerre is an exception to the general rule of innovation.
4
The discovery of saccharin occurred by accident during drug research.
5
The company 3M should have supported Art Fry by funding his idea of Post-It Notes.

5 ____ The company 3M should have supported Art Fry by funding his idea of Post-It Notes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('257c5e86-4c2e-5ac1-bc0f-2d2b95c36ab4', '972b8e6e-b116-5a94-b68d-89c59a8c4007', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c751f037-71c5-5f98-b708-bfe8062383f6', '972b8e6e-b116-5a94-b68d-89c59a8c4007', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('450cece7-c643-5855-8dd3-f3dbcd74339a', '972b8e6e-b116-5a94-b68d-89c59a8c4007', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('165895f8-e7a1-57a6-9b97-5ffea6050f46', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
The usual business environment
7
Geroki and Markides’s book
8
Microsoft is an example of a company which
9
The origin of useful accidents
A
can be found in unusual thoughts and chance events.
B
can be taught in business schools.
c
has made a success from someone else’s invention.
D
is designed to nurture differences.
E
is unlikely to lead to creative innovation
F
says that all mistakes are the same.
G
shows that businesses are good at either inventing of selling.
H
suggests ways of increasing the number of mistakes

6 ____ The usual business environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06442807-f727-5a91-acdc-5a876d544aa9', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ef92e72-b509-56a4-8427-685ccde28287', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acfea978-3f20-5c9a-8ec2-648f47d83af8', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e4d0f14-7b39-5d4b-b4e3-ba772f524cfe', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81d554e1-b08b-5cd6-977a-85fd55c175b9', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53af997c-36b7-5c83-aa5a-b98251302ca7', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ba33724-c657-56da-82b2-68d26812f66b', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba5e9349-de5c-5241-94cd-c276d757eb21', '165895f8-e7a1-57a6-9b97-5ffea6050f46', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93026365-4818-564b-9abe-2cbda3c6c6e2', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
The usual business environment
7
Geroki and Markides’s book
8
Microsoft is an example of a company which
9
The origin of useful accidents
A
can be found in unusual thoughts and chance events.
B
can be taught in business schools.
c
has made a success from someone else’s invention.
D
is designed to nurture differences.
E
is unlikely to lead to creative innovation
F
says that all mistakes are the same.
G
shows that businesses are good at either inventing of selling.
H
suggests ways of increasing the number of mistakes

7 ____ Geroki and Markides’s book$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eaf810b-8f21-5156-9da5-647975f235d0', '93026365-4818-564b-9abe-2cbda3c6c6e2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('870f2056-a11c-5bf3-99fc-4e84528f5cd4', '93026365-4818-564b-9abe-2cbda3c6c6e2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cb0c09f-1c3c-56a1-a635-ac28f36aeb70', '93026365-4818-564b-9abe-2cbda3c6c6e2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b64fcd93-2675-5d5d-954a-1bdc419ac7df', '93026365-4818-564b-9abe-2cbda3c6c6e2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd37fd4b-850a-55ba-8c2d-6de0d71b842c', '93026365-4818-564b-9abe-2cbda3c6c6e2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0315e6d-c823-50e0-b0d1-ef464581aa9e', '93026365-4818-564b-9abe-2cbda3c6c6e2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('804cc7a3-e4d9-5939-8884-9b133b434e4b', '93026365-4818-564b-9abe-2cbda3c6c6e2', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b70d8338-0da6-531d-b24d-97bb13c1a58d', '93026365-4818-564b-9abe-2cbda3c6c6e2', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('413c00ae-3bdf-53f0-9d95-0f3b27418c44', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
The usual business environment
7
Geroki and Markides’s book
8
Microsoft is an example of a company which
9
The origin of useful accidents
A
can be found in unusual thoughts and chance events.
B
can be taught in business schools.
c
has made a success from someone else’s invention.
D
is designed to nurture differences.
E
is unlikely to lead to creative innovation
F
says that all mistakes are the same.
G
shows that businesses are good at either inventing of selling.
H
suggests ways of increasing the number of mistakes

8 ____ Microsoft is an example of a company which$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e528f84-578b-5e39-bc3a-b90d3fce297b', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e11d35aa-406e-543b-9f73-84a40e312cf0', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adb68dde-8c3c-5001-a5db-1681d04fbba4', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2413ee88-5eff-5d46-90e7-dabe59937bcc', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f284067-5860-5c4f-b04b-0f76811a479d', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec4b8677-1c33-5e01-ae34-0ed3a12fb01c', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66b6510e-473f-5501-9b0e-648c89c19e77', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c6faa55-d0a9-5f88-b98d-888ae5813509', '413c00ae-3bdf-53f0-9d95-0f3b27418c44', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17b41dbc-cb9d-547f-a6c1-d998692779b3', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
The usual business environment
7
Geroki and Markides’s book
8
Microsoft is an example of a company which
9
The origin of useful accidents
A
can be found in unusual thoughts and chance events.
B
can be taught in business schools.
c
has made a success from someone else’s invention.
D
is designed to nurture differences.
E
is unlikely to lead to creative innovation
F
says that all mistakes are the same.
G
shows that businesses are good at either inventing of selling.
H
suggests ways of increasing the number of mistakes

9 ____ The origin of useful accidents$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd1757e7-7a06-56db-b156-edda6c6d4410', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('603fdfdd-4306-5e0c-bf7f-e8f692e89ac6', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90a3c753-e83c-5096-a891-fc637b35ef62', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40c9190e-73a6-5872-b8b3-1f0cae2e415b', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8925bc23-f6f7-596f-997d-0a37614d55b6', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56f0c86c-a1ef-5584-aa56-7a7f67d1004f', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11e20cc9-734c-5a38-9d16-34c41c19649a', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('933e4ed8-760b-5aef-91d2-283d9b9a0f49', '17b41dbc-cb9d-547f-a6c1-d998692779b3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d81f78e-8fda-5481-b76f-1eebd3a6191e', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Choose the correct letter, A, B, c or D
Write the correct letter in boxes 10-14 on your answer sheet.
10. How do Austin and Devin advise companies to get out of the 'cone of expectation'?
A
by decreasing the number of company systems
B
by forming teams of different types of people
C
by hiring new and creative people
D
by holding regular brainstorming meetings
11. In recommending ‘counter-intuitive’ thinking, what do Austin and Devin imply?
A
that failing at business is bad for staff morale
B
that innovation cannot be planned for
C
that most businesses should be devoted to avoiding mistakes
D
that the cost of mistakes is an important consideration
12. The writer describes the Empire Lager disaster in order to show that
A
success can come out of a business failure
B
the majority of companies now value risk-talking.
C
TV advertising works better on older people
D
young beer drinkers do not like a sweet taste
13. Pure Blonde has been more successful than Empire Lager because
A
digital media other than TV were used.
B
it was advertised under a different brand name.
C
it was launched with very little advertising.
D
the advertising budget was larger
14. The writer concludes that creating a culture that learns from mistakes
A
brings short-term financial gains.
B
can be very difficult for some companies.
C
holds no risk for workers.
D
is a popular move with shareholders.

Choose the correct letter, A, B, c or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('158368e1-97fb-53e8-9537-3e600ecdfecb', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Choose the correct letter, A, B, c or D
Write the correct letter in boxes 10-14 on your answer sheet.
10. How do Austin and Devin advise companies to get out of the 'cone of expectation'?
A
by decreasing the number of company systems
B
by forming teams of different types of people
C
by hiring new and creative people
D
by holding regular brainstorming meetings
11. In recommending ‘counter-intuitive’ thinking, what do Austin and Devin imply?
A
that failing at business is bad for staff morale
B
that innovation cannot be planned for
C
that most businesses should be devoted to avoiding mistakes
D
that the cost of mistakes is an important consideration
12. The writer describes the Empire Lager disaster in order to show that
A
success can come out of a business failure
B
the majority of companies now value risk-talking.
C
TV advertising works better on older people
D
young beer drinkers do not like a sweet taste
13. Pure Blonde has been more successful than Empire Lager because
A
digital media other than TV were used.
B
it was advertised under a different brand name.
C
it was launched with very little advertising.
D
the advertising budget was larger
14. The writer concludes that creating a culture that learns from mistakes
A
brings short-term financial gains.
B
can be very difficult for some companies.
C
holds no risk for workers.
D
is a popular move with shareholders.

Choose the correct letter, A, B, c or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7368c61c-47c0-5b4b-b44a-42280b03fb14', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Choose the correct letter, A, B, c or D
Write the correct letter in boxes 10-14 on your answer sheet.
10. How do Austin and Devin advise companies to get out of the 'cone of expectation'?
A
by decreasing the number of company systems
B
by forming teams of different types of people
C
by hiring new and creative people
D
by holding regular brainstorming meetings
11. In recommending ‘counter-intuitive’ thinking, what do Austin and Devin imply?
A
that failing at business is bad for staff morale
B
that innovation cannot be planned for
C
that most businesses should be devoted to avoiding mistakes
D
that the cost of mistakes is an important consideration
12. The writer describes the Empire Lager disaster in order to show that
A
success can come out of a business failure
B
the majority of companies now value risk-talking.
C
TV advertising works better on older people
D
young beer drinkers do not like a sweet taste
13. Pure Blonde has been more successful than Empire Lager because
A
digital media other than TV were used.
B
it was advertised under a different brand name.
C
it was launched with very little advertising.
D
the advertising budget was larger
14. The writer concludes that creating a culture that learns from mistakes
A
brings short-term financial gains.
B
can be very difficult for some companies.
C
holds no risk for workers.
D
is a popular move with shareholders.

Choose the correct letter, A, B, c or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ab0c56d-66d2-50ea-bd1b-62fea0737f54', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Choose the correct letter, A, B, c or D
Write the correct letter in boxes 10-14 on your answer sheet.
10. How do Austin and Devin advise companies to get out of the 'cone of expectation'?
A
by decreasing the number of company systems
B
by forming teams of different types of people
C
by hiring new and creative people
D
by holding regular brainstorming meetings
11. In recommending ‘counter-intuitive’ thinking, what do Austin and Devin imply?
A
that failing at business is bad for staff morale
B
that innovation cannot be planned for
C
that most businesses should be devoted to avoiding mistakes
D
that the cost of mistakes is an important consideration
12. The writer describes the Empire Lager disaster in order to show that
A
success can come out of a business failure
B
the majority of companies now value risk-talking.
C
TV advertising works better on older people
D
young beer drinkers do not like a sweet taste
13. Pure Blonde has been more successful than Empire Lager because
A
digital media other than TV were used.
B
it was advertised under a different brand name.
C
it was launched with very little advertising.
D
the advertising budget was larger
14. The writer concludes that creating a culture that learns from mistakes
A
brings short-term financial gains.
B
can be very difficult for some companies.
C
holds no risk for workers.
D
is a popular move with shareholders.

Choose the correct letter, A, B, c or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33222505-83f9-54e0-a049-5507030c586a', '2123c7db-13ac-5f57-ba0f-b8a193a39831', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Choose the correct letter, A, B, c or D
Write the correct letter in boxes 10-14 on your answer sheet.
10. How do Austin and Devin advise companies to get out of the 'cone of expectation'?
A
by decreasing the number of company systems
B
by forming teams of different types of people
C
by hiring new and creative people
D
by holding regular brainstorming meetings
11. In recommending ‘counter-intuitive’ thinking, what do Austin and Devin imply?
A
that failing at business is bad for staff morale
B
that innovation cannot be planned for
C
that most businesses should be devoted to avoiding mistakes
D
that the cost of mistakes is an important consideration
12. The writer describes the Empire Lager disaster in order to show that
A
success can come out of a business failure
B
the majority of companies now value risk-talking.
C
TV advertising works better on older people
D
young beer drinkers do not like a sweet taste
13. Pure Blonde has been more successful than Empire Lager because
A
digital media other than TV were used.
B
it was advertised under a different brand name.
C
it was launched with very little advertising.
D
the advertising budget was larger
14. The writer concludes that creating a culture that learns from mistakes
A
brings short-term financial gains.
B
can be very difficult for some companies.
C
holds no risk for workers.
D
is a popular move with shareholders.

Choose the correct letter, A, B, c or D$md$, NULL);

COMMIT;
