BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-roller-coaster-1186'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-roller-coaster-1186';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-roller-coaster-1186';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-roller-coaster-1186';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b22fbf51-4f62-5ec6-b40c-f53a49dfe68e', 'ielts-reading-roller-coaster-1186', $t$Roller coaster$t$, $md$## Roller coaster

Nguồn:
- Test: https://mini-ielts.com/1186/reading/roller-coaster
- Solution: https://mini-ielts.com/1186/view-solution/reading/roller-coaster$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 'b22fbf51-4f62-5ec6-b40c-f53a49dfe68e', 1, $t$Reading — Roller coaster$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Roller coaster

A 600 years ago, roller coaster pioneers never would have imagined the advancements that have been made to create the roller coasters of today. The tallest and fastest roller coaster in the world is the Kingda Ka, a coaster in New Jersey that launches its passengers from zero to 128 miles per hour in 3.5 seconds (most sports cars take over four seconds to get to just 60 miles per hour). It then heaves its riders skyward at a 90-degree angle (straight up) until it reaches a height of 456 feet, over one and a half football fields, above the ground, before dropping another 418 feet (Coaster Grotto “Kingda Ka”). With that said, roller coasters are about more than just speed and height, they are about the creativity of the designers that build them, each coaster having its own unique way of producing intense thrills at a lesser risk than the average car ride. Roller coasters have evolved drastically over the years, from their primitive beginnings as Russian ice slides, to the metal monsters of today. Their combination of creativity and structural elements make them one of the purest forms of architecture.

B At first glance, a roller coaster is something like a passenger train. It consists of a series of connected cars that move on tracks. But unlike a passenger train, a roller coaster has no engine or power source of its own. For most of the ride, the train is moved by gravity and momentum. To build up this momentum, you need to get the train to the top of the first hill or give it a powerful launch. The traditional lifting mechanism is a long length of chain running up the hill under the track. The chain is fastened in a loop , which is wound around a gear at the top of the hill and another one at the bottom of the hill. The gear at the bottom of the hill is turned by a simple motor . This turns the chain loop so that it continually moves up the hill like a long conveyer belt. The coaster cars grip onto the chain with several chain dogs, sturdy hinged hooks. When the train rolls to the bottom of the hill, the dogs catches onto the chain links. Once the chain dog is hooked, the chain simply pulls the train to the top of the hill. At the summit, the chain dog is released and the train starts its descent down the hill.

C Roller coasters have a long, fascinating history. The direct ancestors of roller coasters were monumental ice slides – long, steep wooden-slides covered in ice , some as high as 70 feet – that were popular in Russia in the 16th and 17th centuries. Riders shot down the slope in sleds made out of wood or blocks of ice, crash-landing in a sand pile. Coaster historians diverge on the exact evolution of these ice slides into actual rolling carts. The most widespread account is that a few entrepreneurial Frenchmen imported the ice slide idea to France. The warmer climate of France tended to melt the ice, so the French started building waxed slides instead, eventually adding wheels to the sleds. In 1817, the Russes a Belleville (Russian Mountains of Belleville) became the first roller coaster where the train was attached to the track (in this case, the train axle fit into a carved groove). The French continued to expand on this idea, coming up with more complex track layouts, with multiple cars and all sorts of twists and turns.

D In comparison to the world’s first roller coaster, there is perhaps an even greater debate over what was America’s first true coaster. Many will say that it is Pennsylvania’s own Maunch Chunk-Summit Hill and Switch Back Railroad. The Maunch Chunk-Summit Hill and Switch Back Railroad was originally America’s second railroad, and considered my many to be the greatest coaster of all time. Located in the Lehigh valley, it was originally used to transport coal from the top of Mount Pisgah to the bottom of Mount Jefferson, until Josiah White, a mining entrepreneur, had the idea of turning it into a part-time thrill ride. Because of its immediate popularity, it soon became strictly a passenger train. A steam engine would haul passengers to the top of the mountain, before letting them coast back down, with speeds rumored to reach 100 miles per hour! The reason that it was called a switch back railroad, a switch back track was located at the top – where the steam engine would let the riders coast back down. This type of track featured a dead end where the steam engine would detach its cars, allowing riders to coast down backwards. The railway went through a couple of minor track changes and name changes over the years, but managed to last from 1829 to 1937, over 100 years.

E The coaster craze in America was just starting to build. The creation of the Switch Back Railway, by La Marcus Thompson, gave roller coasters national attention. Originally built at New York’s Coney Island in 1884, Switch Back Railways began popping up all over the country . The popularity of these rides may puzzle the modern-day thrill seeker, due to the mild ride they gave in comparison to the modern-day roller coaster. Guests would pay a nickel to wait in line up to five hours just to go down a pair of side-by-side tracks with gradual hills that vehicles coasted down at a top speed around six miles per hour. Regardless, Switchback Railways were very popular, and sparked many people, including Thompson, to design coasters that were bigger and better.

F The 1910s and 1920s were probably the best decade that the roller coaster has ever seen. The new wave of technology, such as the “unstop wheels”, an arrangement that kept a coaster’s wheels to its tracks by resisted high gravitational forces, showed coasters a realm of possibilities that has never been seen before. In 1919, North America alone had about 1,500 roller coasters, a number that was rising rampantly. Then, the Great Depression gave a crushing blow to amusement parks all over America. As bad as it was, amusement parks had an optimistic look on the future in the late 1930s. But, in 1942 roller coasters could already feel the effects of World War Two, as they were forced into a shadow of neglect. Most, nearly all of America’s roller coasters were shut down . To this very day, the number of roller coaster in America is just a very tiny fraction of the amount of roller coasters in the 1920s.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d091062c-b3b9-5eec-b299-4f006da7d23b', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Answer the questions below.
A diagram that explains the mechanism and working principles of roller coaster.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Traditional lifting mechanism
1
Locate
2
Locate
3
Locate
4
Locate

1 ____ Locate$md$, NULL, ARRAY['.*chain.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('72197687-fa64-5acf-8fa7-c359dc61b257', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Answer the questions below.
A diagram that explains the mechanism and working principles of roller coaster.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Traditional lifting mechanism
1
Locate
2
Locate
3
Locate
4
Locate

2 ____ Locate$md$, NULL, ARRAY['.*loop.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8aa3f52e-9784-5710-9bc5-b442c864ff9b', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Answer the questions below.
A diagram that explains the mechanism and working principles of roller coaster.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Traditional lifting mechanism
1
Locate
2
Locate
3
Locate
4
Locate

3 ____ Locate$md$, NULL, ARRAY['.*gear.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('68fe3047-099f-5227-bf6a-744c4dce0e4f', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Answer the questions below.
A diagram that explains the mechanism and working principles of roller coaster.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Traditional lifting mechanism
1
Locate
2
Locate
3
Locate
4
Locate

4 ____ Locate$md$, NULL, ARRAY['.*simple.*motor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5479d4fb-e927-508f-9914-821625c68883', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

The first roller coaster was perhaps originated from Russia which is wrapped up by 5 ____ , which was introduced into France, and it was modified to 6 ____ , because temperature there would 7 ____ the ice. This time 8 ____ were installed on the board.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a589a5e9-91f5-5aa5-988e-945912890a88', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

The first roller coaster was perhaps originated from Russia which is wrapped up by 5 ____ , which was introduced into France, and it was modified to 6 ____ , because temperature there would 7 ____ the ice. This time 8 ____ were installed on the board.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f37ce6d-b0fd-5408-9b05-e1b6a72638f9', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

The first roller coaster was perhaps originated from Russia which is wrapped up by 5 ____ , which was introduced into France, and it was modified to 6 ____ , because temperature there would 7 ____ the ice. This time 8 ____ were installed on the board.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('189237b2-471f-54c1-b0f3-05a9226a35df', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

The first roller coaster was perhaps originated from Russia which is wrapped up by 5 ____ , which was introduced into France, and it was modified to 6 ____ , because temperature there would 7 ____ the ice. This time 8 ____ were installed on the board.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da57ce9c-5f35-5b06-a3af-51a8754cad6d', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send 9 ____ between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a 10 ____ there allowed riders to slide downward back again.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('723e82d3-ae27-5375-8d62-b7b4aef0cad6', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The first roller coaster was perhaps originated from Russia which is wrapped up by
5
, which was introduced into France, and it was modified to
6
, because temperature there would
7
the ice. This time
8
were installed on the board.
In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send
9
between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a
10
there allowed riders to slide downward back again.
Locate
Locate
Locate
Locate
Locate
Locate

In America, the first roller coaster was said to appear in Pennsylvania, it was actually a railroad which was designed to send 9 ____ between two mountains. Josiah White turned it into a thrill ride, it was also called switch back track and a 10 ____ there allowed riders to slide downward back again.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19ed9aad-6842-57c3-89cc-92fe38490fcb', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the view of the writer
NO
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
The most exiting roller coaster in the world is in New Jersey.
12
French added more innovation on Russian ice slide including both cars and tracks.
Locate
13
Switch Back Railways began to gain popularity since its first construction in New York.
Locate
14
The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world.
Locate

11 ____ The most exiting roller coaster in the world is in New Jersey. 12 ____ French added more innovation on Russian ice slide including both cars and tracks. Locate 13 ____ Switch Back Railways began to gain popularity since its first construction in New York. Locate 14 ____ The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7be784b-d939-57e4-8f38-24be819a0ec3', '19ed9aad-6842-57c3-89cc-92fe38490fcb', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6b9f28d-4604-5b9a-bed2-2ac620af9ba4', '19ed9aad-6842-57c3-89cc-92fe38490fcb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc7f7b85-be19-5a1c-8678-9ae73283e6d6', '19ed9aad-6842-57c3-89cc-92fe38490fcb', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fccba784-49bd-598e-a7d9-f8ec90b6df46', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the view of the writer
NO
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
The most exiting roller coaster in the world is in New Jersey.
12
French added more innovation on Russian ice slide including both cars and tracks.
Locate
13
Switch Back Railways began to gain popularity since its first construction in New York.
Locate
14
The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world.
Locate

11 ____ The most exiting roller coaster in the world is in New Jersey. 12 ____ French added more innovation on Russian ice slide including both cars and tracks. Locate 13 ____ Switch Back Railways began to gain popularity since its first construction in New York. Locate 14 ____ The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6105b17-e27a-57fb-ac39-08dc56c48ecb', 'fccba784-49bd-598e-a7d9-f8ec90b6df46', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e3381ef-9b11-565a-a1fd-7d94d028e675', 'fccba784-49bd-598e-a7d9-f8ec90b6df46', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4636948-17c1-5611-919b-ef074939aeca', 'fccba784-49bd-598e-a7d9-f8ec90b6df46', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d036400-5f2d-53a8-bfe3-984f49d4f5a2', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the view of the writer
NO
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
The most exiting roller coaster in the world is in New Jersey.
12
French added more innovation on Russian ice slide including both cars and tracks.
Locate
13
Switch Back Railways began to gain popularity since its first construction in New York.
Locate
14
The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world.
Locate

11 ____ The most exiting roller coaster in the world is in New Jersey. 12 ____ French added more innovation on Russian ice slide including both cars and tracks. Locate 13 ____ Switch Back Railways began to gain popularity since its first construction in New York. Locate 14 ____ The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5745efb-6fa9-56c1-b97a-82fdb5622930', '5d036400-5f2d-53a8-bfe3-984f49d4f5a2', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dd9e027-96af-5fd2-aea6-1356bc9fadb8', '5d036400-5f2d-53a8-bfe3-984f49d4f5a2', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ccbc718-2cfe-5e6b-bd5d-ce1009d51150', '5d036400-5f2d-53a8-bfe3-984f49d4f5a2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('554fa0ce-eea3-5b19-9aa3-1b212399e6fd', '516df4dc-2e41-5ff2-ac4c-11df0d4bd0ba', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the view of the writer
NO
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
The most exiting roller coaster in the world is in New Jersey.
12
French added more innovation on Russian ice slide including both cars and tracks.
Locate
13
Switch Back Railways began to gain popularity since its first construction in New York.
Locate
14
The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world.
Locate

11 ____ The most exiting roller coaster in the world is in New Jersey. 12 ____ French added more innovation on Russian ice slide including both cars and tracks. Locate 13 ____ Switch Back Railways began to gain popularity since its first construction in New York. Locate 14 ____ The Great Depression affected amusement parks yet did not shake the significant role of US roller coasters in the world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdbffc53-fac8-5366-909b-4b4361ca3bab', '554fa0ce-eea3-5b19-9aa3-1b212399e6fd', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfd65cdd-7e29-5534-9d91-62af52ba75d4', '554fa0ce-eea3-5b19-9aa3-1b212399e6fd', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59cf4356-7545-5f80-9b6b-8a233f8313fb', '554fa0ce-eea3-5b19-9aa3-1b212399e6fd', 3, $md$NOT GIVEN$md$, true);

COMMIT;
