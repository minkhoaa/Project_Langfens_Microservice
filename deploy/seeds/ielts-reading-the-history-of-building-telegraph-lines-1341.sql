BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-building-telegraph-lines-1341'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-building-telegraph-lines-1341';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-building-telegraph-lines-1341';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-building-telegraph-lines-1341';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b3f2ad0b-7ee6-551f-8e7d-d042cd4811a7', 'ielts-reading-the-history-of-building-telegraph-lines-1341', $t$The History of building Telegraph lines$t$, $md$## The History of building Telegraph lines

Nguồn:
- Test: https://mini-ielts.com/1341/reading/the-history-of-building-telegraph-lines
- Solution: https://mini-ielts.com/1341/view-solution/reading/the-history-of-building-telegraph-lines$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('80ca608a-631e-5a1d-a9fe-36f34be937e2', 'b3f2ad0b-7ee6-551f-8e7d-d042cd4811a7', 1, $t$Reading — The History of building Telegraph lines$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The History of building Telegraph lines

A

The idea of electrical communication seems to have begun as long ago as 1746 when about 200 monks at a monastery in Paris arranged themselves in a line over a mile long, each holding ends of 25 ft iron wires. The abbot, also a scientist, discharged a primitive electrical battery into the wire, giving all the monks a simultaneous electrical shock. “This all sounds very silly, but is in fact extremely important because, firstly, they all said ‘ow’ which showed that you were sending a signal right along the line; and, secondly, they all said ‘ow’ at the same time, and that meant that you were sending the signal very quickly, “explains Tom Standage, author of the Victorian Internet and technology editor at the Economist. Given a more humane detection system, this could be a way of signaling over long distances.

B

With wars in Europe and colonies beyond, such a signaling system was urgently needed. All sorts of electrical possibilities were proposed, some of them quite ridiculous. Two Englishmen, William Cooke and Charles Wheatstone came up with a system in which dials were made to point at different letters, but that involved five wires and would have been expensive to construct.

C

Much simpler was that of an American, Samuel Morse, whose system only required a single wire to send a code of dots and dashes. At first, it was imagined that only a few highly skilled encoders would be able to use it but it soon became clear that many people could become proficient in Morse code. A system of lines strung on telegraph poles began to spread in Europe and America.

D

The next problem was to cross the sea. Britain, as an island with an empire, led the way. Any such cable to be insulated and the first breakthrough came with the discovery that a rubber-like latex from a tropical tree on the Malay peninsula could do the trick. It was called gutta-percha. The first attempt at a cross channel cable came in 1850. With thin wire and thick installation, it floated and had to be weighed down with a lead pipe.

E

It never worked well as the effect of water on its electrical properties was not understood, and it is reputed that a French fisherman hooked out a section and took it home as a strange new form of seaweed. The cable was too big for a single boat so two had to start in the middle of the Atlantic, join their cables and sail in opposite directions. Amazingly, they succeeded in 1858, and this enabled Queen Victoria to send a telegraph message to President Buchanan. However, the 98-word message took more than 19 hours to send and a misguided attempt to increase the speed by increasing the voltage resulted in the failure of the line a week later.

F

By 1870, a submarine cable was heading towards Australia. It seemed likely that it would come ashore at the northern port of Darwin from where it might connect around the coast to Queensland and New South Wales. It was an undertaking more ambitious than spanning an ocean. Flocks of sheep had to be driven with the 400 workers to provide food. They needed horses and bullock carts and, for the parched interior, camels. In the north, tropical rains left the teams flooded. In the centre, it seemed that they would die of thirst. One critical section in the red heart of Australia involved finding a route through the McDonnell mountain range and the finding water on the other side.

G

The water was not only essential for the construction team. There had to be telegraph repeater stations every few hundred miles to boost the signal and the staff obviously had to have a supply of water. Just as one mapping team was about to give up and resort to drinking brackish water, some aboriginals took pity on them. Altogether, 40,000 telegraph poles were used in the Australian overland wire. Some were cut from trees. Where there were no trees, or where termites ate the wood, steel poles were imported.

H

On Thursday, August 22, 1872, the overland line was completed and the first messages could be sent across the continent; and within a few months, Australia was at last in direct contact with England via the submarine cable, too. The line remained in service to bring news of the Japanese attack on Darwin in 1942. It could cost several pounds to send a message and it might take several hours for it to reach its destination on the other side of the globe, but the world would never be the same again. Governments could be in touch with their colonies. Traders could send cargoes based on demand and the latest prices. Newspapers could publish news that had just happened and was not many months old.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2de7f6fe-338c-5771-824e-1ba6deb3f89d', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

1 ____ In the research of French scientists, the metal lines were used to send a message.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2b2319a-f931-53d5-aa72-e09f67ac8e3a', '2de7f6fe-338c-5771-824e-1ba6deb3f89d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb5df93f-805c-5c35-8476-a51cdc1773b7', '2de7f6fe-338c-5771-824e-1ba6deb3f89d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1917369-46a6-5b1a-8aae-7a5113aaeeec', '2de7f6fe-338c-5771-824e-1ba6deb3f89d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64f0e9e5-304e-53b5-ac59-8ab15f0643a9', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

2 ____ Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a9369b6-1252-5bd3-8811-a2222f5dbfd1', '64f0e9e5-304e-53b5-ac59-8ab15f0643a9', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21f0608e-a1ed-59c8-b0e8-e2592fca0383', '64f0e9e5-304e-53b5-ac59-8ab15f0643a9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b31b18b3-54b4-5f02-8f96-519556092fad', '64f0e9e5-304e-53b5-ac59-8ab15f0643a9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f855251a-4ace-52bb-963f-adf43d39174c', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

3 ____ Using Morse Code to send message need to simplify the message firstly.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50d6d3b7-3463-5f7e-9d00-f565a4897c40', 'f855251a-4ace-52bb-963f-adf43d39174c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71c2547b-20d6-55fe-9253-7071aa1686aa', 'f855251a-4ace-52bb-963f-adf43d39174c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bec33ff5-25cc-59f6-a437-e43afd012263', 'f855251a-4ace-52bb-963f-adf43d39174c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d47193dd-95b6-5335-aa5c-2cf33f3e23f9', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

4 ____ Morse was a famous inventor before he invented the code$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45104d13-b66d-5c72-8965-55750c74b3d9', 'd47193dd-95b6-5335-aa5c-2cf33f3e23f9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa6e9d51-03d3-5cd3-aa5a-ccce3e712b7b', 'd47193dd-95b6-5335-aa5c-2cf33f3e23f9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4d33789-fdb2-5dd6-a762-0233991a6bbf', 'd47193dd-95b6-5335-aa5c-2cf33f3e23f9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e56de7ed-189a-5f59-bf3c-1856ec2cffba', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

5 ____ The water is significant to early telegraph repeater on the continent.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09744f57-4d91-5e36-8aa2-1ad4506bb1ae', 'e56de7ed-189a-5f59-bf3c-1856ec2cffba', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('138ead85-bab6-55a6-a594-6baf8e7b28d4', 'e56de7ed-189a-5f59-bf3c-1856ec2cffba', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('645495d3-ddd7-56a5-a55e-e1b715ebb7db', 'e56de7ed-189a-5f59-bf3c-1856ec2cffba', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df1ec770-c02e-5fe1-92e9-909af60d2d44', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
In the research of French scientists, the metal lines were used to send a message.
2
Abbots gave the monks an electrical shock at the same time, which constitutes the exploration of the long-distance signaling.
3
Using Morse Code to send message need to simplify the message firstly.
4
Morse was a famous inventor before he invented the code
5
The water is significant to early telegraph repeater on the continent.
6
US Government offered fund to the 1st overland line across the continent.

6 ____ US Government offered fund to the 1st overland line across the continent.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ff8cd3d-2958-5f43-8db6-a17bd6f5ecd1', 'df1ec770-c02e-5fe1-92e9-909af60d2d44', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6010da1-eb2f-5484-87f5-f418c7d6c9f7', 'df1ec770-c02e-5fe1-92e9-909af60d2d44', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aec33432-fbd4-5671-a986-7ea858b25f84', 'df1ec770-c02e-5fe1-92e9-909af60d2d44', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b1b56f32-0fb7-5655-b8e9-bce8e6988687', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

7 ____ Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?$md$, NULL, ARRAY['.*it.*s.*expensive.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1bb14abc-a75b-517c-b0c6-7cb51fb23894', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

8 ____ What material was used for insulating cable across the sea?$md$, NULL, ARRAY['.*latex.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0a1b4c31-0ec6-5fc6-b8ae-6851b81117ab', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

9 ____ What was used by British pioneers to increase the weight of the cable in the sea?$md$, NULL, ARRAY['.*lead.*pipe.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce084797-3197-5402-92e6-e3df950442a4', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

10 ____ What dis Fisherman mistakenly take the cable as?$md$, NULL, ARRAY['.*unusual.*seaweed.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3d466aaa-3f7e-5d53-bd3e-3225ff5b8bd8', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

11 ____ Who was the message firstly sent to across the Atlantic by the Queen?$md$, NULL, ARRAY['.*president.*buchanan.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3793a34c-803d-5213-a85d-4e3d1c76622a', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

12 ____ What giant animals were used to carry the cable through the desert?$md$, NULL, ARRAY['.*camels.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('81422d3b-34cb-58c5-bd6f-87ea14515809', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

13 ____ What weather condition did it delay the construction in north Australia?$md$, NULL, ARRAY['.*tropical.*rain.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d9e48c50-cadd-54d4-9b1a-bd6e626e4f6b', '80ca608a-631e-5a1d-a9fe-36f34be937e2', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 7-14
Questions 7-14
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/ OR A NUMBER
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
7
Why is the disadvantage for Charles Wheatstone’s telegraph system to fail in the beginning?
8
What material was used for insulating cable across the sea?
9
What was used by British pioneers to increase the weight of the cable in the sea?
10
What dis Fisherman mistakenly take the cable as?
11
Who was the message firstly sent to across the Atlantic by the Queen?
12
What giant animals were used to carry the cable through the desert?
13
What weather condition did it delay the construction in north Australia?
14
How long did it take to send a telegraph message from Australia to England

14 ____ How long did it take to send a telegraph message from Australia to England$md$, NULL, ARRAY['.*several.*hours.*']);

COMMIT;
