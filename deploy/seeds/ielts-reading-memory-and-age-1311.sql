BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-memory-and-age-1311'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-memory-and-age-1311';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-memory-and-age-1311';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-memory-and-age-1311';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9f080cb1-fda4-5cef-a52d-06c285a7b4a8', 'ielts-reading-memory-and-age-1311', $t$Memory and Age$t$, $md$## Memory and Age

Nguồn:
- Test: https://mini-ielts.com/1311/reading/memory-and-age
- Solution: https://mini-ielts.com/1311/view-solution/reading/memory-and-age$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1d63cc36-bf51-5898-8151-3e467d31700c', '9f080cb1-fda4-5cef-a52d-06c285a7b4a8', 1, $t$Reading — Memory and Age$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Memory and Age

{A} Aging, it is now clear, is part of an ongoing maturation process that all our organs go through. “In a sense, aging is keyed to the level of vigor of the body and the continuous interaction between levels of body activity and levels of mental activity,” reports Arnold B. Scheibel, M.D., whose very academic title reflects how once far-flung domains now converge on the mind and the brain. Scheibel is professor of anatomy, cell biology, psychiatry, and behavioral sciences at the University of California at Los Angeles, and director of the university’s Brain Research Institute. Experimental evidence has backed up popular assumptions that the aging mind undergoes decay analogous to that of the aging body. Younger monkeys, chimps, and lower animals consistently outperform their older colleagues on memory tests. In humans, psychologists concluded, memory and other mental functions deteriorate over time because of inevitable organic changes in the brain as neurons die off. Mental decline after young adulthood appeared inevitable.

{B} Equipped with imaging techniques that capture the brain in action, Stanley Rapoport, Ph.D., at the National Institutes of Health, measured the flow of blood in the brains of old and young people as they went through the task of matching photos of faces. Since blood flow reflects neuronal activity, Rapoport could compare which networks of neurons were being used by different subjects. “Even when the reaction times of older and younger subjects were the same, the neural networks they used were significantly different. The older subjects were using different internal strategies to accomplish the same result in the same time,” Rapoport says. Either the task required greater effort on the part of the older subjects or the work of neurons originally involved in tasks of that type had been taken over by other neurons, creating different networks.

{C} At the Georgia Institute of Technology, psychologist Timothy Salthouse, Ph.D., compared a group of very fast and accurate typists of college age with another group in their 60s. Since reaction time is faster in younger people and most people’s fingers grow less nimble with age, younger typists might be expected to tap right along while the older ones fumble. But both typed 60 words a minute. The older typists, it turned out, achieved their speed with cunning little strategies that made them far more efficient than their younger counterparts: They made fewer finger movements, saving a fraction of a second here and there. They also read ahead in the text. The neural networks involved in typing appear to have been reshaped to compensate for losses in motor skills or other age changes.

{D} “When a rat is kept in isolation without playmates or objects to interact with, the animal’s brain shrinks, but if we put that rat with 11 other rats in a large cage and give them an assortment of wheels, ladders, and other toys, we can show–after four days– significant differences in its brain,” says Diamond, professor of integrative biology. Proliferating dendrites first appear in the visual association areas. After a month in the enriched environment, the whole cerebral cortex has expanded, as has its blood supply. Even in the enriched environment, rats get bored unless the toys are varied. “Animals are just like we are. They need stimulation,” says Diamond.

{E} One of the most profoundly important mental functions is memory-notorious for its failure with age. So important is memory that the Charles A. Dana Foundation recently spent $8.4 million to set up a consortium of leading medical centers to measure memory loss and aging through brain imaging technology, neurochemical experiments, and cognitive and psychological tests. One thing, however, is already fairly clear–many aspects of memory are not a function of age at all but of education. Memory exists in more than one form. What we call knowledge–facts-is what psychologists such as Harry P. Bahrick, Ph.D., of Ohio Wesleyan University calls semantic memory. Events, conversations, and occurrences in time and space, on the other hand, make up episodic or event memory, which is triggered by cues from the context. If you were around in 1963 you don’t need to be reminded of the circumstances surrounding the moment you heard that JFK had been assassinated. That event is etched into your episodic memory.

{F} When you forget a less vivid item, like buying a roll of paper towels at the supermarket, you may blame it on your aging memory. It’s true that episodic memory begins to decline when most people are in their 50s, but it’s never perfect at any age. “Every memory begins as an event,” says Bahrick. “Through repetition, certain events leave behind a residue of knowledge, or semantic memory. On a specific day in the past, somebody taught you that two and two are four, but you’ve been over that information so often you don’t remember where you learned it. What started as an episodic memory has become a permanent part of your knowledge base.” You remember the content, not the context. Our language knowledge, our knowledge of the world and of people, is largely that permanent or semipermanent residue.

{G} Probing the longevity of knowledge, Bahrick tested 1,000 high school graduates to see how well they recalled their algebra. Some had completed the course as recently as a month before, others as long as 50 years earlier. He also determined how long each person had studied algebra, the grade received, and how much the skill was used over the course of adulthood. Surprisingly, a person’s grasp of algebra at the time of testing did not depend on how long ago he’d taken the course–the determining factor was the duration of instruction. Those who had spent only a few months learning algebra forgot most of it within two or three years.

{H} In another study, Bahrick discovered that people who had taken several courses in Spanish, spread out over a couple of years, could recall, decades later, 60 percent or more of the vocabulary they learned. Those who took just one course retained only a trace after three years. “This long-term residue of knowledge remains stable over the decades, independent of the age of the person and the age of the memory. No serious deficit appears until people get to their 50s and 60s, probably due to the degenerative processes of aging rather than a cognitive loss.”

{I} “You could say metamemory is a byproduct of going to school,” says psychologist Robert Kail, Ph.D., of Purdue University, who studies children from birth to 20 years, the time of life when mental development is most rapid. “The question-and-answer process, especially exam-taking, helps children learn–and also teaches them how their memory works This may be one reason why, according to a broad range of studies in people over 60, the better educated a person is, the more likely they are to perform better in life and on psychological tests. A group of adult novice chess players were compared with a group of child experts at the game. In tests of their ability to remember a random series of numbers, the adults, as expected, outscored the children. But when asked to remember the patterns of chess pieces arranged on a board, the children won. “Because they’d played a lot of chess, their knowledge of chess was better organized than that of the adults, and their existing knowledge of chess served as a framework for new memory,” explains Kail.

{J} Specialized knowledge is a mental resource that only improves with time. Crystallized intelligence about one’s occupation apparently does not decline at all until at least age 75, and if there is no disease or dementia, may remain even longer. Special knowledge is often organized by a process called “chunking.” If procedure A and procedure B are always done together, for example, the mind may merge them into a single command. When you apply yourself to a specific interest–say, cooking–you build increasingly elaborate knowledge structures that let you do more and do it better. This ability, which is tied to experience, is the essence of expertise. Vocabulary is one such specialized form of accrued knowledge. Research clearly shows that vocabulary improves with time. Retired professionals, especially teachers and journalists, consistently score higher on tests of vocabulary and general information than college students, who are supposed to be in their mental prime.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('840bb7f0-daa9-5f1e-9535-34bd0c940e4a', '1d63cc36-bf51-5898-8151-3e467d31700c', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-4 on your answer sheet.
Choose the correct letter, A, B, C or D.
Write your answers in boxes 14-17 on your answer sheet.
Question 1.
What does the typist’s experiment show in the passage?
A
Old people reading ability is superior
B
Losses of age is irreversible
C
Seasoned tactics made elders more efficient
D
Old people performed poorly in driving test
Question 2.
Which is correct about rat experiment?
A
Different toys have different effect for rats
B
Rat’s brain weight increased in both cages.
C
Isolated rat’s brain grows new connections
D
Boring and complicated surroundings affect brain development
Question 3.
What can be concluded in the chess game of a children’s group?
A
They won game with adults.
B
Their organization of chess knowledge is better
C
Their image memory is better than adults
D
They used different part of brain when chessing
Question 4.
What is the author’s purpose of using “vocabulary study” at the end of the passage?
A
Certain people are sensitive to vocabularies while others aren’t
B
Teachers and professionals won by their experience
C
Vocabulary memory as a crystallized intelligence is hard to decline
D
Old people use their special zone of brain when study

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f2a1cad-f1b4-5118-a813-84223a4ab2a7', '1d63cc36-bf51-5898-8151-3e467d31700c', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-4 on your answer sheet.
Choose the correct letter, A, B, C or D.
Write your answers in boxes 14-17 on your answer sheet.
Question 1.
What does the typist’s experiment show in the passage?
A
Old people reading ability is superior
B
Losses of age is irreversible
C
Seasoned tactics made elders more efficient
D
Old people performed poorly in driving test
Question 2.
Which is correct about rat experiment?
A
Different toys have different effect for rats
B
Rat’s brain weight increased in both cages.
C
Isolated rat’s brain grows new connections
D
Boring and complicated surroundings affect brain development
Question 3.
What can be concluded in the chess game of a children’s group?
A
They won game with adults.
B
Their organization of chess knowledge is better
C
Their image memory is better than adults
D
They used different part of brain when chessing
Question 4.
What is the author’s purpose of using “vocabulary study” at the end of the passage?
A
Certain people are sensitive to vocabularies while others aren’t
B
Teachers and professionals won by their experience
C
Vocabulary memory as a crystallized intelligence is hard to decline
D
Old people use their special zone of brain when study

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3fab1e89-c6ab-51db-b1ae-22b8d3848178', '1d63cc36-bf51-5898-8151-3e467d31700c', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-4 on your answer sheet.
Choose the correct letter, A, B, C or D.
Write your answers in boxes 14-17 on your answer sheet.
Question 1.
What does the typist’s experiment show in the passage?
A
Old people reading ability is superior
B
Losses of age is irreversible
C
Seasoned tactics made elders more efficient
D
Old people performed poorly in driving test
Question 2.
Which is correct about rat experiment?
A
Different toys have different effect for rats
B
Rat’s brain weight increased in both cages.
C
Isolated rat’s brain grows new connections
D
Boring and complicated surroundings affect brain development
Question 3.
What can be concluded in the chess game of a children’s group?
A
They won game with adults.
B
Their organization of chess knowledge is better
C
Their image memory is better than adults
D
They used different part of brain when chessing
Question 4.
What is the author’s purpose of using “vocabulary study” at the end of the passage?
A
Certain people are sensitive to vocabularies while others aren’t
B
Teachers and professionals won by their experience
C
Vocabulary memory as a crystallized intelligence is hard to decline
D
Old people use their special zone of brain when study

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd8ae781-3551-5b1f-b303-35829d452cdf', '1d63cc36-bf51-5898-8151-3e467d31700c', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-4 on your answer sheet.
Choose the correct letter, A, B, C or D.
Write your answers in boxes 14-17 on your answer sheet.
Question 1.
What does the typist’s experiment show in the passage?
A
Old people reading ability is superior
B
Losses of age is irreversible
C
Seasoned tactics made elders more efficient
D
Old people performed poorly in driving test
Question 2.
Which is correct about rat experiment?
A
Different toys have different effect for rats
B
Rat’s brain weight increased in both cages.
C
Isolated rat’s brain grows new connections
D
Boring and complicated surroundings affect brain development
Question 3.
What can be concluded in the chess game of a children’s group?
A
They won game with adults.
B
Their organization of chess knowledge is better
C
Their image memory is better than adults
D
They used different part of brain when chessing
Question 4.
What is the author’s purpose of using “vocabulary study” at the end of the passage?
A
Certain people are sensitive to vocabularies while others aren’t
B
Teachers and professionals won by their experience
C
Vocabulary memory as a crystallized intelligence is hard to decline
D
Old people use their special zone of brain when study

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cfe4f60a-079a-5be3-ae0b-ab1e9090314b', '1d63cc36-bf51-5898-8151-3e467d31700c', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c0d5864b-4916-58cc-9f2f-3f94e6bb9470', '1d63cc36-bf51-5898-8151-3e467d31700c', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c467807e-03e5-58ae-8e5e-68f9b776e481', '1d63cc36-bf51-5898-8151-3e467d31700c', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9840175f-0028-5dd2-bc32-02858e440d4a', '1d63cc36-bf51-5898-8151-3e467d31700c', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('42e2b760-dfe7-5cb2-bfcd-32b6e4923eba', '1d63cc36-bf51-5898-8151-3e467d31700c', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9922dc31-ce8c-505a-a799-4777cd064648', '1d63cc36-bf51-5898-8151-3e467d31700c', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 5-10 on your answer sheet.
It’s long been known that
5
declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and
6
experiments. Bahrick called one form ”
7
“, which describes factual knowledge. Another one called “
8
“contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of
9
, some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of
10
they learned after decades, whereas single course taker only remembered as short as 3 years.

It’s long been known that 5 ____ declined with age. Charles A. Dana foundation invested millions of dollars to test memory decline. They used advanced technology, neurochemical experiments and ran several cognitive and 6 ____ experiments. Bahrick called one form ” 7 ____ “, which describes factual knowledge. Another one called “ 8 ____ “contains events in time and space format. He conducted two experiments toward knowledge memory’s longevity, he asked 1000 candidates some knowledge of 9 ____ , some could even remember it decades ago. Second research of Spanish courses found that multiple course participants could remember more than half of 10 ____ they learned after decades, whereas single course taker only remembered as short as 3 years.$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f330415f-6672-580b-a5f9-905ab562d2e4', '1d63cc36-bf51-5898-8151-3e467d31700c', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Use the information in the passage to match the people (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes
11-14
on your answer sheet.
(A)
Harry P. Bahrick
(B)
Arnold B. Scheibel
(C)
Marion Diamond
(D)
Timothy Salthouse
(E)
Stanley Rapport
(F)
Robert Kail
11
Examined both young and old’s blood circulation of brain while testing,
12
Aging is a significant link between physical and mental activity.
13
Some semantic memories of an event fade away by repetition.
14
Rat’s brain developed when put in a diverse environment.

11 ____ Examined both young and old’s blood circulation of brain while testing,$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be7235f7-fd6d-56af-9573-aa4de9d07663', 'f330415f-6672-580b-a5f9-905ab562d2e4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1d5174b-6f69-5742-b1f0-7893e01fbba9', 'f330415f-6672-580b-a5f9-905ab562d2e4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98293a13-0490-5103-89df-6be1d65c5dd2', 'f330415f-6672-580b-a5f9-905ab562d2e4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('220b0a4a-332a-54ae-88df-7496903c737e', 'f330415f-6672-580b-a5f9-905ab562d2e4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6f57ce0-d8b2-5159-aca9-e8a843e95940', 'f330415f-6672-580b-a5f9-905ab562d2e4', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('450206bb-abf1-55fa-a4e0-7f8550e692de', 'f330415f-6672-580b-a5f9-905ab562d2e4', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('29410381-848f-5a4a-b9cc-b3cb6b3afe0c', '1d63cc36-bf51-5898-8151-3e467d31700c', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Use the information in the passage to match the people (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes
11-14
on your answer sheet.
(A)
Harry P. Bahrick
(B)
Arnold B. Scheibel
(C)
Marion Diamond
(D)
Timothy Salthouse
(E)
Stanley Rapport
(F)
Robert Kail
11
Examined both young and old’s blood circulation of brain while testing,
12
Aging is a significant link between physical and mental activity.
13
Some semantic memories of an event fade away by repetition.
14
Rat’s brain developed when put in a diverse environment.

12 ____ Aging is a significant link between physical and mental activity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('613010db-a0c1-5349-a1a6-4df16e6f621a', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c30643-1dbc-5355-b298-d8495633c654', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('362c26c5-56d6-5800-be79-e19294313645', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fdeb267-7d48-52e9-b9ac-1e2b5affd157', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('889c305f-2841-57dc-8f02-b29509e5a963', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8172d44-c792-54e9-8166-0c1b4ff06f20', '29410381-848f-5a4a-b9cc-b3cb6b3afe0c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93a04484-5ffc-57f2-99b0-2632eab552f7', '1d63cc36-bf51-5898-8151-3e467d31700c', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Use the information in the passage to match the people (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes
11-14
on your answer sheet.
(A)
Harry P. Bahrick
(B)
Arnold B. Scheibel
(C)
Marion Diamond
(D)
Timothy Salthouse
(E)
Stanley Rapport
(F)
Robert Kail
11
Examined both young and old’s blood circulation of brain while testing,
12
Aging is a significant link between physical and mental activity.
13
Some semantic memories of an event fade away by repetition.
14
Rat’s brain developed when put in a diverse environment.

13 ____ Some semantic memories of an event fade away by repetition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f634140-8f0e-54fd-81de-d194d84443f8', '93a04484-5ffc-57f2-99b0-2632eab552f7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17744b4c-1856-55dc-ad38-956f02844cf7', '93a04484-5ffc-57f2-99b0-2632eab552f7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60e301f0-1112-58f7-9c98-a72e1e27b205', '93a04484-5ffc-57f2-99b0-2632eab552f7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25f7a010-1787-5a36-a551-66648f4d723e', '93a04484-5ffc-57f2-99b0-2632eab552f7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c823af2-c7f9-5014-b3b1-9a7b1d8d118b', '93a04484-5ffc-57f2-99b0-2632eab552f7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('709e9ae6-4cf1-5a19-bf56-3231723e34df', '93a04484-5ffc-57f2-99b0-2632eab552f7', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1889d5d-c3e8-5f51-8e23-4e0178752e31', '1d63cc36-bf51-5898-8151-3e467d31700c', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Use the information in the passage to match the people (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes
11-14
on your answer sheet.
(A)
Harry P. Bahrick
(B)
Arnold B. Scheibel
(C)
Marion Diamond
(D)
Timothy Salthouse
(E)
Stanley Rapport
(F)
Robert Kail
11
Examined both young and old’s blood circulation of brain while testing,
12
Aging is a significant link between physical and mental activity.
13
Some semantic memories of an event fade away by repetition.
14
Rat’s brain developed when put in a diverse environment.

14 ____ Rat’s brain developed when put in a diverse environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bcd0c18-b3a6-5713-9017-3e6e1447994e', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b39d3ede-370a-58d3-bf7f-671b528b9c40', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b3e32b0-1007-58a1-9c30-5b9d1c3b8662', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0c6b99a-cf61-59f2-bb6f-84a146935b8b', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e445cd6b-172f-5c2d-b7c8-c0d2ce5f7889', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df519bb1-59bb-5fa5-a0ea-f55fdce150cb', 'a1889d5d-c3e8-5f51-8e23-4e0178752e31', 6, $md$F$md$, false);

COMMIT;
