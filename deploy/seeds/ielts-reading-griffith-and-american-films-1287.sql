BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-griffith-and-american-films-1287'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-griffith-and-american-films-1287';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-griffith-and-american-films-1287';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-griffith-and-american-films-1287';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4228dd89-8210-5454-8cc7-76378edf1f24', 'ielts-reading-griffith-and-american-films-1287', $t$Griffith and American Films$t$, $md$## Griffith and American Films

Nguồn:
- Test: https://mini-ielts.com/1287/reading/griffith-and-american-films
- Solution: https://mini-ielts.com/1287/view-solution/reading/griffith-and-american-films$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0776e225-fc98-5bd0-86d7-965900ee33ad', '4228dd89-8210-5454-8cc7-76378edf1f24', 1, $t$Reading — Griffith and American Films$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Griffith and American Films

Movies are key cultural artifacts that offer a window into American cultural and social history. A mixture of art, business, and popular entertainment, the movies provide a host of insights into Americans’ shifting ideals, fantasies, and preoccupations

A . Many films of the early silent era dealt with gender relations. Before 1905, as Kathy Peiss has argued, movie screens were filled with salacious sexual imagery and risque humor, drawn from burlesque halls and vaudeville theaters. Early films offered many glimpses of women disrobing or of passionate kisses. As the movies’ female audience grew, sexual titillation and voyeurism persisted. But an ever increasing number of film dealt with the changing work and sexual roles of women in a more sophisticated manner. While D.w. Griffith’s films presented an idealized picture of the frail Victorian child-woman, and showed an almost obsessive preoccupation with female honor and chastity, other silent movies presented quite different images of femininity. These ranged from the exotic, sexually aggressive vamp to the athletic, energetic “serial queen”; the street smart urban working gal, who repels the sexual advances of her lascivious boss; and cigarette-smoking, alcohol drinking chorus girls or burlesque queens.

B . In early 1910, director D.w. Griffith was sent by the Biograph Company to the west coast with his acting troupe, consisting of actors Blanche Sweet, Lillian Gish, Mary Pickford, Lionel Barrymore, and others. While there, the company decided to explore new territories, traveling several miles north to Hollywood, a little village that was friendly and enjoyed the movie company filming there. By focusing the camera on particular actors and actresses, Griffith inadvertently encouraged the development of the star system. As early as 1910, newspapers were deluged with requests for actors’ names. But most studios refused to divulge their identities, fearing the salary demands of popular performers. As one industry observer put it, “In the ‘star’ your producer gets not only a ‘production’ value…but a ‘trademark’ value, and an ‘insurance’ value which are…very potent in guaranteeing the sale of this product.” As the star system emerged, salaries soared. In the course of just two years, the salary of actress Mary Pickford rose from less than $400 a week in 1914 to $10,000 a week in 1916. This action made Griffith believe the big potential in movie industry. Thus many competitors completely copy the same system as Griffith used, for the considerable profits. Additionally, they also study the theory and methods which Griffith suggested.

C . From the moment America entered the war, Hollywood feared that the industry would be subject to heavy-handed government censorship. But the government itself wanted no repeat of World War I, when the Committee on Public Information had whipped up anti-German hysteria and oversold the war as “a Crusade not merely to re-win the tomb of Christ, but to bring back to earth the rule of right, the peace, goodwill to men and gentleness he taught.”

D . The formation of the movie trust ushered in a period of rationalization within the film industry. Camera and projecting equipment was standardized; film rental fees were fixed; theaters were upgraded; which improved the quality of movies by removing damaged prints from cnculation. This was also a period intense artistic and technical innovation, as pioneering directors like David Wark Griffith and others created a new language of film and revolutionized screen narrative.

E . With just six months of film experience, Griffith, a former stage actor, was hired as a director by the Biograph Company and promised $50 a week and one-twentieth of a cent for every foot of film sold to a rental exchange. Each week, Griffith turned out two or three one-reelers. While earlier directors had used such cinematic devices as close ups, slow motion, fade-ins and fade-outs, lighting effects, and editing before, Griffith’s great contribution to the movie industry was to show how these techniques could be used to create a wholly new style of storytelling, distinct from the theater. Griffith’s approach to movie storytelling has been aptly called “photographic realism. “This is not to say that he merely wished to record a story accurately; rather he sought to convey the illusion of realism. He demanded that his performers act less in a more lifelike manner, avoiding the broad, exaggerated gestures and pantomiming of emotions that characterized the nineteenth century stage. He wanted his performers to take on a role rather than directly addressing the camera. Above all, he used close-ups, lighting, editing, and other cinematic techniques convey suspense and other emotions and to focus the audience’s attention on individual performers.

F . During the 1920s and 1930s, a small group of film companies consolidated then control. Known as the “Big Five” – Paramount, Warner Brothers, RKO, 20th Century-Fox, and Lowe’s (MGM) and the “Little Three” – Universal, Columbia, and United Artists, they formed fully integrated companies. The old film company’s opposition was shocked by new tycoons. The confusion of tongues in the foreign version of American films deepened when American directors themselves embarked on the shooting of the new version. They did not usually speak Spanish (or the given target language) and, at that time, there were only few translators at the studio’s disposal. For this reason, it was more general to contract Spanish directors, actors, and screenwriters to produce American films in Spanish for Latin American audiences and for the public in the Iberian Peninsula. Hollywood had depended on overseas markets for as much as 40 percent of its revenue. But in an effort to nurture then own film industries and prevent an excessive outflow of dollars, Britain, France, and Italy imposed stiff import tariffs and restrictive quotas on imported American movies.

G . A basic problem facing today’s Hollywood is the rapidly rising cost of making and marketing a movie: an average of $40 million today. The immense cost of producing movies has led the studios to seek guaranteed hits: blockbuster loaded with high-tech special effects, sequels, and remakes of earlier movies, foreign films, and even old TV shows. Hollywood has also sought to cope with rising costs by focusing ever more intently on its core audiences. Since the mid-1980s, the movie going audience has continued to decrease in size. Ticket sales fell from 1.2 billion in 1983 to 950 million in 1992, with the biggest drop occurring among adults. And since over half of Hollywood’s profits are earned overseas, the target market has to be changed due to the increasing costs and salary of making a film. The industry has concentrated much of its energy on crude action films easily understood by an international audience, featuring stars like Arnold Schwarzenegger and Sylvester Stallone.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e4e1e46-4715-57db-a103-7a77c2a80068', '0776e225-fc98-5bd0-86d7-965900ee33ad', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48737d19-970c-5fd0-8d9a-bce5a9ff6efb', '6e4e1e46-4715-57db-a103-7a77c2a80068', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('460359e9-ac77-59ab-9727-bcd478147712', '6e4e1e46-4715-57db-a103-7a77c2a80068', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfc0f1bf-ef56-55fa-91c1-d95d4c90ca63', '6e4e1e46-4715-57db-a103-7a77c2a80068', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f46d01d7-6754-5b1d-a02d-f5e3e0fdd9a1', '6e4e1e46-4715-57db-a103-7a77c2a80068', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b880c22-23ea-5cd8-87ba-23a668cdc35a', '6e4e1e46-4715-57db-a103-7a77c2a80068', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe62211-440d-57d6-863f-c8bf9df9b193', '6e4e1e46-4715-57db-a103-7a77c2a80068', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab115479-1ce8-5483-a7a6-16c6f69f2824', '6e4e1e46-4715-57db-a103-7a77c2a80068', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('419efd87-6b2d-5138-8150-5e7e15b13e1f', '0776e225-fc98-5bd0-86d7-965900ee33ad', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40ff8f5f-e10a-5855-9408-660c06c9b4be', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0305246-d83e-553c-a52f-5a34e077465e', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8a710b4-752a-5298-b5fd-a18836e60443', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36224404-9394-5cea-a332-3b9de5cecb68', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb236745-ab20-5c09-9810-f7e2f54adbcd', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebbb77d7-1c73-5b82-9604-8833ff1bbc69', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('531ef40e-093b-57ff-a3bd-7f43466cb3b7', '419efd87-6b2d-5138-8150-5e7e15b13e1f', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ca07e318-5801-59e3-aede-8e85d8d906ae', '0776e225-fc98-5bd0-86d7-965900ee33ad', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e302ca70-dd3d-528d-b053-cbc7d48292f6', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6f5ef0f-f5bb-5c74-8b11-a8d5be719514', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbc1f1c6-20c3-5326-a61d-721fb6fb3de9', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b400d8c-8f1a-5b93-8b25-d0f3cf69f3a6', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca54d8b1-43c0-5652-bc0a-6783f98e5e9b', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3398b42b-570a-582d-b0e6-7c601e351c46', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a460462-42ec-52e0-97cc-d642da7e975d', 'ca07e318-5801-59e3-aede-8e85d8d906ae', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba5a269e-ffb6-548d-8197-6182a913e888', '0776e225-fc98-5bd0-86d7-965900ee33ad', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2ef0d46-d580-5d4e-bc01-44bc7d6d8dc8', 'ba5a269e-ffb6-548d-8197-6182a913e888', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4288c535-e8e2-581b-bce7-40a098ada5e2', 'ba5a269e-ffb6-548d-8197-6182a913e888', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa53d585-ebea-5f56-a3cc-946311771083', 'ba5a269e-ffb6-548d-8197-6182a913e888', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4d3e13d-f21c-5a57-a77b-ab6888befd4c', 'ba5a269e-ffb6-548d-8197-6182a913e888', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8f8449b-e3f9-5954-be58-34e43939f1a9', 'ba5a269e-ffb6-548d-8197-6182a913e888', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6bfa6e2-41b7-5ce4-83b7-11abe141e7ea', 'ba5a269e-ffb6-548d-8197-6182a913e888', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('668ecfa9-da74-56e0-8db3-f5e1a96084bf', 'ba5a269e-ffb6-548d-8197-6182a913e888', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85141dd1-5894-5807-accb-fd0fa3dedc6e', '0776e225-fc98-5bd0-86d7-965900ee33ad', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea001963-3e80-585e-a5a2-60c7845321b0', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7e56654-d0db-58b5-8820-795e6866676b', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4d8f459-02e8-54cf-b149-fa080edd6685', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a822b6e4-5cd7-581a-9fe1-1782cc9858ff', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c17bfd1-e1b0-5bee-865c-de90b7704a45', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6a01b8a-7b65-571f-9fc8-d15dfa8e44e4', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54928c02-2dcb-585f-a0b3-d3a47b309a0c', '85141dd1-5894-5807-accb-fd0fa3dedc6e', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b63d3f02-484e-570a-905b-79cc4fc9f72b', '0776e225-fc98-5bd0-86d7-965900ee33ad', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below. Write the correct number, i-vii, in boxes 1-6 on your answer sheet.
List of Headings
i
. Detailed description for film system
ii
. Griffith’s contribution to American films
iii
. The gender in development of American film
iv
. Change the view of the American movie
V
. People’s reaction to making movies in the war period
vi.
The increasing market of film in society
vii.
Griffith improved the gender recognition in society
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24287e7c-3a81-5022-81cc-299081f71ac2', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f3d1c19-d7bd-58c2-9cab-81dc5e37039d', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('456f91b6-0302-5351-87b3-e06b09d5238b', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01d62913-183a-51ca-9b1c-e58bfa961080', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b1118e6-ef04-5824-b0e1-465f2ee9df1c', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f11ab325-b197-54f9-9f78-c9e32e8e375b', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0eff8c0-56b2-58e5-aee9-38db933da6ae', 'b63d3f02-484e-570a-905b-79cc4fc9f72b', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7e7854a6-1bcf-5779-b2fb-9a87fb613121', '0776e225-fc98-5bd0-86d7-965900ee33ad', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Use the information in the passage to match the companies (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A, B, C or D
in boxes
7-10
on your answer sheet
A
. old company’s opposition
B
. huge drop happens among adults
C
. the pressure to change its market
D
. completely copy his system
7
Griffith’s successful in 1910s, led his rivals
8
The growing costs and salary in Hollywood which shows it has
9
The increasing new movie industries have a big impact on
10
In 1992, ticket sales declined dramatically, due to

7 ____ Griffith’s successful in 1910s, led his rivals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42709589-8149-5ab7-bc30-361d02445eee', '7e7854a6-1bcf-5779-b2fb-9a87fb613121', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98881632-f774-5ecb-913d-f33493ad779f', '7e7854a6-1bcf-5779-b2fb-9a87fb613121', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5cca15d-3ad3-51bf-aa38-a3589e933d96', '7e7854a6-1bcf-5779-b2fb-9a87fb613121', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1aadaa5-b896-5841-b083-65a3eee16396', '7e7854a6-1bcf-5779-b2fb-9a87fb613121', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0978ed3a-e107-50e9-8c77-55e71adaba39', '0776e225-fc98-5bd0-86d7-965900ee33ad', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Use the information in the passage to match the companies (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A, B, C or D
in boxes
7-10
on your answer sheet
A
. old company’s opposition
B
. huge drop happens among adults
C
. the pressure to change its market
D
. completely copy his system
7
Griffith’s successful in 1910s, led his rivals
8
The growing costs and salary in Hollywood which shows it has
9
The increasing new movie industries have a big impact on
10
In 1992, ticket sales declined dramatically, due to

8 ____ The growing costs and salary in Hollywood which shows it has$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05a6bf2b-d2c9-562a-8936-e52916dc0918', '0978ed3a-e107-50e9-8c77-55e71adaba39', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9978a295-3ba9-598f-b610-b94d3d0fde89', '0978ed3a-e107-50e9-8c77-55e71adaba39', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30fbebd5-046a-5d1d-a443-86a04cbc1de8', '0978ed3a-e107-50e9-8c77-55e71adaba39', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('333ca50a-d9b4-596b-923f-d3f7be4559ce', '0978ed3a-e107-50e9-8c77-55e71adaba39', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b528444-1e93-5912-b637-a6a03b454886', '0776e225-fc98-5bd0-86d7-965900ee33ad', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Use the information in the passage to match the companies (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A, B, C or D
in boxes
7-10
on your answer sheet
A
. old company’s opposition
B
. huge drop happens among adults
C
. the pressure to change its market
D
. completely copy his system
7
Griffith’s successful in 1910s, led his rivals
8
The growing costs and salary in Hollywood which shows it has
9
The increasing new movie industries have a big impact on
10
In 1992, ticket sales declined dramatically, due to

9 ____ The increasing new movie industries have a big impact on$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08cace44-4dbb-5d8f-93ea-c3acb7176233', '2b528444-1e93-5912-b637-a6a03b454886', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf2c2c9-6b6d-5216-b641-433a7133dba2', '2b528444-1e93-5912-b637-a6a03b454886', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d33df6e-6cc0-5509-b79b-5ef1375613c3', '2b528444-1e93-5912-b637-a6a03b454886', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8fccd66-5b51-5d34-9ce3-f7c1c96615e6', '2b528444-1e93-5912-b637-a6a03b454886', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ca97a969-bde4-54f3-b4e6-561061b896bf', '0776e225-fc98-5bd0-86d7-965900ee33ad', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Use the information in the passage to match the companies (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A, B, C or D
in boxes
7-10
on your answer sheet
A
. old company’s opposition
B
. huge drop happens among adults
C
. the pressure to change its market
D
. completely copy his system
7
Griffith’s successful in 1910s, led his rivals
8
The growing costs and salary in Hollywood which shows it has
9
The increasing new movie industries have a big impact on
10
In 1992, ticket sales declined dramatically, due to

10 ____ In 1992, ticket sales declined dramatically, due to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04763e34-8e9c-5518-a599-e82bcf04f452', 'ca97a969-bde4-54f3-b4e6-561061b896bf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ae4463f-2319-58f8-87df-1e205f3dbf3e', 'ca97a969-bde4-54f3-b4e6-561061b896bf', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72f72960-4c3a-5512-9aea-a78ee4447fad', 'ca97a969-bde4-54f3-b4e6-561061b896bf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5152f632-7ad7-5600-bdf1-065166873524', 'ca97a969-bde4-54f3-b4e6-561061b896bf', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ba467a9-2b23-5a29-8c24-5877f2789ce3', '0776e225-fc98-5bd0-86d7-965900ee33ad', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose the correct letter.
A, B, C or D
. Write your answer in boxes
11-13
on your answer sheet
11. Why Griffith believe the potential in making movies?
A
The gender development in American films
B
He used the star system successfully
C
He prefer the advanced movie techniques
D
He earns lots of money
12. What are other competitors’ reaction to Griffith?
A
Adopt Griffith’s theory and methods in making films
B
Completely copy his theory and methods
C
Try to catch up their innovations
D
Find a new system to against Griffith
13. What is the great change in films industries during 1920s and 1930s?
A
Try to seek the high-tech special efforts
B
Dismiss the needs of overseas audiences
C
Changed its goal market
D
Improved the foreign version of American movies

Choose the correct letter. A, B, C or D . Write your answer in boxes 11-13 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4494f4f6-e85f-5249-bd83-a03fcd03ce61', '0776e225-fc98-5bd0-86d7-965900ee33ad', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose the correct letter.
A, B, C or D
. Write your answer in boxes
11-13
on your answer sheet
11. Why Griffith believe the potential in making movies?
A
The gender development in American films
B
He used the star system successfully
C
He prefer the advanced movie techniques
D
He earns lots of money
12. What are other competitors’ reaction to Griffith?
A
Adopt Griffith’s theory and methods in making films
B
Completely copy his theory and methods
C
Try to catch up their innovations
D
Find a new system to against Griffith
13. What is the great change in films industries during 1920s and 1930s?
A
Try to seek the high-tech special efforts
B
Dismiss the needs of overseas audiences
C
Changed its goal market
D
Improved the foreign version of American movies

Choose the correct letter. A, B, C or D . Write your answer in boxes 11-13 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28de021d-c5c6-5ec9-80c0-63a3345bb566', '0776e225-fc98-5bd0-86d7-965900ee33ad', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose the correct letter.
A, B, C or D
. Write your answer in boxes
11-13
on your answer sheet
11. Why Griffith believe the potential in making movies?
A
The gender development in American films
B
He used the star system successfully
C
He prefer the advanced movie techniques
D
He earns lots of money
12. What are other competitors’ reaction to Griffith?
A
Adopt Griffith’s theory and methods in making films
B
Completely copy his theory and methods
C
Try to catch up their innovations
D
Find a new system to against Griffith
13. What is the great change in films industries during 1920s and 1930s?
A
Try to seek the high-tech special efforts
B
Dismiss the needs of overseas audiences
C
Changed its goal market
D
Improved the foreign version of American movies

Choose the correct letter. A, B, C or D . Write your answer in boxes 11-13 on your answer sheet$md$, NULL);

COMMIT;
