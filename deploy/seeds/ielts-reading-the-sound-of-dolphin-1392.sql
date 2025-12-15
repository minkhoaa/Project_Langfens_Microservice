BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-sound-of-dolphin-1392'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sound-of-dolphin-1392';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sound-of-dolphin-1392';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-sound-of-dolphin-1392';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('14d659b9-4d6f-564f-b99c-2915f0e34045', 'ielts-reading-the-sound-of-dolphin-1392', $t$The Sound of Dolphin$t$, $md$## The Sound of Dolphin

Nguồn:
- Test: https://mini-ielts.com/1392/reading/the-sound-of-dolphin
- Solution: https://mini-ielts.com/1392/view-solution/reading/the-sound-of-dolphin$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0eb7f9c6-97e3-5377-b938-1807b4d27f44', '14d659b9-4d6f-564f-b99c-2915f0e34045', 1, $t$Reading — The Sound of Dolphin$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Sound of Dolphin

A. Each and every dolphin has a different sound just like you and me, a sound that other dolphins recognize as a particular individual . Even a new baby dolphin, (calf), can detect its mother’s whistle within the pod soon after birth. Utilizing their blowholes, air sacks and valves, dolphins can emit a very wide variety of sounds. In fact, the frequency levels range 10 times beyond what humans can hear.

B. This system is called “Echolocation”, or “Sonar”, just like what a submarine uses to navigate while underwater. Yet the dolphins sonar is much more advanced than human technology and can pin point exact information about its surroundings ranging from size, distance and even the nature of the object .

C. Millions of years ago, toothed whales developed echolocation, a sensory faculty that enabled them to survive in often murky and dark aquatic environments. It is a process in which an organism probes its environment by emitting sounds and listening to echoes as the sounds bounce off objects in the environment . With sound traveling better in water than electromagnetic, thermal, chemical, or light signals, it was advantageous for dolphins to evolve echolocation, a capability in which acoustic energy is used, in a sense, to see underwater. Synonymous with the term “sonar” (sound navigation and ranging) and used interchangeably, dolphin echolocation is considered to be the most advanced sonar capability, unrivaled by any sonar system on Earth, man-made or natural.

D. Dolphins identify themselves with a signature whistles. However, scientists have found no evidence of a dolphin language . For example, a mother dolphin may whistle to her calf almost continually for several days after giving birth . This acoustic imprinting helps the calf learn to identify its mother. Besides whistles, dolphins produce clicks and sounds that resemble moans, trills, grunts and squeaks . They make these sounds at any time and at considerable depths. Sounds vary in volume, wavelength, frequency and pattern. Dolphins produce sounds ranging from 0.25 to 150 kHz. The lower frequency vocalizations (0.25 to 50 kHz) are likely used in social communication. Higher frequency clicks (40 to 150 kHz) are primarily used in echolocation. Dolphins rely heavily on sound production and reception to navigate, communicate, and hunt in dark or murky waters. Under these conditions, sight is of little use . Dolphins can produce clicks and whistles at the same time.

E. As with all toothed whales, a dolphin’s larynx does not possess vocal cords, but researchers have theorized that at least some sound production originates from the larynx . Early studies suggested that “whistles” were generated in the larynx while “clicks” were produced in the nasal sac region . Technological advances in bio-acoustic research enable scientists to better explore the nasal region. Studies suggest that a tissue complex in the nasal region is most likely the site of all sound production. Movements of air in the trachea and nasal sacs probably produce sounds.

F. The process of echolocation begins when dolphins emit very short sonar pulses called clicks, which are typically less than 50-70 millionth of a second long. The clicks are emitted from the melon of the dolphin in a narrow beam . A special fat in the melon called lipid helps to focus the clicks into a beam. The echoes that are reflected off the object are then received by the lower jaws. They enter through certain parts of the lower jaw and are directed to ear bones by lipid fat channels. The characteristics of the echoes are then transmitted directly to the brain.

G. The short echolocation clicks used by dolphins can encode a considerable amount of information on an ensonified object - much more information than is possible from signals of longer duration that are emitted by manned sonar. Underwater sounds can penetrate objects, producing echoes from the portion of the object as well as from other surfaces within the object. This provides dolphins with a way to gain more information than if only a simple reflection occurred at the front of the object.

H. Dolphins are extremely mobile creatures and can therefore direct their sonar signals on an object from many different orientations, with slightly different bits of information being returned at each orientation; and since the echolocation clicks are so brief and numerous, the multiple reflections from internal surfaces return to the animal as distinct entities and are used by the dolphin to distinguish between different types of objects. Since they possess extremely good auditory-spatial memory, it seems that they are able to “remember” all the important information received from the echoes taken from different positions and orientations as they navigate and scan their environment. Dolphins’ extremely high mobility and good auditory spatial memory are capabilities that enhance their use of echolocation. With much of the dolphin’s large brain (which is slightly larger than the human brain) devoted to acoustic signal processing, we can better understand the evolutionary importance of this extraordinary sensory faculty. Yet no one feature in the process of echolocation is more important than the other . Dolphin sonar must be considered as a complete system, well adapted to the dolphin’s overall objective of finding prey, avoiding predators, and avoiding dangerous environments.

I. This ideal evolutionary adaption has contributed to the success of cetacean hunting and feeding and their survival as a species overall. As a result, dolphins are especially good at finding and identifying prey in shallow and noisy coastal waters containing rocks and other objects. By using their sonar ability, dolphins are able to detect and recognize prey that have burrowed up to 1 feet into sandy ocean or river bottoms –a talent that has stirred the imagination (and envy) of designers of manmade sonar.

J. Researchers, documenting the behavior of Atlantic dolphins foraging for buried prey along the banks of Grand Bahama Island, have found that these dolphins, while swimming close to the bottom searching for prey, typically move their heads in a scanning motion, either swinging their snout back and forth or moving their heads in a circular motion as they emit sonar sounds. They have been observed digging as deep as 18 inches into the sand to secure a prey. Such a capability is unparalleled in the annals of human sonar development.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c106f2f-9e7f-5a21-982a-4f87b97bc31d', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Every single dolphin is labeled by a specific sound.
2
The system a dolphin uses as the detector could give a whole picture of the observed objects.
3
Echolocation is a specific system evolving only for animals living in a dim environment.
4
The sounds are made only in the area related to the nose.
5
When producing various forms of sounds, dolphins have the asynchronism as one characteristic.

1 ____ Every single dolphin is labeled by a specific sound.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9215510-8e42-5d72-9a81-5c3effc7d2b2', '1c106f2f-9e7f-5a21-982a-4f87b97bc31d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b01b9c5a-491b-5828-81af-ac8e41948bb3', '1c106f2f-9e7f-5a21-982a-4f87b97bc31d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3baa3e-b9a4-5b81-8d98-204b0dcebc6e', '1c106f2f-9e7f-5a21-982a-4f87b97bc31d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2be28717-44f1-529e-a64f-96a18b214245', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Every single dolphin is labeled by a specific sound.
2
The system a dolphin uses as the detector could give a whole picture of the observed objects.
3
Echolocation is a specific system evolving only for animals living in a dim environment.
4
The sounds are made only in the area related to the nose.
5
When producing various forms of sounds, dolphins have the asynchronism as one characteristic.

2 ____ The system a dolphin uses as the detector could give a whole picture of the observed objects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88e9c1b8-6dc0-544a-bec2-1b516ae5f35e', '2be28717-44f1-529e-a64f-96a18b214245', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43f92f06-0046-5d9c-a67b-d7a5a0ea6fe4', '2be28717-44f1-529e-a64f-96a18b214245', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e3fa962-b241-5073-972c-22db2aeb4e60', '2be28717-44f1-529e-a64f-96a18b214245', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('439bab86-dfdc-5a5b-8ad6-98af984b6abb', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Every single dolphin is labeled by a specific sound.
2
The system a dolphin uses as the detector could give a whole picture of the observed objects.
3
Echolocation is a specific system evolving only for animals living in a dim environment.
4
The sounds are made only in the area related to the nose.
5
When producing various forms of sounds, dolphins have the asynchronism as one characteristic.

3 ____ Echolocation is a specific system evolving only for animals living in a dim environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('662d5261-478f-5182-b9f2-a3d47b43c25d', '439bab86-dfdc-5a5b-8ad6-98af984b6abb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0a99da2-d872-5fa3-b28c-9f1be8edf716', '439bab86-dfdc-5a5b-8ad6-98af984b6abb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0233a68d-d97d-5c00-ab67-67bf68ca7fb2', '439bab86-dfdc-5a5b-8ad6-98af984b6abb', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba83267b-8a48-5086-af6e-3c43a2b88ac7', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Every single dolphin is labeled by a specific sound.
2
The system a dolphin uses as the detector could give a whole picture of the observed objects.
3
Echolocation is a specific system evolving only for animals living in a dim environment.
4
The sounds are made only in the area related to the nose.
5
When producing various forms of sounds, dolphins have the asynchronism as one characteristic.

4 ____ The sounds are made only in the area related to the nose.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73158abe-8e9f-510e-a49e-f8a49a84a41e', 'ba83267b-8a48-5086-af6e-3c43a2b88ac7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8c65007-4729-53a1-9f60-11388b89c2ae', 'ba83267b-8a48-5086-af6e-3c43a2b88ac7', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b7bfe7e-eb1a-5dc3-ada3-30eee0eee5c0', 'ba83267b-8a48-5086-af6e-3c43a2b88ac7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fd72ef3-055d-5498-b55a-c5dfe34508b7', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Every single dolphin is labeled by a specific sound.
2
The system a dolphin uses as the detector could give a whole picture of the observed objects.
3
Echolocation is a specific system evolving only for animals living in a dim environment.
4
The sounds are made only in the area related to the nose.
5
When producing various forms of sounds, dolphins have the asynchronism as one characteristic.

5 ____ When producing various forms of sounds, dolphins have the asynchronism as one characteristic.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5848cd1d-214e-5bdb-9265-887bfb0ea332', '5fd72ef3-055d-5498-b55a-c5dfe34508b7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d14e4f7f-feb4-5a17-bea6-9102d8189d83', '5fd72ef3-055d-5498-b55a-c5dfe34508b7', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('991739aa-b347-5bf2-b5f2-d4d8e7cdf185', '5fd72ef3-055d-5498-b55a-c5dfe34508b7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d50ef588-1146-5cea-91b7-f6904a5ff174', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6- 8
Questions 6- 8
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 6-8 on your answer sheet.
Question 6
What feature do the sounds deep in the water emitted by dolphins possess?
A
diverging
B
tri-dimensional
C
piercing
D
striking
Question 7
Which makes the difference between the dolphins and man when it comes to the treating of vocal messages?
A
an acute sense of smell
B
a bigger brain
C
a flexible positioning system
D
a unique organ
Question 8
Which is the undefeatable characteristic of the sonar system owned by dolphins compared with the one humans have?
A
making more accurate analysis
B
hiding the hunted animals
C
having the wider range in frequencies
D
comprising more components

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('160e554d-c3be-5fa4-a1bd-baa3d293ca2e', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6- 8
Questions 6- 8
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 6-8 on your answer sheet.
Question 6
What feature do the sounds deep in the water emitted by dolphins possess?
A
diverging
B
tri-dimensional
C
piercing
D
striking
Question 7
Which makes the difference between the dolphins and man when it comes to the treating of vocal messages?
A
an acute sense of smell
B
a bigger brain
C
a flexible positioning system
D
a unique organ
Question 8
Which is the undefeatable characteristic of the sonar system owned by dolphins compared with the one humans have?
A
making more accurate analysis
B
hiding the hunted animals
C
having the wider range in frequencies
D
comprising more components

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('063d9ac6-578d-5ead-a0fc-f9f27f93f206', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6- 8
Questions 6- 8
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 6-8 on your answer sheet.
Question 6
What feature do the sounds deep in the water emitted by dolphins possess?
A
diverging
B
tri-dimensional
C
piercing
D
striking
Question 7
Which makes the difference between the dolphins and man when it comes to the treating of vocal messages?
A
an acute sense of smell
B
a bigger brain
C
a flexible positioning system
D
a unique organ
Question 8
Which is the undefeatable characteristic of the sonar system owned by dolphins compared with the one humans have?
A
making more accurate analysis
B
hiding the hunted animals
C
having the wider range in frequencies
D
comprising more components

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('34731b8a-1d72-5101-9269-76c1bd23579b', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Whether
9
exists or not has not been confirmed yet.
10
is the bond between the baby dolphin and its mother. What’s more,
11
which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while
12
is not that imperative. Similar to all toothed whales, vocal cords do not exist in
13
but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.

Whether 9 ____ exists or not has not been confirmed yet. 10 ____ is the bond between the baby dolphin and its mother. What’s more, 11 ____ which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while 12 ____ is not that imperative. Similar to all toothed whales, vocal cords do not exist in 13 ____ but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.$md$, NULL, ARRAY['.*a.*dolphin.*language.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8784d548-a9cc-5b7d-8069-076b3df97d2d', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Whether
9
exists or not has not been confirmed yet.
10
is the bond between the baby dolphin and its mother. What’s more,
11
which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while
12
is not that imperative. Similar to all toothed whales, vocal cords do not exist in
13
but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.

Whether 9 ____ exists or not has not been confirmed yet. 10 ____ is the bond between the baby dolphin and its mother. What’s more, 11 ____ which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while 12 ____ is not that imperative. Similar to all toothed whales, vocal cords do not exist in 13 ____ but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.$md$, NULL, ARRAY['.*a.*dolphin.*language.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('31a585bb-b2c6-5789-8e57-cba347f5b126', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Whether
9
exists or not has not been confirmed yet.
10
is the bond between the baby dolphin and its mother. What’s more,
11
which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while
12
is not that imperative. Similar to all toothed whales, vocal cords do not exist in
13
but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.

Whether 9 ____ exists or not has not been confirmed yet. 10 ____ is the bond between the baby dolphin and its mother. What’s more, 11 ____ which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while 12 ____ is not that imperative. Similar to all toothed whales, vocal cords do not exist in 13 ____ but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.$md$, NULL, ARRAY['.*a.*dolphin.*language.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a1f84bbe-c819-5363-9a34-49219709c5ad', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Whether
9
exists or not has not been confirmed yet.
10
is the bond between the baby dolphin and its mother. What’s more,
11
which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while
12
is not that imperative. Similar to all toothed whales, vocal cords do not exist in
13
but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.

Whether 9 ____ exists or not has not been confirmed yet. 10 ____ is the bond between the baby dolphin and its mother. What’s more, 11 ____ which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while 12 ____ is not that imperative. Similar to all toothed whales, vocal cords do not exist in 13 ____ but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.$md$, NULL, ARRAY['.*a.*dolphin.*language.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dca92bbc-ca73-59ec-ac46-866b33811a09', '0eb7f9c6-97e3-5377-b938-1807b4d27f44', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Whether
9
exists or not has not been confirmed yet.
10
is the bond between the baby dolphin and its mother. What’s more,
11
which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while
12
is not that imperative. Similar to all toothed whales, vocal cords do not exist in
13
but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.

Whether 9 ____ exists or not has not been confirmed yet. 10 ____ is the bond between the baby dolphin and its mother. What’s more, 11 ____ which are like different sounds made by humans are also used by dolphins. The sounds are made at a certain level of depth within a specific scope from a higher frequency aimed at communicating to a lower one to echolocate. Sounds are vital to dolphins living in deep waters while 12 ____ is not that imperative. Similar to all toothed whales, vocal cords do not exist in 13 ____ but it produces some sound. The tissue in the nasal area is perhaps to do with the sound production.$md$, NULL, ARRAY['.*a.*dolphin.*language.*']);

COMMIT;
