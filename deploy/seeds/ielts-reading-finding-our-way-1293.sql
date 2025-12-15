BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-finding-our-way-1293'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-finding-our-way-1293';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-finding-our-way-1293';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-finding-our-way-1293';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1244937b-ade3-55bc-b3c5-0fe57c22a708', 'ielts-reading-finding-our-way-1293', $t$Finding our way$t$, $md$## Finding our way

Nguồn:
- Test: https://mini-ielts.com/1293/reading/finding-our-way
- Solution: https://mini-ielts.com/1293/view-solution/reading/finding-our-way$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e46caa82-d57e-57cf-99a3-2275babae4b4', '1244937b-ade3-55bc-b3c5-0fe57c22a708', 1, $t$Reading — Finding our way$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Finding our way

A . “Drive 200 yards, and then turn right,” says the car’s computer voice. You relax in the driver’s seat, follow the directions and reach your destination without error. It’s certainly nice to have the Global Positioning System (GPS) to direct you to within a few yards of your goal. Yet if the satellite service’s digital maps become even slightly outdated, you can become lost. Then you have to rely on the ancient human skill of navigating in three-dimensional space. Luckily, your biological finder has an important advantage over GPS: it does not go awry if only one part of the guidance system goes wrong, because it works in various ways. You can ask questions of people on the sidewalk. Or follow a street that looks familiar. Or rely on a navigational rubric: “If I keep the East River on my left, I will eventually cross 34th Street.” The human positioning system is flexible and capable of learning. Anyone who knows the way from point A to point B—and from A to C—can probably figure out how to get from B to c, too.

B . But how does this complex cognitive system really work? Researchers are looking at several strategies people use to orient themselves in space: guidance, path integration and route following. We may use all three or combinations thereof. And as experts learn more about these navigational skills, they are making the case that our abilities may underlie our powers of memory and logical thinking. Grand Central, Please Imagine that you have arrived in a place you have never visited-New York City. You get off the train at Grand Central Terminal in midtown Manhattan. You have a few hours to explore before you must return for your ride home. You head uptown to see popular spots you have been told about: Rockefeller Center, Central Park, the Metropolitan Museum of Art. You meander in and out of shops along the way. Suddenly, it is time to get back to the station. But how?

C . If you ask passersby for help, most likely you will receive information in many different forms. A person who orients herself by a prominent landmark would gesture southward: “Look down there. See the tall, broad MetLife Building? Head for that “the station is right below it.” Neurologists call this navigational approach “guidance,” meaning that a landmark visible from a distance serves as the marker for one’s destination.

D . Another city dweller might say: “What places do you remember passing? … Okay. Go toward the end of Central Park, then walk down to St. Patrick’s Cathedral. A few more blocks, and Grand Central will be off to your left.” In this case, you are pointed toward the most recent place you recall, and you aim for it. Once there you head for the next notable place and so on, retracing your path. Your brain is adding together the individual legs of your trek into a cumulative progress report. Researchers call this strategy “path integration.” Many animals rely primarily on path integration to get around, including insects, spiders, crabs and rodents. The desert ants of the genus Cataglyphis employ this method to return from foraging as far as 100 yards away. They note the general direction they came from and retrace then steps, using the polarization of sunlight to orient themselves even under overcast skies. On their way back they are faithful to this inner homing vector. Even when a scientist picks up an ant and puts it in a totally different spot, the insect stubbornly proceeds in the originally determined direction until it has gone “back” all of the distance it wandered from its nest. Only then does the ant realize it has not succeeded, and it begins to walk in successively larger loops to find its way home.

E . Whether it is trying to get back to the anthill or the train station, any animal using path integration must keep track of its own movements so it knows, while returning, which segments it has already completed. As you move, your brain gathers data from your environment—sights, sounds, smells, lighting, muscle contractions, a sense of time passing—to determine which way your body has gone. The church spire, the sizzling sausages on that vendor’s grill, the open courtyard, and the train station—all represent snapshots of memorable junctures during your journey.

F . In addition to guidance and path integration, we use a third method for finding our way. An office worker you approach for help on a Manhattan street comer might say: “Walk straight down Fifth, turn left on 47th, turn right on Park, go through the walkway under the Helmsley Building, then cross the street to the MetLife Building into Grand Central.” This strategy, called route following, uses landmarks such as buildings and street names, plus directions-straight, turn, go through—for reaching intermediate points. Route following is more precise than guidance or path integration, but if you forget the details and take a wrong turn, the only way to recover is to backtrack until you reach a familiar spot, because you do not know the general direction or have a reference landmark for your goal. The route-following navigation strategy truly challenges the brain. We have to keep all the landmarks and intermediate directions in our head. It is the most detailed and therefore most reliable method, but it can be undone by routine memory lapses. With path integration, our cognitive memory is less burdened; it has to deal with only a few general instructions and the homing vector. Path integration works because it relies most fundamentally on our knowledge of our body’s general direction of movement, and we always have access to these inputs. Nevertheless, people often choose to give route-following directions, in part because saying “Go straight that way!” just does not work in our complex, man-made surroundings.

G . Road Map or Metaphor? On your next visit to Manhattan you will rely on your memory to get around. Most likely you will use guidance, path integration and route following in various combinations. But how exactly do these constructs deliver concrete directions? Do we humans have, as an image of the real world, a kind of road map in our heads—with symbols for cities, train stations and churches; thick lines for highways; narrow lines for local streets? Neurobiologists and cognitive psychologists do call the portion of our memory that controls navigation a “cognitive map.” The map metaphor is obviously seductive: maps are the easiest way to present geographic information for convenient visual inspection. In many cultures, maps were developed before writing, and today they are used in almost every society. It is even possible that maps derive from a universal way in which our spatial-memory networks are wired.

H . Yet the notion of a literal map in our heads may be misleading; a growing body of research implies that the cognitive map is mostly a metaphor. It may be more like a hierarchical structure of relationships. To get back to Grand Central, you first envision the large scale-that is, you visualize the general direction of the station. Within that system you then imagine the route to the last place you remember. After that, you observe your nearby surroundings to pick out a recognizable storefront or street comer that will send you toward that place. In this hierarchical, or nested, scheme, positions and distances are relative, in contrast with a road map, where the same information is shown in a geometrically precise scale.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73fb18bb-49d3-5113-930b-da4df3055ee2', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 1, 'CLASSIFICATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed
A-C
) with correct statement. Write the appropriate letters
A-C
in boxes
1-5
on your answer sheet.
NB you may use any letter more than once
A. Guidance
B. Path integration,
C
.
Route following
1
Using basic direction from starting point and light intensity to move on
2
Using combination of place and direction heading for destination
3
Using an iconic building near your destination as orientation
4
Using a retrace method from a known place if a mistake happens
5
Using a passed spot as reference for a new integration

1 ____ Using basic direction from starting point and light intensity to move on$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eee36674-43e6-55d6-9855-9f68425ebdca', '73fb18bb-49d3-5113-930b-da4df3055ee2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e22fef3-4683-5487-b2d9-c27154e8ba7d', '73fb18bb-49d3-5113-930b-da4df3055ee2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8be6cfcb-b3d1-5a95-be91-43c2b3081b1c', '73fb18bb-49d3-5113-930b-da4df3055ee2', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('072065c9-031c-58de-aed4-b7cd07ba5541', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 2, 'CLASSIFICATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed
A-C
) with correct statement. Write the appropriate letters
A-C
in boxes
1-5
on your answer sheet.
NB you may use any letter more than once
A. Guidance
B. Path integration,
C
.
Route following
1
Using basic direction from starting point and light intensity to move on
2
Using combination of place and direction heading for destination
3
Using an iconic building near your destination as orientation
4
Using a retrace method from a known place if a mistake happens
5
Using a passed spot as reference for a new integration

2 ____ Using combination of place and direction heading for destination$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84304f6d-3514-56fb-8b7c-7f55afb8e638', '072065c9-031c-58de-aed4-b7cd07ba5541', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53368055-43c2-52bb-ac18-47fa958fe709', '072065c9-031c-58de-aed4-b7cd07ba5541', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('391d2637-5d55-5058-98d7-6856bee1bffc', '072065c9-031c-58de-aed4-b7cd07ba5541', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f49c44f-de7f-51a0-9dbc-919d7a12e195', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 3, 'CLASSIFICATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed
A-C
) with correct statement. Write the appropriate letters
A-C
in boxes
1-5
on your answer sheet.
NB you may use any letter more than once
A. Guidance
B. Path integration,
C
.
Route following
1
Using basic direction from starting point and light intensity to move on
2
Using combination of place and direction heading for destination
3
Using an iconic building near your destination as orientation
4
Using a retrace method from a known place if a mistake happens
5
Using a passed spot as reference for a new integration

3 ____ Using an iconic building near your destination as orientation$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6280bbe5-598d-5f31-b16a-3b88beb770fe', '6f49c44f-de7f-51a0-9dbc-919d7a12e195', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9665f0a-a071-5231-815e-f141f98f3c61', '6f49c44f-de7f-51a0-9dbc-919d7a12e195', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c655f0dd-1688-5c26-a84f-e220f6e40721', '6f49c44f-de7f-51a0-9dbc-919d7a12e195', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7afe2394-3068-5808-9999-d0b48df19174', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 4, 'CLASSIFICATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed
A-C
) with correct statement. Write the appropriate letters
A-C
in boxes
1-5
on your answer sheet.
NB you may use any letter more than once
A. Guidance
B. Path integration,
C
.
Route following
1
Using basic direction from starting point and light intensity to move on
2
Using combination of place and direction heading for destination
3
Using an iconic building near your destination as orientation
4
Using a retrace method from a known place if a mistake happens
5
Using a passed spot as reference for a new integration

4 ____ Using a retrace method from a known place if a mistake happens$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e7696ce-6876-567e-a3e8-7b5eef46f764', '7afe2394-3068-5808-9999-d0b48df19174', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9feba626-a6ad-518d-b592-d114d2e9c7d7', '7afe2394-3068-5808-9999-d0b48df19174', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e22793f-082c-594c-8e89-600ca1d629a1', '7afe2394-3068-5808-9999-d0b48df19174', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75911735-71df-5380-a2ed-e202604d86b6', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed
A-C
) with correct statement. Write the appropriate letters
A-C
in boxes
1-5
on your answer sheet.
NB you may use any letter more than once
A. Guidance
B. Path integration,
C
.
Route following
1
Using basic direction from starting point and light intensity to move on
2
Using combination of place and direction heading for destination
3
Using an iconic building near your destination as orientation
4
Using a retrace method from a known place if a mistake happens
5
Using a passed spot as reference for a new integration

5 ____ Using a passed spot as reference for a new integration$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c1cae1c-f943-59fe-b461-8d0d5fc81e0c', '75911735-71df-5380-a2ed-e202604d86b6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b608c3fb-fdb0-56f1-921d-69e714ed049f', '75911735-71df-5380-a2ed-e202604d86b6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ab8e8e4-b9d3-5cf2-8dd2-4c347b1f8225', '75911735-71df-5380-a2ed-e202604d86b6', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9fc433c-3259-5763-855c-04a9cf07ab42', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C or D
.
Write your answers in boxes
6-8
on your answer sheet.
6. What does the ant of
Cataglyphis
respond if it has been taken to another location according to the passage?
A
Changes the orientation sensors improvingly
B
Releases biological scent for help from others
C
Continues to move by the original orientation
D
Totally gets lost once disturbed
7. Which of the followings is true about “cognitive map” in this passage?
A
There is not obvious difference contrast by real map
B
It exists in our head and is always correct
C
It only exists under some cultures
D
It was managed by brain memory
8. Which of following description of way findings correctly reflects the function of
cognitive map
?
A
It visualises a virtual route in a large scope
B
It reproduces an exact details of every landmark
C
Observation plays a more important role
D
Store or supermarket is a must in file map

Choose the correct letter, A, B, C or D . Write your answers in boxes 6-8 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19dc824c-bc36-54a9-81ba-f4b8f488d84e', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C or D
.
Write your answers in boxes
6-8
on your answer sheet.
6. What does the ant of
Cataglyphis
respond if it has been taken to another location according to the passage?
A
Changes the orientation sensors improvingly
B
Releases biological scent for help from others
C
Continues to move by the original orientation
D
Totally gets lost once disturbed
7. Which of the followings is true about “cognitive map” in this passage?
A
There is not obvious difference contrast by real map
B
It exists in our head and is always correct
C
It only exists under some cultures
D
It was managed by brain memory
8. Which of following description of way findings correctly reflects the function of
cognitive map
?
A
It visualises a virtual route in a large scope
B
It reproduces an exact details of every landmark
C
Observation plays a more important role
D
Store or supermarket is a must in file map

Choose the correct letter, A, B, C or D . Write your answers in boxes 6-8 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e6b6db5-bfb8-5f6b-bcc3-6ff95056b6f2', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C or D
.
Write your answers in boxes
6-8
on your answer sheet.
6. What does the ant of
Cataglyphis
respond if it has been taken to another location according to the passage?
A
Changes the orientation sensors improvingly
B
Releases biological scent for help from others
C
Continues to move by the original orientation
D
Totally gets lost once disturbed
7. Which of the followings is true about “cognitive map” in this passage?
A
There is not obvious difference contrast by real map
B
It exists in our head and is always correct
C
It only exists under some cultures
D
It was managed by brain memory
8. Which of following description of way findings correctly reflects the function of
cognitive map
?
A
It visualises a virtual route in a large scope
B
It reproduces an exact details of every landmark
C
Observation plays a more important role
D
Store or supermarket is a must in file map

Choose the correct letter, A, B, C or D . Write your answers in boxes 6-8 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18ce7163-e0a5-52d6-80b4-5a4c1e184dfe', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in
Reading Passage
? In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
Biological navigation has a state of flexibility
10
You will always receive good reaction when you ask direction
11
When someone follows a route, he or she collects comprehensive perceptional information in mind on the way
12
Path integration requires more thought from brain compared with route- following
13
In a familiar surrounding, an exact map of where you are will automatically emerge in your head

9 ____ Biological navigation has a state of flexibility$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7d31f82-d413-5087-94b5-d4a0e076171f', '18ce7163-e0a5-52d6-80b4-5a4c1e184dfe', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1958adcf-e6a2-5b0e-b106-c55993a0e2ef', '18ce7163-e0a5-52d6-80b4-5a4c1e184dfe', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dfe53f5-3fdc-57bf-8f46-d85876efd650', '18ce7163-e0a5-52d6-80b4-5a4c1e184dfe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4bce52b-5f9f-55de-9879-04744fd1af81', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in
Reading Passage
? In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
Biological navigation has a state of flexibility
10
You will always receive good reaction when you ask direction
11
When someone follows a route, he or she collects comprehensive perceptional information in mind on the way
12
Path integration requires more thought from brain compared with route- following
13
In a familiar surrounding, an exact map of where you are will automatically emerge in your head

10 ____ You will always receive good reaction when you ask direction$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c823fb93-8b2d-5d69-b94e-00b830ba0f15', 'e4bce52b-5f9f-55de-9879-04744fd1af81', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db9c3d0b-6aa7-5115-8abc-6f9fd6820912', 'e4bce52b-5f9f-55de-9879-04744fd1af81', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b074cf4-195f-5ef6-a118-848aed0b4772', 'e4bce52b-5f9f-55de-9879-04744fd1af81', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c151760-1ae1-55d5-a80c-c9d06051ee63', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in
Reading Passage
? In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
Biological navigation has a state of flexibility
10
You will always receive good reaction when you ask direction
11
When someone follows a route, he or she collects comprehensive perceptional information in mind on the way
12
Path integration requires more thought from brain compared with route- following
13
In a familiar surrounding, an exact map of where you are will automatically emerge in your head

11 ____ When someone follows a route, he or she collects comprehensive perceptional information in mind on the way$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5083eee7-2a9b-5741-8b43-64015ed5db02', '4c151760-1ae1-55d5-a80c-c9d06051ee63', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b44d76e-8271-5554-a52a-d454d2530485', '4c151760-1ae1-55d5-a80c-c9d06051ee63', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e58ca9fa-0b9f-5047-be23-92de893665b7', '4c151760-1ae1-55d5-a80c-c9d06051ee63', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('03932b08-edfd-51b4-af68-806c2f5e01cd', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in
Reading Passage
? In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
Biological navigation has a state of flexibility
10
You will always receive good reaction when you ask direction
11
When someone follows a route, he or she collects comprehensive perceptional information in mind on the way
12
Path integration requires more thought from brain compared with route- following
13
In a familiar surrounding, an exact map of where you are will automatically emerge in your head

12 ____ Path integration requires more thought from brain compared with route- following$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a47ee78e-0e71-5de1-8019-eb530a8989b3', '03932b08-edfd-51b4-af68-806c2f5e01cd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6ba9103-3b91-57e1-a582-bbf26ecde53d', '03932b08-edfd-51b4-af68-806c2f5e01cd', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72ff5291-089d-55bb-80a8-032ca26b4863', '03932b08-edfd-51b4-af68-806c2f5e01cd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5b8bbadc-7a0e-5ad6-b829-7c4642d53bdd', 'e46caa82-d57e-57cf-99a3-2275babae4b4', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in
Reading Passage
? In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
Biological navigation has a state of flexibility
10
You will always receive good reaction when you ask direction
11
When someone follows a route, he or she collects comprehensive perceptional information in mind on the way
12
Path integration requires more thought from brain compared with route- following
13
In a familiar surrounding, an exact map of where you are will automatically emerge in your head

13 ____ In a familiar surrounding, an exact map of where you are will automatically emerge in your head$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bed0912-c92d-5850-a697-04d2e843c7b2', '5b8bbadc-7a0e-5ad6-b829-7c4642d53bdd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdfa3927-0d66-5ae1-8944-22ca9bcefc9b', '5b8bbadc-7a0e-5ad6-b829-7c4642d53bdd', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c75d0a0c-28c3-5c83-bc90-b5f3283081e0', '5b8bbadc-7a0e-5ad6-b829-7c4642d53bdd', 3, $md$NOT GIVEN$md$, false);

COMMIT;
