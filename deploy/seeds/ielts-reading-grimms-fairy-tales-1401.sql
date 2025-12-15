BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-grimms-fairy-tales-1401'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-grimms-fairy-tales-1401';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-grimms-fairy-tales-1401';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-grimms-fairy-tales-1401';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('648e5f34-ad04-5727-855f-1d25f68aa1f6', 'ielts-reading-grimms-fairy-tales-1401', $t$Grimm’s Fairy Tales$t$, $md$## Grimm’s Fairy Tales

Nguồn:
- Test: https://mini-ielts.com/1401/reading/grimms-fairy-tales
- Solution: https://mini-ielts.com/1401/view-solution/reading/grimms-fairy-tales$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b0b083b2-d6f4-569f-86d6-bda58c8bc19f', '648e5f34-ad04-5727-855f-1d25f68aa1f6', 1, $t$Reading — Grimm’s Fairy Tales$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Grimm’s Fairy Tales

The Brothers Grimm, Jacob and Wilhelm, named their story collection Children’s and Household Tales and published the first of its seven editions in Germany in 1812. The table of contents reads like an A-list of fairy-tale celebrities: Cinderella, Sleeping Beauty, Snow White, Little Red Riding Hood, Rapunzel, Rumpelstiltskin, Hansel and Gretel, the Frog King. Drawn mostly from oral narratives, the 210 stories in die Grimm’s’ collection represent an anthology of fairy tales, animal fables, rustic farces, and religious allegories that remain unrivalled to this day.

Such lasting fame would have shocked the humble Grimms. During their lifetimes the collection sold modestly in Germany, at first only a few hundred copies a year. The early editions were not even aimed at children. The brothers initially refused to consider illustrations, and scholarly footnotes took up almost as much space as the tales themselves. Jacob and Wilhelm viewed themselves as patriotic folklorists, not as entertainers of children. They began their work at a time when Germany had been overrun by the French under Napoleon, who was intent on suppressing local culture. As young, workaholic scholars, single and sharing a cramped flat, the Brothers Grimm undertook the fairy-tale collection with the goal of serving the endangered oral tradition of Germany.

For much of the 19th century teachers, parents, and religious figures, particularly in the United States, deplored the Grimms’ collection for its raw, uncivilized content. Offended adults objected to the gruesome punishments inflicted on the stories’ villains. In the original “Snow White” the evil stepmother is forced to dance in red-hot iron shoes until she falls down dead. Even today some protective parents shy from the Grimms’ tales because of their reputation for violence.

Despite its sometimes rocky reception, Children’s and Household Tales gradually took root with the public. The brothers had not foreseen that the appearance of their work would coincide with a great flowering of children’s literature in Europe. English publishers led the way, issuing high-quality picture books such as Jack and the Beanstalk and handsome folktale collections, all to satisfy a newly literate audience seeking virtuous material for the nursery. Once the Brothers Grimm sighted this new public, they set about refining and softening their tales, which had originated centuries earlier as earthy peasant fare. In the Grimms’ hands, cruel mothers became nasty stepmothers, unmarried lovers were made chaste, and the incestuous father was recast as the devil.

In the 20th century the Grimms’ fairy tales have come to rule the bookshelves of children’s bedrooms. The stories read like dreams come true: handsome lads and beautiful damsels, armed with magic, triumph over giants and witches and wild beasts. They outwit mean, selfish adults. Inevitably the boy and girl fall in love and live happily ever after. And parents keep reading because they approve of the finger-wagging lessons inserted into the stories: keep your promises, don’t talk to strangers, work hard, obey your parents. According to the Grimms, the collection served as “a manual of manners”.

Altogether some 40 persons delivered tales to the Grimms. Many of the storytellers came to the Grimms’ house in Kassel. The brothers particularly welcomed the visits of Dorothea Viehmann, a widow who walked to town to sell produce from her garden. An innkeeper daughter, Viehmann had grown up listening to stories from travellers on the road to Frankfurt. Among her treasure was “Aschenputtel” -Cinderella. Marie Hassenpflug was a 20-year-old friend of their sister, Charlotte, from a well-bred, French-speaking family. Marie’s wonderful stories blended motifs from the oral tradition and from Perrault’s influential 1697 book, Tales of My Mother Goose, which contained elaborate versions of “Little Red Riding Hood”, “Snow White”, and “Sleeping Beauty”, among others. Many of these had been adapted from earlier Italian tales.

Given that the origins of many of the Grimm fairy tales reach throughout Europe and into the Middle East and Orient, the question must be asked: How German are the Grimm tales? Very, says scholar Heinz Rolleke. Love of the underdog, rustic simplicity, creative energy—these are Teutonic traits. The coarse texture of life during medieval times in Germany, when many of the tales entered the oral tradition, also coloured the narratives. Throughout Europe, children were often neglected and abandoned, like Hansel and Gretel. Accused witches were burned at the stake, like the evil mother-in-law in “The Six Swans”. “The cruelty in the stories was not the Grimm’s fantasy”, Rolleke points out” It reflected the law-and-order system of the old times”.

The editorial fingerprints left by the Grimms betray the specific values of 19th-century Christian, bourgeois German society. But that has not stopped the tales from being embraced by almost every culture and nationality in the world. What accounts for this widespread, enduring popularity? Bernhard Lauer points to the “universal style” of the writing, you have no concrete descriptions of the land, or the clothes, or the forest, or the castles. It makes the stories timeless and placeless,” The tales allow us to express ‘our utopian longings’,” says Jack Zipes of the University of Minnesota, whose 1987 translation of the complete fairy tales captures the rustic vigour of the original text. They show a striving for happiness that none of us knows but that we sense is possible. We can identify with the heroes of the tales and become in our mind the masters and mistresses of our own destinies.”

Fairy tales provide a workout for the unconscious, psychoanalysts maintain. Bruno Bettelheim famously promoted the therapeutic of the Grimms’ stories, calling fairy tales the “great comforters. By confronting fears and phobias, symbolized by witches, heartless stepmothers, and hungry wolves, children find they can master their anxieties. Bettelheim’s theory continues to be hotly debated. But most young readers aren’t interested in exercising their unconsciousness. The Grimm tales, in fact, please in an infinite number of ways, something about them seems to mirror whatever moods or interests we bring to our reading of them. The flexibility of interpretation suits them for almost any time and any culture.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('74c2e7cc-a3a6-51de-81a4-8b87692de935', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

1 ____ The Grimm brothers believed they would achieve international fame.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('474497c9-0288-5d71-aff0-148b16ffae45', '74c2e7cc-a3a6-51de-81a4-8b87692de935', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76a879ee-af3e-5cd0-9d01-b97be652a4f6', '74c2e7cc-a3a6-51de-81a4-8b87692de935', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f3908ba-dda5-5f55-83a2-02cd673cf338', '74c2e7cc-a3a6-51de-81a4-8b87692de935', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0e7fa0a5-8c92-572b-a179-e3e12d456d2f', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

2 ____ The Grimm brothers were forced to work in secret.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b2ba531-8627-5987-bdc2-5eb56ff28b2f', '0e7fa0a5-8c92-572b-a179-e3e12d456d2f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c474b08-0bbd-5f2f-bcaa-ba0690beb03c', '0e7fa0a5-8c92-572b-a179-e3e12d456d2f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc25e8e6-5e5f-5bf0-a180-d1e3cff27a25', '0e7fa0a5-8c92-572b-a179-e3e12d456d2f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52e79aee-9b61-5c33-8f80-037e77bb0eea', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

3 ____ Some parents today still think Grimm fairy tales are not suitable for children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6db16234-c668-5530-ace7-97665f0fdcdc', '52e79aee-9b61-5c33-8f80-037e77bb0eea', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da1aaee3-a3b6-57f8-a576-dd5167218d9d', '52e79aee-9b61-5c33-8f80-037e77bb0eea', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c70b9e3a-6263-548f-9c2d-3920ed31deea', '52e79aee-9b61-5c33-8f80-037e77bb0eea', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40b84a17-ab7b-5b14-ac89-bbf7abd7c622', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

4 ____ The first edition of Grimm’s fairy tales sold more widely in England than in Germany.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eeac21e-5645-5dca-8180-05e35165d6b2', '40b84a17-ab7b-5b14-ac89-bbf7abd7c622', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('970025ad-b53e-53dc-b3f7-4b159c9f35ed', '40b84a17-ab7b-5b14-ac89-bbf7abd7c622', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c3d0cd5-1f8a-57d7-8676-1d30048845aa', '40b84a17-ab7b-5b14-ac89-bbf7abd7c622', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e22722f-013a-56ea-83c5-9ae61a14e5ea', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

5 ____ Adults like reading Grimm’s fairy tales for reasons different from those of children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcd8aff3-8fe8-52c6-8c23-cba668370ac0', '1e22722f-013a-56ea-83c5-9ae61a14e5ea', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93bdb961-ab20-5b41-8828-2440315f06c5', '1e22722f-013a-56ea-83c5-9ae61a14e5ea', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e9f8a51-c90f-5bb7-a5df-1f49564013b2', '1e22722f-013a-56ea-83c5-9ae61a14e5ea', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da083161-de05-52ff-8037-e585b03f65ee', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The Grimm brothers believed they would achieve international fame.
2
The Grimm brothers were forced to work in secret.
3
Some parents today still think Grimm fairy tales are not suitable for children.
4
The first edition of Grimm’s fairy tales sold more widely in England than in Germany.
5
Adults like reading Grimm’s fairy tales for reasons different from those of children.
6
The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann

6 ____ The Grimm brothers based the story “Cinderella” on the life of Dorothea Viehmann$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dfad605-55d8-5231-be12-c95d352d8d36', 'da083161-de05-52ff-8037-e585b03f65ee', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b947a723-bd70-5cec-a6a0-a4d4f507e8ff', 'da083161-de05-52ff-8037-e585b03f65ee', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80956b92-a6d3-5a38-8cf2-851b1050ec7d', 'da083161-de05-52ff-8037-e585b03f65ee', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77a49e21-67a9-511d-9f72-d8e485bd46e4', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7.
In paragraph 4, what changes happened at that time in Europe?
A
Literacy levels of the population increased.
B
The development of printing technology made it easier to publish.
C
Schools were open to children.
D
People were fond of collecting superb picture books.
8.
What changes did the Grimm Brothers make in later editions?
A
They made the stories shorter.
B
They used more oral language.
C
The content of the tales became less violent.
D
They found other origins of the tales.
9.
What did Marie Hassenpflug contribute to the Grimm’s Fairy tales?
A
She wrote stories.
B
She discussed the stories with them.
C
She translated a popular book for the brothers using her talent for languages.
D
She told the oral stories that were based on traditional Italian stories.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c844fe5-f784-50e6-8fc0-073c7321ceaa', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7.
In paragraph 4, what changes happened at that time in Europe?
A
Literacy levels of the population increased.
B
The development of printing technology made it easier to publish.
C
Schools were open to children.
D
People were fond of collecting superb picture books.
8.
What changes did the Grimm Brothers make in later editions?
A
They made the stories shorter.
B
They used more oral language.
C
The content of the tales became less violent.
D
They found other origins of the tales.
9.
What did Marie Hassenpflug contribute to the Grimm’s Fairy tales?
A
She wrote stories.
B
She discussed the stories with them.
C
She translated a popular book for the brothers using her talent for languages.
D
She told the oral stories that were based on traditional Italian stories.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27d1352f-4076-569a-906b-936027ddc4f9', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7.
In paragraph 4, what changes happened at that time in Europe?
A
Literacy levels of the population increased.
B
The development of printing technology made it easier to publish.
C
Schools were open to children.
D
People were fond of collecting superb picture books.
8.
What changes did the Grimm Brothers make in later editions?
A
They made the stories shorter.
B
They used more oral language.
C
The content of the tales became less violent.
D
They found other origins of the tales.
9.
What did Marie Hassenpflug contribute to the Grimm’s Fairy tales?
A
She wrote stories.
B
She discussed the stories with them.
C
She translated a popular book for the brothers using her talent for languages.
D
She told the oral stories that were based on traditional Italian stories.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ecabb33c-bc59-56aa-ac40-ba256a02e859', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Write the correct letter,
A-H
, in boxes
10-14
on your answer sheet.
10
Heinz Rolleke said the Grimm’s tales are “German” because the tales
11
Heinz Rolleke said the abandoned children in tales
12
Bernhard Lauer said the writing style of the Grimm brothers is universal because they
13
Jack Zipes said the pursuit of happiness in the tales means they
14
Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales
A
reflect what life was like at that time
B
help children deal with their problems
C
demonstrate the outdated system
D
tell of the simplicity of life in the German countryside
E
encourage people to believe that they can do anything
F
recognize the heroes in the real life
G
contribute to the belief in nature power
H
avoid details about characters’ social settings.

10 ____ Heinz Rolleke said the Grimm’s tales are “German” because the tales$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56ede86c-10ec-50a1-88ec-9c3b79d1183f', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9065887-3fa0-5599-b27b-c6b7f993f122', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67414d7f-6e4c-5f28-a345-182ee3caacf6', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f1ab185-62ec-577a-8b31-c37aae3fcae8', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16085859-7b07-550f-b924-47bdeb02a751', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65d24ab4-9556-5a9a-bd4d-a24566b6ad9e', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13e3e38f-13cf-58ef-aee1-872c7853fe48', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a95537b3-6b88-52e0-a506-01331964c55f', 'ecabb33c-bc59-56aa-ac40-ba256a02e859', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Write the correct letter,
A-H
, in boxes
10-14
on your answer sheet.
10
Heinz Rolleke said the Grimm’s tales are “German” because the tales
11
Heinz Rolleke said the abandoned children in tales
12
Bernhard Lauer said the writing style of the Grimm brothers is universal because they
13
Jack Zipes said the pursuit of happiness in the tales means they
14
Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales
A
reflect what life was like at that time
B
help children deal with their problems
C
demonstrate the outdated system
D
tell of the simplicity of life in the German countryside
E
encourage people to believe that they can do anything
F
recognize the heroes in the real life
G
contribute to the belief in nature power
H
avoid details about characters’ social settings.

11 ____ Heinz Rolleke said the abandoned children in tales$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('083a5382-dd9e-5ee8-9299-b28c822c3589', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c58e09e-46af-5168-88dc-4a85521cd86e', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53ea64c3-f841-5d21-8de7-96aa5f2b6f39', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ed1f37d-186f-566c-9e6c-b4983b4834c8', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1bc6b64-7f87-5758-93c2-f723be8163df', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37b5091f-cf42-5410-9472-b275e76b4da9', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3278a177-e183-5885-a641-399cb400d260', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4bb01f4-e8c7-5f0a-88be-30971b6fa827', 'dfb1b582-bc5d-5ce7-a017-208e476a0d7a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d806b872-be30-578a-bc6c-725c0fdce39d', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Write the correct letter,
A-H
, in boxes
10-14
on your answer sheet.
10
Heinz Rolleke said the Grimm’s tales are “German” because the tales
11
Heinz Rolleke said the abandoned children in tales
12
Bernhard Lauer said the writing style of the Grimm brothers is universal because they
13
Jack Zipes said the pursuit of happiness in the tales means they
14
Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales
A
reflect what life was like at that time
B
help children deal with their problems
C
demonstrate the outdated system
D
tell of the simplicity of life in the German countryside
E
encourage people to believe that they can do anything
F
recognize the heroes in the real life
G
contribute to the belief in nature power
H
avoid details about characters’ social settings.

12 ____ Bernhard Lauer said the writing style of the Grimm brothers is universal because they$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('326b7b9d-cb85-57d2-b805-45d53f41bb10', 'd806b872-be30-578a-bc6c-725c0fdce39d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00df2556-c395-5f98-8694-039feb6468b3', 'd806b872-be30-578a-bc6c-725c0fdce39d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('861245dd-f8ca-5730-814a-6452b0054a6f', 'd806b872-be30-578a-bc6c-725c0fdce39d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06383fe4-e7cd-57b5-a259-7f4ea181b394', 'd806b872-be30-578a-bc6c-725c0fdce39d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4932fcf5-430e-5aba-a5b3-a24fedbfd784', 'd806b872-be30-578a-bc6c-725c0fdce39d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93bb8063-f077-5d16-aae5-80eb8cf22ac3', 'd806b872-be30-578a-bc6c-725c0fdce39d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61f8064b-9fa0-5786-951d-a3a4b2cfa796', 'd806b872-be30-578a-bc6c-725c0fdce39d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1df0452d-4e40-59d7-8d5c-be4782226728', 'd806b872-be30-578a-bc6c-725c0fdce39d', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Write the correct letter,
A-H
, in boxes
10-14
on your answer sheet.
10
Heinz Rolleke said the Grimm’s tales are “German” because the tales
11
Heinz Rolleke said the abandoned children in tales
12
Bernhard Lauer said the writing style of the Grimm brothers is universal because they
13
Jack Zipes said the pursuit of happiness in the tales means they
14
Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales
A
reflect what life was like at that time
B
help children deal with their problems
C
demonstrate the outdated system
D
tell of the simplicity of life in the German countryside
E
encourage people to believe that they can do anything
F
recognize the heroes in the real life
G
contribute to the belief in nature power
H
avoid details about characters’ social settings.

13 ____ Jack Zipes said the pursuit of happiness in the tales means they$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5db7e02-ee65-505a-a0aa-582edbf4cda8', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39b48a0b-5d27-568b-b1ac-27d4d8d6af1a', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2076cb2b-9abc-5b73-a491-34149860d7fa', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1243fa9e-03be-51fe-9fca-7833b4b04764', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1947df9-3a78-533e-a551-868aa6aa2b61', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8d4ba47-02ac-51d3-8834-f7316d47bc47', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ee309f5-cc6c-5f7b-9837-28fc52c6d1db', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba8ada4c-6840-5d62-9572-94b4e28bf244', 'dd5e206d-06e4-5047-8d58-7ac6252bbd4b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53b62ee5-460f-542c-b8ca-8de55d6a5523', 'b0b083b2-d6f4-569f-86d6-bda58c8bc19f', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Write the correct letter,
A-H
, in boxes
10-14
on your answer sheet.
10
Heinz Rolleke said the Grimm’s tales are “German” because the tales
11
Heinz Rolleke said the abandoned children in tales
12
Bernhard Lauer said the writing style of the Grimm brothers is universal because they
13
Jack Zipes said the pursuit of happiness in the tales means they
14
Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales
A
reflect what life was like at that time
B
help children deal with their problems
C
demonstrate the outdated system
D
tell of the simplicity of life in the German countryside
E
encourage people to believe that they can do anything
F
recognize the heroes in the real life
G
contribute to the belief in nature power
H
avoid details about characters’ social settings.

14 ____ Bruno Bettelheim said the therapeutic value of the tales means that the fairy tales$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('846b4d0a-bc1d-5243-9b12-9e4e90e731b7', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2079bad8-e0ec-5160-9b94-35682349c204', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d7e57c7-ae4c-564a-964a-7cfaad414934', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0302aca6-e8f8-5b00-b32d-3d8659ec69fa', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80280c4e-f6a7-5a9b-b486-0a53bbf13fbf', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49e8329e-2048-5c67-88ef-562e2063c4d1', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2808334b-4421-5a39-b93a-55b6be18b9c8', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('651d96b0-1b6b-5ac4-a4ef-db8df416f4d3', '53b62ee5-460f-542c-b8ca-8de55d6a5523', 8, $md$H$md$, false);

COMMIT;
