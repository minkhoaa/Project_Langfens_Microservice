BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-personality-and-appearance-1410'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-personality-and-appearance-1410';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-personality-and-appearance-1410';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-personality-and-appearance-1410';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('88ae896f-8819-58ab-948c-eee06ac6bd99', 'ielts-reading-personality-and-appearance-1410', $t$Personality and appearance$t$, $md$## Personality and appearance

Nguồn:
- Test: https://mini-ielts.com/1410/reading/personality-and-appearance
- Solution: https://mini-ielts.com/1410/view-solution/reading/personality-and-appearance$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('39f75966-d29f-5e82-906c-8689799ecdd0', '88ae896f-8819-58ab-948c-eee06ac6bd99', 1, $t$Reading — Personality and appearance$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Personality and appearance

When Charles Darwin applied to be the “energetic young man” that Robert Fitzroy, the Beagle’s captain, sought as his gentleman companion, he was almost let down by a woeful shortcoming that was as plain as the nose on his face. Fitzroy believed in physiognomy—the idea that you can tell a person’s character from their appearance. As Darwin’s daughter Henrietta later recalled, Fitzroy had “made up his mind that no man with such a nose could have energy”. This was hardly the case. Fortunately, the rest of Darwin’s visage compensated for his sluggardly proboscis: “His brow saved him.”

The idea that a person’s character can be glimpsed in their face dates back to the ancient Greeks. It was most famously popularised in the late 18th century by the Swiss poet Johann Lavater, whose ideas became a talking point in intellectual circles. In Darwin’s day, they were more or less taken as given. It was only after the subject became associated with phrenology, which fell into disrepute in the late 19th century, that physiognomy was written off as pseudoscience.

First impressions are highly influential, despite the well-worn admonition not to judge a book by its cover. Within a tenth of a second of seeing an unfamiliar face we have already made a judgement about its owner’s character—caring, trustworthy, aggressive, extrovert, competent and so on. Once that snap judgement has formed, it is surprisingly hard to budge. People also act on these snap judgements. Politicians with competent-looking faces have a greater chance of being elected, and CEOs who look dominant are more likely to run a profitable company. There is also a well-established “attractiveness halo”. People seen as good-looking not only get the most valentines but are also judged to be more outgoing, socially competent, powerful, intelligent and healthy.

In 1966, psychologists at the University of Michigan asked 84 undergraduates who had never met before to rate each other on five personality traits, based entirely on appearance, as they sat for 15 minutes in silence. For three traits—extroversion, conscientiousness and openness—the observers’ rapid judgements matched real personality scores significantly more often than chance. More recently, researchers have re-examined the link between appearance and personality, notably Anthony Little of the University of Stirling and David Perrett of the University of St Andrews, both in the UK. They pointed out that the Michigan studies were not tightly controlled for confounding factors. But when Little and Perrett re-ran the experiment using mugshots rather than live subjects, they also found a link between facial appearance and personality—though only for extroversion and conscientiousness. Little and Perrett claimed that they only found a correlation at the extremes of personality.

Justin Carre and Cheryl McCormick of Brock University in Ontario, Canada studied 90 ice-hockey players. They found that a wider face in which the cheekbone-to-cheekbone distance was unusually large relative to the distance between brow and upper lip was linked in a statistically significant way with the number of penalty minutes a player was given for violent acts including slashing, elbowing, checking from behind and fighting. The kernel of truth idea isn’t the only explanation on offer for our readiness to make facial judgements. Leslie Zebrowitz, a psychologist at Brandeis University in Waltham, Massachusetts, says that in many cases snap judgements are not accurate. The snap judgement, she says, is often an “overgeneralisation” of a more fundamental response. A classic example of overgeneralisation can be seen in predators’ response to eye spots, the conspicuous circular markings seen on some moths, butterflies and fish. These act as a deterrent to predators because they mimic the eyes of other creatures that the potential predators might see as a threat.

Another researcher who leans towards overgeneralisation is Alexander Todorov. With Princeton colleague Nikolaas Oosterhof, he recently put forward a theory which he says explains our snap judgements of faces in terms of how threatening they appear. Todorov and Oosterhof asked people for their gut reactions to pictures of emotionally neutral faces, sifted through all the responses, and boiled them down to two underlying factors: how trustworthy the face looks, and how dominant. Todorov and Oosterhof conclude that personality judgements based on people’s faces are an overgeneralisation of our evolved ability to infer emotions from facial expressions, and hence a person’s intention to cause us harm and their ability to carry it out. Todorov, however, stresses that overgeneralisation does not rule out the idea that there is sometimes a kernel of truth in these assessments of personality.

So if there is a kernel of truth, where does it come from? Perrett has a hunch that the link arises when our prejudices about faces turn into self-fulfilling prophecies—an idea that was investigated by other researchers back in 1977. Our expectations can lead us to influence people to behave in ways that confirm those expectations: consistently treat someone as untrustworthy and they end up behaving that way. This effect sometimes works the other way round, however, especially for those who look cute. The Nobel prize-winning ethologist Konrad Lorenz once suggested that baby-faced features evoke a nurturing response. Support for this has come from work by Zebrowitz, who has found that baby-faced boys and men stimulate an emotional centre of the brain, the amygdala, in a similar way. But there’s a twist. Babyfaced men are, on average, better educated, more assertive and apt to win more military medals than their mature-looking counterparts. They are also more likely to be criminals; think Al Capone. Similarly, Zebrowitz found baby-faced boys to be quarrelsome and hostile, and more likely to be academic highfliers. She calls this the “self-defeating prophecy effect”: a man with a baby face strives to confound expectations and ends up overcompensating.

There is another theory that recalls the old parental warning not to pull faces because they might freeze that way. According to this theory, our personality moulds the way our faces look. It is supported by a study two decades ago which found that angry old people tend to look cross even when asked to strike a neutral expression. A lifetime of scowling, grumpiness and grimaces seemed to have left its mark.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('050fb500-f3e0-5866-bfa4-60a458f0b3ca', '39f75966-d29f-5e82-906c-8689799ecdd0', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT
GIVEN
if it is impossible to say that the writer thinks about this
1
Robert Fitzroy’s first impression of Darwin was accurate.
2
The precise rules of “physiognomy” have remained unchanged since the 18th century.
3
The first impression of a person can be modified later with little effort.
4
People who appear capable are more likely to be chosen to a position of power.
5
It is unfair for good-looking people to be better treated in society.

1 ____ Robert Fitzroy’s first impression of Darwin was accurate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d3a607a-cf02-59b3-a702-44b1df9e1744', '050fb500-f3e0-5866-bfa4-60a458f0b3ca', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ef7614d-51c7-52da-a090-3954c9818682', '050fb500-f3e0-5866-bfa4-60a458f0b3ca', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbadc34f-5aae-5897-8a7a-280619cc784c', '050fb500-f3e0-5866-bfa4-60a458f0b3ca', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('334567cb-831c-52df-9523-44d8009b4015', '39f75966-d29f-5e82-906c-8689799ecdd0', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT
GIVEN
if it is impossible to say that the writer thinks about this
1
Robert Fitzroy’s first impression of Darwin was accurate.
2
The precise rules of “physiognomy” have remained unchanged since the 18th century.
3
The first impression of a person can be modified later with little effort.
4
People who appear capable are more likely to be chosen to a position of power.
5
It is unfair for good-looking people to be better treated in society.

2 ____ The precise rules of “physiognomy” have remained unchanged since the 18th century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca07355e-4332-56b1-8091-b35a918494cd', '334567cb-831c-52df-9523-44d8009b4015', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38d5d742-ef29-528f-82d8-6fd8883c59c0', '334567cb-831c-52df-9523-44d8009b4015', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a82393b-42cc-5036-946f-89e5c5cd7b52', '334567cb-831c-52df-9523-44d8009b4015', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6332b278-c68e-599b-91ba-ad41c8bfd113', '39f75966-d29f-5e82-906c-8689799ecdd0', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT
GIVEN
if it is impossible to say that the writer thinks about this
1
Robert Fitzroy’s first impression of Darwin was accurate.
2
The precise rules of “physiognomy” have remained unchanged since the 18th century.
3
The first impression of a person can be modified later with little effort.
4
People who appear capable are more likely to be chosen to a position of power.
5
It is unfair for good-looking people to be better treated in society.

3 ____ The first impression of a person can be modified later with little effort.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('106728a2-fdeb-55cc-aec1-e372ebf85f07', '6332b278-c68e-599b-91ba-ad41c8bfd113', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42ec7196-fd2e-5b3d-a9aa-dd27edb41387', '6332b278-c68e-599b-91ba-ad41c8bfd113', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c625111-9922-51f8-94f5-d884379d48d7', '6332b278-c68e-599b-91ba-ad41c8bfd113', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d1cd37c-9a42-51e6-8d05-4b6628e36580', '39f75966-d29f-5e82-906c-8689799ecdd0', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT
GIVEN
if it is impossible to say that the writer thinks about this
1
Robert Fitzroy’s first impression of Darwin was accurate.
2
The precise rules of “physiognomy” have remained unchanged since the 18th century.
3
The first impression of a person can be modified later with little effort.
4
People who appear capable are more likely to be chosen to a position of power.
5
It is unfair for good-looking people to be better treated in society.

4 ____ People who appear capable are more likely to be chosen to a position of power.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac7b5dff-9078-537a-ae4a-6e7c0bef9a55', '5d1cd37c-9a42-51e6-8d05-4b6628e36580', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd9febff-0874-5930-af53-256bb18157da', '5d1cd37c-9a42-51e6-8d05-4b6628e36580', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f134863-ab30-564b-8ab5-b2ed1815f519', '5d1cd37c-9a42-51e6-8d05-4b6628e36580', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('549e51d5-5847-5013-860c-9a0166f6e17a', '39f75966-d29f-5e82-906c-8689799ecdd0', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT
GIVEN
if it is impossible to say that the writer thinks about this
1
Robert Fitzroy’s first impression of Darwin was accurate.
2
The precise rules of “physiognomy” have remained unchanged since the 18th century.
3
The first impression of a person can be modified later with little effort.
4
People who appear capable are more likely to be chosen to a position of power.
5
It is unfair for good-looking people to be better treated in society.

5 ____ It is unfair for good-looking people to be better treated in society.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f010f75-c690-54e0-b93b-ff41a05641a2', '549e51d5-5847-5013-860c-9a0166f6e17a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20ba8fbb-b885-59bb-91e4-e7d44c178242', '549e51d5-5847-5013-860c-9a0166f6e17a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa334b81-1dd1-5367-b136-542a4fabcbd4', '549e51d5-5847-5013-860c-9a0166f6e17a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d9fe31d-2dce-5b45-a9b9-32ed6fdc462d', '39f75966-d29f-5e82-906c-8689799ecdd0', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
6-10
on your answer sheet.
6.
What’s true about Anthony Little and David Perrett’s experiment?
A
It is based on the belief that none of the conclusions in the Michigan experiment is accurate.
B
It supports parts of the conclusions in the Michigan experiment.
C
It replicates the study conditions in the Michigan experiment.
D
It has a greater range of faces than in the Michigan experiment.
7.
What can be concluded from Justin Carre and Cheryl McCormick’s experiment?
A
A wide-faced man may be more aggressive.
B
Aggressive men have a wide range of facial features.
C
There is no relation between facial features and an aggressive character.
D
It’s necessary for people to be aggressive in competitive games.
8.
What’s exemplified by referring to butterfly marks?
A
Threats to safety are easy to notice.
B
Instinct does not necessarily lead to accurate judgment.
C
People should learn to distinguish between accountable and unaccountable judgments.
D
Different species have various ways to notice danger.
9.
What is the aim of Alexander Todorov’s study?
A
to determine the correlation between facial features and social development
B
to undermine the belief that appearance is important
C
to learn the influence of facial features on judgments of a person’s personality
D
to study the role of judgments in a person’s relationship
10.
Which of the following is the conclusion of Alexander Todorov’s study?
A
People should draw accurate judgments from overgeneralization.
B
Using appearance to determine a person’s character is undependable.
C
Overgeneralization can be misleading as a way to determine a person’s character.
D
The judgment of a person’s character based on appearance may be accurate.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0cc39053-f7a0-51bf-a6a8-ed2bbc72ecd7', '39f75966-d29f-5e82-906c-8689799ecdd0', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
6-10
on your answer sheet.
6.
What’s true about Anthony Little and David Perrett’s experiment?
A
It is based on the belief that none of the conclusions in the Michigan experiment is accurate.
B
It supports parts of the conclusions in the Michigan experiment.
C
It replicates the study conditions in the Michigan experiment.
D
It has a greater range of faces than in the Michigan experiment.
7.
What can be concluded from Justin Carre and Cheryl McCormick’s experiment?
A
A wide-faced man may be more aggressive.
B
Aggressive men have a wide range of facial features.
C
There is no relation between facial features and an aggressive character.
D
It’s necessary for people to be aggressive in competitive games.
8.
What’s exemplified by referring to butterfly marks?
A
Threats to safety are easy to notice.
B
Instinct does not necessarily lead to accurate judgment.
C
People should learn to distinguish between accountable and unaccountable judgments.
D
Different species have various ways to notice danger.
9.
What is the aim of Alexander Todorov’s study?
A
to determine the correlation between facial features and social development
B
to undermine the belief that appearance is important
C
to learn the influence of facial features on judgments of a person’s personality
D
to study the role of judgments in a person’s relationship
10.
Which of the following is the conclusion of Alexander Todorov’s study?
A
People should draw accurate judgments from overgeneralization.
B
Using appearance to determine a person’s character is undependable.
C
Overgeneralization can be misleading as a way to determine a person’s character.
D
The judgment of a person’s character based on appearance may be accurate.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25af9d8f-e1a6-52ba-83e4-33f802c73c11', '39f75966-d29f-5e82-906c-8689799ecdd0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
6-10
on your answer sheet.
6.
What’s true about Anthony Little and David Perrett’s experiment?
A
It is based on the belief that none of the conclusions in the Michigan experiment is accurate.
B
It supports parts of the conclusions in the Michigan experiment.
C
It replicates the study conditions in the Michigan experiment.
D
It has a greater range of faces than in the Michigan experiment.
7.
What can be concluded from Justin Carre and Cheryl McCormick’s experiment?
A
A wide-faced man may be more aggressive.
B
Aggressive men have a wide range of facial features.
C
There is no relation between facial features and an aggressive character.
D
It’s necessary for people to be aggressive in competitive games.
8.
What’s exemplified by referring to butterfly marks?
A
Threats to safety are easy to notice.
B
Instinct does not necessarily lead to accurate judgment.
C
People should learn to distinguish between accountable and unaccountable judgments.
D
Different species have various ways to notice danger.
9.
What is the aim of Alexander Todorov’s study?
A
to determine the correlation between facial features and social development
B
to undermine the belief that appearance is important
C
to learn the influence of facial features on judgments of a person’s personality
D
to study the role of judgments in a person’s relationship
10.
Which of the following is the conclusion of Alexander Todorov’s study?
A
People should draw accurate judgments from overgeneralization.
B
Using appearance to determine a person’s character is undependable.
C
Overgeneralization can be misleading as a way to determine a person’s character.
D
The judgment of a person’s character based on appearance may be accurate.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e9c9d2a8-b5cf-5b2e-ae9e-3a478b1191d2', '39f75966-d29f-5e82-906c-8689799ecdd0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
6-10
on your answer sheet.
6.
What’s true about Anthony Little and David Perrett’s experiment?
A
It is based on the belief that none of the conclusions in the Michigan experiment is accurate.
B
It supports parts of the conclusions in the Michigan experiment.
C
It replicates the study conditions in the Michigan experiment.
D
It has a greater range of faces than in the Michigan experiment.
7.
What can be concluded from Justin Carre and Cheryl McCormick’s experiment?
A
A wide-faced man may be more aggressive.
B
Aggressive men have a wide range of facial features.
C
There is no relation between facial features and an aggressive character.
D
It’s necessary for people to be aggressive in competitive games.
8.
What’s exemplified by referring to butterfly marks?
A
Threats to safety are easy to notice.
B
Instinct does not necessarily lead to accurate judgment.
C
People should learn to distinguish between accountable and unaccountable judgments.
D
Different species have various ways to notice danger.
9.
What is the aim of Alexander Todorov’s study?
A
to determine the correlation between facial features and social development
B
to undermine the belief that appearance is important
C
to learn the influence of facial features on judgments of a person’s personality
D
to study the role of judgments in a person’s relationship
10.
Which of the following is the conclusion of Alexander Todorov’s study?
A
People should draw accurate judgments from overgeneralization.
B
Using appearance to determine a person’s character is undependable.
C
Overgeneralization can be misleading as a way to determine a person’s character.
D
The judgment of a person’s character based on appearance may be accurate.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30518314-ef4b-516d-a8af-5de7fdc42805', '39f75966-d29f-5e82-906c-8689799ecdd0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
6-10
on your answer sheet.
6.
What’s true about Anthony Little and David Perrett’s experiment?
A
It is based on the belief that none of the conclusions in the Michigan experiment is accurate.
B
It supports parts of the conclusions in the Michigan experiment.
C
It replicates the study conditions in the Michigan experiment.
D
It has a greater range of faces than in the Michigan experiment.
7.
What can be concluded from Justin Carre and Cheryl McCormick’s experiment?
A
A wide-faced man may be more aggressive.
B
Aggressive men have a wide range of facial features.
C
There is no relation between facial features and an aggressive character.
D
It’s necessary for people to be aggressive in competitive games.
8.
What’s exemplified by referring to butterfly marks?
A
Threats to safety are easy to notice.
B
Instinct does not necessarily lead to accurate judgment.
C
People should learn to distinguish between accountable and unaccountable judgments.
D
Different species have various ways to notice danger.
9.
What is the aim of Alexander Todorov’s study?
A
to determine the correlation between facial features and social development
B
to undermine the belief that appearance is important
C
to learn the influence of facial features on judgments of a person’s personality
D
to study the role of judgments in a person’s relationship
10.
Which of the following is the conclusion of Alexander Todorov’s study?
A
People should draw accurate judgments from overgeneralization.
B
Using appearance to determine a person’s character is undependable.
C
Overgeneralization can be misleading as a way to determine a person’s character.
D
The judgment of a person’s character based on appearance may be accurate.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('74ec4ca7-eea0-52c3-a553-05711b118b55', '39f75966-d29f-5e82-906c-8689799ecdd0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
Perret believed people behaving dishonestly
12
The writer supports the view that people with babyish features
13
According to Zebrowitz, baby-faced people who behave dominantly
14
The writer believes facial features
A
judge other people by overgeneralization,
B
may influence the behaviour of other people,
C
tend to commit criminal acts.
D
may be influenced by the low expectations of other people.
E
may show the effect of long-term behaviours.
F
may be trying to repel the expectations of other people.

11 ____ Perret believed people behaving dishonestly$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6ac9ec2-4588-5a0d-9251-90b5c04581e9', '74ec4ca7-eea0-52c3-a553-05711b118b55', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60814b48-573b-5440-b1f1-577851cf707f', '74ec4ca7-eea0-52c3-a553-05711b118b55', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfea94a1-4597-5dc5-bc95-9afccf517d91', '74ec4ca7-eea0-52c3-a553-05711b118b55', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1d385f2-8b9f-5f19-88e2-d0857d39f6b5', '74ec4ca7-eea0-52c3-a553-05711b118b55', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0563cc5-00d1-5b66-932d-28ed72870212', '74ec4ca7-eea0-52c3-a553-05711b118b55', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('393b9c0b-85a4-538d-8e72-2a7b239e2673', '74ec4ca7-eea0-52c3-a553-05711b118b55', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6adba956-6441-53b0-ade6-8069a1df3981', '39f75966-d29f-5e82-906c-8689799ecdd0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
Perret believed people behaving dishonestly
12
The writer supports the view that people with babyish features
13
According to Zebrowitz, baby-faced people who behave dominantly
14
The writer believes facial features
A
judge other people by overgeneralization,
B
may influence the behaviour of other people,
C
tend to commit criminal acts.
D
may be influenced by the low expectations of other people.
E
may show the effect of long-term behaviours.
F
may be trying to repel the expectations of other people.

12 ____ The writer supports the view that people with babyish features$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a678a829-ca88-593a-91b6-a12e4415e85e', '6adba956-6441-53b0-ade6-8069a1df3981', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3efe9707-45c5-58d0-92f4-f57c9c766631', '6adba956-6441-53b0-ade6-8069a1df3981', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('323191c4-8f2c-5823-bfd3-384a5466cad0', '6adba956-6441-53b0-ade6-8069a1df3981', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('656b3264-7873-584b-bcd8-fe7d54a9a3d1', '6adba956-6441-53b0-ade6-8069a1df3981', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a29f4b56-5085-5c63-b366-a62312d6de4f', '6adba956-6441-53b0-ade6-8069a1df3981', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('154ba9e4-2704-50bc-95ff-ad49d2789bb3', '6adba956-6441-53b0-ade6-8069a1df3981', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c683634-6da6-5336-a5af-e55a8a983fba', '39f75966-d29f-5e82-906c-8689799ecdd0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
Perret believed people behaving dishonestly
12
The writer supports the view that people with babyish features
13
According to Zebrowitz, baby-faced people who behave dominantly
14
The writer believes facial features
A
judge other people by overgeneralization,
B
may influence the behaviour of other people,
C
tend to commit criminal acts.
D
may be influenced by the low expectations of other people.
E
may show the effect of long-term behaviours.
F
may be trying to repel the expectations of other people.

13 ____ According to Zebrowitz, baby-faced people who behave dominantly$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57fd9cc3-f66f-5d88-8e4b-e4360d650b28', '9c683634-6da6-5336-a5af-e55a8a983fba', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b46b3e4f-c351-5170-81bc-fe9583de93d5', '9c683634-6da6-5336-a5af-e55a8a983fba', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f620133c-ea18-5908-b35e-bf49ba0befeb', '9c683634-6da6-5336-a5af-e55a8a983fba', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d8f8ce9-4814-5414-8e98-f093e9e5873a', '9c683634-6da6-5336-a5af-e55a8a983fba', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9448c02-c97c-5338-b8da-1bdcacab8479', '9c683634-6da6-5336-a5af-e55a8a983fba', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2384a963-a898-5e36-9fc1-f24d1bcbda42', '9c683634-6da6-5336-a5af-e55a8a983fba', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d61a168-5622-57e5-bf6f-0be4413b74d2', '39f75966-d29f-5e82-906c-8689799ecdd0', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
Perret believed people behaving dishonestly
12
The writer supports the view that people with babyish features
13
According to Zebrowitz, baby-faced people who behave dominantly
14
The writer believes facial features
A
judge other people by overgeneralization,
B
may influence the behaviour of other people,
C
tend to commit criminal acts.
D
may be influenced by the low expectations of other people.
E
may show the effect of long-term behaviours.
F
may be trying to repel the expectations of other people.

14 ____ The writer believes facial features$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b637e77b-a84f-528b-aa5d-994871adf372', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03e545cd-4a72-5e3f-bcf9-c254c5e3e7b1', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97d0c607-815e-5e3f-9c88-8c254b513825', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9db46e0f-031b-5388-acce-983760f6bb4a', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0500719-bf2a-5d40-a3f9-aee4c79d2fa8', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7c27313-b94e-5e96-8661-7c2a7b35f2fc', '0d61a168-5622-57e5-bf6f-0be4413b74d2', 6, $md$F$md$, false);

COMMIT;
