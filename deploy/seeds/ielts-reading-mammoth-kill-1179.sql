BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mammoth-kill-1179'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mammoth-kill-1179';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mammoth-kill-1179';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mammoth-kill-1179';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('350e196d-bfc3-5ac5-bb80-1f9126b5edbf', 'ielts-reading-mammoth-kill-1179', $t$Mammoth kill$t$, $md$## Mammoth kill

Nguồn:
- Test: https://mini-ielts.com/1179/reading/mammoth-kill
- Solution: https://mini-ielts.com/1179/view-solution/reading/mammoth-kill$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', '350e196d-bfc3-5ac5-bb80-1f9126b5edbf', 1, $t$Reading — Mammoth kill$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Mammoth kill

A mammoth is any species of the extinct genus Mammuthus, proboscideans commonly equipped with long, curved tusks and, in northern species, a covering of long hair. They lived from the Pliocene epoch (from around 5 million years ago) into the Holocene at about 4,500 years ago, and were members of the family Elephantidae, which contains, along with mammoths, the two genera of modern elephants and their ancestors.

A Like their modern relatives, mammoths were quite large. The largest known species reached heights in the region of 4 m at the shoulder and weights of up to 8 tonnes, while exceptionally large males may have exceeded 12 tonnes. However, most species of mammoth were only about as large as a modern Asian elephant. Both sexes bore tusks. A first, small set appeared at about the age of six months, and these were replaced at about 18 months by the permanent set. Growth of the permanent set was at a rate of about 2.5 to 15.2 cm per year. Based on studies of their close relatives, the modern elephants, mammoths probably had a gestation period of 22 months, resulting in a single calf being born. Their social structure was probably the same as that of African and Asian elephants, with females living in herds headed by a matriarch, whilst bulls lived solitary lives or formed loose groups after sexual maturity.

B MEXICO CITY – Although it’s hard to imagine in this age of urban sprawl and automobiles, North America once belonged to mammoths, camels, ground sloths as large as cows, bear-size beavers and other formidable beasts. Some 11,000 years ago, however, these large-bodied mammals and others – about 70 species in all – disappeared. Their demise coincided roughly with the arrival of humans in the New World and dramatic climatic change – factors that have inspired several theories about the die-off. Yet despite decades of scientific investigation, the exact cause remains a mystery. Now new findings offer support to one of these controversial hypotheses: that human hunting drove this megafaunal menagerie to extinction. The overkill model emerged in the 1960s, when it was put forth by Paul S. Martin of the University of Arizona. Since then, critics have charged that no evidence exists to support the idea that the first Americans hunted to the extent necessary to cause these extinctions. But at the annual meeting of the Society of Vertebrate Paleontology in Mexico City last October, paleoecologist John Alroy of the University of California at Santa Barbara argued that, in fact, hunting-driven extinction is not only plausible, it was unavoidable. He has determined, using a computer simulation, that even a very modest amount of hunting would have wiped these animals out.

C Assuming an initial human population of 100 people that grew no more than 2 percent annually, Alroy determined that if each band of, say, 50 people killed 15 to 20 large mammals a year, humans could have eliminated the animal populations within 1,000 years. Large mammals in particular would have been vulnerable to the pressure because they have longer gestation periods than smaller mammals and their young require extended care.

D Not everyone agrees with Alroy’s assessment. For one, the results depend in part on population-size estimates for the extinct animals – figures that are not necessarily reliable. But a more specific criticism comes from mammalogist Ross D. E. MacPhee of the American Museum of Natural History in New York City, who points out that the relevant archaeological record contains barely a dozen examples of stone points embedded in mammoth bones (and none, it should be noted, are known from other megafaunal remains) – hardly what one might expect if hunting drove these animals to extinction. Furthermore, some of these species had huge ranges – the giant Jefferson’s ground sloth, for example, lived as far north as the Yukon and as far south as Mexico – which would have made slaughtering them in numbers sufficient to cause their extinction rather implausible, he says.

E MacPhee agrees that humans most likely brought about these extinctions (as well as others around the world that coincided with human arrival), but not directly. Rather he suggests that people may have introduced hyperlethal disease , perhaps through their dogs or hitchhiking vermin, which then spread wildly among the immunologically naive species of the New World. As in the overkill model, populations of large mammals would have a harder time recovering. Repeated outbreaks of a hyperdisease could thus quickly drive them to the point of no return. So far MacPhee does not have empirical evidence for the hyperdisease hypothesis, and it won’t be easy to come by: hyperlethal disease would kill far too quickly to leave its signature on the bones themselves. But he hopes that analyses of tissue and DNA from the last mammoths to perish will eventually reveal murderous microbes.

F The third explanation for what brought on this North American extinction does not involve human beings. Instead its proponents blame the loss on the weather. The Pleistocene epoch witnessed considerable climatic instability , explains paleontologist Russell W. Graham of the Denver Museum of Nature and Science. As a result, certain habitats disappeared, and species that had once formed communities split apart. For some animals, this change brought opportunity. For much of the megafauna, however, the increasingly homogeneous environment left them with shrinking geographical ranges – a death sentence for large animals, which need large ranges. Although these creatures managed to maintain viable populations through most of the Pleistocene, the final major fluctuation – the so-called Younger Dryas event – pushed them over the edge, Graham says. For his part, Alroy is convinced that human hunters demolished the titans of the Ice Age. The overkill model explains everything the disease and climate scenarios explain , he asserts, and makes accurate predictions about which species would eventually go extinct. “Personally, I’m a vegetarian,” he remarks, “and I find all of this kind of gross – but believable.”

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6a858cd1-271f-5eb7-a255-19d682095c2a', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3c792879-1832-5b08-8c12-940a157e0c08', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('08d302e7-8563-52e4-bb09-1d38486efb20', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4963274c-9961-528e-a182-75b808860794', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7a69f024-4122-51e2-a823-910a74eca2f7', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('294e5833-5e7b-5cc8-b6e1-fac7b3f23b08', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1276d910-a122-5c12-a94c-c0a16a351477', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that
1
Locate
of human made it happen. This so called
2
Locate
began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly
3
Locate
from human causes their demises. However his hypothesis required more
4
Locate
to testify its validity. Graham proposed a third hypothesis that
5
Locate
in Pleistocene epoch drove some species disappear, reduced
6
Locate
posed a dangerous signal to these giants, and
7
Locate
finally wiped them out.

The reason why had big size mammals become extinct 11,000 years ago is under hot debate. First explanation is that 1 ____ Locate of human made it happen. This so called 2 ____ Locate began from 1960s suggested by an expert, who however received criticism of lack of further information. Another assumption promoted by MacPhee is that deadly 3 ____ Locate from human causes their demises. However his hypothesis required more 4 ____ Locate to testify its validity. Graham proposed a third hypothesis that 5 ____ Locate in Pleistocene epoch drove some species disappear, reduced 6 ____ Locate posed a dangerous signal to these giants, and 7 ____ Locate finally wiped them out.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b455fc70-89e5-5601-a7e9-17f1d7887141', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

8 ____ Human hunting well explained which species would finally disappear. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('748d18c2-c0a1-5990-9851-d1ad41e01e56', 'b455fc70-89e5-5601-a7e9-17f1d7887141', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f2ed6bf-5507-518a-bb7a-97da6829b000', 'b455fc70-89e5-5601-a7e9-17f1d7887141', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2d88eee-8e33-5846-bfe5-f0a3271b82ab', 'b455fc70-89e5-5601-a7e9-17f1d7887141', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f827eace-55e0-5cab-b1e0-96436788d857', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

9 ____ Further grounded proof needed to explain human’s indirect impact on mammals Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c498ac53-350f-54e8-bf96-6c4de2d8a113', 'f827eace-55e0-5cab-b1e0-96436788d857', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dfdff98-1308-558a-8310-0e8d2a5fe880', 'f827eace-55e0-5cab-b1e0-96436788d857', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5e93724-760f-56b3-977d-89e817b99c57', 'f827eace-55e0-5cab-b1e0-96436788d857', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5e70beb-0cce-5a6e-9fa9-0cc6ef9143bf', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

10 ____ Over hunting situation has caused die-out of large mammals. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adb9aec2-265a-5ef4-96bb-0539650fb05c', 'd5e70beb-0cce-5a6e-9fa9-0cc6ef9143bf', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e9c2a33-0187-56e3-9831-a935a1cc553e', 'd5e70beb-0cce-5a6e-9fa9-0cc6ef9143bf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f441731-0736-5db0-b1ed-3ff74f9f70ff', 'd5e70beb-0cce-5a6e-9fa9-0cc6ef9143bf', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a223940e-61cc-55d5-8fda-068820d7d7bc', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

11 ____ Illness rather than hunting caused extensive extinction. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c20df6e9-2900-5108-a6ec-a88e8b7b313e', 'a223940e-61cc-55d5-8fda-068820d7d7bc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9362f244-bdda-5fc8-8794-6d2475262e1e', 'a223940e-61cc-55d5-8fda-068820d7d7bc', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b1af5f7-163e-5f09-bb89-bf427fcb6a1a', 'a223940e-61cc-55d5-8fda-068820d7d7bc', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22ca8dd7-f62f-5aec-baa8-6e48c273e9bd', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

12 ____ Doubt raised through the study of several fossil records. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('114d4dcb-db28-5969-a574-963bb8d6a914', '22ca8dd7-f62f-5aec-baa8-6e48c273e9bd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3687f62-ac3f-532f-b363-b3c362c72259', '22ca8dd7-f62f-5aec-baa8-6e48c273e9bd', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4837f82f-4d64-5e27-924a-ffe856891de3', '22ca8dd7-f62f-5aec-baa8-6e48c273e9bd', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eab8c6f9-ad13-52c9-8371-81a7561697f1', '5ebbcff9-9ac2-5a40-80f0-b28ea1b897c6', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
8
-
13
on your answer sheet.
NB
you may use any letter more than once.
A
John Alroy
B
Ross D.E. MacPhee
C
Russell W. Graham
8
Human hunting well explained which species would finally disappear.
Locate
9
Further grounded proof needed to explain human’s indirect impact on mammals
Locate
10
Over hunting situation has caused die-out of large mammals.
Locate
11
Illness rather than hunting caused extensive extinction.
Locate
12
Doubt raised through the study of several fossil records.
Locate
13
Climate shift is the main reason of extinction.
Locate

13 ____ Climate shift is the main reason of extinction. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf99c7d-c315-50a3-bfb7-3a832d41ce9f', 'eab8c6f9-ad13-52c9-8371-81a7561697f1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06faa6fd-8806-534f-bb3c-739892140c0e', 'eab8c6f9-ad13-52c9-8371-81a7561697f1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('862281b4-bf44-5e91-9585-5047c919e78d', 'eab8c6f9-ad13-52c9-8371-81a7561697f1', 3, $md$C$md$, true);

COMMIT;
