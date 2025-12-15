BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-dinosaurs-and-the-secrets-they-still-hold-1302'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-dinosaurs-and-the-secrets-they-still-hold-1302';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-dinosaurs-and-the-secrets-they-still-hold-1302';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-dinosaurs-and-the-secrets-they-still-hold-1302';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2b7721a6-5636-5140-822a-5ec9527be631', 'ielts-reading-dinosaurs-and-the-secrets-they-still-hold-1302', $t$Dinosaurs and the secrets they still hold$t$, $md$## Dinosaurs and the secrets they still hold

Nguồn:
- Test: https://mini-ielts.com/1302/reading/dinosaurs-and-the-secrets-they-still-hold
- Solution: https://mini-ielts.com/1302/view-solution/reading/dinosaurs-and-the-secrets-they-still-hold$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('90bd5873-2f84-5f46-a62e-0ac35f9b48bd', '2b7721a6-5636-5140-822a-5ec9527be631', 1, $t$Reading — Dinosaurs and the secrets they still hold$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Dinosaurs and the secrets they still hold

Dinosaur expert Dr Steve Brusatte continues to investigate the mysteries surrounding these fascinating prehistoric creatures

I was recently part of a team of palaeontologists that discovered a new dinosaur. Living in what is now China, the species would have resembled a strange bird. It was about the size of a sheep and covered in feathers, with a sharp beak that it probably used to crack open shellfish. It was given the formal scientific name Tongtianlong , but we called it ‘Mud Dragon’ because its skeleton was discovered in rock that had hardened from ancient mud. It seems that the creature got trapped in the mud and died. Then its fossil remains were found a few months ago when workmen were excavating a site in order to build a school.

It is every dinosaur-obsessed child’s dearest wish to discover and name a completely new species. In fact what my colleagues and I did wasn’t that unusual. New dinosaurs are appearing everywhere these days – about 50 each year. And this pace shows no signs of slowing, as different areas continue to open up to fossil hunters and a fresh generation of scientists comes of age. Because of this plentiful supply of new fossils, we now know more about dinosaurs than we do about many modern animals. But there are still many unsolved mysteries.

Dinosaurs didn’t start out as huge monsters like Tyrannosaurus Rex. Instead they evolved from a group of angular, cat-sized reptiles called dinosauromorphs. These creatures remained small and rare for millions of years until they developed into dinosaurs. The boundary between dinosauromorphs and dinosaurs is becoming less and less distinct with each new discovery that’s made, but what’s becoming clear is that it took millions of years for these first dinosaurs to spread around the world, grow to huge sizes and become truly dominant.

Some discoveries in the 1970s, like the agile and strangely bird-like Deinonychus , proved that dinosaurs were far more dynamic and intelligent than previously thought. Some palaeontologists even proposed that they were warm-blooded creatures like modern birds with a constant high body temperature that they controlled internally, rather than from warming themselves by lying in the sun. A few decades later opinions are still mixed. The problem is that dinosaurs can’t be observed. Palaeontologists must rely on studying fossils. Some results are convincing: we know from studying their bones that dinosaurs had rapid growth rates, just like modern, warm-blooded animals. Other palaeontologists, however, use the same fossils to suggest that dinosaurs were somewhere between cold-blooded reptiles and warm-blooded birds. More studies are needed to provide more clarity.

The discovery of Deinonychus with its long arms, skinny legs, arched neck and big claws on its feet, helped to strengthen the theory that birds evolved from dinosaurs. In the late 1990s, the discovery of thousands of feather- covered dinosaurs closed the argument.

But the fossils raised another question: why did feathers first develop in dinosaurs? They probably originated as simple, hair-like strands — a necessary means of keeping warm. Many dinosaurs retained this basic fluffy coat, but in one group the strands modified. They grew bigger, started to branch out and changed into feathers like those on modern birds. They lined the arms, and sometimes the legs, forming wings. These feathers were probably for display: to attract mates or scare off rivals. They appeared in species such as the ostrich-like Ornithomimosaur . Such creatures were too large to fly. Flight may actually have come about by accident when smaller winged dinosaurs began jumping between trees or leaping in the air, and suddenly found that their wings had aerodynamic properties. This is one of the most stimulating new notions about dinosaurs and a fascinating area for further investigation.

There’s something else that these feathers can tell us. They allow us to determine what colour dinosaurs were. If you look at modern bird feathers under a microscope, you can see tiny blobs called melanosomes. These structures contain melanin, one of the main colour-producing pigments in animals. Some are round, others are egg-shaped, etc. And that’s important, because different shapes contain different colour pigments. So if you can identify the shape, you can identify the colour. A few years ago, some palaeontologists realised that you could find melanosomes in particularly well-preserved fossil feathers. They discovered that different dinosaurs had different melanosomes, which meant they had a variety of colours. Dinosaurs, therefore, probably came in a rainbow of colours – yet another thing that links them to modern birds.

The most enduring mystery of all, which has been argued about ever since the first dinosaur fossils were found, is ‘Why aren’t dinosaurs around today?’ Of course, we now know that birds evolved from dinosaurs, so some dinosaurs do continue in a sense. But there’s nothing like a Tyrannosaurus Rex today. They dominated the planet for over 150 million years, but suddenly disappeared from the fossil record 66 million years ago. That’s when a 10 km-wide asteroid came out of space and struck what is now Mexico, impacting with huge force and unleashing earthquakes, tidal waves, wildfires and hurricane-force winds. Although palaeontologists still like to argue about what part the asteroid played in the dinosaurs’ extinction, there really isn’t much of a mystery left. The asteroid did it and did it quickly. There are few signs that dinosaurs were struggling before the impact. None survived except a few birds and some small furry mammals. They found themselves in an empty world, and as the planet started to recover, they evolved into new creatures, including the first apes, and so the long journey began to the beginning of humankind.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b5f3bac0-2edf-5e4c-9ab1-77e2989aed64', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The discovery of Tongtianlong
This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a
1
. It is thought to have eaten
2
and it used its
3
to get through their hard exterior. The fossil of Tongtianlong was found surrounded by
4
under the ground where the foundations of a new
5
were being dug.

This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a 1 ____ . It is thought to have eaten 2 ____ and it used its 3 ____ to get through their hard exterior. The fossil of Tongtianlong was found surrounded by 4 ____ under the ground where the foundations of a new 5 ____ were being dug.$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a8b8c1e5-5ae7-53f9-a316-f6f7f4498fc5', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The discovery of Tongtianlong
This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a
1
. It is thought to have eaten
2
and it used its
3
to get through their hard exterior. The fossil of Tongtianlong was found surrounded by
4
under the ground where the foundations of a new
5
were being dug.

This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a 1 ____ . It is thought to have eaten 2 ____ and it used its 3 ____ to get through their hard exterior. The fossil of Tongtianlong was found surrounded by 4 ____ under the ground where the foundations of a new 5 ____ were being dug.$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('53b137fe-e5ac-54c7-afdb-1ce05f44daf3', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The discovery of Tongtianlong
This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a
1
. It is thought to have eaten
2
and it used its
3
to get through their hard exterior. The fossil of Tongtianlong was found surrounded by
4
under the ground where the foundations of a new
5
were being dug.

This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a 1 ____ . It is thought to have eaten 2 ____ and it used its 3 ____ to get through their hard exterior. The fossil of Tongtianlong was found surrounded by 4 ____ under the ground where the foundations of a new 5 ____ were being dug.$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5bc7c136-9dfb-5ede-91ba-ad541bdfb401', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The discovery of Tongtianlong
This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a
1
. It is thought to have eaten
2
and it used its
3
to get through their hard exterior. The fossil of Tongtianlong was found surrounded by
4
under the ground where the foundations of a new
5
were being dug.

This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a 1 ____ . It is thought to have eaten 2 ____ and it used its 3 ____ to get through their hard exterior. The fossil of Tongtianlong was found surrounded by 4 ____ under the ground where the foundations of a new 5 ____ were being dug.$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e23ceac0-6458-5c00-8d0e-1cd9bf455a36', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The discovery of Tongtianlong
This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a
1
. It is thought to have eaten
2
and it used its
3
to get through their hard exterior. The fossil of Tongtianlong was found surrounded by
4
under the ground where the foundations of a new
5
were being dug.

This species of dinosaur has only recently been found in an area of China. Scientists believe that it was bird-like in appearance and probably no bigger than a 1 ____ . It is thought to have eaten 2 ____ and it used its 3 ____ to get through their hard exterior. The fossil of Tongtianlong was found surrounded by 4 ____ under the ground where the foundations of a new 5 ____ were being dug.$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de53d250-83a4-5304-ac25-68e2b2119115', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6. What does the writer suggest about finding new dinosaurs?
A
Many scientists dream of being able to do so one day.
B
It is probable that most have now been discovered.
C
People are running out of places to look for them.
D
It is becoming relatively common to dig one up.
7. In the fourth paragraph, what does the writer suggest about palaeontologists?
A
They should study the fossilised bones of dinosaurs more closely.
B
Their theories are based on evidence that can be interpreted in different ways.
C
It is impossible to have any confidence in the proposals they have made.
D
It is worrying that they still cannot agree about dinosaurs’ body temperature.
8. When describing the theory of how dinosaurs began to fly, the writer is
A
amused that their flight probably came about by chance.
B
surprised by the reason for the initial development of feathers.
C
excited by the different possibilities it holds for future research.
D
confused that feathers were also present on some creatures’ legs.
9. One significance of melanosomes is that they
A
provide further evidence of where birds evolved from.
B
are only found in certain parts of the world.
C
can be clearly seen in most fossilised feathers.
D
are only found in certain birds and dinosaurs.
10. Which of the following best summarises the writer’s point in the final paragraph?
A
Scientists are right to continue questioning the effects of the asteroid strike.
B
Large flightless dinosaurs may have existed after the asteroid hit.
C
The dinosaurs were already declining before the asteroid hit.
D
The effects of the asteroid strike killed most dinosaurs.

Choose the correct letter, A, B, C or D . Write the correct letter in boxes 6-10 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08773530-a35e-50b7-828a-a86b9471506c', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6. What does the writer suggest about finding new dinosaurs?
A
Many scientists dream of being able to do so one day.
B
It is probable that most have now been discovered.
C
People are running out of places to look for them.
D
It is becoming relatively common to dig one up.
7. In the fourth paragraph, what does the writer suggest about palaeontologists?
A
They should study the fossilised bones of dinosaurs more closely.
B
Their theories are based on evidence that can be interpreted in different ways.
C
It is impossible to have any confidence in the proposals they have made.
D
It is worrying that they still cannot agree about dinosaurs’ body temperature.
8. When describing the theory of how dinosaurs began to fly, the writer is
A
amused that their flight probably came about by chance.
B
surprised by the reason for the initial development of feathers.
C
excited by the different possibilities it holds for future research.
D
confused that feathers were also present on some creatures’ legs.
9. One significance of melanosomes is that they
A
provide further evidence of where birds evolved from.
B
are only found in certain parts of the world.
C
can be clearly seen in most fossilised feathers.
D
are only found in certain birds and dinosaurs.
10. Which of the following best summarises the writer’s point in the final paragraph?
A
Scientists are right to continue questioning the effects of the asteroid strike.
B
Large flightless dinosaurs may have existed after the asteroid hit.
C
The dinosaurs were already declining before the asteroid hit.
D
The effects of the asteroid strike killed most dinosaurs.

Choose the correct letter, A, B, C or D . Write the correct letter in boxes 6-10 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2444c74c-1acf-523d-a4be-60a597811480', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6. What does the writer suggest about finding new dinosaurs?
A
Many scientists dream of being able to do so one day.
B
It is probable that most have now been discovered.
C
People are running out of places to look for them.
D
It is becoming relatively common to dig one up.
7. In the fourth paragraph, what does the writer suggest about palaeontologists?
A
They should study the fossilised bones of dinosaurs more closely.
B
Their theories are based on evidence that can be interpreted in different ways.
C
It is impossible to have any confidence in the proposals they have made.
D
It is worrying that they still cannot agree about dinosaurs’ body temperature.
8. When describing the theory of how dinosaurs began to fly, the writer is
A
amused that their flight probably came about by chance.
B
surprised by the reason for the initial development of feathers.
C
excited by the different possibilities it holds for future research.
D
confused that feathers were also present on some creatures’ legs.
9. One significance of melanosomes is that they
A
provide further evidence of where birds evolved from.
B
are only found in certain parts of the world.
C
can be clearly seen in most fossilised feathers.
D
are only found in certain birds and dinosaurs.
10. Which of the following best summarises the writer’s point in the final paragraph?
A
Scientists are right to continue questioning the effects of the asteroid strike.
B
Large flightless dinosaurs may have existed after the asteroid hit.
C
The dinosaurs were already declining before the asteroid hit.
D
The effects of the asteroid strike killed most dinosaurs.

Choose the correct letter, A, B, C or D . Write the correct letter in boxes 6-10 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('87ecaf8b-be94-574f-b92b-5aa5cc617133', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6. What does the writer suggest about finding new dinosaurs?
A
Many scientists dream of being able to do so one day.
B
It is probable that most have now been discovered.
C
People are running out of places to look for them.
D
It is becoming relatively common to dig one up.
7. In the fourth paragraph, what does the writer suggest about palaeontologists?
A
They should study the fossilised bones of dinosaurs more closely.
B
Their theories are based on evidence that can be interpreted in different ways.
C
It is impossible to have any confidence in the proposals they have made.
D
It is worrying that they still cannot agree about dinosaurs’ body temperature.
8. When describing the theory of how dinosaurs began to fly, the writer is
A
amused that their flight probably came about by chance.
B
surprised by the reason for the initial development of feathers.
C
excited by the different possibilities it holds for future research.
D
confused that feathers were also present on some creatures’ legs.
9. One significance of melanosomes is that they
A
provide further evidence of where birds evolved from.
B
are only found in certain parts of the world.
C
can be clearly seen in most fossilised feathers.
D
are only found in certain birds and dinosaurs.
10. Which of the following best summarises the writer’s point in the final paragraph?
A
Scientists are right to continue questioning the effects of the asteroid strike.
B
Large flightless dinosaurs may have existed after the asteroid hit.
C
The dinosaurs were already declining before the asteroid hit.
D
The effects of the asteroid strike killed most dinosaurs.

Choose the correct letter, A, B, C or D . Write the correct letter in boxes 6-10 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85d47fe5-d30c-5f37-8d01-79dc856d174c', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6. What does the writer suggest about finding new dinosaurs?
A
Many scientists dream of being able to do so one day.
B
It is probable that most have now been discovered.
C
People are running out of places to look for them.
D
It is becoming relatively common to dig one up.
7. In the fourth paragraph, what does the writer suggest about palaeontologists?
A
They should study the fossilised bones of dinosaurs more closely.
B
Their theories are based on evidence that can be interpreted in different ways.
C
It is impossible to have any confidence in the proposals they have made.
D
It is worrying that they still cannot agree about dinosaurs’ body temperature.
8. When describing the theory of how dinosaurs began to fly, the writer is
A
amused that their flight probably came about by chance.
B
surprised by the reason for the initial development of feathers.
C
excited by the different possibilities it holds for future research.
D
confused that feathers were also present on some creatures’ legs.
9. One significance of melanosomes is that they
A
provide further evidence of where birds evolved from.
B
are only found in certain parts of the world.
C
can be clearly seen in most fossilised feathers.
D
are only found in certain birds and dinosaurs.
10. Which of the following best summarises the writer’s point in the final paragraph?
A
Scientists are right to continue questioning the effects of the asteroid strike.
B
Large flightless dinosaurs may have existed after the asteroid hit.
C
The dinosaurs were already declining before the asteroid hit.
D
The effects of the asteroid strike killed most dinosaurs.

Choose the correct letter, A, B, C or D . Write the correct letter in boxes 6-10 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc681c62-e500-5e32-b1bd-d992faf35316', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Look at the following statements (
Questions 11-13
) and the list of prehistoric animals below.
Match each statement with the correct animal,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes 11-13 on your answer sheet.
NB
You may use any letter more than once.
11
It may have used its feathers to frighten off members of the same species.
12
This species resembles a large flightless bird that exists today.
13
Finding this species made scientists revise their opinion of the brain power of dinosaurs.
List of Prehistoric Animals
A
Tongtianlong
B
Tyrannosaurus Rex
C
Deinonychus
D
Ornithomimosaur

11 ____ It may have used its feathers to frighten off members of the same species. 12 ____ This species resembles a large flightless bird that exists today. 13 ____ Finding this species made scientists revise their opinion of the brain power of dinosaurs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bb295ac-de88-595d-8c9a-8d0d3127dd5d', 'dc681c62-e500-5e32-b1bd-d992faf35316', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58e6fea6-ce7f-54b3-8803-d1f8b747e59f', 'dc681c62-e500-5e32-b1bd-d992faf35316', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfc8bdcd-8943-5b35-97a0-e46271188386', 'dc681c62-e500-5e32-b1bd-d992faf35316', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a2c8fe6-4f8f-5cdb-8188-8bfd43ee50cb', 'dc681c62-e500-5e32-b1bd-d992faf35316', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d660733a-9573-5a7d-9875-8bc758f88d99', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Look at the following statements (
Questions 11-13
) and the list of prehistoric animals below.
Match each statement with the correct animal,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes 11-13 on your answer sheet.
NB
You may use any letter more than once.
11
It may have used its feathers to frighten off members of the same species.
12
This species resembles a large flightless bird that exists today.
13
Finding this species made scientists revise their opinion of the brain power of dinosaurs.
List of Prehistoric Animals
A
Tongtianlong
B
Tyrannosaurus Rex
C
Deinonychus
D
Ornithomimosaur

11 ____ It may have used its feathers to frighten off members of the same species. 12 ____ This species resembles a large flightless bird that exists today. 13 ____ Finding this species made scientists revise their opinion of the brain power of dinosaurs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d404537b-8282-5203-8b73-34ac627abd59', 'd660733a-9573-5a7d-9875-8bc758f88d99', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0197895e-7035-5423-b9af-d38d6596cde7', 'd660733a-9573-5a7d-9875-8bc758f88d99', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52868689-d38b-5cee-b5d2-d0ee87789697', 'd660733a-9573-5a7d-9875-8bc758f88d99', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29962db1-1a52-53e1-9223-027d39116577', 'd660733a-9573-5a7d-9875-8bc758f88d99', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f88d5161-b0e1-57b0-b0b4-1322c48c04b4', '90bd5873-2f84-5f46-a62e-0ac35f9b48bd', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Look at the following statements (
Questions 11-13
) and the list of prehistoric animals below.
Match each statement with the correct animal,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes 11-13 on your answer sheet.
NB
You may use any letter more than once.
11
It may have used its feathers to frighten off members of the same species.
12
This species resembles a large flightless bird that exists today.
13
Finding this species made scientists revise their opinion of the brain power of dinosaurs.
List of Prehistoric Animals
A
Tongtianlong
B
Tyrannosaurus Rex
C
Deinonychus
D
Ornithomimosaur

11 ____ It may have used its feathers to frighten off members of the same species. 12 ____ This species resembles a large flightless bird that exists today. 13 ____ Finding this species made scientists revise their opinion of the brain power of dinosaurs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea36c6ae-22e4-53a1-ad15-566ab180e18a', 'f88d5161-b0e1-57b0-b0b4-1322c48c04b4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63267dcc-4651-513b-97a9-59db977e4e61', 'f88d5161-b0e1-57b0-b0b4-1322c48c04b4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a3d54ae-de01-584c-82cf-761e0029aa86', 'f88d5161-b0e1-57b0-b0b4-1322c48c04b4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9715b72-674f-50e3-b606-ef5ae908c17e', 'f88d5161-b0e1-57b0-b0b4-1322c48c04b4', 4, $md$D$md$, true);

COMMIT;
