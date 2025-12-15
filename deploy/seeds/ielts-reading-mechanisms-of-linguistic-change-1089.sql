BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mechanisms-of-linguistic-change-1089'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mechanisms-of-linguistic-change-1089';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mechanisms-of-linguistic-change-1089';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mechanisms-of-linguistic-change-1089';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9e7794fe-1de1-5e99-80fd-c10f6903c76f', 'ielts-reading-mechanisms-of-linguistic-change-1089', $t$Mechanisms of Linguistic Change$t$, $md$## Mechanisms of Linguistic Change

Nguồn:
- Test: https://mini-ielts.com/1089/reading/mechanisms-of-linguistic-change
- Solution: https://mini-ielts.com/1089/view-solution/reading/mechanisms-of-linguistic-change$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('eff2def6-1830-520d-87bc-5df353bf1d15', '9e7794fe-1de1-5e99-80fd-c10f6903c76f', 1, $t$Reading — Mechanisms of Linguistic Change$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Mechanisms of Linguistic Change

A The changes that have caused the most disagreement are those in pronunciation. We have various sources of evidence for the pronunciations of earlier times , such as the spellings, the treatment of words borrowed from other languages or borrowed by them, the descriptions of contemporary grammarians and spelling-reformers, and the modern pronunciations in all the languages and dialects concerned From the middle of the sixteenth century, there are in England writers who attempt to describe the position of the speech-organs for the production of English phonemes, and who invent what are in effect systems of phonetic symbols. These various kinds of evidence, combined with a knowledge of the mechanisms of speech-production, can often give us a very good idea of the pronunciation of an earlier age, though absolute certainty is never possible.

B When we study the pronunciation of a language over any period of a few generations or more, we find there are always large-scale regularities in the changes: for example, over a certain period of time, just about all the long [a:] vowels in a language may change into long [e:] vowels, or all the [b] consonants in a certain position (for example at the end of a word) may change into [p] consonants . Such regular changes are often called sound laws . There are no universal sound laws (even though sound laws often reflect universal tendencies), but simply particular sound laws for one given language (or dialect) at one given period

C It is also possible that fashion plays a part in the process of change. It certainly plays a part in the spread of change: one person imitates another, and people with the most prestige are most likely to be imitated, so that a change that takes place in one social group may be imitated (more or less accurately) by speakers in another group. When a social group goes up or down in the world, its pronunciation of Russian, which had formerly been considered desirable, became on the contrary an undesirable kind of accent to have, so that people tried to disguise it . Some of the changes in accepted English pronunciation in the seventeenth and eighteenth centuries have been shown to consist in the replacement of one style of pronunciation by another style already existing, and it is likely that such substitutions were a result of the great social changes of the period: the increased power and wealth of the middle classes, and their steady infiltration upwards into the ranks of the landed gentry, probably carried elements of middle-class pronunciation into upper-class speech.

D A less specific variant of the argument is that the imitation of children is imperfect : they copy their parents’ speech, but never reproduce it exactly. This is true, but it is also true that such deviations from adult speech are usually corrected in later childhood. Perhaps it is more significant that even adults show a certain amount of random variation in their pronunciation of a given phoneme, even if the phonetic context is kept unchanged. This, however, cannot explain changes in pronunciation unless it can be shown that there is some systematic trend in the failures of imitation: if they are merely random deviations they will cancel one another out and there will be no net change in the language .

E One such force which is often invoked is the principle of ease , or minimization of effort. The change from fussy to fuzzy would be an example of assimilation, which is a very common kind of change. Assimilation is the changing of a sound under the influence of a neighbouring one . For example, the word scant was once skamt , but the /m/ has been changed to /n/ under the influence of the following /t/. Greater efficiency has hereby been achieved, because /n/ and /t/ are articulated in the same place (with the tip of the tongue against the teeth-ridge), whereas /m/ is articulated elsewhere (with the two lips). So the place of articulation of the nasal consonant has been changed to conform with that of the following plosive. A more recent example of the same kind of thing is the common pronunciation of football as football.

F Assimilation is not the only way in which we change our pronunciation in order to increase efficiency. It is very common for consonants to be lost at the end of a word: in Middle English, word-final [-n] was often lost in unstressed syllables, so that baken ‘to bake’ changed from [‘ba:kan] to [‘ba:k3],and later to [ba:k]. Consonant-clusters are often simplified. At one time there was a [t] in words like castle and Christmas , and an initial [k] in words like knight and know . Sometimes a whole syllable is dropped out when two successive syllables begin with the same consonant (haplology): a recent example is temporary, which in Britain is often pronounced as if it were tempory.

--------

Great thanks to volunteer Lan Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6c9b7874-706f-51e0-85e5-6cb2e920aca3', 'eff2def6-1830-520d-87bc-5df353bf1d15', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called
1
Locate
. There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of
2
Locate
. Secondly, the imitation of children from adults1 language sometimes are
3
Locate
, and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the
4
Locate
or minimization of effort.

The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called 1 ____ Locate . There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of 2 ____ Locate . Secondly, the imitation of children from adults1 language sometimes are 3 ____ Locate , and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the 4 ____ Locate or minimization of effort.$md$, NULL, ARRAY['.*sound.*laws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('40a43ec4-418f-53cf-a5e5-73fc5b193464', 'eff2def6-1830-520d-87bc-5df353bf1d15', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called
1
Locate
. There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of
2
Locate
. Secondly, the imitation of children from adults1 language sometimes are
3
Locate
, and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the
4
Locate
or minimization of effort.

The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called 1 ____ Locate . There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of 2 ____ Locate . Secondly, the imitation of children from adults1 language sometimes are 3 ____ Locate , and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the 4 ____ Locate or minimization of effort.$md$, NULL, ARRAY['.*sound.*laws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('302d012b-b2b5-5749-8b58-8b6dfaf1575b', 'eff2def6-1830-520d-87bc-5df353bf1d15', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called
1
Locate
. There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of
2
Locate
. Secondly, the imitation of children from adults1 language sometimes are
3
Locate
, and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the
4
Locate
or minimization of effort.

The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called 1 ____ Locate . There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of 2 ____ Locate . Secondly, the imitation of children from adults1 language sometimes are 3 ____ Locate , and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the 4 ____ Locate or minimization of effort.$md$, NULL, ARRAY['.*sound.*laws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f24dce4c-86f5-535e-84d5-91011655d82c', 'eff2def6-1830-520d-87bc-5df353bf1d15', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called
1
Locate
. There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of
2
Locate
. Secondly, the imitation of children from adults1 language sometimes are
3
Locate
, and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the
4
Locate
or minimization of effort.

The pronunciation of living language undergo changes throughout thousands of years. Large scale regular Changes are usually called 1 ____ Locate . There are three reasons for these changes. Firstly, the influence of one language on another; when one person imitates another pronunciation(the most prestige’s), the imitation always partly involving factor of 2 ____ Locate . Secondly, the imitation of children from adults1 language sometimes are 3 ____ Locate , and may also contribute to this change if there are insignificant deviations tough later they may be corrected Finally, for those random variations in pronunciation, the deeper evidence lies in the 4 ____ Locate or minimization of effort.$md$, NULL, ARRAY['.*sound.*laws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f48d6e2f-33f3-5c6c-b692-4d31aeb8ca4a', 'eff2def6-1830-520d-87bc-5df353bf1d15', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

5 ____ It is impossible for modern people to find pronunciation of words in an earlier age Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22551b70-f584-5d88-afe1-ca4410ce67f3', 'f48d6e2f-33f3-5c6c-b692-4d31aeb8ca4a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('451d722c-55e9-500a-ab6b-b412446d4bd3', 'f48d6e2f-33f3-5c6c-b692-4d31aeb8ca4a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('589f03b4-5952-5cd1-bcd7-1587098f2d68', 'f48d6e2f-33f3-5c6c-b692-4d31aeb8ca4a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('086f82dd-f8e3-5d8e-9083-484c3faa6264', 'eff2def6-1830-520d-87bc-5df353bf1d15', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

6 ____ The great change of language in Russian history is related to the rising status and fortune of middle classes. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd513d37-16dd-5d9c-ab43-59773ed721a3', '086f82dd-f8e3-5d8e-9083-484c3faa6264', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d748083c-fde7-549a-b70c-f4fba95ae968', '086f82dd-f8e3-5d8e-9083-484c3faa6264', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6df50dbe-cfbc-5ead-818f-697727975144', '086f82dd-f8e3-5d8e-9083-484c3faa6264', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fc0d7e9-25ec-5f12-a64d-2ca1a09cf2f3', 'eff2def6-1830-520d-87bc-5df353bf1d15', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

7 ____ All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42905170-2c14-5a0c-a696-dfb34f7d0ae1', '1fc0d7e9-25ec-5f12-a64d-2ca1a09cf2f3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6045075e-543a-53be-a971-9c7a72525a9d', '1fc0d7e9-25ec-5f12-a64d-2ca1a09cf2f3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8236de8-3be2-520d-9322-7d4128722031', '1fc0d7e9-25ec-5f12-a64d-2ca1a09cf2f3', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f3febec-269a-5c91-8a06-7eec7fbbd227', 'eff2def6-1830-520d-87bc-5df353bf1d15', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

8 ____ Pronunciation with causal inaccuracy will not exert big influence on language changes. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c11caf59-b544-5c8f-969a-7c31d48dcce6', '5f3febec-269a-5c91-8a06-7eec7fbbd227', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dea16899-a17b-50fc-8c2d-2ff69694cc2e', '5f3febec-269a-5c91-8a06-7eec7fbbd227', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea19139b-dfd0-5a8d-b916-d87cab25fcdc', '5f3febec-269a-5c91-8a06-7eec7fbbd227', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48295c68-dfc3-59f5-b94f-7319fe2f1f73', 'eff2def6-1830-520d-87bc-5df353bf1d15', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

9 ____ The word 'scant' can be pronounced more easily than 'skamt' Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dac3d95c-1e47-51f1-85a7-bd0834f88c1c', '48295c68-dfc3-59f5-b94f-7319fe2f1f73', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5b046fe-c5a8-53d9-8644-b1f1dd5d7080', '48295c68-dfc3-59f5-b94f-7319fe2f1f73', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac32a908-a958-5f96-862c-dd7d6f743fac', '48295c68-dfc3-59f5-b94f-7319fe2f1f73', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f117a8a8-230e-5047-b14e-2a900e720f82', 'eff2def6-1830-520d-87bc-5df353bf1d15', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

10 ____ The [g] in gnat not being pronounced will not be spelt out in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('462e31be-2874-5060-a1d2-e3402a6bc46a', 'f117a8a8-230e-5047-b14e-2a900e720f82', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8458d8b0-5d9a-5c9c-87ae-429f72612fbd', 'f117a8a8-230e-5047-b14e-2a900e720f82', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a081ead-4c12-5754-9658-8c2aed3bb8ad', 'f117a8a8-230e-5047-b14e-2a900e720f82', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd008ee0-6643-57eb-8bda-c758e838df44', 'eff2def6-1830-520d-87bc-5df353bf1d15', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 5-11
Questions 5-11
Do the following statements agree with the information given in Reading Passage?
In boxes
5-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
It is impossible for modern people to find pronunciation of words in an earlier age
Locate
6
The great change of language in Russian history is related to the rising status and fortune of middle classes.
Locate
7
All the children learn speeches from adults white they assume that certain language is difficult to imitate exactly.
8
Pronunciation with causal inaccuracy will not exert big influence on language changes.
Locate
9
The word 'scant' can be pronounced more easily than 'skamt'
Locate
10
The [g] in gnat not being pronounced will not be spelt out in the future.
11
The sound of ‘temporary’ cannot wholly present its spelling.
Locate

11 ____ The sound of ‘temporary’ cannot wholly present its spelling. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f183392a-db41-539e-9302-ef4f119eca7f', 'dd008ee0-6643-57eb-8bda-c758e838df44', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('600576ef-45eb-5485-8881-5ebbbc44e2b5', 'dd008ee0-6643-57eb-8bda-c758e838df44', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d5371fe-75f1-50ae-a518-0e4f7eb4a28f', 'dd008ee0-6643-57eb-8bda-c758e838df44', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af4fd92b-0b38-5b54-aa9d-028fba2b6fa3', 'eff2def6-1830-520d-87bc-5df353bf1d15', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Look at the following sentences and the list of statements below. Match each statement with the correct sentence,
A-D
.
Write the correct letter,
A-D
, in boxes
12-14
on your answer sheet
A
Since the speakers can pronounce it with less effort
B
Assimilation of a sound under the influence of a neighbouring one
C
It is a trend for changes in pronunciation in a large scale in a given period
D
Because the speaker can pronounce [n] and [t] both in the same time
12
As a consequence, ‘b’ will be pronounced as
Locate
13
The pronunciation of [mt] changed to [nt]
Locate
14
The omit of ‘f in the sound of Christmas
Locate

12 ____ As a consequence, ‘b’ will be pronounced as Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7a0a0fa-181f-5282-8db5-5176e69090fc', 'af4fd92b-0b38-5b54-aa9d-028fba2b6fa3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c20954cb-7593-5ff2-bd79-90e4f1f1b2d1', 'af4fd92b-0b38-5b54-aa9d-028fba2b6fa3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('245f263a-d1ce-5d98-abb9-5603bcb88069', 'af4fd92b-0b38-5b54-aa9d-028fba2b6fa3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df4b14a7-f58d-5410-bdb0-599c60bb1ed1', 'af4fd92b-0b38-5b54-aa9d-028fba2b6fa3', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dded96b9-91a3-539f-875e-7e759ffeda13', 'eff2def6-1830-520d-87bc-5df353bf1d15', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Look at the following sentences and the list of statements below. Match each statement with the correct sentence,
A-D
.
Write the correct letter,
A-D
, in boxes
12-14
on your answer sheet
A
Since the speakers can pronounce it with less effort
B
Assimilation of a sound under the influence of a neighbouring one
C
It is a trend for changes in pronunciation in a large scale in a given period
D
Because the speaker can pronounce [n] and [t] both in the same time
12
As a consequence, ‘b’ will be pronounced as
Locate
13
The pronunciation of [mt] changed to [nt]
Locate
14
The omit of ‘f in the sound of Christmas
Locate

13 ____ The pronunciation of [mt] changed to [nt] Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aea766e4-e0c4-5c76-94d6-0d361b8fd4b4', 'dded96b9-91a3-539f-875e-7e759ffeda13', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eebf45b6-4ae7-5df5-8cd7-e09912b3edcb', 'dded96b9-91a3-539f-875e-7e759ffeda13', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31f16945-5942-5e9f-ad5d-06276692a86b', 'dded96b9-91a3-539f-875e-7e759ffeda13', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7fa67f5-0a6d-568e-bec0-50910325a9be', 'dded96b9-91a3-539f-875e-7e759ffeda13', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f67c8c81-ec4c-591d-a968-a0f476581566', 'eff2def6-1830-520d-87bc-5df353bf1d15', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Look at the following sentences and the list of statements below. Match each statement with the correct sentence,
A-D
.
Write the correct letter,
A-D
, in boxes
12-14
on your answer sheet
A
Since the speakers can pronounce it with less effort
B
Assimilation of a sound under the influence of a neighbouring one
C
It is a trend for changes in pronunciation in a large scale in a given period
D
Because the speaker can pronounce [n] and [t] both in the same time
12
As a consequence, ‘b’ will be pronounced as
Locate
13
The pronunciation of [mt] changed to [nt]
Locate
14
The omit of ‘f in the sound of Christmas
Locate

14 ____ The omit of ‘f in the sound of Christmas Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f9c3818-233d-558e-a30b-eb5e0ba307d9', 'f67c8c81-ec4c-591d-a968-a0f476581566', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7d7146c-71ac-5288-9db2-1fef97e0e60f', 'f67c8c81-ec4c-591d-a968-a0f476581566', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cb4f28d-5cf1-5909-bd2b-1ffba87af66a', 'f67c8c81-ec4c-591d-a968-a0f476581566', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('433d484c-0fe2-50ad-9453-622daa69ded2', 'f67c8c81-ec4c-591d-a968-a0f476581566', 4, $md$D$md$, false);

COMMIT;
