BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-new-voyage-round-the-world-1451'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-voyage-round-the-world-1451';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-voyage-round-the-world-1451';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-new-voyage-round-the-world-1451';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ffed7928-db71-5e8c-be8e-54281536a986', 'ielts-reading-a-new-voyage-round-the-world-1451', $t$A New Voyage Round the World$t$, $md$## A New Voyage Round the World

Nguồn:
- Test: https://mini-ielts.com/1451/reading/a-new-voyage-round-the-world
- Solution: https://mini-ielts.com/1451/view-solution/reading/a-new-voyage-round-the-world$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 'ffed7928-db71-5e8c-be8e-54281536a986', 1, $t$Reading — A New Voyage Round the World$t$, $md$Read the passage and answer questions **1–14**.

### Passage: A New Voyage Round the World

A very old travel hook that holds an unusual place in English literature

Part travelogue, part historical record of the Caribbean pirates, part scientific treatise, A New Voyage Round the World was William Dampier’s account of his twelve-year series of journeys around the globe from 1679 to 1691.

The wealth and novelty of Dampier’s descriptions, combined with the highly counts of his comrades’, escapades, proved so popular with a public hungry for tales of discovery and adventure that A New Voyage went into its third reprint within a year of publication. So ground­breaking was Dampier’s account that the writers Swift and Defoe were inspired to create two of the most famous books in the English language, Gulliver’s Travels and Robinson Crusoe.

Dampier’s commentators have portrayed him as an unusual, not to say peculiar, man. Notwithstanding his undoubted qualities as an observer, he has been variously characterised as aloof, arrogant, hot-tempered and a weak leader of men. When he arrived on the western coast of Australia, he promptly elected to leave and head north out of dislike for the cold of more southerly latitudes. This physical sensitivity has often been seized on by his detractors, who point out that, as a result, Dampier missed out on becoming the name forever associated with the European discovery of Australia, that honour instead going to Captain James Cook some 80 years later. Yet it should be remembered that he was able to endure a never-ending plague of discomforts and ailments in the tropics. And once, wrecked off Ascension Island in the South Atlantic Ocean, he managed with his crew to survive for five weeks without help, living entirely on turtles and goats.

What of his early life, then? Dampier was born in 1651 in Somerset, England, the son of a tenant farmer, George, and his wife Ann. His birthplace, Hymerford House, stands to this day. His parents died before he reached seniority and his guardians apprenticed the young William to a ship’s captain, the boy having shown very early inclinations to see the world’. There was nothing in his childhood to set Dampier apart from the numerous other young boys who were sent to sea at this time.

Having made brief passages to France and Newfoundland, he completed a more extended voyage to Java, where he began to learn the art of navigation. Returning briefly to Somerset, a neighbour offered Dampier a position overseeing his plantation in Jamaica, which he took up for a time, but he soon returned to sea on a trading voyage among the Caribbean islands. From the viewpoint of posterity, the most significant aspect of this time was that, as plantation manager, Dampier first started to keep a journal.

Although Dampier wrote several books, A New Voyage Round the World is the most important and it is worth considering just why this text met with such success. Certainly, the book would not have done so well purely on the merits of Dampier’s findings regarding meteorology and natural history, even though they broke new ground at the time. What appealed more to book buyers of this era was his narrative of life among the pirates of the Caribbean islands, whom he joined for several years after leaving Jamaica. These tales of adventure among rogues and villains who had no regard for the law sparked widespread interest among his countrymen back home. More important even than this, however, it is the superb nature of Dampier’s prose, and his ability to communicate so vividly that raised the book above the common lot.

Dampier himself admits in the book’s preface that he received help with the writing of the book, and other evidence exists to suggest that he was assisted by an unknown source. But whatever outside assistance he may have had, the book still has certain problems. In particular, his observations about nature are sometimes roughly dropped into the narrative at very odd junctures and these asides can sometimes interrupt the flow of the story Dampier himself kept his observations about nature entirely separate from the main body of his travels, and we should therefore hold James Knapton responsible, as he was in charge of checking and revising Dampier’s text, and his publishing company brought the finished book to a wider audience.

Dampier’s life has been chronicled in full by numerous biographers, and I refer the reader in particular to Clennell Wilkinson’s excellent (and sadly out-of- print) 1929 biography, as well as the recent portrait by Anton Gill. In short, despite wide acclaim for his writing, Dampier was not blessed in the art of wealth accumulation Travelling with the pirates, while providing subsistence and adventure, never netted him the treasure chest that a more astute financial operative might have acquired. He died in 1715, aged sixty-three, in Colerman Street, London.

We have then a man of myriad and colourful parts, and perhaps not always the easiest of sailors to get along with because of his arrogance and hot temper. But to dwell on these aspects today is to miss the point: it is A New Voyage Round the World that should provide the most illuminating and entertaining of Dampier’s legacies. Above all, the text is studded with some wonderfully colourful expressions, and readers will enjoy some of the finest descriptions of storms in the English language, and the liberal wit throughout.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('147cba30-e2ec-51be-b01a-3484041393cc', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 1, 'CLASSIFICATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. Which of the following best summarises the writer’s point in the first paragraph?
A
Dampier’s book does not fall into a single category.
B
Readers were not interested in books on the subject of travel.
C
Today’s readers do not appreciate the style of Dampier’s writing
D
Dampier sailed round the world more quickly than anyone before.
2. The writer refers to Swift and Defoe in order to
A
provide information regarding Dampier’s sources.
B
compare Dampier to two earlier writers.
C
give an example of Dampier’s influence
D
highlight two of Dampier’s critics
3. Dampier left the western coast of Australia because
A
He wanted to get to the north before Cook arrived
B
He found the temperature there unpleasant
C
He had problems with his crews
D
He requested medical attention
4. What does the writer more about Dampier in the second paragraph?
A
He could cope with physical hardship
B
He was a more adventurous explorer than Cook was
C
He had a kind personality than he is given credit for
D
He was calm in a crisis
5. What information is given about Dampier’s early life?
A
He had a difficult relationship with the people looking after him
B
He was different from other youths who went to see
C
He wanted to travel from a young age
D
He came from a family of sailors

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('557f94f6-56c9-54d5-b5ea-486049c164ea', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 2, 'CLASSIFICATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. Which of the following best summarises the writer’s point in the first paragraph?
A
Dampier’s book does not fall into a single category.
B
Readers were not interested in books on the subject of travel.
C
Today’s readers do not appreciate the style of Dampier’s writing
D
Dampier sailed round the world more quickly than anyone before.
2. The writer refers to Swift and Defoe in order to
A
provide information regarding Dampier’s sources.
B
compare Dampier to two earlier writers.
C
give an example of Dampier’s influence
D
highlight two of Dampier’s critics
3. Dampier left the western coast of Australia because
A
He wanted to get to the north before Cook arrived
B
He found the temperature there unpleasant
C
He had problems with his crews
D
He requested medical attention
4. What does the writer more about Dampier in the second paragraph?
A
He could cope with physical hardship
B
He was a more adventurous explorer than Cook was
C
He had a kind personality than he is given credit for
D
He was calm in a crisis
5. What information is given about Dampier’s early life?
A
He had a difficult relationship with the people looking after him
B
He was different from other youths who went to see
C
He wanted to travel from a young age
D
He came from a family of sailors

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bc93569-a2c7-52bd-abde-698bf3e1c93d', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 3, 'CLASSIFICATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. Which of the following best summarises the writer’s point in the first paragraph?
A
Dampier’s book does not fall into a single category.
B
Readers were not interested in books on the subject of travel.
C
Today’s readers do not appreciate the style of Dampier’s writing
D
Dampier sailed round the world more quickly than anyone before.
2. The writer refers to Swift and Defoe in order to
A
provide information regarding Dampier’s sources.
B
compare Dampier to two earlier writers.
C
give an example of Dampier’s influence
D
highlight two of Dampier’s critics
3. Dampier left the western coast of Australia because
A
He wanted to get to the north before Cook arrived
B
He found the temperature there unpleasant
C
He had problems with his crews
D
He requested medical attention
4. What does the writer more about Dampier in the second paragraph?
A
He could cope with physical hardship
B
He was a more adventurous explorer than Cook was
C
He had a kind personality than he is given credit for
D
He was calm in a crisis
5. What information is given about Dampier’s early life?
A
He had a difficult relationship with the people looking after him
B
He was different from other youths who went to see
C
He wanted to travel from a young age
D
He came from a family of sailors

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('845bec90-7d3e-56a1-9b0e-10c4d6dac946', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 4, 'CLASSIFICATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. Which of the following best summarises the writer’s point in the first paragraph?
A
Dampier’s book does not fall into a single category.
B
Readers were not interested in books on the subject of travel.
C
Today’s readers do not appreciate the style of Dampier’s writing
D
Dampier sailed round the world more quickly than anyone before.
2. The writer refers to Swift and Defoe in order to
A
provide information regarding Dampier’s sources.
B
compare Dampier to two earlier writers.
C
give an example of Dampier’s influence
D
highlight two of Dampier’s critics
3. Dampier left the western coast of Australia because
A
He wanted to get to the north before Cook arrived
B
He found the temperature there unpleasant
C
He had problems with his crews
D
He requested medical attention
4. What does the writer more about Dampier in the second paragraph?
A
He could cope with physical hardship
B
He was a more adventurous explorer than Cook was
C
He had a kind personality than he is given credit for
D
He was calm in a crisis
5. What information is given about Dampier’s early life?
A
He had a difficult relationship with the people looking after him
B
He was different from other youths who went to see
C
He wanted to travel from a young age
D
He came from a family of sailors

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('361e9bb8-10ce-536c-8a02-34c514e9b48a', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. Which of the following best summarises the writer’s point in the first paragraph?
A
Dampier’s book does not fall into a single category.
B
Readers were not interested in books on the subject of travel.
C
Today’s readers do not appreciate the style of Dampier’s writing
D
Dampier sailed round the world more quickly than anyone before.
2. The writer refers to Swift and Defoe in order to
A
provide information regarding Dampier’s sources.
B
compare Dampier to two earlier writers.
C
give an example of Dampier’s influence
D
highlight two of Dampier’s critics
3. Dampier left the western coast of Australia because
A
He wanted to get to the north before Cook arrived
B
He found the temperature there unpleasant
C
He had problems with his crews
D
He requested medical attention
4. What does the writer more about Dampier in the second paragraph?
A
He could cope with physical hardship
B
He was a more adventurous explorer than Cook was
C
He had a kind personality than he is given credit for
D
He was calm in a crisis
5. What information is given about Dampier’s early life?
A
He had a difficult relationship with the people looking after him
B
He was different from other youths who went to see
C
He wanted to travel from a young age
D
He came from a family of sailors

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('26e7d180-c10c-5ba5-9131-5621c448b12c', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-l below.
Write the correct letter, A-l, in boxes 6-9 on your answer sheet.
The Text of A New Voyage Round the World
The success of the book cannot solely be attributed to the originality of Dampier’s
6
. Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery
7
. Some aspects of
A New Voyage Round the
World are
problematic, descriptions of
8
were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the
9
A.
Detailed illustrations
D.
Editor
G. The crew
E.
Writer
H. Artist
B.
Traveller
F.
Scientific observations
I. Plain language
C
Nature

The success of the book cannot solely be attributed to the originality of Dampier’s 6 ____ . Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery 7 ____ . Some aspects of A New Voyage Round the World are problematic, descriptions of 8 ____ were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c626c7c9-73c7-5d6f-ae98-72357c8791b2', '26e7d180-c10c-5ba5-9131-5621c448b12c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ca35f4d-64e5-5a97-a013-80ca7b2c92f9', '26e7d180-c10c-5ba5-9131-5621c448b12c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38677614-956b-55aa-8bf5-5bbb4a991a46', '26e7d180-c10c-5ba5-9131-5621c448b12c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64cbb9ba-981c-554a-824d-7b349b8667b2', '26e7d180-c10c-5ba5-9131-5621c448b12c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0ee5f22-613f-53b2-bf68-3d268bd8f537', '26e7d180-c10c-5ba5-9131-5621c448b12c', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8523cf78-bfe7-5b1c-8dd4-081bd761b557', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-l below.
Write the correct letter, A-l, in boxes 6-9 on your answer sheet.
The Text of A New Voyage Round the World
The success of the book cannot solely be attributed to the originality of Dampier’s
6
. Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery
7
. Some aspects of
A New Voyage Round the
World are
problematic, descriptions of
8
were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the
9
A.
Detailed illustrations
D.
Editor
G. The crew
E.
Writer
H. Artist
B.
Traveller
F.
Scientific observations
I. Plain language
C
Nature

The success of the book cannot solely be attributed to the originality of Dampier’s 6 ____ . Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery 7 ____ . Some aspects of A New Voyage Round the World are problematic, descriptions of 8 ____ were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03feff31-a64f-5276-9943-2bde2f044d36', '8523cf78-bfe7-5b1c-8dd4-081bd761b557', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbe8e5bb-c8ef-5194-9676-0bf87f30a9d0', '8523cf78-bfe7-5b1c-8dd4-081bd761b557', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e45d2708-931d-52f6-aa85-2a8223f7c16a', '8523cf78-bfe7-5b1c-8dd4-081bd761b557', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed83b635-7049-5be6-8182-4fd0b4e826b8', '8523cf78-bfe7-5b1c-8dd4-081bd761b557', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b6204bd-1f9e-552f-b5ce-dd0ffa842146', '8523cf78-bfe7-5b1c-8dd4-081bd761b557', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('929ef4c4-2d1b-53d4-8c5b-6181bf795942', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-l below.
Write the correct letter, A-l, in boxes 6-9 on your answer sheet.
The Text of A New Voyage Round the World
The success of the book cannot solely be attributed to the originality of Dampier’s
6
. Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery
7
. Some aspects of
A New Voyage Round the
World are
problematic, descriptions of
8
were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the
9
A.
Detailed illustrations
D.
Editor
G. The crew
E.
Writer
H. Artist
B.
Traveller
F.
Scientific observations
I. Plain language
C
Nature

The success of the book cannot solely be attributed to the originality of Dampier’s 6 ____ . Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery 7 ____ . Some aspects of A New Voyage Round the World are problematic, descriptions of 8 ____ were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53950dfb-6406-56dc-b10c-670b7f2e0757', '929ef4c4-2d1b-53d4-8c5b-6181bf795942', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a061f90b-d5cb-5319-b80c-c4e87e2d9b99', '929ef4c4-2d1b-53d4-8c5b-6181bf795942', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21240bbb-b3e9-5df1-8866-52a5c39f1e6a', '929ef4c4-2d1b-53d4-8c5b-6181bf795942', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f5dc90a-86dd-5111-a1cf-24aa3b92c8d7', '929ef4c4-2d1b-53d4-8c5b-6181bf795942', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6c60d6d-47f8-5c5d-9529-bf10e31a30a3', '929ef4c4-2d1b-53d4-8c5b-6181bf795942', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd20693a-4373-5087-9595-8667b24314af', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-l below.
Write the correct letter, A-l, in boxes 6-9 on your answer sheet.
The Text of A New Voyage Round the World
The success of the book cannot solely be attributed to the originality of Dampier’s
6
. Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery
7
. Some aspects of
A New Voyage Round the
World are
problematic, descriptions of
8
were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the
9
A.
Detailed illustrations
D.
Editor
G. The crew
E.
Writer
H. Artist
B.
Traveller
F.
Scientific observations
I. Plain language
C
Nature

The success of the book cannot solely be attributed to the originality of Dampier’s 6 ____ . Readers of the time were fascinated with his stories of the time he spent with outlaws and his colorful way of writing. It seems certain that Dampier worked on the book with a mystery 7 ____ . Some aspects of A New Voyage Round the World are problematic, descriptions of 8 ____ were inserted into the account of Dampier’s adventures in a way that distracted the reader. It seems that the responsibility for the final version of the book lies with the 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('818678ee-b3c2-5490-bb06-24c8de5b8575', 'fd20693a-4373-5087-9595-8667b24314af', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1b9a0d7-5206-5767-9892-60398d130d22', 'fd20693a-4373-5087-9595-8667b24314af', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('258f238e-819b-56a9-8c92-7fa404b212bf', 'fd20693a-4373-5087-9595-8667b24314af', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5067d61e-08d7-5176-be38-2dd66ea49058', 'fd20693a-4373-5087-9595-8667b24314af', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d95be39-4318-55ba-aded-e849185f9b6e', 'fd20693a-4373-5087-9595-8667b24314af', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7270b228-fc70-5baa-976a-23b3a0164746', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage In the boxes 10-14 on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Many people wrote biographies of Dampier as a result of personal contact with him
11
Dampier was skilled at making money
12
Dampier's patience was represented by the writer
13
A New Voyage Round the World is considered as one of the most modern books
14
Dampier supervised his neighbour’s plantation in Jamaica

10 ____ Many people wrote biographies of Dampier as a result of personal contact with him$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d181550-c18c-527e-b5fd-4842f20cdfbf', '7270b228-fc70-5baa-976a-23b3a0164746', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ce269de-b3c3-5ae7-bafc-08f78550ff2a', '7270b228-fc70-5baa-976a-23b3a0164746', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40827229-291d-5b38-8669-a9aef1adf60c', '7270b228-fc70-5baa-976a-23b3a0164746', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2455e0d3-d599-5e12-b0f6-920131177147', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage In the boxes 10-14 on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Many people wrote biographies of Dampier as a result of personal contact with him
11
Dampier was skilled at making money
12
Dampier's patience was represented by the writer
13
A New Voyage Round the World is considered as one of the most modern books
14
Dampier supervised his neighbour’s plantation in Jamaica

11 ____ Dampier was skilled at making money$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54d62e01-9c1b-5e26-9e41-feb8e93af680', '2455e0d3-d599-5e12-b0f6-920131177147', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34bdc6b8-c55a-5462-a36f-dd67fbf3f708', '2455e0d3-d599-5e12-b0f6-920131177147', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4bd9053-eb43-5280-a34f-3e20ea25735a', '2455e0d3-d599-5e12-b0f6-920131177147', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aaf27e61-08b0-5655-8caf-20c087587927', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage In the boxes 10-14 on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Many people wrote biographies of Dampier as a result of personal contact with him
11
Dampier was skilled at making money
12
Dampier's patience was represented by the writer
13
A New Voyage Round the World is considered as one of the most modern books
14
Dampier supervised his neighbour’s plantation in Jamaica

12 ____ Dampier's patience was represented by the writer$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3133da70-17f8-539c-86a0-779a5efb1ebe', 'aaf27e61-08b0-5655-8caf-20c087587927', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d426d5b-69c4-52d8-bbec-2124caa3bc06', 'aaf27e61-08b0-5655-8caf-20c087587927', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32d702ed-4bee-5fa5-bb8b-4b15ec763fd2', 'aaf27e61-08b0-5655-8caf-20c087587927', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1ceb67c6-0a63-5957-be07-c4952d43b3d0', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage In the boxes 10-14 on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Many people wrote biographies of Dampier as a result of personal contact with him
11
Dampier was skilled at making money
12
Dampier's patience was represented by the writer
13
A New Voyage Round the World is considered as one of the most modern books
14
Dampier supervised his neighbour’s plantation in Jamaica

13 ____ A New Voyage Round the World is considered as one of the most modern books$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec7b6a9-8e1b-5ad3-8a66-012b0d9a8838', '1ceb67c6-0a63-5957-be07-c4952d43b3d0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('906887dd-f861-542c-ad61-0fd22b765555', '1ceb67c6-0a63-5957-be07-c4952d43b3d0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('babfc2e6-596f-57b9-bbf8-8013bb1c5f9c', '1ceb67c6-0a63-5957-be07-c4952d43b3d0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('29e338ea-28b3-5795-b56c-60850d18db92', 'd1ea0fd0-ea58-598e-9d9a-346fdc0949aa', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage In the boxes 10-14 on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Many people wrote biographies of Dampier as a result of personal contact with him
11
Dampier was skilled at making money
12
Dampier's patience was represented by the writer
13
A New Voyage Round the World is considered as one of the most modern books
14
Dampier supervised his neighbour’s plantation in Jamaica

14 ____ Dampier supervised his neighbour’s plantation in Jamaica$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92528a1b-f5a1-54a9-9ab4-ca2f3bfa0375', '29e338ea-28b3-5795-b56c-60850d18db92', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0454a7a4-f018-5676-becb-4c4ab6eda44a', '29e338ea-28b3-5795-b56c-60850d18db92', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f1870c1-acbb-5198-98fa-0e51087029c2', '29e338ea-28b3-5795-b56c-60850d18db92', 3, $md$NOT GIVEN$md$, false);

COMMIT;
