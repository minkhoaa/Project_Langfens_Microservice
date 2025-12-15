BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-deafhood-1417'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-deafhood-1417';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-deafhood-1417';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-deafhood-1417';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8e030d11-e8b2-50dc-8011-4a1083454913', 'ielts-reading-deafhood-1417', $t$Deafhood$t$, $md$## Deafhood

Nguồn:
- Test: https://mini-ielts.com/1417/reading/deafhood
- Solution: https://mini-ielts.com/1417/view-solution/reading/deafhood$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('201121ec-1ba0-5823-ac0f-c72b61f82789', '8e030d11-e8b2-50dc-8011-4a1083454913', 1, $t$Reading — Deafhood$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Deafhood

A

At this point, you might be wondering: what does ‘deafhood’ mean? Is it a synonym for ‘deafness’? Is it a slightly more politically correct term to express the very same concept you’ve grown accustomed to-a person who lacks the power of hearing, or a person whose hearing is impaired? What’s wrong with terms like ‘hard of hearing’ or ‘deafness’? Have they not represented the deaf community just fine for the past few centuries? Who came up with the term ‘Deafhood’ anyway, and why?

B

The term ‘Deafhood’ was first coined in 1993 by Dr Paddy Ladd, a deaf scholar in the Deaf Studies Department at the University of Bristol in England. First explored through his doctoral dissertation in 1998, and later elaborated on in his 2003 book, ‘Understanding Deaf Culture – In Search of Deafhood ‘, the idea behind Deafhood is twofold: first, it seeks to collect everything that is already known about the life, culture, politics, etc. of Sign Language Peoples (SLPs); secondly, it attempts to remove the limitations imposed on SLPs through their colonization from hearing people.

C

In order to understand what Deafhood represents, it’s first important to understand what is meant by colonisation. To do that, we need to examine two terms: Oralism and Audism. Oralism is a philosophy that first emerged in the late 19th century, and which suggests that reduced use of sign language would be more beneficial to SLPs, as it would allow them to integrate better to the hearing world. In that respect, sign language is dismissively regarded as a mere obstacle to listening skills and acquisition of speech-treated, in effect, in the same manner as the languages of other peoples who were oppressed and colonised, e.g. the Maori in New Zealand, or the Aborigines in Australia. Audism, however, is an even more sinister ideology: first coined in 1975 by Dr Tom Humphries of the University of California in San Diego, it describes the belief that deaf people are somehow inferior to hearing people, and that deafhood – or, in this case, we should say ‘deafness’ – is a flaw, a terrible disability that needs to be eliminated. It is the effect of these two ideologies that Deafhood seeks to counter, by presenting SLPs in a positive light, not as patients who require treatment.

D

But even if we understand the oppression that SLPs have suffered at the hands of hearing people since the late 1800s, and even if we acknowledge that ‘deafness’ is a medical term with negative connotations that need to be replaced, that doesn’t mean it’s easy to explain what the term Deafhood represents exactly. This is because Deafhood is, as Dr Donald Grushkin puts it, a ‘physical, emotional, mental, spiritual, cultural and linguistic’ journey that every deaf person is invited-but not obligated-to embark on.

E

Deafhood is essentially a search for understanding: what does being ‘Deaf’ mean? How did deaf people in the past define themselves, and what did they believe to be their reasons for existing before Audism was conceived? Why are some people born deaf? Are they biologically defective, or are there more positive reasons for their existence? What do terms like ‘Deaf Art’ or ‘Deaf Culture’ actually mean? What is ‘the Deaf Way’ or doing things? True Deafhood is achieved when a deaf person feels comfortable with who they are and connected to the rest of the deaf community through use of their natural language, but the journey there might differ.

F

Aside from all those questions, however, Deafhood also seeks to counter the eﬀect of what is known as ‘neo-eugenics’. Neo-eugenics, as described by Patrick Boudreault at the 2005 California Association of the Deaf Conference, is a modern manifestation of what has traditionally been defined as ‘eugenics’, i.e. an attempt to eradicate any human characteristics which are perceived as negative. Deaf people have previously been a target of eugenicists through the aforementioned ideologies of Audism and Oralism, but recent developments in science and society-such as cochlear implants or genetic engineering-mean that Deafhood is once again under threat, and needs to be protected. The only way to do this is by celebrating the community’s history, language, and countless contributions to the world, and confronting those who want to see it gone.

G

So, how do we go forward? We should start by decolonising SLPs-by embracing Deafhood for what it is, removing all the negative connotations that surround it and accepting that deaf people are neither broken nor incomplete. This is a task not just for hearing people, but for deaf people as well, who have for decades internalised society’s unfavourable views of them. We should also seek recognition of the deaf community’s accomplishments, as well as official recognition of sign languages around the world by their respective governments. Effectively, what we should do is ask ourselves: how would the Deaf community be like, had it never been colonised by the mainstream world? And whatever it is it would be like, we should all together-hearing and Deaf alike-strive to achieve it.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', '201121ec-1ba0-5823-ac0f-c72b61f82789', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

1 ____ Examples of other groups treated the same way as deaf people$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83178ee7-6c6a-5a24-ae68-cd86cf3e378b', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1de0039-c56d-52d3-b0da-67e62957943a', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c268dd6-2fc3-510f-8b38-eba840040f24', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4ca08b0-8d81-5c27-8562-657595813264', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3492e6cc-0e1f-5d02-afac-16ffbcc1af8f', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d882574-769a-5890-aab7-7fe664cda71e', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('161c67a0-2fea-5631-ab25-8dc674bcc69e', '0f3f3fd1-e016-5463-8f49-ae7e8499c7b8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b930e743-caf5-549d-8066-5fead0a7601c', '201121ec-1ba0-5823-ac0f-c72b61f82789', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

2 ____ Why the word ‘deafness’ is no longer appropriate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb7b19fc-b445-549d-98dc-4f2de60bdb64', 'b930e743-caf5-549d-8066-5fead0a7601c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5eb5f93-e6ae-5999-93ab-bb7ea2d2ef09', 'b930e743-caf5-549d-8066-5fead0a7601c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2effe6da-368c-5ff4-ac80-c7680a218878', 'b930e743-caf5-549d-8066-5fead0a7601c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d00d948-bdd8-513a-b12b-2c345bfd01ca', 'b930e743-caf5-549d-8066-5fead0a7601c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfd7ee65-f811-5aba-9952-243f55e2d9b6', 'b930e743-caf5-549d-8066-5fead0a7601c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('381e2184-9b1a-5148-ae17-e6cf6201ee16', 'b930e743-caf5-549d-8066-5fead0a7601c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9299b258-0d21-5076-b1d6-e7b7c954c4dc', 'b930e743-caf5-549d-8066-5fead0a7601c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b3273a01-d859-5340-955a-6a49e2f4e8fb', '201121ec-1ba0-5823-ac0f-c72b61f82789', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

3 ____ The definition of the word ‘dear$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f15632d-48ce-57cd-a783-76e47b3d1952', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2194b20d-a542-554d-b35c-0863a09c774c', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32ba5146-0b61-5145-bd70-30dfa284d4cc', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47a74ada-8f68-5cd2-bab2-b1cddb235527', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4cb27eb-fee6-541d-bcd2-b1cbb40e5481', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08c399cd-1bc4-58db-b33a-ac3795b14469', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5369b1c0-05a4-51ac-83e5-cea28ab35f7c', 'b3273a01-d859-5340-955a-6a49e2f4e8fb', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2dcff2c0-9ba5-5800-97e4-1e21a81407da', '201121ec-1ba0-5823-ac0f-c72b61f82789', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

4 ____ Why deaf people might sometimes think negatively of themselves$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e32e42de-159c-50b4-a8ad-9c0541c64ea1', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4390e1f-69be-5cde-a390-8a5a60bc6d3c', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfab6a93-6873-538f-92a0-8460356d65c1', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ebb752a-3c0d-51c3-b23e-717ebaf9d79d', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5491a46d-bf66-5399-81d0-4de6bf20dcdc', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d994bec2-eb23-5e36-9c41-9a95373a51b7', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6470db7-47f3-5eb2-841d-318023f1c114', '2dcff2c0-9ba5-5800-97e4-1e21a81407da', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8aedb6f-298d-5f27-b09e-b34c69c83777', '201121ec-1ba0-5823-ac0f-c72b61f82789', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

5 ____ How one can attain deafhood$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bb2ec78-60b7-565a-ae4a-9b56e0029e82', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('057c238a-6cf2-5b35-a4dd-f3635d9bb580', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3632aa9-55ee-5651-88ad-d37d08c54299', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3b245bb-0a5d-5338-b7e8-052b091e108f', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38c69141-40f3-5b28-b1af-1e60a99b9dfd', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f27bb33c-fc8a-5d8e-a054-add296d0ce38', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dae3e6a-ac28-5f0b-a543-5aaea373acd8', 'f8aedb6f-298d-5f27-b09e-b34c69c83777', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a05237f-d305-5ce2-8899-c1d4d29b6b26', '201121ec-1ba0-5823-ac0f-c72b61f82789', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

6 ____ Where the word ‘deafhood’ came from$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04aa4e70-1439-52b2-b00c-bf07400d9261', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1971e20-cd9b-5237-bc62-2215102306c6', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d901340-118a-5d48-a440-406a1131ff52', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76486cbd-4b2c-52a9-95a7-de1f9772f1a5', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5100cc53-cddd-5404-8c1d-33571017207f', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30094877-a2b5-5a5c-8c1e-5b800dbd189d', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fc487f3-d3f4-526c-baba-11a93fe19cf5', '9a05237f-d305-5ce2-8899-c1d4d29b6b26', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('862cb58c-bcb7-5e70-84f3-79891e06d113', '201121ec-1ba0-5823-ac0f-c72b61f82789', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
Examples of other groups treated the same way as deaf people
2
Why the word ‘deafness’ is no longer appropriate
3
The definition of the word ‘dear
4
Why deaf people might sometimes think negatively of themselves
5
How one can attain deafhood
6
Where the word ‘deafhood’ came from
7
Why deafhood is currently imperilled

7 ____ Why deafhood is currently imperilled$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90271bf6-9715-5cb3-9351-da87e6d04f05', '862cb58c-bcb7-5e70-84f3-79891e06d113', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('287577e2-715b-5e46-a5b6-1109d1f0d8ce', '862cb58c-bcb7-5e70-84f3-79891e06d113', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac053655-a043-579a-881b-38195a8e345a', '862cb58c-bcb7-5e70-84f3-79891e06d113', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dfcee78-0e79-5667-8e5d-380db58050cf', '862cb58c-bcb7-5e70-84f3-79891e06d113', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d98c8879-bd3a-5a76-a2d4-fca1f779ea53', '862cb58c-bcb7-5e70-84f3-79891e06d113', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27c1ba3b-21e3-5ebe-814e-b576ffd88ea9', '862cb58c-bcb7-5e70-84f3-79891e06d113', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f256298-f37c-52cf-830c-23b2d52eb7c9', '862cb58c-bcb7-5e70-84f3-79891e06d113', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('176f10fe-7740-5648-a59f-f997cd009f5f', '201121ec-1ba0-5823-ac0f-c72b61f82789', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
8-10
on your answer sheet.
8.
According to Dr Paddy Ladd, Deafhood
A
is a more appropriate term than ‘hard of hearing’.
B
doesn’t colonise SLPs as much as ‘deafness’ does.
C
strives to get rid of the effects of colonisation.
D
contributes positively to the life and culture of deaf people.
9.
Oralism suggests that
A
SLPs have no use for sign language.
B
SLPs don’t belong in the hearing world.
C
hearing people are superior to SLPs.
D
SLPs are unable to acquire speech.
10.
Aborigines in Australia are similar to deaf people because
A
eugenicists also tried to eradicate them.
B
they were also considered inferior by their oppressors.
C
their languages were also disrespected.
D
their languages were also colonised.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fbbb52a-02ed-5203-a9b0-a1a5e9b78f0a', '201121ec-1ba0-5823-ac0f-c72b61f82789', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
8-10
on your answer sheet.
8.
According to Dr Paddy Ladd, Deafhood
A
is a more appropriate term than ‘hard of hearing’.
B
doesn’t colonise SLPs as much as ‘deafness’ does.
C
strives to get rid of the effects of colonisation.
D
contributes positively to the life and culture of deaf people.
9.
Oralism suggests that
A
SLPs have no use for sign language.
B
SLPs don’t belong in the hearing world.
C
hearing people are superior to SLPs.
D
SLPs are unable to acquire speech.
10.
Aborigines in Australia are similar to deaf people because
A
eugenicists also tried to eradicate them.
B
they were also considered inferior by their oppressors.
C
their languages were also disrespected.
D
their languages were also colonised.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88ae46a5-89c2-5d3a-b090-211a79d0e582', '201121ec-1ba0-5823-ac0f-c72b61f82789', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
8-10
on your answer sheet.
8.
According to Dr Paddy Ladd, Deafhood
A
is a more appropriate term than ‘hard of hearing’.
B
doesn’t colonise SLPs as much as ‘deafness’ does.
C
strives to get rid of the effects of colonisation.
D
contributes positively to the life and culture of deaf people.
9.
Oralism suggests that
A
SLPs have no use for sign language.
B
SLPs don’t belong in the hearing world.
C
hearing people are superior to SLPs.
D
SLPs are unable to acquire speech.
10.
Aborigines in Australia are similar to deaf people because
A
eugenicists also tried to eradicate them.
B
they were also considered inferior by their oppressors.
C
their languages were also disrespected.
D
their languages were also colonised.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('76fe9145-39db-5946-8c6a-c310a66a0764', '201121ec-1ba0-5823-ac0f-c72b61f82789', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Answer the questions below with words taken from Reading Passage.
Use
NO MORE THAN TWO WORDS
for each answer.
11.
What should deaf people use to communicate with each other, according to deafhood?
11
12.
Who has used oralism and audism to attack the deaf community?
12
13.
What does the deaf community strive to achieve for sign language worldwide?
13

11. What should deaf people use to communicate with each other, according to deafhood? 11 ____$md$, NULL, ARRAY['.*natural.*language.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fab04b7e-a5d3-50af-b947-ee409cbc9650', '201121ec-1ba0-5823-ac0f-c72b61f82789', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Answer the questions below with words taken from Reading Passage.
Use
NO MORE THAN TWO WORDS
for each answer.
11.
What should deaf people use to communicate with each other, according to deafhood?
11
12.
Who has used oralism and audism to attack the deaf community?
12
13.
What does the deaf community strive to achieve for sign language worldwide?
13

12. Who has used oralism and audism to attack the deaf community? 12 ____$md$, NULL, ARRAY['.*eugenicists.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ecca6d6e-710a-5bbf-ac97-458c97e046cc', '201121ec-1ba0-5823-ac0f-c72b61f82789', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Answer the questions below with words taken from Reading Passage.
Use
NO MORE THAN TWO WORDS
for each answer.
11.
What should deaf people use to communicate with each other, according to deafhood?
11
12.
Who has used oralism and audism to attack the deaf community?
12
13.
What does the deaf community strive to achieve for sign language worldwide?
13

13. What does the deaf community strive to achieve for sign language worldwide? 13 ____$md$, NULL, ARRAY['.*official.*recognition.*']);

COMMIT;
