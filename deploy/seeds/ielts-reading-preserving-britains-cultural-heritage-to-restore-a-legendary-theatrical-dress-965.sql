BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress-965'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress-965';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress-965';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress-965';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('17766273-0a66-5128-aee2-79aa8f1edfec', 'ielts-reading-preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress-965', $t$Preserving Britain’s cultural heritage: to restore a legendary theatrical dress$t$, $md$## Preserving Britain’s cultural heritage: to restore a legendary theatrical dress

Nguồn:
- Test: https://mini-ielts.com/965/reading/preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress
- Solution: https://mini-ielts.com/965/view-solution/reading/preserving-britains-cultural-heritage-to-restore-a-legendary-theatrical-dress$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4966456d-f0be-5823-901a-080e47aedb1f', '17766273-0a66-5128-aee2-79aa8f1edfec', 1, $t$Reading — Preserving Britain’s cultural heritage: to restore a legendary theatrical dress$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Preserving Britain’s cultural heritage: to restore a legendary theatrical dress

An astonishingly intricate project is being undertaken to restore a legendary theatrical dress , Angela Wintle explains.

On December 28th, 1888, the curtain rose on a daring new stage revival of Shakespeare’s Macbeth at the Lyceum Theatre in London. Topping the bill, playing Lady Macbeth, a main character in the play, was Ellen Terry. She was the greatest and most adored English actress of the age. But she didn't achieve this devotion through her acting ability alone, She knew the power of presentation and carefully cultivated her image . That first night was no exception. When she walked on stage for the famous banqueting scene, her appearance drew a collective gasp from the audience.

She was dressed in the most extraordinary clothes ever to have graced a British stage: a long, emerald and sea-green gown with tapering sleeves, surmounted by a velvet cloak, which glistened and sparkled eerily in the limelight. Yet this was no mere stage trickery. The effect had been achieved using hundreds of wings from beetles . The gown - later named the ‘Beetlewing dress’ became one of the most iconic and celebrated costumes of the age.

Terry was every bit as remarkable as her costumes. At 31, she became a leading lady at the Lyceum Theatre and for two decades, she set about bringing culture to the masses.

The productions she worked on were extravagant and daring. Shakespeare’s plays were staged alongside blood-and-thunder melodramas and their texts were ruthlessly cut. Some people were critical, but they missed the point. The innovations sold tickets and brought new audiences to see masterpieces that they would never otherwise have seen .

However, it was a painter who immortalised her. John Singer Sargent had been so struck by Terry's appearance at that first performance that he asked her to model for him, and his famous portrait of 1889, now at the Tate Gallery in London, showed her with a glint in her eye, holding a crown over her flame-red hair. But while the painting remains almost as fresh as the day it was painted, the years have not been so kind to the dress . Its delicate structure, combined with the cumulative effects of time, has meant it is now in an extremely fragile condition. Thus, two years ago, a fundraising project was launched by Britain's National Trust 1 to pay for its conservation.

It turned to textile conservator Zenzie Tinker to do the job. Zenzie loves historical dress because of the link with the past. ’Working on costumes like the Beetlewing dress gives you a real sense of the people who wore them; you can see the sweat stains and wear marks. But it’s quite unusual to know who actually wore a garment. That’s the thing that makes the Beetlewing project so special .’

Before any of Zenzie’s conservation work can begin, she and her team will conduct a thorough investigation to help determine what changes have been made to the dress and when. This will involve close examination of the dress for signs of damage and wear , and will be aided by comparing it with John Singer Sargent's painting and contemporary photographs. Then and the National Trust will decide how far back to take the reconstruction, as some members feel that even the most recent changes are now part of the history of the dress.

The first stages in the actual restoration will involve delicate surface cleaning, using a small vacuum suction device . Once the level of reconstruction has been determined, the original crocheted 2 overdress will be stitched onto a dyed net support before repairs begin. It’s going to be extraordinarily difficult, because the original doth is quite stretchy, so we’ve deliberately chosen net because that has a certain amount of flexibility in it too ,' says Zenzie. When the dress is displayed, none of our work will be noticeable, but we’ll retain all the evidence on the reverse so that future experts will be able to see exactly what we've done - and I'll produce a detailed report.’

Zenzie has estimated that the project, costing about £30,000, will require more than 700 hours’ work. ‘It will be a huge undertaking and I don’t think the Trust has ever spent quite as much on a costume before,’ she says. ‘But this dress is unique. It's very unusual to see this level of workmanship on a theatrical costume, and it must have looked spectacular on stage.’ If Terry was alive today, there’s no doubt she would be delighted. Unlike many other actresses, she valued her costumes because she kept and reused them time and time again . 'I'd like to think she’d see our contribution as part of the ongoing history of the dress,’ says Zenzie.

1 A conservation organisation whose work includes the funding of projects designed to protect and preserve Britain's cultural heritage

2 Produced using wool and a special needle with a hook at the end

Adapted from Sussex Life magazine$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83196eab-9751-51a0-bebb-7772f70d271c', '4966456d-f0be-5823-901a-080e47aedb1f', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dddf9399-ac3d-5fcf-ab79-63ad83034e8b', '4966456d-f0be-5823-901a-080e47aedb1f', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c485e54c-3845-5505-8f26-603434f89207', '4966456d-f0be-5823-901a-080e47aedb1f', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72804bb4-b3fa-5a05-9e7e-3cb6031da20e', '4966456d-f0be-5823-901a-080e47aedb1f', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5145ec89-a1f0-50c4-9237-f3674cf0ff67', '4966456d-f0be-5823-901a-080e47aedb1f', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf78a929-5a36-55ce-9850-6ab8280c2285', '4966456d-f0be-5823-901a-080e47aedb1f', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Choose the correct letter,
A, B, C
or
D
.
1
What do you learn about Ellen Terry in the first paragraph?
A
Lady Macbeth was her first leading role.
B
The Lyceum was her favourite theatre.
C
She tried hard to look good on stage.
D
She wanted to look young for her audience.
2
What is the writer’s purpose in paragraph 2?
A
to describe different responses to the Beetlewing dress
B
to explain why the Beetlewing dress had such a big impact
C
to consider the suitability of the Beetlewing dress for the play
D
to compare the look of the Beetiewing dress on and off the stage
3
According to the writer, the main effect of the Lyceum productions was to
A
expose more people to Shakespeare’s plays.
B
reduce the interest in other types of production.
C
raise the cost of going to the theatre.
D
encourage writers to produce more plays.
4
In the fourth paragraph, what comparison does the writer make between Sargent’s portrait and the Beetlewing dress?
A
The dress has attracted more attention than the painting.
B
The dress is worth more money than the painting.
C
The painting took longer to produce.
D
The painting looks newer.
5
Zenzie says the Beetlewing project is particularly special because
A
the dress is very old.
B
people know who wore the dress.
C
the dress was designed by someone famous.
D
there is evidence that the dress has been used
6
Which of the following is the most suitable title for the passage?
A
A lesson from the past
B
A challenging task
C
An unusual fashion show
D
An unexpected discovery

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4933d5c7-7d61-59b2-9f28-ec14af4fbe8c', '4966456d-f0be-5823-901a-080e47aedb1f', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Do the following statements agree with the views of the writer in the reading passage?
Write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The National Trust conducted useful research to assist Zenzie's plans for the dress.
8
There will be some discussion over the changes that Zenzie’s team should make to the dress.
9
Zenzie’s estimate for the timing of the project is realistic.
10
Ellen Terry’s attitude towards her dresses was typical of her time.

7 ____ The National Trust conducted useful research to assist Zenzie's plans for the dress.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('882a9cc7-86ee-5404-b15d-8939249a8f5c', '4933d5c7-7d61-59b2-9f28-ec14af4fbe8c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe759f70-13f9-5b0a-890b-df5ba11e8939', '4933d5c7-7d61-59b2-9f28-ec14af4fbe8c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ee7f335-e149-5362-977c-246ae2653292', '4933d5c7-7d61-59b2-9f28-ec14af4fbe8c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb273cfd-3f46-5368-813e-efcb2500caeb', '4966456d-f0be-5823-901a-080e47aedb1f', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Do the following statements agree with the views of the writer in the reading passage?
Write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The National Trust conducted useful research to assist Zenzie's plans for the dress.
8
There will be some discussion over the changes that Zenzie’s team should make to the dress.
9
Zenzie’s estimate for the timing of the project is realistic.
10
Ellen Terry’s attitude towards her dresses was typical of her time.

8 ____ There will be some discussion over the changes that Zenzie’s team should make to the dress.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f1b5cc3-cd12-50b7-b3e0-7f498f0e90ee', 'bb273cfd-3f46-5368-813e-efcb2500caeb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d8b2dbf-b56b-5bca-961d-1279098519ab', 'bb273cfd-3f46-5368-813e-efcb2500caeb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18f19de5-e2b6-560d-9f01-ca30a13f8437', 'bb273cfd-3f46-5368-813e-efcb2500caeb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43b2b568-470a-5dc3-a0b6-e81322381e3a', '4966456d-f0be-5823-901a-080e47aedb1f', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Do the following statements agree with the views of the writer in the reading passage?
Write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The National Trust conducted useful research to assist Zenzie's plans for the dress.
8
There will be some discussion over the changes that Zenzie’s team should make to the dress.
9
Zenzie’s estimate for the timing of the project is realistic.
10
Ellen Terry’s attitude towards her dresses was typical of her time.

9 ____ Zenzie’s estimate for the timing of the project is realistic.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eafebb24-1068-5ed2-b5e6-f740d98cd0fc', '43b2b568-470a-5dc3-a0b6-e81322381e3a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9aadf96e-a6ea-5606-966c-32e21491c87c', '43b2b568-470a-5dc3-a0b6-e81322381e3a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b25edf6-10e9-5b2f-b1e4-f2da0d02b562', '43b2b568-470a-5dc3-a0b6-e81322381e3a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e116c54-474d-52b8-9666-1ebbdb87ae64', '4966456d-f0be-5823-901a-080e47aedb1f', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Do the following statements agree with the views of the writer in the reading passage?
Write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The National Trust conducted useful research to assist Zenzie's plans for the dress.
8
There will be some discussion over the changes that Zenzie’s team should make to the dress.
9
Zenzie’s estimate for the timing of the project is realistic.
10
Ellen Terry’s attitude towards her dresses was typical of her time.

10 ____ Ellen Terry’s attitude towards her dresses was typical of her time.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8088ae73-173b-567e-943c-f94aa719725f', '8e116c54-474d-52b8-9666-1ebbdb87ae64', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a47d683-aa7d-5c58-b2ab-1205d59e0e92', '8e116c54-474d-52b8-9666-1ebbdb87ae64', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a926521f-bcf9-568a-9eaf-f6662e8a7798', '8e116c54-474d-52b8-9666-1ebbdb87ae64', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', '4966456d-f0be-5823-901a-080e47aedb1f', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
11
Pictures will be used
12
A special machine will be used
13
A net material has been selected
14
Work will be visible on one side
Locate
A
to show how the team did the repairs on the dress.
B
to reduce the time taken to repair the dress.
C
to remove the dirt from the top layer of the dress.
D
to demonstrate the quality of the team’s work on the dress.
E
to match a quality of the original fabric used in the dress.
F
to help show where the dress needs repair work.

11 Pictures will be used ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53cfbe2b-ee2b-51da-8926-739f1a36ebe4', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c453029-66b4-5499-aa71-47155a94af9a', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a817a23f-ab3a-5048-926c-7580332f1c42', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b670780e-ed4c-5835-969b-232e7133935b', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86226190-e298-5c97-9025-985245ec46ac', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d20f1ed8-884d-56d7-bdbe-1e4950d3d417', '93b68a17-f4ca-5c49-8a81-9c1e1ba5f67b', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', '4966456d-f0be-5823-901a-080e47aedb1f', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
11
Pictures will be used
12
A special machine will be used
13
A net material has been selected
14
Work will be visible on one side
Locate
A
to show how the team did the repairs on the dress.
B
to reduce the time taken to repair the dress.
C
to remove the dirt from the top layer of the dress.
D
to demonstrate the quality of the team’s work on the dress.
E
to match a quality of the original fabric used in the dress.
F
to help show where the dress needs repair work.

12 A special machine will be used ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6395f3b3-1922-538f-9382-2df7794a7a37', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52b6c9cc-5310-5845-ac8d-953880ecd159', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc08be4c-6a5e-5746-be2c-e102f45e0464', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02513be1-ba47-52a7-90d2-0af40cf0cb7c', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98f903f4-0a2e-55ba-b098-5f8d395d2f9e', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f298369-ae5a-501e-9591-d4de88b0268b', 'c97beffe-a7ac-56c2-bf0c-c8dcfd5a52e6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', '4966456d-f0be-5823-901a-080e47aedb1f', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
11
Pictures will be used
12
A special machine will be used
13
A net material has been selected
14
Work will be visible on one side
Locate
A
to show how the team did the repairs on the dress.
B
to reduce the time taken to repair the dress.
C
to remove the dirt from the top layer of the dress.
D
to demonstrate the quality of the team’s work on the dress.
E
to match a quality of the original fabric used in the dress.
F
to help show where the dress needs repair work.

13 A net material has been selected ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab3b6c7e-3c3c-508c-973c-0753f4cdf3d7', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89fded14-8d77-59af-bb56-a5674f64e128', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6821f82-51ad-5130-9ec8-55f9797445b5', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5305d13-2ef5-5036-ae4e-fd9aa884e9cd', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1d3e380-9407-5905-a141-d87459d0def1', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a44e528-2cb9-587d-98c1-e5277bd4729e', '8ea3c8b3-ba27-5cb2-9914-876cc0c500ec', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf650910-d67a-5cb3-ac52-f8bfb27c83a5', '4966456d-f0be-5823-901a-080e47aedb1f', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
11
Pictures will be used
12
A special machine will be used
13
A net material has been selected
14
Work will be visible on one side
Locate
A
to show how the team did the repairs on the dress.
B
to reduce the time taken to repair the dress.
C
to remove the dirt from the top layer of the dress.
D
to demonstrate the quality of the team’s work on the dress.
E
to match a quality of the original fabric used in the dress.
F
to help show where the dress needs repair work.

14 Work will be visible on one side ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48ac0772-0e6a-535d-b63f-46d3c1b9f3d8', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b95319d-b255-5d4f-8c94-efc846e2b15f', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aeaa2f16-57ef-53f1-bf29-7c26c644e803', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27f42c99-789e-5a68-933d-b5c43e6367e6', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a71ba345-a9a8-5487-a77e-b53e4a792fd3', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d895c9a1-215a-53b9-be5d-765eccaca70d', 'bf650910-d67a-5cb3-ac52-f8bfb27c83a5', 6, $md$F$md$, false);

COMMIT;
