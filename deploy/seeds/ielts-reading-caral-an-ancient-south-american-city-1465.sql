BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-caral-an-ancient-south-american-city-1465'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-caral-an-ancient-south-american-city-1465';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-caral-an-ancient-south-american-city-1465';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-caral-an-ancient-south-american-city-1465';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0633ecaa-c88b-56ba-8058-1eed7db4ea38', 'ielts-reading-caral-an-ancient-south-american-city-1465', $t$Caral: an ancient South American city$t$, $md$## Caral: an ancient South American city

Nguồn:
- Test: https://mini-ielts.com/1465/reading/caral-an-ancient-south-american-city
- Solution: https://mini-ielts.com/1465/view-solution/reading/caral-an-ancient-south-american-city$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('02904353-1fd3-5dc2-80f5-036edc0aebce', '0633ecaa-c88b-56ba-8058-1eed7db4ea38', 1, $t$Reading — Caral: an ancient South American city$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Caral: an ancient South American city

Huge earth and rock mounds rise out of the desert of the Supe Valley near the coast of Peru in South America. These immense mounds appear simply to be part of the geographical landscape in this arid region squeezed between the Pacific Ocean and the Andes mountains.But looks deceive. These are actually human-made pyramids strong evidence indicates they are the remains of a city known as Caral that flourished nearly 5,000 years ago. It true, it would be the oldest known urban center in the America and among the most ancient in the world.

Research undertaken by Peruvian archaeologist Ruth Shady suggests that the 150-acre plex of pyramids, plazas and residential buildings was a thriving metropolis when Egypt's great pyramids were still being built. Though discovered in 1905, for years Caral attracted little attention, largely because archaeologists believed the structures were rainy recent. But the monumental scale of the pyramids had long interested Shady, who began excavations at the site in 1996, about 22 kilometers from the coast and 190 kilometers north of Peru's capital city of Lima.

Shady and her crew searched for broken remains of the pots and containers that most such sites contain. Not finding any only made her more excited: it meant Caral could be what archaeologists term pre-ceramic, that is, existing before the advent in the area of pot-firing techniques. Shady's team undertook the task of excavating Piramide Mayor, the largest of the pyramids. After carefully clearing away many hundreds of years' worth of rubble and sand, they identified staircases, walls covered with remnants of colored plaster, and brickwork. In the foundations, they found the remains of grass-like reeds woven into bags. The original workers, she surmised, must have filled these bags with stones from a nearby quarry and laid them atop one another inside retaining walls, gradually giving rise to the pyramid's immense structure. Shady had samples of the reeds subjected to radiocarbon dating and found that the reeds were 4,600 years old. This evidence indicated that Caral was, in fact, more than 1,000 years older than what had previously been thought to be the oldest urban center in the Americas.

What amazed archaeologists was not just the age, but the complexity and scope of Caral. Piramide Mayor alone covers an area nearly the size of four football fields and is 18 meters tall. A nine-meter-wide staircase rises from a circular plaza at the foot of the pyramid, passing over three terraced levels until it reaches the top. Thousands of manual laborers would have been needed to build such a project, not counting the many architects, craftsmen, and managers. Shady's team found the remains of a large amphitheater, containing almost 70 musical instruments made of bird and deer bones Clearly music plaved an important role in Caral's society. Around the perimeter of Caral are a series of smaller mounds and various buildings. These indicate a hierarchy of living arrangements: large, well-kept rooms atop pyramids for the elite, ground-level quarters for shabbier outlying dwellings for workers

But why had Caral been built in the first place? Her excavations convinced Shady that Caral once served as a trade center for the region, which extends from the rainforests of the Amazon to the high forests of the Andes. Shady found evidence of a rich trading environment, including seeds of the cocoa bush and necklaces of shells, neither of which was native to the immediate Caral area. This environment gave rise to people who did not take part in the production of food, allowing them to become priests and planners, builders and designers. Thus occupational specialization, elemental to an urban society, emerged.

But what sustained such a trading center and drew travelers to it? Was it food? Shady and her team found the bones of small edible fish, which must have come from the Pacific coast to the west, in the excavations. But they also found evidence of squash, sweet potatoes and beans having been grown locally. Shady theorized that Caral's early farmers diverted the area's rivers into canals, which still cross the Supe Valley today, to irrigate their fields.But because she found no traces of maize, which can be traded or stored and used in times of crop failure, she concluded that Caral's trade leverage was not based on stockpiling food supplies.

It was evidence of another crop in the excavations that gave Shady the best clue to Caral’s success. In nearly every excavated building, her team discovered evidence of cotton - seeds, fibers and textiles. Her theory fell into place when a large fishing net made of those fibers, unearthed in an unrelated dig on Peru's coast, turned out to be as old as Caral. 'The farmers of Caral grew the cotton that the fishermen needed to make their nets, Shady speculates. And the fishermen gave them shellfish and dried fish in exchange for these nets.' In essence, the people of Caral enabled fishermen to work with larger and more effective nets, which made the resources of the sea more readily available, and the fishermen probably used dried squash grown by the Caral people as flotation devices for their nets.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0029875-c89a-555e-9432-1c0ad60f0bd4', '02904353-1fd3-5dc2-80f5-036edc0aebce', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

1 ____ Caral was built at the same time as the construction of the Egyptian pyramids.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edf8657a-155c-55ee-9c0a-20d2d0e7c31e', 'a0029875-c89a-555e-9432-1c0ad60f0bd4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31c52d8a-f385-56c4-86e4-0773919e5d58', 'a0029875-c89a-555e-9432-1c0ad60f0bd4', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9510a344-400d-5ba8-96ac-b865702962f5', 'a0029875-c89a-555e-9432-1c0ad60f0bd4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91378c88-b7c7-5a16-87aa-34c7d70b53d0', '02904353-1fd3-5dc2-80f5-036edc0aebce', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

2 ____ The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6855730-811e-56fc-8e40-8961af02f18c', '91378c88-b7c7-5a16-87aa-34c7d70b53d0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820923c6-bba9-58b9-a1ec-0b74502e4f19', '91378c88-b7c7-5a16-87aa-34c7d70b53d0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87420236-3e62-5aef-b4d4-5a38baf6216e', '91378c88-b7c7-5a16-87aa-34c7d70b53d0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7727e9cb-c6d7-5b2f-a8f4-60961500362a', '02904353-1fd3-5dc2-80f5-036edc0aebce', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

3 ____ The stones used to build Piramide Mayor came from a location far away$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f64647b-e3e3-56db-a727-800b30234272', '7727e9cb-c6d7-5b2f-a8f4-60961500362a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3550a6f-5071-5cd0-aafd-bfdb03fcc72e', '7727e9cb-c6d7-5b2f-a8f4-60961500362a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afb3b935-b437-5d0e-ac9c-381ed625e913', '7727e9cb-c6d7-5b2f-a8f4-60961500362a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a8057d4-076b-5adb-ad64-26ebf66286f1', '02904353-1fd3-5dc2-80f5-036edc0aebce', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

4 ____ The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f417638c-91d4-5cbe-b073-86e3a4392835', '2a8057d4-076b-5adb-ad64-26ebf66286f1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cab510e8-94fd-5108-927a-c1d2e79d62b1', '2a8057d4-076b-5adb-ad64-26ebf66286f1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('875654ec-a928-5d07-8393-e635ba42b921', '2a8057d4-076b-5adb-ad64-26ebf66286f1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('04a62d7a-5435-54a3-8b51-cf1b0ca6e579', '02904353-1fd3-5dc2-80f5-036edc0aebce', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

5 ____ Archaeological evidence shows that the residents of Caral were highly skilled musicians.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5d89f84-721b-522a-8f3d-af0d56ba0d11', '04a62d7a-5435-54a3-8b51-cf1b0ca6e579', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ab8ded1-1353-546b-9d06-2d65446f4151', '04a62d7a-5435-54a3-8b51-cf1b0ca6e579', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03cf11d0-3162-5bdd-a7da-8d0255cd80bf', '04a62d7a-5435-54a3-8b51-cf1b0ca6e579', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1bea385-86b9-579e-bbc9-d64938a73eca', '02904353-1fd3-5dc2-80f5-036edc0aebce', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ? In boxes 1 -6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Caral was built at the same time as the construction of the Egyptian pyramids.
2
The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.
3
The stones used to build Piramide Mayor came from a location far away
4
The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.
5
Archaeological evidence shows that the residents of Caral were highly skilled musicians.
6
The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.

6 ____ The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbdaaecb-0742-5baa-949e-62b0a74fb2d7', 'd1bea385-86b9-579e-bbc9-d64938a73eca', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac4797c-2e40-53f7-9bdd-1e18c195088e', 'd1bea385-86b9-579e-bbc9-d64938a73eca', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b02d2ff-f089-56e4-be38-84ba2bd67abb', 'd1bea385-86b9-579e-bbc9-d64938a73eca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0f246f4a-e135-57c4-bc51-783f3bab0ab3', '02904353-1fd3-5dc2-80f5-036edc0aebce', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

the 7 ____ of a certain plant$md$, NULL, ARRAY['.*seeds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6e9324f4-cfbe-51cd-985d-11352d86d248', '02904353-1fd3-5dc2-80f5-036edc0aebce', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

8 ____ used to make jewellery$md$, NULL, ARRAY['.*shells.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e7bb8008-c02a-5388-a575-f272ebb00768', '02904353-1fd3-5dc2-80f5-036edc0aebce', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

the remains of certain food such as 9 ____$md$, NULL, ARRAY['.*fish.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('29409add-5bb7-5165-b268-30ccb46ad550', '02904353-1fd3-5dc2-80f5-036edc0aebce', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

10 ____ still in existence today indicate water diverted from rivers$md$, NULL, ARRAY['.*canals.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bdef94d0-7273-52d4-871c-2831d81655de', '02904353-1fd3-5dc2-80f5-036edc0aebce', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

no evidence that 11 ____ was grown$md$, NULL, ARRAY['.*maize.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e2c9f8cc-888c-5ea5-8b2c-fbadd4d602b4', '02904353-1fd3-5dc2-80f5-036edc0aebce', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

the excavation findings and fishing nets found on the coast suggest Caral farmers traded 12 ____$md$, NULL, ARRAY['.*cotton.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f3611145-3c6d-5a8f-98f1-dd276c3ba9ab', '02904353-1fd3-5dc2-80f5-036edc0aebce', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Caral as a trading centre
Items discovered at Caral but not naturally occurring in the area
the
7
of a certain plant
8
used to make jewellery
the remains of certain food such as
9
Clues to farming around Caral
10
still in existence today indicate water diverted from rivers
no evidence that
11
was grown
Evidence of relationship with fishing communities
the excavation findings and fishing nets found on the coast suggest Caral farmers traded
12
dried squash may have been used to aid
13

dried squash may have been used to aid 13 ____$md$, NULL, ARRAY['.*flotation.*']);

COMMIT;
