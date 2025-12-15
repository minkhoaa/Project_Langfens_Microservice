BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-burgess-shale-fossils-1261'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-burgess-shale-fossils-1261';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-burgess-shale-fossils-1261';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-burgess-shale-fossils-1261';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cc9dbc27-0100-521d-b7a8-ea69ff35681e', 'ielts-reading-the-burgess-shale-fossils-1261', $t$The Burgess Shale fossils$t$, $md$## The Burgess Shale fossils

Nguồn:
- Test: https://mini-ielts.com/1261/reading/the-burgess-shale-fossils
- Solution: https://mini-ielts.com/1261/view-solution/reading/the-burgess-shale-fossils$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('be90d703-0b94-536e-ae38-a16b45b73f48', 'cc9dbc27-0100-521d-b7a8-ea69ff35681e', 1, $t$Reading — The Burgess Shale fossils$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Burgess Shale fossils

Fauna vanished with a whimper, not a bang

Some discoveries are so unusual it takes decades and sometimes even centuries to understand their full significance. One such discovery is the fossil bed known as the ago. It was discovered in the Canadian Rockies over a century ago and was popularised in 1989 in a book, Wonderful Life, by Stephen Jay Gould an American palaeontologist.

The Burgess Shale fossils were created at a time when the future Canadian land mass was situated near the Earth’s equator. The creatures were preserved when an entire marine ecosystem was buried in mud that eventually hardened and became exposed hundreds of millions of years later in an outcrop of the Rocky Mountains. American palaeontologist Charles Walcott, following reports of fabulous fossils finds by construction workers on Canadian railways who were digging in the mountains in the late 19 th century, is said to have tripped over a block of shale in 1909 that revealed the area’s remarkable supply of specimens. It has long been believed that the curious fauna that lived there vanished in a series of extinction because the fossil record ends abruptly, but that no longer appears to be the case.

The Burgess Shale began to form soon after a period of time known as the Cambrian explosion, when most major groups of complex animals arose over a surprisingly short period. Before 560m years ago, most living things were either individual cells or simple colonies of cells. Then, and for reasons that remain a mystery, life massively diversified and became ever more complex as the rate of evolution increased. An unusual feature of the Burgess Shale is that it is one of the earliest fossil beds to contain impressions of the soft body parts alongside the remains of bones and shells, which is highly unusual.

Although the fossil bed was discovered on a mountain, these animals originally existed below an ocean, the bed of which was later pushed up to create the Rockies. Nobody knows exactly why they were so well preserved. One possibility is that the creatures were buried quickly and in conditions that were hostile to the bacteria that cause decomposition of soft body parts.

Those that first worked on the Burgess Shale, unearthing 65,000 specimens over a 14-year period up to 1924, assumed that the fossils came from extinct members of groups of animals in existence today. This turned out to be misleading because many of the creatures are so unusual that they are still difficult to classify.

One such example is Opabinia, a creature that grew to about 8cm (3 inches), had five eyes, a body that was a series of lobes, a tail in the shape of a fan and that ate using a long proboscis. The proboscis had a set of grasping claws on the end, with which it grabbed food and stuff it into its mouth. Nectocaris, meanwhile, could be mistaken for a leech, with fins and tentacles. Weirdest of all was Hallucigenia, described by palaeontologist Simon Conway Morris when he re-examined Walcott’s specimens in 1979. With its multiplicity of spines and tentacles, little about Hallucigenia made sense. Like an abstract painting, its orientation is a mystery at first, making it difficult to work out which way up it went, which hole food went into, and which hole food come out of.

Palaeontologists had long thought that many of the Burgess Shale animals were examples of experiments in evolution. In other words, entirely new forms of life that did not survive or lead to other groups or species. Hallucigenia, ironically, turned out to be the exception that proved the rule. It is now thought to be an ancestor of the modern group of arthropods, which includes everything from flies and butterflies to centipedes and crabs.

Now another misconception has been quashed. Writing in Nature, Peter Van Roy of Yale University and his colleagues suggest that the sudden absence of such crazy soft-bodied fossils does not indicate a mass extinction, but merely an end to the unusual local circumstances that caused the creatures to be preserved. In an area of the Atlas Mountains of Morocco, Van Roy’s team of researchers have found another diverse (and sometimes bizarre) assemblage of soft-bodied organisms from a period after the Burgess Shale was formed. One discovery includes something that may be a stalked barnacle. This suggests that the evolution of such complex life went on uninterrupted. For its part, the Burgess Shale continues to produce an astonishing array of indefinable creatures faster than palaeontologists can examine them. The world still has plenty to learn about this wonderful life.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33c6cae0-badb-52cc-b146-93c52afad6a1', 'be90d703-0b94-536e-ae38-a16b45b73f48', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

QUESTIONS 1 - 5
QUESTIONS 1 - 5
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
there is no information on this
1
The Burgess Shale became widely known to the public because of Gould’s book.
2
Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.
3
The Burgess Shale includes impressions of soft and hard body parts.
4
The Burgess Shale creatures were land animals.
5
Researchers now believe that Hallucigenia is unrelated to any modern creature.

1 ____ The Burgess Shale became widely known to the public because of Gould’s book.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02f94756-03bc-5408-9485-5830ac4db8ae', '33c6cae0-badb-52cc-b146-93c52afad6a1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59da763c-33e9-5acb-bcef-05e755715eb7', '33c6cae0-badb-52cc-b146-93c52afad6a1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c50e54bb-746f-540f-8187-5c9583eb5a92', '33c6cae0-badb-52cc-b146-93c52afad6a1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('461b06fb-876a-5bbc-b4d8-4b8c001b162a', 'be90d703-0b94-536e-ae38-a16b45b73f48', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

QUESTIONS 1 - 5
QUESTIONS 1 - 5
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
there is no information on this
1
The Burgess Shale became widely known to the public because of Gould’s book.
2
Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.
3
The Burgess Shale includes impressions of soft and hard body parts.
4
The Burgess Shale creatures were land animals.
5
Researchers now believe that Hallucigenia is unrelated to any modern creature.

2 ____ Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db30553b-5250-5442-9643-3d31b1e8a2d7', '461b06fb-876a-5bbc-b4d8-4b8c001b162a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a9d299b-56f5-5db5-9dd6-a28553055214', '461b06fb-876a-5bbc-b4d8-4b8c001b162a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc7d0b52-fbe1-554c-906a-7c8477d11b64', '461b06fb-876a-5bbc-b4d8-4b8c001b162a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1c03dec-74b2-57e1-af3f-3e42910b2ad1', 'be90d703-0b94-536e-ae38-a16b45b73f48', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

QUESTIONS 1 - 5
QUESTIONS 1 - 5
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
there is no information on this
1
The Burgess Shale became widely known to the public because of Gould’s book.
2
Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.
3
The Burgess Shale includes impressions of soft and hard body parts.
4
The Burgess Shale creatures were land animals.
5
Researchers now believe that Hallucigenia is unrelated to any modern creature.

3 ____ The Burgess Shale includes impressions of soft and hard body parts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe9cefcd-4589-5a5a-95c4-dd3cee436359', 'a1c03dec-74b2-57e1-af3f-3e42910b2ad1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c720bb5-6645-5305-9314-aee22ac4745b', 'a1c03dec-74b2-57e1-af3f-3e42910b2ad1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f45b34c-87ae-59ad-b688-9ab036422364', 'a1c03dec-74b2-57e1-af3f-3e42910b2ad1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('366eed9b-799c-50cb-960d-d6e8e1729f86', 'be90d703-0b94-536e-ae38-a16b45b73f48', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

QUESTIONS 1 - 5
QUESTIONS 1 - 5
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
there is no information on this
1
The Burgess Shale became widely known to the public because of Gould’s book.
2
Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.
3
The Burgess Shale includes impressions of soft and hard body parts.
4
The Burgess Shale creatures were land animals.
5
Researchers now believe that Hallucigenia is unrelated to any modern creature.

4 ____ The Burgess Shale creatures were land animals.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c385db9-406f-5310-b38c-968f45f83168', '366eed9b-799c-50cb-960d-d6e8e1729f86', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efc52510-2a8d-55ee-91fd-6875a3bf12ce', '366eed9b-799c-50cb-960d-d6e8e1729f86', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf03ee0-1854-59ec-8a09-a5ffe9a873d8', '366eed9b-799c-50cb-960d-d6e8e1729f86', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c393a6c-f020-5b5c-ac55-770a9215a948', 'be90d703-0b94-536e-ae38-a16b45b73f48', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

QUESTIONS 1 - 5
QUESTIONS 1 - 5
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
there is no information on this
1
The Burgess Shale became widely known to the public because of Gould’s book.
2
Charles Walcott had to get permission from Canadian authorities to gain access to the fossil site.
3
The Burgess Shale includes impressions of soft and hard body parts.
4
The Burgess Shale creatures were land animals.
5
Researchers now believe that Hallucigenia is unrelated to any modern creature.

5 ____ Researchers now believe that Hallucigenia is unrelated to any modern creature.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2135d170-3ad4-5c99-a91b-44c366d454f3', '4c393a6c-f020-5b5c-ac55-770a9215a948', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2101a360-e08b-543b-a584-598ac50eaebb', '4c393a6c-f020-5b5c-ac55-770a9215a948', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae26e4fc-3e5d-549b-9799-fcfe4a87b59d', '4c393a6c-f020-5b5c-ac55-770a9215a948', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('76232540-eb80-5c8e-973f-e3a28ecaf45d', 'be90d703-0b94-536e-ae38-a16b45b73f48', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

QUESTIONS 6 - 9
QUESTIONS 6 - 9
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
Burgess Shale
Formation:
- Burgess Shale was formed following a time called the
6
Discovery and Investigation in the twentieth century​:
- discovered in 1909
- Charles Walcott learned of the fossil finds from people building a
7
-
the first work on Burgess Shale was undertaken at the start of the century
- a researcher looked at Burgess Shale findings again in
8
Recent theories​:
- Peter Van Roy
- believes that discoveries in Morocco show that the
9
of complex life forms continued

- Burgess Shale was formed following a time called the 6 ____$md$, NULL, ARRAY['.*cambrian.*explosion.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9fdc4def-f2e6-5a7c-a192-24ab39852bea', 'be90d703-0b94-536e-ae38-a16b45b73f48', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

QUESTIONS 6 - 9
QUESTIONS 6 - 9
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
Burgess Shale
Formation:
- Burgess Shale was formed following a time called the
6
Discovery and Investigation in the twentieth century​:
- discovered in 1909
- Charles Walcott learned of the fossil finds from people building a
7
-
the first work on Burgess Shale was undertaken at the start of the century
- a researcher looked at Burgess Shale findings again in
8
Recent theories​:
- Peter Van Roy
- believes that discoveries in Morocco show that the
9
of complex life forms continued

- Charles Walcott learned of the fossil finds from people building a 7 ____$md$, NULL, ARRAY['.*railway.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('357173fa-a69b-552f-b276-54fd60b40f10', 'be90d703-0b94-536e-ae38-a16b45b73f48', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

QUESTIONS 6 - 9
QUESTIONS 6 - 9
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
Burgess Shale
Formation:
- Burgess Shale was formed following a time called the
6
Discovery and Investigation in the twentieth century​:
- discovered in 1909
- Charles Walcott learned of the fossil finds from people building a
7
-
the first work on Burgess Shale was undertaken at the start of the century
- a researcher looked at Burgess Shale findings again in
8
Recent theories​:
- Peter Van Roy
- believes that discoveries in Morocco show that the
9
of complex life forms continued

- a researcher looked at Burgess Shale findings again in 8 ____$md$, NULL, ARRAY['.*1979.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c748fb04-a185-5f26-800d-0af811787b58', 'be90d703-0b94-536e-ae38-a16b45b73f48', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

QUESTIONS 6 - 9
QUESTIONS 6 - 9
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
Burgess Shale
Formation:
- Burgess Shale was formed following a time called the
6
Discovery and Investigation in the twentieth century​:
- discovered in 1909
- Charles Walcott learned of the fossil finds from people building a
7
-
the first work on Burgess Shale was undertaken at the start of the century
- a researcher looked at Burgess Shale findings again in
8
Recent theories​:
- Peter Van Roy
- believes that discoveries in Morocco show that the
9
of complex life forms continued

- believes that discoveries in Morocco show that the 9 ____ of complex life forms continued$md$, NULL, ARRAY['.*evolution.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('73a37787-67a0-5b62-8a11-e8b4a3b2c3f8', 'be90d703-0b94-536e-ae38-a16b45b73f48', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

QUESTIONS 10 -13
QUESTIONS 10 -13
Complete the table below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
Burgess Shale Creatures
Name
Feature
Opabinia
- five eyes
- tail resembling a
10
- claws used to hold
11
Nectocaris
- looked like a
12
- fins
- tentacles
Hallucigenia
- spines used to
13
- tentacles

- tail resembling a 10 ____$md$, NULL, ARRAY['.*fan.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec0b8ca2-6cef-5791-8bb2-7c28fb61510a', 'be90d703-0b94-536e-ae38-a16b45b73f48', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

QUESTIONS 10 -13
QUESTIONS 10 -13
Complete the table below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
Burgess Shale Creatures
Name
Feature
Opabinia
- five eyes
- tail resembling a
10
- claws used to hold
11
Nectocaris
- looked like a
12
- fins
- tentacles
Hallucigenia
- spines used to
13
- tentacles

- claws used to hold 11 ____$md$, NULL, ARRAY['.*food.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8362de15-f3da-560f-950b-c72ea625e870', 'be90d703-0b94-536e-ae38-a16b45b73f48', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

QUESTIONS 10 -13
QUESTIONS 10 -13
Complete the table below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
Burgess Shale Creatures
Name
Feature
Opabinia
- five eyes
- tail resembling a
10
- claws used to hold
11
Nectocaris
- looked like a
12
- fins
- tentacles
Hallucigenia
- spines used to
13
- tentacles

- looked like a 12 ____ - fins$md$, NULL, ARRAY['.*leech.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b30ae8ca-678d-5889-b5d2-bbf875ecdc5a', 'be90d703-0b94-536e-ae38-a16b45b73f48', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

QUESTIONS 10 -13
QUESTIONS 10 -13
Complete the table below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
Burgess Shale Creatures
Name
Feature
Opabinia
- five eyes
- tail resembling a
10
- claws used to hold
11
Nectocaris
- looked like a
12
- fins
- tentacles
Hallucigenia
- spines used to
13
- tentacles

- spines used to 13 ____$md$, NULL, ARRAY['.*move.*']);

COMMIT;
