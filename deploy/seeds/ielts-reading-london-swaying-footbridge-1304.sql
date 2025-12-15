BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-london-swaying-footbridge-1304'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-london-swaying-footbridge-1304';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-london-swaying-footbridge-1304';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-london-swaying-footbridge-1304';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a0589085-5ea6-5d2a-8a1c-be8c6640ed3e', 'ielts-reading-london-swaying-footbridge-1304', $t$London Swaying Footbridge$t$, $md$## London Swaying Footbridge

Nguồn:
- Test: https://mini-ielts.com/1304/reading/london-swaying-footbridge
- Solution: https://mini-ielts.com/1304/view-solution/reading/london-swaying-footbridge$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1dd5332e-a647-5693-90d5-149b8797d3ff', 'a0589085-5ea6-5d2a-8a1c-be8c6640ed3e', 1, $t$Reading — London Swaying Footbridge$t$, $md$Read the passage and answer questions **1–9**.

### Passage: London Swaying Footbridge

A . In September 1996 a competition was organized by the Financial Times in association with the London Borough of Southwark to design a new footbridge across the Thames. The competition attracted over 200 entries and was won by a team comprising Arup (engineers), Foster and Partners (architects) and the sculptor Sir Anthony Caro.

B . The bridge opened to the public on 10 June 2000. Up to 100,000 people crossed it that day with up to 2000 people on the bridge at any one time. At first, the bridge was still. Then it began to sway just slightly. Then, almost from one moment to the next, when large groups of people were crossing, the wobble intensified. This movement became sufficiently large for people to stop walking to retain their balance and sometimes to hold onto the hand rails for support. It was decided immediately to limit the number of people on the bridge, but even so the deck movement was sufficient to be uncomfortable and to raise concern for public safety so that on 12 June the bridge was closed until the problem could be solved.

C . The embarrassed engineers found the videotape that day which showed the center span swaying about 3 inches side to side every second. The engineers first thought that winds might be exerting excessive force on the many large flags and banners bedecking the bridge for its gala premiere. What’s more, they also discovered that the pedestrians also played a key role. Human activities, such as walking, running, jumping, swaying, etc. could cause horizontal force which in turn could cause excessive dynamic vibration in the lateral direction in the bridge. As the structure began moving, pedestrians adjusted their gait to the same lateral rhythm as the bridge. The adjusted footsteps magnified the motion – just like when four people all stand up in a small boat at the same time. As more pedestrians locked into the same rhythm, the increasing oscillations led to the dramatic swaying captured on film.

D. In order to design a method of reducing the movements, the force exerted by the pedestrians had to be quantified and related to the motion of the bridge. Although there are some descriptions of this phenomenon in existing literature, none of these actually quantifies the force. So there was no quantitative analytical way to design the bridge against this effect. An immediate research program was launched by the bridge’s engineering designers Ove Arup, supported by a number of universities and research organizations.

E . The tests at the University of Southampton involved a person walking ‘on the spot’ on a small shake table. The tests at Imperial College involved persons walking along a specially built, 7.2m-long platform which could be driven laterally at different frequencies (n and amplitudes. Each type of test had its limitations. The Imperial College tests were only able to capture 7-8 footsteps, and the ‘walking on the spot’ tests, although monitoring many footsteps, could not investigate normal forward walking. Neither test could investigate any influence of other people in a crowd on the behavior of the individual being tested.

F . The results of the laboratory tests provided information which enabled the initial design of a retro-fit to be progressed. However, the limitations of these tests was clear and it was felt that the only way to replicate properly the precise conditions of the Millennium Bridge was to carry out crowd tests on the bridge deck itself. These tests done by the Arup engineers could incorporate factors not possible in the laboratory tests. The first of these was carried out with 100 people in July 2000. The results of these tests were used to refine the load model for the pedestrians. A second series of crowd tests was carried out on the bridge in December 2000. The purpose of these tests was to further validate the design assumptions and to load test a prototype damper installation. The test was carried out with 275 people.

G . Unless the usage of the bridge was to be greatly restricted, only two generic options to improve its performance were considered feasible. The first was to increase the stiffness of the bridge to move all its lateral natural frequencies out of the range that could be excited by the lateral footfall forces, and the second was to increase the damping of the bridge to reduce the resonant response.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5b1500c3-8f04-57f5-893a-2fbaa0ebc9f9', '1dd5332e-a647-5693-90d5-149b8797d3ff', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Complete the following summary of the paragraphs of
Reading Passage
using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 5-9 on your answer sheet
After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that
5
and
6
might create excessive force on the bridge. The distribution of
7
resulted from human activities could cause
8
throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the
9
.

After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that 5 ____ and 6 ____ might create excessive force on the bridge. The distribution of 7 ____ resulted from human activities could cause 8 ____ throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the 9 ____ .$md$, NULL, ARRAY['.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('59969f01-3b9c-5d63-aa81-99bb909a179d', '1dd5332e-a647-5693-90d5-149b8797d3ff', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Complete the following summary of the paragraphs of
Reading Passage
using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 5-9 on your answer sheet
After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that
5
and
6
might create excessive force on the bridge. The distribution of
7
resulted from human activities could cause
8
throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the
9
.

After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that 5 ____ and 6 ____ might create excessive force on the bridge. The distribution of 7 ____ resulted from human activities could cause 8 ____ throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the 9 ____ .$md$, NULL, ARRAY['.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dcbdde5a-f0b4-5b4a-ab70-2b58c97fb93a', '1dd5332e-a647-5693-90d5-149b8797d3ff', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Complete the following summary of the paragraphs of
Reading Passage
using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 5-9 on your answer sheet
After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that
5
and
6
might create excessive force on the bridge. The distribution of
7
resulted from human activities could cause
8
throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the
9
.

After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that 5 ____ and 6 ____ might create excessive force on the bridge. The distribution of 7 ____ resulted from human activities could cause 8 ____ throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the 9 ____ .$md$, NULL, ARRAY['.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e247d2e1-c61d-501b-bfad-11e5c88f4c4e', '1dd5332e-a647-5693-90d5-149b8797d3ff', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Complete the following summary of the paragraphs of
Reading Passage
using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 5-9 on your answer sheet
After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that
5
and
6
might create excessive force on the bridge. The distribution of
7
resulted from human activities could cause
8
throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the
9
.

After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that 5 ____ and 6 ____ might create excessive force on the bridge. The distribution of 7 ____ resulted from human activities could cause 8 ____ throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the 9 ____ .$md$, NULL, ARRAY['.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('55d9efa6-a646-5e58-b1e0-c314925be290', '1dd5332e-a647-5693-90d5-149b8797d3ff', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Complete the following summary of the paragraphs of
Reading Passage
using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 5-9 on your answer sheet
After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that
5
and
6
might create excessive force on the bridge. The distribution of
7
resulted from human activities could cause
8
throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the
9
.

After the opening ceremony, the embarrassed engineers tried to find out the reason of the bridge’s wobbling. Judged from the videotape, they thought that 5 ____ and 6 ____ might create excessive force on the bridge. The distribution of 7 ____ resulted from human activities could cause 8 ____ throughout the structure. This swaying prompted people to start adjusting the way they walk, which in turn reinforced the 9 ____ .$md$, NULL, ARRAY['.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('aa4d1370-02b4-5c4a-ae3a-b0a7674dd27a', '1dd5332e-a647-5693-90d5-149b8797d3ff', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the table below.
Choose
NO MORE THAN THREE WORDS
from
Reading Passage
for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Research programs launched by universities and organizations
Universities / People
Activity
Test at
10
Limited ability to have 7-8 footsteps
‘walking on the spot’ at Southampton
Not enough data on
11
Crowd test conducted by
12
Aim to verify
13

Test at 10 ____$md$, NULL, ARRAY['.*imperial.*college.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8c570c1f-7e2c-5f2a-8ffc-49bd5e252cdc', '1dd5332e-a647-5693-90d5-149b8797d3ff', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the table below.
Choose
NO MORE THAN THREE WORDS
from
Reading Passage
for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Research programs launched by universities and organizations
Universities / People
Activity
Test at
10
Limited ability to have 7-8 footsteps
‘walking on the spot’ at Southampton
Not enough data on
11
Crowd test conducted by
12
Aim to verify
13

Not enough data on 11 ____$md$, NULL, ARRAY['.*normal.*forward.*walking.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3bc23a5e-a04e-5aa7-9181-e0e837acb4e4', '1dd5332e-a647-5693-90d5-149b8797d3ff', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the table below.
Choose
NO MORE THAN THREE WORDS
from
Reading Passage
for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Research programs launched by universities and organizations
Universities / People
Activity
Test at
10
Limited ability to have 7-8 footsteps
‘walking on the spot’ at Southampton
Not enough data on
11
Crowd test conducted by
12
Aim to verify
13

Crowd test conducted by 12 ____$md$, NULL, ARRAY['.*arup.*engineers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6083746f-6bc4-534f-938e-2e0c1f942584', '1dd5332e-a647-5693-90d5-149b8797d3ff', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the table below.
Choose
NO MORE THAN THREE WORDS
from
Reading Passage
for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Research programs launched by universities and organizations
Universities / People
Activity
Test at
10
Limited ability to have 7-8 footsteps
‘walking on the spot’ at Southampton
Not enough data on
11
Crowd test conducted by
12
Aim to verify
13

Aim to verify 13 ____$md$, NULL, ARRAY['.*design.*assumptions.*']);

COMMIT;
