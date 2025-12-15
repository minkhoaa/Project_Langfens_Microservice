BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-british-architecture-2-1312'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-british-architecture-2-1312';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-british-architecture-2-1312';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-british-architecture-2-1312';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('366045f9-5f1d-5879-bf2e-b08958f30b55', 'ielts-reading-british-architecture-2-1312', $t$British Architecture 2$t$, $md$## British Architecture 2

Nguồn:
- Test: https://mini-ielts.com/1312/reading/british-architecture-2
- Solution: https://mini-ielts.com/1312/view-solution/reading/british-architecture-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fe55e769-7c1c-5dac-b6dc-d1eed27729ee', '366045f9-5f1d-5879-bf2e-b08958f30b55', 1, $t$Reading — British Architecture 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: British Architecture 2

A . Architecture is about evolution, not revolution. It used to be thought that once the Romans pulled out of Britain in the fifth century, their elegant villas, carefully-planned towns and engineering marvels like Hadrian’s Wall simply fell into decay as British culture was plunged into the Dark Ages. It took the Norman Conquest of 1066 to bring back the light, and the ố othic cathedral-builders of the Middle Ages played an important part in the revival of British culture. However, the truth is not as simple as that Romano-British culture – and that included architecture along with language, religion, political organization and the arts – survived long after the Roman withdrawal. And although the Anglo- Saxons had a sophisticated building style of their own, little survives to bear witness to their achievements as the vast majority of Anglo-Saxon buildings were made of wood.

B . Even so, the period between the Norman landing at Pevensey in 1066 and the day in 1485 when Richard III lost his horse and his head at Bosworth, ushering in the Tudors and the /Early Modern period, marks a rare flowering of British building. And it is all the more remarkable because the underlying ethos of medieval architecture was ‘fitness for purpose’. The great cathedrals and parish churches that lifted up their towers to heaven were not only acts of devotion in stone; they were also fiercely functional buildings. Castles served their particular purpose and their battlements and turrets were for use rather than ornament. In a sense, the buildings of the 16th century were also governed by fitness for purpose – only now, the purpose was very different. In domestic architecture, in particular, buildings were used to display status and wealth.

C . This stately and curious workmanship showed itself in various ways. A greater sense of security led to more outward-looking buildings, as opposed to the medieval arrangement where the need for defense created houses that faced inward onto a courtyard or series of courtyards. This allowed for much more in the way of exterior ornament. The rooms themselves tended to be bigger and lighter – as an expensive commodity, the use of great expanses of glass was in itself a statement of wealth. There was also a general move towards balanced and symmetrical exteriors with central entrances.

D. With the exception of Inigo Jones (1573-1652), whose confident handling of classical detail and proportion set him apart from all other architects of the period, most early 17th century buildings tended to take the innocent exuberance of late Tudor work one step further. /But during the 1640s and 50s the Civil War and its aftermath sent many gentlemen and nobles to the Continent either to escape the fighting or, when the war was lost, to follow Charles II into exile. There they came into contact with French, Dutch and Italian architecture and, with Charles’s restoration in 1660, there was a flurry of building activity as royalists reclaimed their property and built themselves houses reflecting the latest European trends. The British Baroque was a reassertion of authority, an expression of absolutist ideology by men who remembered a world turned upside down during the Civil War. The style is heavy and rich, sometimes overblown and melodramatic. The politics which underpin it are questionable, but its products are breathtaking.

E . The huge glass-and-iron Crystal Palace, designed by Joseph Paxton to house the Great Exhibition of 1851, shows another strand to 19th century architecture – one which embraced new industrial processes. But it wasn’t long before even this confidence in progress came to be regarded with suspicion. Mass production resulted in buildings and furnishings that were too perfect, as the individual craftsman no longer had a major role in their creation. Railing against the dehumanising effects of industrialisation, reformers like John Ruskin and William Morris made a concerted effort to return to hand-crafted, pre-industrial manufacturing techniques. Morris’s influence grew from the production of furniture and textiles, until by the 1880s a generation of principled young architects was following his call for good, honest construction.

F . The most important trends in early 20th century architecture simply passed Britain by. Whilst Gropius was working on cold, hard expanses of glass, and Le Corbusier was experimenting with the use of reinforced concrete frames, we had staid establishment architects like Edwin Lutyens producing Neo-Georgian and Renaissance country houses for an outmoded landed class. In addition there were slightly batty architect-craftsmen, the heirs of William Morris, still trying to turn the clock back to before the Industrial Revolution by making chairs and spurning new technology. Only a handful of Modern Movement buildings of any real merit were produced here during the 1920s and 1930s, and most of these were the work of foreign architects such as Serge Chermayeff, Berthold Lubetkin and Erno Goldf inger who had settled in this country.

G. After the Second World War the situation began to change. The Modern Movement’s belief in progress and the future struck a chord with the mood of post-war Britain and, as reconstruction began under Attlee’s Labour government in 1945, there was a desperate need for cheap housing which could be produced quickly. The use of prefabricated elements, metal frames, concrete cladding and the absence of decoration – all of which had been embraced by Modernists abroad and viewed with suspicion by the British -were adopted to varying degrees for housing developments and schools. Local authorities, charged with the task of rebuilding city center , became important patrons of architecture. This represented a shift away from the private individuals who had dominated the architectural scene for centuries.

H. Since the War it has been corporate bodies like these local authorities, together with national and multinational companies, and large educational institutions, which have dominated British architecture. By the late 1980s the Modern Movement, unfairly blamed for the social experiments implicit in high- rise housing, had lost out to irony and spectacle in the shape of post-modernism, with its cheerful borrowings from anywhere and any period. But now, in the new Millennium, even post-modernism is showing signs of age. What comes next? Post-post-modernism?$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cc02bfb3-41ae-513a-b193-3053299fb02f', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 1, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

1 . The Anglo-Saxon architecture failed to last because the buildings were constructed in 1 ____$md$, NULL, ARRAY['.*wood.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('44bd73f5-35d0-5e68-ae4f-8bb62dd2c123', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 2, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

2 . Different from the medieval architecture, the buildings of the 16th century represents 2 ____$md$, NULL, ARRAY['.*status.*and.*wealth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a023dd29-4f62-55d0-b2cc-fc503c40846c', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 3, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

3 . The costly glass was applied widely as an 3 ____ in that years.$md$, NULL, ARRAY['.*expensive.*commodity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('05d16993-2519-5788-b8fc-bae69e592611', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 4, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

4 . Inigo Jones was skilled at handling 4 ____ style.$md$, NULL, ARRAY['.*classical.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7320cad8-4c43-55d2-9efa-70d84810ae5a', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 5, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

5 . William Morris favored the production of 5 ____ made in pre-industrial manufacturing techniques.$md$, NULL, ARRAY['.*furniture.*and.*textiles.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1285f8de-8423-53ce-8233-04568e94fe61', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 6, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

6 . The architects such as 6 ____ provided the landlord with conservative houses.$md$, NULL, ARRAY['.*edwin.*lutyens.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6c204003-71b6-5a3e-93f3-2f9b8575f09c', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
. The Anglo-Saxon architecture failed to last because the buildings were constructed in
1
2
. Different from the medieval architecture, the buildings of the 16th century represents
2
3
. The costly glass was applied widely as an
3
in that years.
4
. Inigo Jones was skilled at handling
4
style.
5
. William Morris favored the production of
5
made in pre-industrial manufacturing techniques.
6
. The architects such as
6
provided the landlord with conservative houses.
7
. After World War Two, the architect commission shifted from individual to
7

7 . After World War Two, the architect commission shifted from individual to 7 ____$md$, NULL, ARRAY['.*local.*authorities.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cae875fc-893e-5251-95a6-8e14923e5dbf', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 8, 'CLASSIFICATION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('872d4048-472f-53cb-8095-f8ce2216e085', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 9, 'CLASSIFICATION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('675459ac-cca8-5b66-943e-dccab46957a7', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 10, 'CLASSIFICATION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d53085a-cac3-535b-8c57-d69997e25df0', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53df0f90-77dd-5170-96b2-3d09b84ef621', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('642b8c27-0a0e-5571-bed7-d000c1feeb59', 'fe55e769-7c1c-5dac-b6dc-d1eed27729ee', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes
8-13
on your answer sheet.
8. The feature of medieval architecture was
A
immense
B
useful
C
decorative
D
bizarre
9. What contributes to the outward-looking buildings in the 16th century?
A
safety
B
beauty
C
quality
D
technology
10. Why were the buildings in the 1660s influenced by the latest European trends?
A
Because the war was lost.
B
Because the craftsman came from all over the Europe.
C
Because the property belongs to the gentlemen and nobles.
D
Because the monarch came back from the continent.
11. What kind of sense did the British Baroque imply?
A
tough
B
steady
C
mild
D
conservative
12. The individual craftsman was no more the key to creation for the appearance of
A
Crystal Palace
B
preindustrial manufacturing return
C
industrial process in scale
D
ornament
13. The building style changed after World War Two as a result of
A
abundant materials
B
local authority
C
shortage of cheap housing
D
conservative views

Choose the correct letter, A, B, C or D$md$, NULL);

COMMIT;
