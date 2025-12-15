BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-collecting-as-a-hobby-1137'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-collecting-as-a-hobby-1137';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-collecting-as-a-hobby-1137';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-collecting-as-a-hobby-1137';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('be7d0521-d6e8-5003-abe7-98bc597e0def', 'ielts-reading-collecting-as-a-hobby-1137', $t$Collecting as a hobby$t$, $md$## Collecting as a hobby

Nguồn:
- Test: https://mini-ielts.com/1137/reading/collecting-as-a-hobby
- Solution: https://mini-ielts.com/1137/view-solution/reading/collecting-as-a-hobby$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 'be7d0521-d6e8-5003-abe7-98bc597e0def', 1, $t$Reading — Collecting as a hobby$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Collecting as a hobby

Collecting must be one of the most varied of human activities, and it's one that many of us psychologists find fascinating.

Many forms of collecting have been dignified with a technical name: an archtophilist collects teddy bears, a philatelist collects postage stamps, and a deltiologist collects postcards. Amassing hundreds or even thousands of postcards, chocolate wrappers or whatever, takes time, energy and money that could surely to much more productive use. And yet thereare millions of collectors around the world. Why do they do it?

There are the people who collect because they want to make money - this could be called an instrumental reason for collecting; that is, collecting as a means to an end. They'll look for, say, antiques that they can buy cheaply and expect to be able to sell at a profit. But there may well be a psychological element, too - buying cheap and selling dear can give the collector a sense of triumph . And as selling online is so easy, more and more people are joining in.

Many collectors collect to develop their social life, attending meetings of a group of collectors and exchanging information on items. This is a variant on joining a bridge club or a gym, and similarly brings them into contact with like-minded people. Another motive for collecting is the desire to find something special, or a particular example of the collected item, such as a rare early recording by a particular singer.

Some may spend their whole lives in a hunt for this. Psychologically, this can give a purpose to a life that otherwise feels aimless . There is a danger, though, that if the individual is ever lucky enough to find what they're looking for, rather than celebrating their success, they may feel empty , now that the goal that drove them on has gone.

If you think about collecting postage stamps another potential reason for it - Or, perhaps, a result of collecting is its educational value. Stamp collecting opens a window to other countries, and to the plants, animals, or famous people shown on their stamps.

Similarly, in the 19th century, many collectors amassed fossils, animals and plants from around the globe, and their collections provided a vast amount of information about the natural world. Without those collections, our understanding would be greatly inferior to what it is.

In the past - and nowadays, too, though to a lesser extent - a popular form of collecting, particularly among boys and men, was trainspotting. This might involve trying to see every locomotive of a particular type, using published data that identifies each one, and ticking off each engine as it is seen. Trainspotters exchange information, these days often by mobile phone, so they can work out where to go to, to see a particular engine. As a by-product, many practitioners of the hobby become very knowledgeable about railway operations, or the technical specifications of different engine types.

Similarly, people who collect dolls may go beyond simply enlarging their collection, and develop an interest in the way that dolls are made, or the materials that are used. These have changed over the centuries from the wood that was standard in 16th century Europe, through the wax and porcelain of later centuries, to the plastics of today's dolls. Or collectors might be inspired to study how dolls reflect notions of what children like, or ought to like.

Not all collectors are interested in learning from their hobby, though, so what we might call a psychological reason for collecting is the need for a sense of control, perhaps as a way of dealing with insecurity. Stamp collectors, for instance, arrange their stamps in albums, usually very neatly, organising their collection according to certain commonplace principles-perhaps by country in alphabetical order, or grouping stamps by what they depict -people, birds, maps, and so on.

One reason, conscious or not, for what someone chooses to collect is to show the collector's individualism . Someone who decides to collect something as unexpected as dog collars, for instance, may be conveying their belief that they must be interesting themselves. And believe it or not, there is at least one dog collar museum in existence, and it grew out of a personal collection.

Of course, all hobbies give pleasure, but the common factor in collecting is usually passion: pleasure is putting it far too mildly. More than most other hobbies, collecting can be totally engrossing, and can give a strong sense of personal fulfilment. To non-collectors it may appear an eccentric, if harmless, way of spending time, but potentially, collecting has a lot going for it.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ac8240c7-8171-5b05-a985-31b2196a19e3', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 1, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

1 The writer mentions collecting ____ as an example of collecting in order to make money. Locate$md$, NULL, ARRAY['.*antiques.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('831c2662-ca7d-5833-9303-cca733e5348f', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 2, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

2 Collectors may get a feeling of ____ from buying and selling items. Locate$md$, NULL, ARRAY['.*triumph.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b6fa06fd-ad58-5195-973b-966b4655550d', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 3, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

3 Collectors’ clubs provide opportunities to share ____ Locate$md$, NULL, ARRAY['.*information.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f881d284-59d7-5b38-9a33-a91766cf621f', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 4, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

4 Collectors’ clubs offer ____ with people who have similar interests. Locate$md$, NULL, ARRAY['.*contact.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('955faad8-63f0-5145-8469-f0d2ab0a52db', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 5, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

5 Collecting sometimes involves a life-long ____ for a special item. Locate$md$, NULL, ARRAY['.*hunt.*','.*desire.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51a2eb18-1728-5f8a-8fe6-d196c99d9f19', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 6, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

6 Searching for something particular may prevent people from feeling their life is completely ____ Locate$md$, NULL, ARRAY['.*aimless.*','.*empty.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3bc468a6-494a-5a7b-8115-ee79a663e81d', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

7 Stamp collecting may be ____ because it provides facts about different countries. Locate$md$, NULL, ARRAY['.*educational.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('851dc533-0eff-590f-a439-ac236f9ee8a0', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet.
1
The writer mentions collecting
as an example of collecting in order to make money.
Locate
2
Collectors may get a feeling of
from buying and selling items.
Locate
3
Collectors’ clubs provide opportunities to share
Locate
4
Collectors’ clubs offer
with people who have similar interests.
Locate
5
Collecting sometimes involves a life-long
for a special item.
Locate
6
Searching for something particular may prevent people from feeling their life is completely
Locate
7
Stamp collecting may be
because it provides facts about different countries.
Locate
8
tends to be mostly a male hobby.

8 ____ tends to be mostly a male hobby.$md$, NULL, ARRAY['.*trainspotting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ad0325c-e276-58a8-bb4c-15b4aca543ba', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The number of people buying dolls has grown over the centuries.
10
Sixteenth century European dolls were normally made of wax and porcelain.
Locate
11
Arranging a stamp collection by the size of the stamps is less common than other methods.
12
Someone who collects unusual objects may want others to think he or she is also unusual.
Locate
13
Collecting gives a feeling that other hobbies are unlikely to inspire.
Locate

9 ____ The number of people buying dolls has grown over the centuries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffbe4e70-35b7-5c28-b318-7e8079943756', '9ad0325c-e276-58a8-bb4c-15b4aca543ba', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e119eb84-1f16-5f58-aa22-c26182bd8916', '9ad0325c-e276-58a8-bb4c-15b4aca543ba', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce763e42-b0bb-576f-91da-0a504870b9df', '9ad0325c-e276-58a8-bb4c-15b4aca543ba', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fbce7313-43c9-5265-81b3-b1ef1909a138', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The number of people buying dolls has grown over the centuries.
10
Sixteenth century European dolls were normally made of wax and porcelain.
Locate
11
Arranging a stamp collection by the size of the stamps is less common than other methods.
12
Someone who collects unusual objects may want others to think he or she is also unusual.
Locate
13
Collecting gives a feeling that other hobbies are unlikely to inspire.
Locate

10 ____ Sixteenth century European dolls were normally made of wax and porcelain. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('710dd91c-2997-5a29-af65-a9ab9b9376dc', 'fbce7313-43c9-5265-81b3-b1ef1909a138', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f068bb1-9558-5906-a5b8-8ea0a231b9d1', 'fbce7313-43c9-5265-81b3-b1ef1909a138', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3042cd0f-456f-539e-9673-08fbfb93bddb', 'fbce7313-43c9-5265-81b3-b1ef1909a138', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('356a9c71-b906-526f-941c-fdce4d8315de', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The number of people buying dolls has grown over the centuries.
10
Sixteenth century European dolls were normally made of wax and porcelain.
Locate
11
Arranging a stamp collection by the size of the stamps is less common than other methods.
12
Someone who collects unusual objects may want others to think he or she is also unusual.
Locate
13
Collecting gives a feeling that other hobbies are unlikely to inspire.
Locate

11 ____ Arranging a stamp collection by the size of the stamps is less common than other methods.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ec4cbc9-e5ab-588d-8e47-f1918c671ded', '356a9c71-b906-526f-941c-fdce4d8315de', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcac620c-da02-5b5d-9630-7d731f505daf', '356a9c71-b906-526f-941c-fdce4d8315de', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('952e05c7-8a99-5c43-b665-3252a4b61e13', '356a9c71-b906-526f-941c-fdce4d8315de', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6c9d88c-90fe-515c-af0f-6d55ca75a9a0', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The number of people buying dolls has grown over the centuries.
10
Sixteenth century European dolls were normally made of wax and porcelain.
Locate
11
Arranging a stamp collection by the size of the stamps is less common than other methods.
12
Someone who collects unusual objects may want others to think he or she is also unusual.
Locate
13
Collecting gives a feeling that other hobbies are unlikely to inspire.
Locate

12 ____ Someone who collects unusual objects may want others to think he or she is also unusual. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2e3affe-d8bb-5f46-b580-d442e965dc62', 'f6c9d88c-90fe-515c-af0f-6d55ca75a9a0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70f87cb0-186d-5682-90ba-530b53b1a6e2', 'f6c9d88c-90fe-515c-af0f-6d55ca75a9a0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85f67152-d46d-5691-8247-855b181b2573', 'f6c9d88c-90fe-515c-af0f-6d55ca75a9a0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37bf0057-f1dc-5791-a4ad-86964589e2df', '7f4d7b07-35ac-5bed-93a2-777e5a306fd2', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The number of people buying dolls has grown over the centuries.
10
Sixteenth century European dolls were normally made of wax and porcelain.
Locate
11
Arranging a stamp collection by the size of the stamps is less common than other methods.
12
Someone who collects unusual objects may want others to think he or she is also unusual.
Locate
13
Collecting gives a feeling that other hobbies are unlikely to inspire.
Locate

13 ____ Collecting gives a feeling that other hobbies are unlikely to inspire. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685b989a-4333-5353-b2fa-735f2520fdec', '37bf0057-f1dc-5791-a4ad-86964589e2df', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1cf90f2-f7ad-5cf1-8101-ec4ed7053ac3', '37bf0057-f1dc-5791-a4ad-86964589e2df', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1215fe8-b4c8-5e65-98a7-771ba3bfd87f', '37bf0057-f1dc-5791-a4ad-86964589e2df', 3, $md$NOT GIVEN$md$, false);

COMMIT;
