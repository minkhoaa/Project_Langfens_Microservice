BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-do-we-find-our-way-1471'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-do-we-find-our-way-1471';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-do-we-find-our-way-1471';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-do-we-find-our-way-1471';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('819749ef-02ca-5a6b-be62-a0af88dbd768', 'ielts-reading-how-do-we-find-our-way-1471', $t$How do we find our way?$t$, $md$## How do we find our way?

Nguồn:
- Test: https://mini-ielts.com/1471/reading/how-do-we-find-our-way
- Solution: https://mini-ielts.com/1471/view-solution/reading/how-do-we-find-our-way$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('bde08d5c-fb52-59c3-aa27-407038b3d62c', '819749ef-02ca-5a6b-be62-a0af88dbd768', 1, $t$Reading — How do we find our way?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: How do we find our way?

A . Most modern navigation, such as the Global Positioning System (GPS), relies primarily on positions determined electronically by receivers collecting information from satellites. Yet if the satellite service’s digital maps become even slightly outdated, we can become lost. Then we have to rely on the ancient human skill of navigating in three dimensional space. Luckily, our biological finder has an important advantage over GPS: we can ask questions of people on the sidewalk, or follow a street that looks familiar, or rely on a navigational rubric. The human positioning system is flexible and capable of learning. Anyone who knows the way from point A to point B-and from A to C-can probably figure out how to get from B to C, too.

B . But how does this complex cognitive system really work? Researchers are looking at several strategies people use to orient themselves in space: guidance, path integration and route following. We may use all three or combinations thereof, and as experts learn more about these navigational skills, they are making the case that our abilities may underlie our powers of memory and logical thinking. For example, you come to New York City for the first time and you get off the train at Grand Central Terminal in midtown Manhattan. You have a few hours to see popular spots you have been told about: Rockefeller Center, Central Park, and the Metropolitan Museum of Art. You meander in and out of shops along the way. Suddenly, it is time to get back to the station. But how?

C . If you ask passersby for help, most likely you will receive information in many different forms. A person who orients herself by a prominent landmark would gesture southward: “Look down there. See the tall, broad MetLife Building? Head for that- the station is right below it.” Neurologists call this navigational approach “guidance”, meaning that a landmark visible from a distance serves as the marker for one’s destination.

D . Another city dweller might say: “What places do you remember passing? … Okay. Go toward the end of Central Park, then walk down to St. Patrick’s Cathedral. A few more blocks, and Grand Central will be off to your left.” In this case, you are pointed toward the most recent place you recall, and you aim for it. Once there you head for the next notable place and so on, retracing your path. Your brain is adding together the individual legs of your trek into a cumulative progress report. Researchers call this strategy “path integration.” Many animals rely primarily on path integration to get around, including insects, spiders, crabs and rodents. The desert ants of the genus Cataglyphis employ this method to return from foraging as far as 100 yards away. They note the general direction they came from and retrace their steps, using the polarization of sunlight to orient themselves even under overcast skies. On their way back they are faithful to this inner homing vector. Even when a scientist picks up an ant and puts it in a totally different spot, the insect stubbornly proceeds in the originally determined direction until it has gone “back” all of the distance it wandered from its nest. Only then does the ant realize it has not succeeded, and it begins to walk in successively larger loops to find its way home.

E . Whether it is trying to get back to the anthill or the train station, any animal using path integration must keep track of its own movements so it knows, while returning, which segments it has already completed. As you move, your brain gathers data from your environment-sights, sounds, smells, lighting, muscle contractions, a sense of time passing-to determine which way your body has gone. The church spire, the sizzling sausages on that vendor’s grill, the open courtyard, and the train station-all represent snapshots of memorable junctures during your journey.

F . In addition to guidance and path integration, we use a third method for finding our way. An office worker you approach for help on a Manhattan street comer might say: “Walk straight down Fifth, turn left on 47th, turn right on Park, go through the walkway under the Helmsley Building, then cross the street to the MetLife Building into Grand Central.” This strategy, called route following, uses landmarks such as buildings and street names, plus directions straight, turn, go through—for reaching intermediate points. Route following is more precise than guidance or path integration, but if you forget the details and take a wrong turn, the only way to recover is to backtrack until you reach a familiar spot, because you do not know the general direction or have a reference landmark for your goal. The route following navigation strategy truly challenges the brain. We have to keep all the landmarks and intermediate directions in our head. It is the most detailed and therefore most reliable method, but it can be undone by routine memory lapses. With path integration, our cognitive memory is less burdened; it has to deal with only a few general instructions and the homing vector. Path integration works because it relies most fundamentally on our knowledge of our body’s general direction of movement, and we always have access to these inputs. Nevertheless, people often choose to give route-following directions, in part because saying “Go straight that way!” just does not work in our complex, man made surroundings.

G . Road Map or Metaphor? On your next visit to Manhattan you will rely on your memory to get present geographic information for convenient visual obviously seductive: maps around. Most likely you will use guidance, path integration and route following in various combinations. But how exactly do these constructs deliver concrete directions? Do we humans have, as an image of the real world, a kind of road map in our heads? Neurobiologists and cognitive psychologists do call the portion of our memory that controls navigation a “cognitive map”. The map metaphor is are the easiest way to inspection. Yet the notion of a literal map in our heads may be misleading; a growing body of research implies that the cognitive map is mostly a metaphor. It may be more like a hierarchical structure of relationships.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6f263d7-fad2-560a-844d-5c8c317dd59c', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 1, 'CLASSIFICATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed A-C) with correct statement.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
A. guidance method
B. path integration method
C. route following method
1
Split the route up into several smaller parts.
2
When mistakes are made, a person needs to go back.
3
Find a building that can be seen from far away.
4
Recall all the details along the way.
5
Memorize the buildings that you have passed by.

1 ____ Split the route up into several smaller parts. 2 ____ When mistakes are made, a person needs to go back. 3 ____ Find a building that can be seen from far away. 4 ____ Recall all the details along the way. 5 ____ Memorize the buildings that you have passed by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2995111a-6950-51e8-852e-d9a7da309bd6', 'e6f263d7-fad2-560a-844d-5c8c317dd59c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f540385-3c46-50be-a9dd-88d579540066', 'e6f263d7-fad2-560a-844d-5c8c317dd59c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('533b7b42-a219-516e-9a48-a936d192ebb8', 'e6f263d7-fad2-560a-844d-5c8c317dd59c', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf2ff1f8-5224-5c0e-b366-50ef23a025b3', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 2, 'CLASSIFICATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed A-C) with correct statement.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
A. guidance method
B. path integration method
C. route following method
1
Split the route up into several smaller parts.
2
When mistakes are made, a person needs to go back.
3
Find a building that can be seen from far away.
4
Recall all the details along the way.
5
Memorize the buildings that you have passed by.

1 ____ Split the route up into several smaller parts. 2 ____ When mistakes are made, a person needs to go back. 3 ____ Find a building that can be seen from far away. 4 ____ Recall all the details along the way. 5 ____ Memorize the buildings that you have passed by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bac26d7-17bd-5264-8cc9-8ac58d913790', 'bf2ff1f8-5224-5c0e-b366-50ef23a025b3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3158523-f35e-5db2-978b-3e0541b4f044', 'bf2ff1f8-5224-5c0e-b366-50ef23a025b3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('312009e6-defe-5c52-96b1-fa62f4ab79c2', 'bf2ff1f8-5224-5c0e-b366-50ef23a025b3', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3f8203ab-db91-527a-a341-59f43c5a8b6a', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 3, 'CLASSIFICATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed A-C) with correct statement.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
A. guidance method
B. path integration method
C. route following method
1
Split the route up into several smaller parts.
2
When mistakes are made, a person needs to go back.
3
Find a building that can be seen from far away.
4
Recall all the details along the way.
5
Memorize the buildings that you have passed by.

1 ____ Split the route up into several smaller parts. 2 ____ When mistakes are made, a person needs to go back. 3 ____ Find a building that can be seen from far away. 4 ____ Recall all the details along the way. 5 ____ Memorize the buildings that you have passed by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0ecf512-b78e-53f3-a05a-3023a1d04988', '3f8203ab-db91-527a-a341-59f43c5a8b6a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e46dbd4a-5a55-5159-88dd-6c76f213f466', '3f8203ab-db91-527a-a341-59f43c5a8b6a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d29f77-5b76-5c95-8b9d-14d931d4955a', '3f8203ab-db91-527a-a341-59f43c5a8b6a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dcb663bc-51f1-5945-b8fa-eaec6932fe65', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 4, 'CLASSIFICATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed A-C) with correct statement.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
A. guidance method
B. path integration method
C. route following method
1
Split the route up into several smaller parts.
2
When mistakes are made, a person needs to go back.
3
Find a building that can be seen from far away.
4
Recall all the details along the way.
5
Memorize the buildings that you have passed by.

1 ____ Split the route up into several smaller parts. 2 ____ When mistakes are made, a person needs to go back. 3 ____ Find a building that can be seen from far away. 4 ____ Recall all the details along the way. 5 ____ Memorize the buildings that you have passed by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17f8fec7-e381-5587-99a1-27ad128774cd', 'dcb663bc-51f1-5945-b8fa-eaec6932fe65', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f94f837-4266-52eb-b1ab-2b3ac0ae0c47', 'dcb663bc-51f1-5945-b8fa-eaec6932fe65', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92841cf6-4078-54c7-b21a-8b5aea28e096', 'dcb663bc-51f1-5945-b8fa-eaec6932fe65', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6a8da74-772d-5b90-9989-f9b108fe6fa3', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the category of each navigation method (listed A-C) with correct statement.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
A. guidance method
B. path integration method
C. route following method
1
Split the route up into several smaller parts.
2
When mistakes are made, a person needs to go back.
3
Find a building that can be seen from far away.
4
Recall all the details along the way.
5
Memorize the buildings that you have passed by.

1 ____ Split the route up into several smaller parts. 2 ____ When mistakes are made, a person needs to go back. 3 ____ Find a building that can be seen from far away. 4 ____ Recall all the details along the way. 5 ____ Memorize the buildings that you have passed by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab559e3e-5f88-52e5-875b-ce26a3d3c5a9', 'd6a8da74-772d-5b90-9989-f9b108fe6fa3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faedb2ac-f38a-5d0a-9e13-7c217d1b455f', 'd6a8da74-772d-5b90-9989-f9b108fe6fa3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1701cf1b-b73d-54ea-9969-380897cb335d', 'd6a8da74-772d-5b90-9989-f9b108fe6fa3', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b328edbc-dafa-5d16-9150-aeeffbb768ca', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write your answers in boxes 6-8 on your answer sheet.
6. According to the passage, how does the Cataglyphis ant respond if it is taken to a different location?
A
changes its orientation sensors to adapt
B
releases biological scent for help from others
C
continues to move according to the original orientation
D
gets completely lost once disturbed
7. What did the author say about the route following method?
A
dependent on directions to move on
B
dependent on memory and reasoning
C
dependent on man-made settings
D
dependent on the homing vector
8. Which of the following is true about the “cognitive map” in this passage?
A
There is no obvious difference between it and a real map.
B
It exists in our heads and is always correct.
C
It only exists in some cultures.
D
It is managed by a portion of our memory.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('816191f2-bba3-568f-b661-d4b96a8801a9', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write your answers in boxes 6-8 on your answer sheet.
6. According to the passage, how does the Cataglyphis ant respond if it is taken to a different location?
A
changes its orientation sensors to adapt
B
releases biological scent for help from others
C
continues to move according to the original orientation
D
gets completely lost once disturbed
7. What did the author say about the route following method?
A
dependent on directions to move on
B
dependent on memory and reasoning
C
dependent on man-made settings
D
dependent on the homing vector
8. Which of the following is true about the “cognitive map” in this passage?
A
There is no obvious difference between it and a real map.
B
It exists in our heads and is always correct.
C
It only exists in some cultures.
D
It is managed by a portion of our memory.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb8384ae-c05c-5b3c-bc29-4ae1e40dfe7b', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write your answers in boxes 6-8 on your answer sheet.
6. According to the passage, how does the Cataglyphis ant respond if it is taken to a different location?
A
changes its orientation sensors to adapt
B
releases biological scent for help from others
C
continues to move according to the original orientation
D
gets completely lost once disturbed
7. What did the author say about the route following method?
A
dependent on directions to move on
B
dependent on memory and reasoning
C
dependent on man-made settings
D
dependent on the homing vector
8. Which of the following is true about the “cognitive map” in this passage?
A
There is no obvious difference between it and a real map.
B
It exists in our heads and is always correct.
C
It only exists in some cultures.
D
It is managed by a portion of our memory.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2013bfb2-b560-54de-928d-5ed3ad746084', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
9
Biological navigation is flexible.
10
Insects have many ways to navigate that are in common with many other animals.
11
When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way.
12
The path integration method has a higher requirement of memory compared with the route following method.
13
When people find their way, they have an exact map in their mind.

9 ____ Biological navigation is flexible. 10 ____ Insects have many ways to navigate that are in common with many other animals. 11 ____ When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way. 12 ____ The path integration method has a higher requirement of memory compared with the route following method. 13 ____ When people find their way, they have an exact map in their mind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32b7a626-1a98-501d-9bf0-2117b9012bfe', '2013bfb2-b560-54de-928d-5ed3ad746084', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56ce573e-5e82-533b-be48-11e3a34d0994', '2013bfb2-b560-54de-928d-5ed3ad746084', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6698382-bcdb-5248-adc0-0681fdb00422', '2013bfb2-b560-54de-928d-5ed3ad746084', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27946bfb-35c6-55dd-aa10-5e3826e31216', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
9
Biological navigation is flexible.
10
Insects have many ways to navigate that are in common with many other animals.
11
When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way.
12
The path integration method has a higher requirement of memory compared with the route following method.
13
When people find their way, they have an exact map in their mind.

9 ____ Biological navigation is flexible. 10 ____ Insects have many ways to navigate that are in common with many other animals. 11 ____ When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way. 12 ____ The path integration method has a higher requirement of memory compared with the route following method. 13 ____ When people find their way, they have an exact map in their mind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af0266cc-9d27-5a65-a65f-e947a89fc61f', '27946bfb-35c6-55dd-aa10-5e3826e31216', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e3011c0-a0f5-5ca2-9bc4-97889693d052', '27946bfb-35c6-55dd-aa10-5e3826e31216', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3da4471d-c4b3-5d7d-9105-024bb940daf1', '27946bfb-35c6-55dd-aa10-5e3826e31216', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a979161-4268-5f32-954d-e2fb91739b86', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
9
Biological navigation is flexible.
10
Insects have many ways to navigate that are in common with many other animals.
11
When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way.
12
The path integration method has a higher requirement of memory compared with the route following method.
13
When people find their way, they have an exact map in their mind.

9 ____ Biological navigation is flexible. 10 ____ Insects have many ways to navigate that are in common with many other animals. 11 ____ When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way. 12 ____ The path integration method has a higher requirement of memory compared with the route following method. 13 ____ When people find their way, they have an exact map in their mind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d540c55b-cddc-5ac7-8195-16488f978501', '1a979161-4268-5f32-954d-e2fb91739b86', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbca0dd6-1325-59b9-9f26-b16263aef098', '1a979161-4268-5f32-954d-e2fb91739b86', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('158436ca-35e9-5389-b644-5094630bce29', '1a979161-4268-5f32-954d-e2fb91739b86', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a5cb245-9d5f-5bab-a722-818844ebdb82', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
9
Biological navigation is flexible.
10
Insects have many ways to navigate that are in common with many other animals.
11
When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way.
12
The path integration method has a higher requirement of memory compared with the route following method.
13
When people find their way, they have an exact map in their mind.

9 ____ Biological navigation is flexible. 10 ____ Insects have many ways to navigate that are in common with many other animals. 11 ____ When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way. 12 ____ The path integration method has a higher requirement of memory compared with the route following method. 13 ____ When people find their way, they have an exact map in their mind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b59ced6a-13df-5f31-ac63-8e6b1f46811f', '9a5cb245-9d5f-5bab-a722-818844ebdb82', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62e26dcf-6cd8-58f3-ae00-ec31a5d4eebc', '9a5cb245-9d5f-5bab-a722-818844ebdb82', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db37a607-b214-57b0-a3af-f77570e4146c', '9a5cb245-9d5f-5bab-a722-818844ebdb82', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5be59918-9787-5260-a9f0-844e7c1183b2', 'bde08d5c-fb52-59c3-aa27-407038b3d62c', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
9
Biological navigation is flexible.
10
Insects have many ways to navigate that are in common with many other animals.
11
When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way.
12
The path integration method has a higher requirement of memory compared with the route following method.
13
When people find their way, they have an exact map in their mind.

9 ____ Biological navigation is flexible. 10 ____ Insects have many ways to navigate that are in common with many other animals. 11 ____ When someone follows a route, he or she collects comprehensive perceptual information in the mind along the way. 12 ____ The path integration method has a higher requirement of memory compared with the route following method. 13 ____ When people find their way, they have an exact map in their mind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('314db329-82d7-5462-8967-4581d860ff6f', '5be59918-9787-5260-a9f0-844e7c1183b2', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac17a14-ad97-57f0-b3b0-9ecc6d34871e', '5be59918-9787-5260-a9f0-844e7c1183b2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6b90f0e-bf8f-5fb0-96a8-15a4bf06d700', '5be59918-9787-5260-a9f0-844e7c1183b2', 3, $md$NOT GIVEN$md$, false);

COMMIT;
