BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-thomas-harriot-the-discovery-of-refraction-1403'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-thomas-harriot-the-discovery-of-refraction-1403';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-thomas-harriot-the-discovery-of-refraction-1403';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-thomas-harriot-the-discovery-of-refraction-1403';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cfd027eb-de20-578a-adaa-814e7965720d', 'ielts-reading-thomas-harriot-the-discovery-of-refraction-1403', $t$Thomas Harriot: The Discovery of Refraction$t$, $md$## Thomas Harriot: The Discovery of Refraction

Nguồn:
- Test: https://mini-ielts.com/1403/reading/thomas-harriot-the-discovery-of-refraction
- Solution: https://mini-ielts.com/1403/view-solution/reading/thomas-harriot-the-discovery-of-refraction$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ea37b54a-202b-59dd-841e-0f5b72b06777', 'cfd027eb-de20-578a-adaa-814e7965720d', 1, $t$Reading — Thomas Harriot: The Discovery of Refraction$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Thomas Harriot: The Discovery of Refraction

A

When light travels from one medium to another, it generally bends, or refracts. The law of refraction gives us a way of predicting the amount of bending. Refraction has many applications in optics and technology. A lens uses refraction to form an image of an object for many different purposes, such as magnification. A prism uses refraction to form a spectrum of colors from an incident beam of light. Refraction also plays an important role in the formation of a mirage and other optical illusions. The law of refraction is also known as Snell’s Law, named after Willobrord Snell, who discovered the law in 1621. Although Snell’s sine law of refraction is now taught routinely in undergraduate courses, the quest for it spanned many centuries and involved many celebrated scientists. Perhaps the most interesting thing is that the first discovery of the sine law, made by the sixteenth-century English scientist Thomas Harriot (1560-1621), has been almost completely overlooked by physicists, despite much published material describing his contribution.

B

A contemporary of Shakespeare, Elizabeth I, Johannes Kepler and Galilei Galileo, Thomas Harriot (1560-1621) was an English scientist and mathematician. His principal biographer, J. W. Shirley, was quoted saying that in his time he was “England’s most profound mathematician, most imaginative and methodical experimental scientist”. As a mathematician, he contributed to the development of algebra, and introduced the symbols of ”>”, and ”<” for ”more than” and ”less than.” He also studied navigation and astronomy. On September 17, 1607, Harriot observed a comet, later Identified as Hailey-s. With his painstaking observations, later workers were able to compute the comet’s orbit. Harriot was also the first to use a telescope to observe the heavens in England. He made sketches of the moon in 1609, and then developed lenses of increasing magnification. By April 1611, he had developed a lens with a magnification of 32. Between October 17, 1610 and February 26, 1612, he observed the moons of Jupiter, which had already discovered by Galileo. While observing Jupiter’s moons, he made a discovery of his own: sunspots, which he viewed 199 times between December 8, 1610 and January 18, 1613. These observations allowed him to figure out the sun’s period of rotation.

C

He was also an early English explorer of North America. He was a friend of the English courtier and explorer Sir Walter Raleigh and travelled to Virginia as a scientific observer on a colonising expedition in 1585. On June 30, 1585, his ship anchored at Roanoke Island ，off Virginia. On shore, Harriot observed the topography, flora and fauna, made many drawings and maps, and met the native people who spoke a language the English called Algonquian. Harriot worked out a phonetic transcription of the native people’s speech sounds and began to learn the language, which enabled him to converse to some extent with other natives the English encountered. Harriot wrote his report for Raleigh and published it as A Briefe and True Report of the New Found Land of Virginia in 1588. Raleigh gave Harriot his own estate in Ireland, and Harriot began a survey of Raleigh’s Irish holdings. He also undertook a study of ballistics and ship design for Raleigh in advance of the Spanish Armada’s arrival.

D

Harriot kept regular correspondence with other scientists and mathematicians, especially in England but also in mainland Europe, notably with Johannes Kepler. About twenty years before Snell’s discovery, Johannes Kepler (1571-1630) had also looked for the law of refraction, but used the early data of Ptolemy. Unfortunately, Ptolemy’s data was in error, so Kepler could obtain only an approximation which he published in 1604. Kepler later tried to obtain additional experimental results on refraction, and corresponded with Thomas Harriot from 1606 to 1609 since Kepler had heard Harriot had carried out some detailed experiments. In 1606, Harriot sent Kepler some tables of refraction data for different materials at a constant incident angle, but didn’t provide enough detail for the data to be very useful. Kepler requested further information, but Harriot was not forthcoming, and it appears that Kepler eventually gave up the correspondence, frustrated with Harriot’s reluctance.

E

Apart from the correspondence with Kepler, there is no evidence that Harriot ever published his detailed results on refraction. His personal notes, however, reveal extensive studies significantly predating those of Kepler, Snell and Descartes. Harriot carried out many experiments on refraction in the 1590s, and from his notes, it is clear that he had discovered the sine law at least as early as 1602. Around 1606, he had studied dispersion in prisms (predating Newton by around 60 years), measured the refractive indices of different liquids placed in a hollow glass prism, studied refraction in crystal spheres, and correctly understood refraction in the rainbow before Descartes.

F

As his studies of refraction, Harriot’ s discoveries in other fields were largely unpublished during his lifetime, and until this century, Harriot was known only for an account of his travels in Virginia published in 1588, ，and for a treatise on algebra published posthumously in 1631. The reason why Harriot kept his results unpublished is unclear. Harriot wrote to Kepler that poor health prevented him from providing more information, but it is also possible that he was afraid of the seventeenth century’s English religious establishment which was suspicious of the work carried out by mathematicians and scientists.

G

After the discovery of sunspots, Harriot’ s scientific work dwindled. The cause of his diminished productivity might have been a cancer discovered on his nose. Harriot died on July 2, 1621, in London, but his story did not end with his death. Recent research has revealed his wide range of interests and his genuinely original discoveries. What some writers describe as his “thousands upon thousands of sheets of mathematics and of scientific observations” appeared to be lost until 1784, when they were found in Henry Percy’s country estate by one of Percy’s descendants. She gave them to Franz Xaver Zach, her husband’s son’s tutor. Zach eventually put some of the papers in the hands of the Oxford University Press, but much work was required to prepare them for publication, and it has never been done. Scholars have begun to study them，, and an appreciation of Harriot’s contribution started to grow in the second half of the twentieth century. Harriot’s study of refraction is but one example where his work overlapped with independent studies carried out by others in Europe, but in any historical treatment of optics his contribution rightfully deserves to be acknowledged.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dae1452c-2797-5faf-a128-8d3c225385ad', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has 7 paragraphs
A-G
.
Choose the correct heading for paragraphs
B-E
and
G
from the list of headings below.
Write the correct number,
i-x
, in boxes
1-5
on your answer sheet.
List of Headings
i
A misunderstanding in the history of science
ii
Thomas Harriot’s biography
iii
Unknown reasons for his unpublished works
iv
Harriot’s 1588 publication on North America studies
v
Expedition to the New World
vi
Reluctant cooperation with Kepler
vii
Belated appreciation of Harriot’s contribution
viii
Religious pressures keeping him from publishing
ix
Correspondence with Kepler
x
Interests and researches into multiple fields of study
Example Answer
Paragraph
A
i
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph G

1 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a6cf858-f4d7-597c-bd9d-0e9576128588', 'dae1452c-2797-5faf-a128-8d3c225385ad', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f70fee69-8e57-5446-bb00-5e544fa456a1', 'dae1452c-2797-5faf-a128-8d3c225385ad', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1f3b769-52d1-5b5b-b7cc-95f52eae4411', 'dae1452c-2797-5faf-a128-8d3c225385ad', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('814264cd-4910-5df6-9493-47c00116c778', 'dae1452c-2797-5faf-a128-8d3c225385ad', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d223e0dd-267e-516f-b4df-002a3a577753', 'dae1452c-2797-5faf-a128-8d3c225385ad', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4023413-6680-56f0-a6b7-882d2a9383e8', 'dae1452c-2797-5faf-a128-8d3c225385ad', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecc19722-f45f-5a04-b48b-4a6c274b6ffa', 'dae1452c-2797-5faf-a128-8d3c225385ad', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25060785-994f-5a22-a0c1-0d6655f5ff73', 'dae1452c-2797-5faf-a128-8d3c225385ad', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaca9b11-5b9a-554a-afe0-0232a05969a8', 'dae1452c-2797-5faf-a128-8d3c225385ad', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e64086f-1ba6-5cd9-914e-717310a58572', 'dae1452c-2797-5faf-a128-8d3c225385ad', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('950dac25-d4d9-576d-ac19-818a63c869c0', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has 7 paragraphs
A-G
.
Choose the correct heading for paragraphs
B-E
and
G
from the list of headings below.
Write the correct number,
i-x
, in boxes
1-5
on your answer sheet.
List of Headings
i
A misunderstanding in the history of science
ii
Thomas Harriot’s biography
iii
Unknown reasons for his unpublished works
iv
Harriot’s 1588 publication on North America studies
v
Expedition to the New World
vi
Reluctant cooperation with Kepler
vii
Belated appreciation of Harriot’s contribution
viii
Religious pressures keeping him from publishing
ix
Correspondence with Kepler
x
Interests and researches into multiple fields of study
Example Answer
Paragraph
A
i
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph G

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c654184-6a55-5836-849c-97a501d42494', '950dac25-d4d9-576d-ac19-818a63c869c0', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62f4e69c-547b-596b-81df-54e29cdd36c2', '950dac25-d4d9-576d-ac19-818a63c869c0', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07719ef3-bd69-5786-aeea-7a0f9d6945bf', '950dac25-d4d9-576d-ac19-818a63c869c0', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b98c0f43-69a5-5b05-8de6-6a411c1efa21', '950dac25-d4d9-576d-ac19-818a63c869c0', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90f5f158-a9d6-5909-a72b-16bab16abf1b', '950dac25-d4d9-576d-ac19-818a63c869c0', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1cb8a0d-0ea4-5f8c-b365-ef1e75aa27db', '950dac25-d4d9-576d-ac19-818a63c869c0', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0a9044c-c141-5800-ab77-28deb5486c50', '950dac25-d4d9-576d-ac19-818a63c869c0', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('170d9d01-4c92-58b3-b26f-edd00b9076a3', '950dac25-d4d9-576d-ac19-818a63c869c0', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d29f2b0-2740-55b5-a45b-3ce904ce5acf', '950dac25-d4d9-576d-ac19-818a63c869c0', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83d0a3d3-407e-51bc-ad19-bbd4fe611f09', '950dac25-d4d9-576d-ac19-818a63c869c0', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has 7 paragraphs
A-G
.
Choose the correct heading for paragraphs
B-E
and
G
from the list of headings below.
Write the correct number,
i-x
, in boxes
1-5
on your answer sheet.
List of Headings
i
A misunderstanding in the history of science
ii
Thomas Harriot’s biography
iii
Unknown reasons for his unpublished works
iv
Harriot’s 1588 publication on North America studies
v
Expedition to the New World
vi
Reluctant cooperation with Kepler
vii
Belated appreciation of Harriot’s contribution
viii
Religious pressures keeping him from publishing
ix
Correspondence with Kepler
x
Interests and researches into multiple fields of study
Example Answer
Paragraph
A
i
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph G

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('111eaa43-a44d-5863-9eaf-93fce40ee8ca', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17db151d-de43-5512-b1fd-f53cec69e642', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d634723c-d083-5f1a-842c-5a5b2c171d10', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('665daae7-0d43-50bf-b8ee-dcf626414169', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c769113-82e7-5def-8670-4f280b45974c', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64643f39-8c42-5159-9c23-6dae0a4d85e1', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02667652-3d38-5e2d-be4a-29cdc16f8cdb', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8b6ab46-d818-5aa9-8576-feca973f528c', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7389639-3606-5bf0-9df2-ef1ec4943161', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df25aa34-4fd2-5f15-9671-bdc3be816439', '7fdae4aa-93c3-5cd4-9b40-841be9bbf0ec', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has 7 paragraphs
A-G
.
Choose the correct heading for paragraphs
B-E
and
G
from the list of headings below.
Write the correct number,
i-x
, in boxes
1-5
on your answer sheet.
List of Headings
i
A misunderstanding in the history of science
ii
Thomas Harriot’s biography
iii
Unknown reasons for his unpublished works
iv
Harriot’s 1588 publication on North America studies
v
Expedition to the New World
vi
Reluctant cooperation with Kepler
vii
Belated appreciation of Harriot’s contribution
viii
Religious pressures keeping him from publishing
ix
Correspondence with Kepler
x
Interests and researches into multiple fields of study
Example Answer
Paragraph
A
i
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph G

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29208c92-c09f-52a4-befe-c7382ab36959', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('238c14dd-6e40-5d16-a243-7b0c56c91299', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b463a86-6dfd-5e64-ac84-ad5f90ad4ada', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0f1414c-6411-5ffe-b94a-d65fbf708a23', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5032a15-3187-5746-9ac8-1a3f2322fd52', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1929906b-f0d5-572b-9928-2e8fd228fb1e', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5a14b00-146d-50f4-bfa3-71ba0b068773', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4892bb1-3452-57b8-b59d-ce962ecac30c', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea5b0553-f889-54c7-ac71-67e32522dedd', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9830df4-84ba-5e1d-b7a7-12298a19dfac', '47ad629a-d0e5-5e7a-a187-a0f5df8db76a', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('495395d7-f271-5935-8422-f77c632e2336', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has 7 paragraphs
A-G
.
Choose the correct heading for paragraphs
B-E
and
G
from the list of headings below.
Write the correct number,
i-x
, in boxes
1-5
on your answer sheet.
List of Headings
i
A misunderstanding in the history of science
ii
Thomas Harriot’s biography
iii
Unknown reasons for his unpublished works
iv
Harriot’s 1588 publication on North America studies
v
Expedition to the New World
vi
Reluctant cooperation with Kepler
vii
Belated appreciation of Harriot’s contribution
viii
Religious pressures keeping him from publishing
ix
Correspondence with Kepler
x
Interests and researches into multiple fields of study
Example Answer
Paragraph
A
i
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph G

5 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc8aa367-b8ce-5a49-ae52-255ed6c25950', '495395d7-f271-5935-8422-f77c632e2336', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d39bc80-60cc-5fc3-be37-4de134e16d99', '495395d7-f271-5935-8422-f77c632e2336', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc4b7ef0-5d67-5696-ad17-0afd8319b710', '495395d7-f271-5935-8422-f77c632e2336', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0499a240-8532-5c83-8cfb-a1978a9c3541', '495395d7-f271-5935-8422-f77c632e2336', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70c09866-2d1b-5a87-b77f-dae6a3ae1450', '495395d7-f271-5935-8422-f77c632e2336', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85f0bef6-31a3-5c2a-a9eb-dda3b04530b3', '495395d7-f271-5935-8422-f77c632e2336', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f4d937e-7f40-5afb-a42d-39ab18da8c0e', '495395d7-f271-5935-8422-f77c632e2336', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea5f608f-50d7-5783-8bc1-50e98b54b862', '495395d7-f271-5935-8422-f77c632e2336', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1888439a-029e-5492-9b70-1aed3bf40971', '495395d7-f271-5935-8422-f77c632e2336', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a846d0a3-9409-5b7f-aa2d-33709a37c4da', '495395d7-f271-5935-8422-f77c632e2336', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('62a41b27-c5b8-5433-85df-57baa8a8bfee', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Various modem applications base on an image produced by lens uses refraction, such as
6
. And a spectrum of colors from a beam of light can be produced with
7
. Harriot travelled to Virginia and mainly did research which focused on two subjects of American
8
. After, he also enters upon a study of flight dynamics and
9
for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of
10
.

Various modem applications base on an image produced by lens uses refraction, such as 6 ____ . And a spectrum of colors from a beam of light can be produced with 7 ____ . Harriot travelled to Virginia and mainly did research which focused on two subjects of American 8 ____ . After, he also enters upon a study of flight dynamics and 9 ____ for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of 10 ____ .$md$, NULL, ARRAY['.*magnification.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cc6b8d76-e7ec-5607-9bbd-add6ca956e55', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Various modem applications base on an image produced by lens uses refraction, such as
6
. And a spectrum of colors from a beam of light can be produced with
7
. Harriot travelled to Virginia and mainly did research which focused on two subjects of American
8
. After, he also enters upon a study of flight dynamics and
9
for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of
10
.

Various modem applications base on an image produced by lens uses refraction, such as 6 ____ . And a spectrum of colors from a beam of light can be produced with 7 ____ . Harriot travelled to Virginia and mainly did research which focused on two subjects of American 8 ____ . After, he also enters upon a study of flight dynamics and 9 ____ for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of 10 ____ .$md$, NULL, ARRAY['.*magnification.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('af5d2846-2751-5a61-a2a2-de7b9045fce6', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Various modem applications base on an image produced by lens uses refraction, such as
6
. And a spectrum of colors from a beam of light can be produced with
7
. Harriot travelled to Virginia and mainly did research which focused on two subjects of American
8
. After, he also enters upon a study of flight dynamics and
9
for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of
10
.

Various modem applications base on an image produced by lens uses refraction, such as 6 ____ . And a spectrum of colors from a beam of light can be produced with 7 ____ . Harriot travelled to Virginia and mainly did research which focused on two subjects of American 8 ____ . After, he also enters upon a study of flight dynamics and 9 ____ for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of 10 ____ .$md$, NULL, ARRAY['.*magnification.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f8af6c1c-0813-5bbd-a124-969df78e3476', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Various modem applications base on an image produced by lens uses refraction, such as
6
. And a spectrum of colors from a beam of light can be produced with
7
. Harriot travelled to Virginia and mainly did research which focused on two subjects of American
8
. After, he also enters upon a study of flight dynamics and
9
for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of
10
.

Various modem applications base on an image produced by lens uses refraction, such as 6 ____ . And a spectrum of colors from a beam of light can be produced with 7 ____ . Harriot travelled to Virginia and mainly did research which focused on two subjects of American 8 ____ . After, he also enters upon a study of flight dynamics and 9 ____ for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of 10 ____ .$md$, NULL, ARRAY['.*magnification.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('635b8409-7ff5-582f-85f4-92dcfde1b7c7', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Various modem applications base on an image produced by lens uses refraction, such as
6
. And a spectrum of colors from a beam of light can be produced with
7
. Harriot travelled to Virginia and mainly did research which focused on two subjects of American
8
. After, he also enters upon a study of flight dynamics and
9
for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of
10
.

Various modem applications base on an image produced by lens uses refraction, such as 6 ____ . And a spectrum of colors from a beam of light can be produced with 7 ____ . Harriot travelled to Virginia and mainly did research which focused on two subjects of American 8 ____ . After, he also enters upon a study of flight dynamics and 9 ____ for one of his friends much ahead of major European competitor. He undertook extensive other studies which were only noted down personally yet predated than many other great scientists. One result, for example, corrected the misconception about the idea of 10 ____ .$md$, NULL, ARRAY['.*magnification.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Look at the following researchers (listed
A-D
) and findings.
Match each researcher with the correct finding.
Write your answers in boxes
11-14
on your answer sheet.
NB
You may use any researcher more than once
.
A
Willobrord Snell
B
Johannes Kepler
C
Ptolemy
D
Galileo
E
Harriot
11
discovered the moons of Jupiter
12
distracted experimental calculation on refraction
13
the discovery of sunspots
14
the person whose name the sin law was attributed to

11 ____ discovered the moons of Jupiter$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94a6f4a0-0345-5c98-9e13-1d4d86cc2ddb', '70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8224b934-fbff-5531-9da5-eebb12cdaccd', '70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('445956f9-82a5-5f35-b0e7-5a4060de6a39', '70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97072af9-c4a5-5704-bc32-a137efa28f02', '70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce62753e-2644-535f-9b15-4441ae6eb8f3', '70c0cd10-80bd-558f-85bc-c8ea5d3e02cb', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65b31431-97c6-5055-9ee4-6c8e7a4c0743', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Look at the following researchers (listed
A-D
) and findings.
Match each researcher with the correct finding.
Write your answers in boxes
11-14
on your answer sheet.
NB
You may use any researcher more than once
.
A
Willobrord Snell
B
Johannes Kepler
C
Ptolemy
D
Galileo
E
Harriot
11
discovered the moons of Jupiter
12
distracted experimental calculation on refraction
13
the discovery of sunspots
14
the person whose name the sin law was attributed to

12 ____ distracted experimental calculation on refraction$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbc1473f-cec6-557d-ae54-c93b91d11ba6', '65b31431-97c6-5055-9ee4-6c8e7a4c0743', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c88f3601-4a08-5a8a-a105-48f0f03bc53d', '65b31431-97c6-5055-9ee4-6c8e7a4c0743', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68e289c5-6009-5572-890d-be44be777f4a', '65b31431-97c6-5055-9ee4-6c8e7a4c0743', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37946804-5d24-5ee5-8fdb-9a9beda1b9dc', '65b31431-97c6-5055-9ee4-6c8e7a4c0743', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e17e06-2e5e-5064-b4a4-2c10b65d87da', '65b31431-97c6-5055-9ee4-6c8e7a4c0743', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1565d040-c87d-5223-8941-1813be7edf73', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Look at the following researchers (listed
A-D
) and findings.
Match each researcher with the correct finding.
Write your answers in boxes
11-14
on your answer sheet.
NB
You may use any researcher more than once
.
A
Willobrord Snell
B
Johannes Kepler
C
Ptolemy
D
Galileo
E
Harriot
11
discovered the moons of Jupiter
12
distracted experimental calculation on refraction
13
the discovery of sunspots
14
the person whose name the sin law was attributed to

13 ____ the discovery of sunspots$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d30d5a1-9b30-52fb-a56a-c33155c33297', '1565d040-c87d-5223-8941-1813be7edf73', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d1dd1c0-1d04-5130-bda2-7d012e31d095', '1565d040-c87d-5223-8941-1813be7edf73', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb09c5d9-35c0-55a6-a43e-e7c9c1bd7c5a', '1565d040-c87d-5223-8941-1813be7edf73', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67815e03-4fca-59f2-8cd5-22c5ba4851cf', '1565d040-c87d-5223-8941-1813be7edf73', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9fc3e33-0cae-5424-b649-a255314bbe6b', '1565d040-c87d-5223-8941-1813be7edf73', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eae854a5-315d-5eb3-962b-63c3e8f03383', 'ea37b54a-202b-59dd-841e-0f5b72b06777', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Look at the following researchers (listed
A-D
) and findings.
Match each researcher with the correct finding.
Write your answers in boxes
11-14
on your answer sheet.
NB
You may use any researcher more than once
.
A
Willobrord Snell
B
Johannes Kepler
C
Ptolemy
D
Galileo
E
Harriot
11
discovered the moons of Jupiter
12
distracted experimental calculation on refraction
13
the discovery of sunspots
14
the person whose name the sin law was attributed to

14 ____ the person whose name the sin law was attributed to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('007d1625-71e7-5353-88de-146a0865a9c2', 'eae854a5-315d-5eb3-962b-63c3e8f03383', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('130ead39-d6c9-56c7-a662-497c698c4c0c', 'eae854a5-315d-5eb3-962b-63c3e8f03383', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('013384b3-ee2a-516f-aae7-e2d41e4d937d', 'eae854a5-315d-5eb3-962b-63c3e8f03383', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3fecfd4-735a-5cd4-b9a1-ba3895c7b826', 'eae854a5-315d-5eb3-962b-63c3e8f03383', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ba50a25-de94-5dce-9724-8f0f7f4ba4fd', 'eae854a5-315d-5eb3-962b-63c3e8f03383', 5, $md$E$md$, false);

COMMIT;
