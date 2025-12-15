BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-fear-of-the-unknown-1529'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fear-of-the-unknown-1529';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fear-of-the-unknown-1529';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-fear-of-the-unknown-1529';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f43eb2fe-18a2-5d1a-b518-acae893205ec', 'ielts-reading-fear-of-the-unknown-1529', $t$Fear of the Unknown$t$, $md$## Fear of the Unknown

Nguồn:
- Test: https://mini-ielts.com/1529/reading/fear-of-the-unknown
- Solution: https://mini-ielts.com/1529/view-solution/reading/fear-of-the-unknown$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('237d6c04-418d-5bf5-b833-02e31073d766', 'f43eb2fe-18a2-5d1a-b518-acae893205ec', 1, $t$Reading — Fear of the Unknown$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Fear of the Unknown

American companies fear that innovation is the secret of success-and that they cannot innovate

In the small Umagic office in midtown Manhattan, a team of 30 computer programmers are working on setting up websites that will allow subscribers to feed in details about themselves and their problems and to receive advice from ‘virtual’ versions of personalities regarded as experts in their fields: for example, a well-known dietician, a celebrity fitness trainer, a psychologist well known in the media for here work on parent-child relationships . Umagic Systems is a young firm and it’s hard to predict how far they’ll go .hl ten years’ time, consulting a computer about your diet problems might seem natural or it might seem absurd. But the company and others like it are beginning to seriously worry large American firms, who see such half-crazy new and innovative ideas as a threat to their own future success.

Innovation has become a major concern of American management. Firms have found that it is increasingly difficult to redesign existing products or to produce them more economically. The stars of American business tend today to be innovators such as Amazon (the internet bookstore) and Wal-Mart (the supermarket chain) which have produced completely new ideas or products that have changed their industries.

Over the past 15 years, the firms which have achieved the greatest profits have been the ones which have had the most innovations. But such profits aren’t easy to come by .One of the reasons for the increasing number of mergers between companies is a desperate search for new ideas. And a fortune is spent nowadays on identifying and protecting intellectual property: other people’s ideas.

According to the Pasadena-based Patent & License Exchange in the United States , trading in intangible assets such as intellectual property rose from$15 billion in 1990 to $ 100 billion in 1998,with an increasing proportion of the rewards going to small firms and individuals.

And therein lies the terror for big companies : that innovation seems to work best outside them. Many of the large established companies have been struggling to come up with new products recently.' In the management of creativity ,size is your enemy,’ argues Peter Chemin ,who runs Fox TV and film empire for News Corporation. "One person managing 20 movies is never going to be as involved as one doing five movies .'He has thus tried to break down the studio into smaller units ,even at the risk of incurring higher costs.

It is easier for ideas to develop outside big firms these days. In the past, if a clever scientist had an idea he wanted to commercialise ,he would take it first to a big company. Now, with the banks encouraging individuals to set up new businesses through offering special loans, innovators are more likely to set up on their own. Umagic has already raised $5 million and is about to raise $25 million more. Even in capital-intensive businesses such as pharmaceuticals, entrepreneurs can conduct profitable, early- stage research,selling out to the big firms when they reach expensive,risky clinical trials.

Some giants, including General Electric and Cisco, have been remarkably successful at buying up and integrating scores of small companies. But many others worry about the prices they have to pay and the difficulty in keeping hold of the people who dreamt up the ideas . Everybody would like to develop more ideas in-house. Procter & Gamble is now changing the entire direction of its business from global expansion to product development; one of its new aims is to get innovations accepted across the company .Elsewhere ,the search for innovation had led to a craze for ' intrapreneurship ’ -giving more power to individuals in the company and setting up internal ideas -factories so that talents staff will not leave.

And yet innovation does not happen just because the chief executive wills it. Indeed ,it is extremely difficult to come up with new ideas year in, year out, especially brilliant ones. Underneath all experts' diagrams , lists and charts ,most of the available answers seem to focus on two strengths that are difficult to impose: a culture that looks for new ideas, and leaders who know which ones to back. Companies have to discredit the widespread view that jobs working on new products are for ‘those who can't cope in the real business'. They have to change the culture by introducing hard incentives, such as giving more generous bonuses to those who come up with successful new ideas and, particularly ,not punishing those whose experiments fail.

Will all this reorganization and culture tweaking make big firms more creative? David Post, the founder of Umagic, isn't so sure:’ He also recalls with glee the looks of total incomprehension when he tried to sell his 'virtual experts ' idea three years ago to firms such IBM , though ,as he cheerfully adds,’ of course, they could have been right'. Apparently, innovation -unlike diet,fitness and parenting -is one area where a computer cannot tell you what to do.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dec3de5e-caa3-55d6-82f6-8bfe5b31450c', '237d6c04-418d-5bf5-b833-02e31073d766', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

1 ____ the methods some companies use to try to keep their most creative employees$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab5b44b1-b74e-5baa-95f7-467fde294466', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00d91be3-8319-59c7-9dda-9d72201c55f7', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc22145b-e4da-578a-9d03-d7dc24c2a08d', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e734bc0-f73a-5c01-9ba6-f4092299e41e', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00bbb3ed-d329-5f38-b112-e25b98459957', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba8c59a2-f290-519c-9716-2cf53893307b', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0100a4dc-634a-511e-a33b-9051393b03b1', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c19988b-8dd8-5c31-a6d0-830596440651', 'dec3de5e-caa3-55d6-82f6-8bfe5b31450c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff754feb-6f78-5eaa-ad48-24910af982d7', '237d6c04-418d-5bf5-b833-02e31073d766', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

2 ____ a new way of getting help with your personal difficulties$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d3ed0f4-4a9d-5c38-bdfb-6f394026e92b', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3477b9da-925b-5a3b-a40a-748ed547f987', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e46d9fc-8991-5612-b4ee-50ad128ad8b4', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9cc6c1a-ff85-59c8-90ab-9d0ceb5a4a3f', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('637ff0b0-693b-5b8a-a32f-87a0ae1942f3', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cd2529e-b9fe-5f92-84cb-26d3ac0353be', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd710c3b-1270-5dc8-945b-6a99e52c5f37', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1169ba89-23b0-56a5-aec4-86085fd19dc0', 'ff754feb-6f78-5eaa-ad48-24910af982d7', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('197de0be-f454-5070-97b9-a9bad87464e9', '237d6c04-418d-5bf5-b833-02e31073d766', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

3 ____ how much investment goes into safeguarding the ideas of individuals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec4f53b4-04b0-50e7-b263-d5b5ce618963', '197de0be-f454-5070-97b9-a9bad87464e9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59640727-c2f8-55b1-b939-719faa05ceb4', '197de0be-f454-5070-97b9-a9bad87464e9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79202207-3ca3-5cbc-81c8-75e5fba0930c', '197de0be-f454-5070-97b9-a9bad87464e9', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a90f344a-8881-5c10-a9cf-13be52d24c20', '197de0be-f454-5070-97b9-a9bad87464e9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eaeba854-9f80-5529-9278-2231d441b0e7', '197de0be-f454-5070-97b9-a9bad87464e9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bcb9cbf-5543-579d-b48d-0bb7dc7b938e', '197de0be-f454-5070-97b9-a9bad87464e9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('277db7f9-eeb9-5c5f-8b9e-24afc55aabc2', '197de0be-f454-5070-97b9-a9bad87464e9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eadcbc52-2eb1-5e2b-9a76-780824368d33', '197de0be-f454-5070-97b9-a9bad87464e9', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('944c0786-c807-5ca9-8ba6-1e000aa865c4', '237d6c04-418d-5bf5-b833-02e31073d766', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

4 ____ two examples of companies which have succeeded through being innovative$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4617e8d8-2d35-5378-a5c7-cd9729eb7c60', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('044ccf0b-e398-542f-a0a3-997e1169aa82', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('591ea42c-5076-5123-b2f4-5e21e47b7fcc', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca6b9a3e-31b5-5fb6-99f8-fabda0916cb4', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85716e3b-e856-57d1-9187-65977540cd58', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a29428b0-5b69-5330-b11c-c4d605049b8e', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('943b83c7-8df8-56c1-b714-527614417607', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22cb2e38-ddc3-54f8-8141-d51874383121', '944c0786-c807-5ca9-8ba6-1e000aa865c4', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ce6ae866-374b-5e25-b408-27e4cb454409', '237d6c04-418d-5bf5-b833-02e31073d766', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

5 ____ how some innovators manage to avoid spending large sums of money on testing out their ideas$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c101f79-4f8a-59e7-a5d3-6011564f78ce', 'ce6ae866-374b-5e25-b408-27e4cb454409', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8377c9e8-c14b-5f21-9571-6205a5138cf8', 'ce6ae866-374b-5e25-b408-27e4cb454409', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89e48e89-d59e-5975-b703-f5c092eefccb', 'ce6ae866-374b-5e25-b408-27e4cb454409', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ea0ba2c-a5fe-5651-a18e-c3d292f6f0a0', 'ce6ae866-374b-5e25-b408-27e4cb454409', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9937401-9dd2-5bd3-b232-d027972b15ab', 'ce6ae866-374b-5e25-b408-27e4cb454409', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4b28208-7b17-5fc3-9c4c-4917d6f8f993', 'ce6ae866-374b-5e25-b408-27e4cb454409', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c6baaeb-649d-503b-8945-999b09c21a78', 'ce6ae866-374b-5e25-b408-27e4cb454409', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ac87519-3abb-5c07-ba3b-aab249db2783', 'ce6ae866-374b-5e25-b408-27e4cb454409', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('86b23679-1423-509a-a1f1-e18d724b6ac0', '237d6c04-418d-5bf5-b833-02e31073d766', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

6 ____ a commonly held opinion about product designers that needs to be proved wrong$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7951e0cc-c580-5f30-94cf-b33ddd339d9a', '86b23679-1423-509a-a1f1-e18d724b6ac0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91fb1d5e-9e21-59e2-abc8-b5ee649adc8b', '86b23679-1423-509a-a1f1-e18d724b6ac0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d31d233d-7ad0-5a81-975b-fe1d85ea116c', '86b23679-1423-509a-a1f1-e18d724b6ac0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44f381a2-b95d-57ea-97a1-bb845cc70365', '86b23679-1423-509a-a1f1-e18d724b6ac0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('710b606f-3f77-5e72-8b60-4e68a0976517', '86b23679-1423-509a-a1f1-e18d724b6ac0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e447b27b-fe34-5cc1-a0dc-15a2dc837ee8', '86b23679-1423-509a-a1f1-e18d724b6ac0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24dd0e51-e4a6-5f66-bbcc-da0a6a393957', '86b23679-1423-509a-a1f1-e18d724b6ac0', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('610b319a-8d6c-55ee-835a-b0a9bc380a90', '86b23679-1423-509a-a1f1-e18d724b6ac0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1fb127a-c862-559b-a4df-5dc40ff56aa6', '237d6c04-418d-5bf5-b833-02e31073d766', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
you may use any letter more than once.
1
the methods some companies use to try to keep their most creative employees
2
a new way of getting help with your personal difficulties
3
how much investment goes into safeguarding the ideas of individuals
4
two examples of companies which have succeeded through being innovative
5
how some innovators manage to avoid spending large sums of money on
testing out
their ideas
6
a
commonly held opinion about product designers that needs to be proved
wrong
7
the
target
of
one large company that has changed its business focus

7 ____ the target of one large company that has changed its business focus$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3681e10f-3891-5ec7-aa95-6fbcd5942cea', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52d05492-177f-54e3-b1a4-d3f6ed32fcbe', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a6e96c-3b3f-5ede-b1e2-c8ff112f8cc9', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd44cc14-6f11-5edf-b12c-f17234859cca', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('027ee9be-acf8-566f-94b7-fb25deb24bde', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcd4aea5-eb4b-58d6-8dff-3f185c8bcf86', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bee444d-5765-5f3c-ba8f-f2b6e6bbb976', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd177662-198b-5f03-9a70-caab34fffe12', 'c1fb127a-c862-559b-a4df-5dc40ff56aa6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9cf6f23-2b80-54c4-8f08-4bd8d71657ce', '237d6c04-418d-5bf5-b833-02e31073d766', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Do the following
statements agree with the information given in Reading Passage?
In boxes 8-11
on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Umagic
Systems is an example of a new innovative company.
9
Amazon
and Wal-Mart have exchanged
successful
ideas on innovation.
10
Using
financial rewards to encourage innovation is an outdated practice.
11
IBM failed to understand David Post's 'virtual experts’ idea.

8 ____ Umagic Systems is an example of a new innovative company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38527b2b-60cb-5f8b-b5b0-3a6f58c1659a', 'b9cf6f23-2b80-54c4-8f08-4bd8d71657ce', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1a8fb86-6232-54e1-a36e-47a9deff2d77', 'b9cf6f23-2b80-54c4-8f08-4bd8d71657ce', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('546ff79e-6328-5060-8999-5d039fd6414c', 'b9cf6f23-2b80-54c4-8f08-4bd8d71657ce', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7397ec63-5bc1-5905-b8c5-97ae6cf9c495', '237d6c04-418d-5bf5-b833-02e31073d766', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Do the following
statements agree with the information given in Reading Passage?
In boxes 8-11
on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Umagic
Systems is an example of a new innovative company.
9
Amazon
and Wal-Mart have exchanged
successful
ideas on innovation.
10
Using
financial rewards to encourage innovation is an outdated practice.
11
IBM failed to understand David Post's 'virtual experts’ idea.

9 ____ Amazon and Wal-Mart have exchanged successful ideas on innovation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('873c3880-b60a-5a2f-8119-eb1aa6a1c960', '7397ec63-5bc1-5905-b8c5-97ae6cf9c495', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('342378b2-a68b-5d8d-b983-414bf2d28c0e', '7397ec63-5bc1-5905-b8c5-97ae6cf9c495', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c41d0d9a-e9e4-5898-ad30-23b0c66c046a', '7397ec63-5bc1-5905-b8c5-97ae6cf9c495', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffaee30f-febd-56d3-9fe1-f008a4379b69', '237d6c04-418d-5bf5-b833-02e31073d766', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Do the following
statements agree with the information given in Reading Passage?
In boxes 8-11
on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Umagic
Systems is an example of a new innovative company.
9
Amazon
and Wal-Mart have exchanged
successful
ideas on innovation.
10
Using
financial rewards to encourage innovation is an outdated practice.
11
IBM failed to understand David Post's 'virtual experts’ idea.

10 ____ Using financial rewards to encourage innovation is an outdated practice.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae4b0943-d560-5462-aaec-cf8c70556d39', 'ffaee30f-febd-56d3-9fe1-f008a4379b69', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('562bf6e5-7300-5baa-8269-69efc0afa908', 'ffaee30f-febd-56d3-9fe1-f008a4379b69', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28381fd-3bdb-5efe-a475-dc32ce149275', 'ffaee30f-febd-56d3-9fe1-f008a4379b69', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('902235eb-0ade-5277-ad15-0dc23d9eb229', '237d6c04-418d-5bf5-b833-02e31073d766', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Do the following
statements agree with the information given in Reading Passage?
In boxes 8-11
on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Umagic
Systems is an example of a new innovative company.
9
Amazon
and Wal-Mart have exchanged
successful
ideas on innovation.
10
Using
financial rewards to encourage innovation is an outdated practice.
11
IBM failed to understand David Post's 'virtual experts’ idea.

11 ____ IBM failed to understand David Post's 'virtual experts’ idea.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a238d56-2cb2-5412-826e-8a835f0c751d', '902235eb-0ade-5277-ad15-0dc23d9eb229', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8045b381-7f97-596f-afd1-5c75b5f6ff5a', '902235eb-0ade-5277-ad15-0dc23d9eb229', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79e23b07-f357-5ffe-86ef-9bed164d0e08', '902235eb-0ade-5277-ad15-0dc23d9eb229', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42465ab2-879f-5d44-bb81-b5dbc7413777', '237d6c04-418d-5bf5-b833-02e31073d766', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Choose the correct letter,
A,B,C
or
D
Write the correct letter in boxes 12-14 on your answer sheet.
12.
What point does the writer make about intellectual property?
A
It can be lost when firms merge.
B
It tends to belong to companies rather than individuals.
C
It is valued more than it used to be.
D
It is not usually owned by small companies.
13.
Peter Chemin is an example of someone who has realized that
A
large companies are less innovative than small ones.
B
other businesses are more innovative than the film business,
C
his employees need more experience of innovation.
D
he is the best person to encourage innovation.
14.
In conclusion, the writer suggests that
A
computer-based industries cannot be innovative.
B
big firms are right to be cautious about innovation,
C
small firms should not worry
about early failures.
D
innovation will always involve some uncertainty.

Choose the correct letter, A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c33ec77-93aa-5796-89d9-ba1f192a77d0', '237d6c04-418d-5bf5-b833-02e31073d766', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Choose the correct letter,
A,B,C
or
D
Write the correct letter in boxes 12-14 on your answer sheet.
12.
What point does the writer make about intellectual property?
A
It can be lost when firms merge.
B
It tends to belong to companies rather than individuals.
C
It is valued more than it used to be.
D
It is not usually owned by small companies.
13.
Peter Chemin is an example of someone who has realized that
A
large companies are less innovative than small ones.
B
other businesses are more innovative than the film business,
C
his employees need more experience of innovation.
D
he is the best person to encourage innovation.
14.
In conclusion, the writer suggests that
A
computer-based industries cannot be innovative.
B
big firms are right to be cautious about innovation,
C
small firms should not worry
about early failures.
D
innovation will always involve some uncertainty.

Choose the correct letter, A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0915d89-fe7e-5c35-a3cb-780afadf501b', '237d6c04-418d-5bf5-b833-02e31073d766', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Choose the correct letter,
A,B,C
or
D
Write the correct letter in boxes 12-14 on your answer sheet.
12.
What point does the writer make about intellectual property?
A
It can be lost when firms merge.
B
It tends to belong to companies rather than individuals.
C
It is valued more than it used to be.
D
It is not usually owned by small companies.
13.
Peter Chemin is an example of someone who has realized that
A
large companies are less innovative than small ones.
B
other businesses are more innovative than the film business,
C
his employees need more experience of innovation.
D
he is the best person to encourage innovation.
14.
In conclusion, the writer suggests that
A
computer-based industries cannot be innovative.
B
big firms are right to be cautious about innovation,
C
small firms should not worry
about early failures.
D
innovation will always involve some uncertainty.

Choose the correct letter, A,B,C or D$md$, NULL);

COMMIT;
