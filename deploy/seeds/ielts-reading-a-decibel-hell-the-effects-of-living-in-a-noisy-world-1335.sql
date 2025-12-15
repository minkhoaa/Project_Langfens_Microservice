BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-decibel-hell-the-effects-of-living-in-a-noisy-world-1335'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-decibel-hell-the-effects-of-living-in-a-noisy-world-1335';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-decibel-hell-the-effects-of-living-in-a-noisy-world-1335';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-decibel-hell-the-effects-of-living-in-a-noisy-world-1335';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('015c9a67-90c7-5fb1-bcc2-cdf1b94de48b', 'ielts-reading-a-decibel-hell-the-effects-of-living-in-a-noisy-world-1335', $t$A decibel Hell (The Effects of Living in a Noisy World)$t$, $md$## A decibel Hell (The Effects of Living in a Noisy World)

Nguồn:
- Test: https://mini-ielts.com/1335/reading/a-decibel-hell-the-effects-of-living-in-a-noisy-world
- Solution: https://mini-ielts.com/1335/view-solution/reading/a-decibel-hell-the-effects-of-living-in-a-noisy-world$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4a8448d7-b6e8-5f96-b5b8-660b791b969e', '015c9a67-90c7-5fb1-bcc2-cdf1b94de48b', 1, $t$Reading — A decibel Hell (The Effects of Living in a Noisy World)$t$, $md$Read the passage and answer questions **1–13**.

### Passage: A decibel Hell (The Effects of Living in a Noisy World)

Section A decibel Hell:

It’s not difficult for a person to encounter sound at levels that can cause adverse health effects. During a single day, people living in a typical urban environment can experience a wide range of sounds in many locations, even once-quiet locales have become polluted with noise. In fact, it’s difficult today to escape sound completely. In its 1999 Guidelines for Community Noise, the World Health Organization (WHO) declared, “Worldwide, noise-induced hearing impairment is the most prevalent irreversible occupational hazard, and it is estimated that 120 million people worldwide have disabling hearing difficulties.” Growing evidence also points to many other health effects of too much volume.

Mark Stephenson, a Cincinnati, Ohio-based senior research audiologist at the National Institute for Occupational Safety and Health (NIOSH), says his agency’s definition of hazardous noise is sound that exceeds the time-weighted average of 85 dBA, meaning the average noise exposure measured over a typical eight-hour workday. Other measures and definitions are used for other purposes.

Section B Growing Volume

In the United States, about 30 million workers are exposed to hazardous sound levels on the job, according to NIOSH. Industries having a high number of workers exposed to loud sounds include construction, agriculture, mining, manufacturing, utilities, transportation, and the military.

Noise in U.S. industry is an extremely difficult problem to monitor, acknowledges Craig Moulton, a senior industrial hygienist for the Occupational Safety and Health Administration (OSHA). “Still,” he says, “OSHA does require that any employer with workers overexposed to noise provide protection for those employees against the harmful effects of noise. Additionally, employers must implement a continuing, effective hearing conservation program as outlined in OSHA’s Noise Standard.”

Section C Scary Sound Effects

Numerous scientific studies over the years have confirmed that exposure to certain levels of sound can damage hearing. Prolonged exposure can actually change the structure of the hair cells in the inner ear, resulting in hearing loss. It can also cause tinnitus, a ringing, roaring, buzzing, or clicking on the ears.

NIOSH studies from the mid to late 1990s show that 90% of coal miners have hearing impairment by age 52 – compared to 9% of the general population – and 70% of male metal/nonmetal miners will experience hearing impairment by age 60 (Stephenson notes that from adolescence onward, females tend to have better hearing than males). Neitzel says nearly half of all construction workers have some degree of hearing loss. “NIOSH research also reveals that by age twenty-five, the average carpenter’s hearing is equivalent to an otherwise healthy fifty-year-old male who hasn’t been exposed to noise,” he says.

William Luxford, medical director of the House Ear Clinic of St. Vincent Medical Center in Los Angeles, points out one piece of good news: “It’s true that continuous noise exposure will lead to the continuation of hearing loss, but as soon as the exposure is stopped, the hearing loss stops. So a change in environment can improve a person’s hearing health.”

Research is catching up with this anecdotal evidence. In the July 2001 issue of Pediatrics, researchers from the Centers for Disease Control and Prevention reported that, based on audiometric testing of 5,249 children as part of the Third National Health and Nutrition, Examination Survey, an estimated 12.5% of American children have noise-induced hearing threshold shifts – or dulled hearing – in one or both ears. Most children with noise-induced hearing threshold shifts have only limited hearing damage, but continued exposure to excessive noise can lead to difficulties with high-frequency sound discrimination. The report listed stereos, music concerts, toys (such as toy telephones and certain rattles), lawnmowers, and fireworks as producing potentially harmful sounds.

Section D Beyond the Ears

The effects of sound don’t stop with the ears. Nonauditory effects of noise exposure are those effects that don’t cause hearing loss but still can be measured, such as elevated blood pressure, loss of sleep, increased heart rate, cardiovascular constriction, labored breathing, and changes in brain chemistry.

The nonauditory effects of noise were noted as early as 1930 in a study published by E.L. Smith and D.L. Laird in volume 2 of the Journal of the Acoustical Society of America. The results showed that exposure to noise caused stomach contractions in healthy human beings. Reports on noise’s nonauditory effects published since that pioneering study have been both contradictory and controversial in some areas.

Bronzaft and the school principal persuaded the school board to have acoustical tile installed in the classrooms adjacent to the tracks. The Transit Authority also treated the tracks near the school to make them less noisy. A follow-up study published in the September 1981 issue of the Journal of Environmental Psychology found that children’s reading scores improved after these interventions were put in place.

Section E Fighting for Quiet

Anti-noise activists say that Europe and several countries in Asia are more advanced than the United States in terms of combating noise. “Population pressure has prompted Europe to move more quickly on the noise issue that the United States has,” Hume says. In the European Union, countries with cities of at least 250,000 people are creating noise maps of those cities to help leaders determine noise pollution policies. Paris has already prepared its first noise maps. The map data, which must be finished by 2007, will be fed into computer models that will help test the sound impact of street designs or new buildings before construction begins.

Activists in other countries say they too want the United States to play a more leading role on the noise issue. But as in other areas of environmental health, merely having a more powerful government agency in place that can set more regulations is not the ultimate answer, according to other experts. Bronzaft stresses that governments worldwide need to increase funding for noise research and do a better job coordinating their noise pollution efforts so they can establish health and environmental policies based on solid scientific research. “Governments have a responsibility to protect their citizens by curbing noise pollution,” she says.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('21effe9b-2f19-5736-8b1d-2f845c39b290', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of
1
referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage
2
on certain senior age.
From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in
3
sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of
4
##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating
5
to help to create noise pollution policies.

Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of 1 ____ referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage 2 ____ on certain senior age.$md$, NULL, ARRAY['.*85.*dba.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2539772c-8e3d-5cc9-9b7c-aa397f9b5e73', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of
1
referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage
2
on certain senior age.
From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in
3
sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of
4
##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating
5
to help to create noise pollution policies.

Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of 1 ____ referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage 2 ____ on certain senior age.$md$, NULL, ARRAY['.*85.*dba.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('087bd335-8f77-5557-9b50-d7d83567421b', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of
1
referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage
2
on certain senior age.
From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in
3
sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of
4
##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating
5
to help to create noise pollution policies.

From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in 3 ____ sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of 4 ____ ##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating 5 ____ to help to create noise pollution policies.$md$, NULL, ARRAY['.*high.*frequency.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eebd49fb-a1b2-5907-8bf6-7bb711276fd8', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of
1
referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage
2
on certain senior age.
From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in
3
sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of
4
##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating
5
to help to create noise pollution policies.

From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in 3 ____ sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of 4 ____ ##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating 5 ____ to help to create noise pollution policies.$md$, NULL, ARRAY['.*high.*frequency.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('14e09bef-80e4-5097-841d-44f5a2e63b52', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Nowadays it seems difficult for people to avoid the effects of living in a noisy world. Noise is the sound beyond the average of
1
referring to the agency’s definition. Scientific studies over the years from the mid to late 1990s have confirmed that exposure to certain levels of sound can cause damage
2
on certain senior age.
From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in
3
sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of
4
##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating
5
to help to create noise pollution policies.

From the testing of 5,249 children, those who are constantly exposed to excessive noise may have trouble in 3 ____ sound discrimination. The effects of sound don’t stop with the ears, exposure to noise may lead to the unease of 4 ____ ##a in healthy people. Europe has taken steps on the noise issue, big cities of over 250,000 people are creating 5 ____ to help to create noise pollution policies.$md$, NULL, ARRAY['.*high.*frequency.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4daafc0-c183-54ba-afb5-cc140dd416c0', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Look at the following researchers and the list of findings below. Match each researcher with the correct finding.
Write the correct letter in boxes
6-10
on your answer sheet.
List of people or organisations
A
WHO
B
William Luxford (the House Ear Clinic),
C
Craig Moulton (OSHA)
D
Arline Bronzaft
E
Centers for Disease Control and Prevention
6
People can change the environment to improve hearing health.
7
The government should continue the research on anti-noise researches with the fund.
8
companies should be required to protect the employees to avoid noise
9
Noise has posed an effect on American children’s hearing ability
10
noise has seriously affected human being where they live worldwide

6 ____ People can change the environment to improve hearing health.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f63c450-ffec-552e-8bb7-aaad5a91b567', 'd4daafc0-c183-54ba-afb5-cc140dd416c0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99d9d489-9894-53dd-a025-7d326786080e', 'd4daafc0-c183-54ba-afb5-cc140dd416c0', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b67d07e-3342-54a6-856c-073736c1f6b8', 'd4daafc0-c183-54ba-afb5-cc140dd416c0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa679f41-570d-5746-a519-fd4f5a19140e', 'd4daafc0-c183-54ba-afb5-cc140dd416c0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e71ae413-91f1-55cb-b8b9-ec9cc4afea6c', 'd4daafc0-c183-54ba-afb5-cc140dd416c0', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('57855605-8a63-518f-8f21-9e311f276c8d', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Look at the following researchers and the list of findings below. Match each researcher with the correct finding.
Write the correct letter in boxes
6-10
on your answer sheet.
List of people or organisations
A
WHO
B
William Luxford (the House Ear Clinic),
C
Craig Moulton (OSHA)
D
Arline Bronzaft
E
Centers for Disease Control and Prevention
6
People can change the environment to improve hearing health.
7
The government should continue the research on anti-noise researches with the fund.
8
companies should be required to protect the employees to avoid noise
9
Noise has posed an effect on American children’s hearing ability
10
noise has seriously affected human being where they live worldwide

7 ____ The government should continue the research on anti-noise researches with the fund.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('408f231e-c105-56ab-beb3-4622995a593b', '57855605-8a63-518f-8f21-9e311f276c8d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20d5fec6-2ace-532d-b353-b70ae8e21b91', '57855605-8a63-518f-8f21-9e311f276c8d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2049991f-2782-5da7-990a-4dd391bd3a67', '57855605-8a63-518f-8f21-9e311f276c8d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f885f568-755c-577f-8a5a-d9c30b54c11d', '57855605-8a63-518f-8f21-9e311f276c8d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e6a48c0-c799-5f48-8933-ea5fc3775492', '57855605-8a63-518f-8f21-9e311f276c8d', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Look at the following researchers and the list of findings below. Match each researcher with the correct finding.
Write the correct letter in boxes
6-10
on your answer sheet.
List of people or organisations
A
WHO
B
William Luxford (the House Ear Clinic),
C
Craig Moulton (OSHA)
D
Arline Bronzaft
E
Centers for Disease Control and Prevention
6
People can change the environment to improve hearing health.
7
The government should continue the research on anti-noise researches with the fund.
8
companies should be required to protect the employees to avoid noise
9
Noise has posed an effect on American children’s hearing ability
10
noise has seriously affected human being where they live worldwide

8 ____ companies should be required to protect the employees to avoid noise$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18579e12-f4ba-5965-b463-6eb48324a76d', 'e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7d616b2-38f9-59e2-972c-479eb3a08894', 'e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c79b816e-c755-531d-835d-64d6f6e96332', 'e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13900221-c843-53da-a4a5-f0f43d5425e8', 'e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('157a53aa-de7e-552c-9448-33f09826859f', 'e0bb3d91-7845-57bd-91dd-b544f3c4c6c0', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('44c09300-9e2b-5dac-8ba3-0ff49fdec76e', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Look at the following researchers and the list of findings below. Match each researcher with the correct finding.
Write the correct letter in boxes
6-10
on your answer sheet.
List of people or organisations
A
WHO
B
William Luxford (the House Ear Clinic),
C
Craig Moulton (OSHA)
D
Arline Bronzaft
E
Centers for Disease Control and Prevention
6
People can change the environment to improve hearing health.
7
The government should continue the research on anti-noise researches with the fund.
8
companies should be required to protect the employees to avoid noise
9
Noise has posed an effect on American children’s hearing ability
10
noise has seriously affected human being where they live worldwide

9 ____ Noise has posed an effect on American children’s hearing ability$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98073c53-4072-54a7-9733-0e34a5c76d93', '44c09300-9e2b-5dac-8ba3-0ff49fdec76e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fc23734-e0e4-5d32-a8d6-16cf35fd11e3', '44c09300-9e2b-5dac-8ba3-0ff49fdec76e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74c0ad78-3f05-5198-b277-84693577ac13', '44c09300-9e2b-5dac-8ba3-0ff49fdec76e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec0d9e13-f409-512a-bc56-6cc29edbedda', '44c09300-9e2b-5dac-8ba3-0ff49fdec76e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d37ce80-b0b2-5428-962c-90324bcf543c', '44c09300-9e2b-5dac-8ba3-0ff49fdec76e', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('92e0b06b-fe60-51d9-97a1-ea5d77462aaa', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Look at the following researchers and the list of findings below. Match each researcher with the correct finding.
Write the correct letter in boxes
6-10
on your answer sheet.
List of people or organisations
A
WHO
B
William Luxford (the House Ear Clinic),
C
Craig Moulton (OSHA)
D
Arline Bronzaft
E
Centers for Disease Control and Prevention
6
People can change the environment to improve hearing health.
7
The government should continue the research on anti-noise researches with the fund.
8
companies should be required to protect the employees to avoid noise
9
Noise has posed an effect on American children’s hearing ability
10
noise has seriously affected human being where they live worldwide

10 ____ noise has seriously affected human being where they live worldwide$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4addee2-9454-582f-a8db-71581c8e662c', '92e0b06b-fe60-51d9-97a1-ea5d77462aaa', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('166d2fe9-5751-583a-83bd-ee58d3fc3398', '92e0b06b-fe60-51d9-97a1-ea5d77462aaa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55b15d1d-5660-51d6-91ef-96c94d49faaf', '92e0b06b-fe60-51d9-97a1-ea5d77462aaa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0ee4add-e4ee-5564-a483-b05e6fdf3965', '92e0b06b-fe60-51d9-97a1-ea5d77462aaa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43a5e05c-8853-5ba4-8fb4-467ccda3c0d5', '92e0b06b-fe60-51d9-97a1-ea5d77462aaa', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b61c4efe-75ce-5c1b-bb77-e6a9189e4e2d', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
Write your answers in boxes
11-13
on your answer sheet.
11
The board of schools built close to the tracks are convinced to
A
moved the classrooms away from the noisy track
B
regulated the track usage to a less extent
C
utilised a special material into classroom buildings lessening the effect of outside noise
D
organised a team for a follow-up study
12
In European countries, the big cities’ research on noise focuses on
A
How to record pollution details of the city on maps
B
the impact of noise on population shift in the European cities
C
how wide can a city be to avoid noise pollution
D
helping the authorities better make a decision on management of the city
13
What is the best title in paragraph 1?
A
How people cope with noise pollutions
B
the fight against the noise with the powerful technology
C
The Effects of Living in a Noisy World
D
The Effects of noise on children’s learning

Choose the correct letter A , B , C or D Write your answers in boxes 11-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d8cb0b6-3bc3-5f1b-b4a4-74d655e2bf0f', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
Write your answers in boxes
11-13
on your answer sheet.
11
The board of schools built close to the tracks are convinced to
A
moved the classrooms away from the noisy track
B
regulated the track usage to a less extent
C
utilised a special material into classroom buildings lessening the effect of outside noise
D
organised a team for a follow-up study
12
In European countries, the big cities’ research on noise focuses on
A
How to record pollution details of the city on maps
B
the impact of noise on population shift in the European cities
C
how wide can a city be to avoid noise pollution
D
helping the authorities better make a decision on management of the city
13
What is the best title in paragraph 1?
A
How people cope with noise pollutions
B
the fight against the noise with the powerful technology
C
The Effects of Living in a Noisy World
D
The Effects of noise on children’s learning

Choose the correct letter A , B , C or D Write your answers in boxes 11-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d4092bf-5b99-56b2-90e4-c73a3029c111', '4a8448d7-b6e8-5f96-b5b8-660b791b969e', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
Write your answers in boxes
11-13
on your answer sheet.
11
The board of schools built close to the tracks are convinced to
A
moved the classrooms away from the noisy track
B
regulated the track usage to a less extent
C
utilised a special material into classroom buildings lessening the effect of outside noise
D
organised a team for a follow-up study
12
In European countries, the big cities’ research on noise focuses on
A
How to record pollution details of the city on maps
B
the impact of noise on population shift in the European cities
C
how wide can a city be to avoid noise pollution
D
helping the authorities better make a decision on management of the city
13
What is the best title in paragraph 1?
A
How people cope with noise pollutions
B
the fight against the noise with the powerful technology
C
The Effects of Living in a Noisy World
D
The Effects of noise on children’s learning

Choose the correct letter A , B , C or D Write your answers in boxes 11-13 on your answer sheet.$md$, NULL);

COMMIT;
