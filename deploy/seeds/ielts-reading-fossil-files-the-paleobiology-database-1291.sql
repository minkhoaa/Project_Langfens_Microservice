BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-fossil-files-the-paleobiology-database-1291'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fossil-files-the-paleobiology-database-1291';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fossil-files-the-paleobiology-database-1291';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-fossil-files-the-paleobiology-database-1291';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c2693db8-03b9-5c95-bf62-776fbf85b59d', 'ielts-reading-fossil-files-the-paleobiology-database-1291', $t$Fossil Files “The Paleobiology Database”$t$, $md$## Fossil Files “The Paleobiology Database”

Nguồn:
- Test: https://mini-ielts.com/1291/reading/fossil-files-the-paleobiology-database
- Solution: https://mini-ielts.com/1291/view-solution/reading/fossil-files-the-paleobiology-database$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 'c2693db8-03b9-5c95-bf62-776fbf85b59d', 1, $t$Reading — Fossil Files “The Paleobiology Database”$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Fossil Files “The Paleobiology Database”

A . Are we now living through the sixth extinction as our own activities destroy ecosystems and wipe out diversity? That’s the doomsday scenario painted by many ecologists, and they may well be right. The trouble is we don’t know for sure because we don’t have a clear picture of how life changes between extinction events or what has happened in previous episodes. We don’t even know how many species are alive today, let alone the rate at which they are becoming extinct. A new project aims to fill some of the gaps. The Paleobiology Database aspires to be an online repository of information about every fossil ever dug up. It is a huge undertaking that has been described as biodiversity’s equivalent of the Human Genome Project. Its organizers hope that by recording the history of biodiversity they will gain an insight into how environmental changes have shaped life on Earth in the past and how they might do so in the future. The database may even indicate whether life can rebound no matter what we throw at it, or whether a human induced extinction could be without parallel, changing the rules that have applied throughout the rest of the planet’s history.

B . But already the project is attracting harsh criticism. Some experts believe it to be seriously flawed. They point out that a database is only as good as the data fed into it, and that even if all the current fossil finds were catalogued, they would provide an incomplete inventory of life because we are far from discovering every fossilised species. They say that researchers should get up from their computers and get back into the dirt to dig up new fossils. Others are more sceptical still, arguing that we can never get the full picture because the fossil record is riddled with holes and biases.

C . Fans of the Paleobiology Database acknowledge that the fossil record will always be incomplete. But they see value in looking for global patterns that show relative changes in biodiversity. “The fossil record is the best tool we have for understanding how diversity and extinction work in normal times,” says John Alroy from the National Center for Ecological Analysis and Synthesis in Santa Barbara. “Having a background extinction estimate gives US a benchmark for understanding the mass extinction that’s currently under way. It allows us to say just how bad it is in relative terms.”

D . To this end, the Paleobiology Database aims to be the most thorough attempt yet to come up with good global diversity curves. Every day between 10 and 15 scientists around the world add information about fossil finds to the database. Since it got up and running in 1998, scientists have entered almost 340,000 specimens, ranging from plants to whales to insects to dinosaurs to sea urchins. Overall totals are updated hourly at www.paleodb.org. Anyone can download data from the public part of the site and play with the numbers to their heart’s content. Already, the database has thrown up some surprising results. Looking at the big picture, Alroy and his colleagues believe they have found evidence that biodiversity reached a plateau long ago, contrary to the received wisdom that species numbers have increased continuously between extinction events. “The traditional view is that diversity has gone up and up and up,” he says. “Our research is showing that diversity limits were approached many tens of millions of years before the dinosaurs evolved, much less suffered extinction.” This suggests that only a certain number of species can live on Earth at a time, filling a prescribed number of niches like spaces in a multi-storey car park. Once it’s full, no more new species can squeeze in, until extinctions free up new spaces or something rare and catastrophic adds a new floor to the car park.

E . Alroy has also used the database to reassess the accuracy of species names. His findings suggest that irregularities in classification inflate the overall number of species in the fossil record by between 32 and 44 per cent. Single species often end up with several names, he says, due to misidentification or poor communication between taxonomists in different countries. Repetition like this can distort diversity curves. “If you have really bad taxonomy in one short interval, it will look like a diversity spike—a big diversification followed by a big extinction-when all that has happened is a change in the quality of names,” says Alroy. For example, his statistical analysis indicates that of the 4861 North American fossil mammal species catalogued in the database, between 24 and 31 per cent will eventually prove to be duplicates.

F . Of course, the fossil record is undeniably patchy. Some places and times have left behind more fossil-filled rocks than others. Some have been sampled more thoroughly. And certain kinds of creatures—those with hard parts that lived in oceans, for example–are more likely to leave a record behind, while others, like jellyfish, will always remain a mystery. Alroy has also tried to account for this. He estimates, for example, that only 41 per cent of North American mammals that have ever lived are known from fossils, and he suspects that a similar proportion of fossils are missing from other groups, such as fungi and insects.

G . Not everyone is impressed with such mathematical wizardry. Jonathan Adrain from the University of Iowa in Iowa City points out that statistical wrangling has been known to create mass extinctions where none occurred. It is easy to misinterpret data. For example, changes in sea level or inconsistent sampling methods can mimic major changes in biodiversity. Indeed, a recent and thorough examination of the literature on marine bivalve fossils has convinced David Jablonsky from the University of Chicago and his colleagues that their diversity has increased steadily over the past 5 million years.

H . With an inventory of all living species, ecologists could start to put the current biodiversity crisis in historical perspective. Although creating such a list would be a task to rival even the Palaeobiology Database, it is exactly what the San Francisco-based ALL Species Foundation hopes to achieve in the next 25 years. The effort is essential, says Harvard biologist Edward o. Wilson, who is alarmed by current rates of extinction. “There is a crisis. We’ve begun to measure it, and it’s very high,” Wilson says. “We need this kind of information in much more detail to protect all of biodiversity, not just the ones we know well.” Let the counting continue.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf605403-4070-54a6-9eb9-6f6825d5c66b', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3ed68ef-e2a9-5274-9bb8-52d3c2fb4197', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c7526c6-da65-5d04-927c-055b5ef574cb', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8657f885-0ddb-5ab3-b792-5101fcbb85f8', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba43a60a-e0fb-5f07-b515-31018ac1f544', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cde7f980-bfc6-5958-897b-c5a67fd1425b', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('776da332-63d6-55e7-80c1-44c4bf7a19fc', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b70537cb-23d2-579e-abd6-3c8da9ca01a0', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bb1d4bd-015a-5cc9-ad43-a090dcd94154', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b296de37-91c7-5f00-b87e-d39cc7db6aed', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1bd8822-c936-56b4-8ab3-20abeb9b7254', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fd72df8-f1be-5a81-8a3c-f1aa311904e0', 'bf605403-4070-54a6-9eb9-6f6825d5c66b', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22bd2860-0f15-59c8-8e06-2803f150a8ed', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8a6763b-1d13-56de-b4f6-d202088c16be', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89671fbf-ae53-5c7a-a122-642931d72359', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da3380ae-d02f-58ba-8edc-3e86928b2322', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4774655-cbcd-5b4a-bc3b-ea52f6bbc82a', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0cfce56-a3ca-5a52-b18b-4577fa74b87a', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a78fd4d-8107-5821-8abe-1ac809a01d31', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a1b5f56-b14e-5d6c-afb5-e7ba7e30adc9', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f954ee3-e6b0-5e06-901a-cf7ceb0dd8eb', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18e2ab68-9165-5c8c-b66d-93a50ff28436', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('248c5788-cd34-5ca9-a1ab-7ceaf241e676', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c45b5183-f577-5f5e-85fb-08e923eac852', '22bd2860-0f15-59c8-8e06-2803f150a8ed', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a47baf5e-0894-5142-8366-87ee68070ee6', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph c$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ea43a40-02a3-5b0c-a230-3eaaadcdace4', 'a47baf5e-0894-5142-8366-87ee68070ee6', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66750be2-e898-5fa4-988b-94590077f70c', 'a47baf5e-0894-5142-8366-87ee68070ee6', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa85f8fd-5062-5ee8-92ee-67c230ddc30e', 'a47baf5e-0894-5142-8366-87ee68070ee6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c78edd36-9a52-51a3-873a-08e836a5de8a', 'a47baf5e-0894-5142-8366-87ee68070ee6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68bdfa46-0197-5446-bf25-13bd394a8af9', 'a47baf5e-0894-5142-8366-87ee68070ee6', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b0d722d-9ea9-5a91-967c-8c17b43725bc', 'a47baf5e-0894-5142-8366-87ee68070ee6', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4772df85-3600-52a1-a604-8af0368692ee', 'a47baf5e-0894-5142-8366-87ee68070ee6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21f2b038-06de-5a7c-b381-cd4dd6399955', 'a47baf5e-0894-5142-8366-87ee68070ee6', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3d896fa-7ee7-525b-9ba7-f4913f4ea44b', 'a47baf5e-0894-5142-8366-87ee68070ee6', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ddc9332-4eec-5047-91b4-6b7ed7deed31', 'a47baf5e-0894-5142-8366-87ee68070ee6', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab1a59ba-a79d-5001-82a3-a3d6101f1bf1', 'a47baf5e-0894-5142-8366-87ee68070ee6', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fadaa13-2cf2-5f57-82cf-e93f14db880e', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70dc0830-34ab-5952-a4bc-8d53213cde60', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f60b0d33-72db-5f02-a0b8-c8de40129167', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f550895-77af-57de-96a9-79e619cc9f49', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c1aa15-a1d5-581b-b75d-0ad00fbcddfe', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c79996bc-dff5-514d-8d7c-325e56b67064', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a32c0a0b-b55a-545f-b88d-f6f85b28a3bd', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('767f4d68-541a-5787-8e05-db0053ab4cfe', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dc9350f-377a-51ab-927c-3e8f5db91f89', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f185f187-decf-56ab-a1d4-d1c108c092e3', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b5e96f7-6b02-5370-85a8-3f38dd65194d', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a129241-ded4-5f85-9467-14b7251d2bf2', '0fadaa13-2cf2-5f57-82cf-e93f14db880e', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff08193d-de77-5bf6-8476-fc5c20f6c217', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48018608-1998-5801-b32b-1012d5b828fa', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eea952f8-4719-5acb-968e-f745f2d0000c', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40c784e3-0856-51e2-b2df-80dff550b5a8', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4346318f-aeb6-5464-86b6-1ecfabd6f0ba', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d878be7f-855e-5ebe-83b0-6c727c7d5c1c', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('484d6428-4fcd-5e6b-bea9-d31d28edb931', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0c762ca-852d-5f36-9a28-5052d970a379', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('461fea68-8511-56a4-b421-518e4110eee1', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c8fa5ad-d2f7-5676-aea0-641edc0b16ce', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5fb3ceb-2968-5fa7-9ad4-941baa05ea0c', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('816200d4-ffd5-5277-acf5-708d79dc9fd4', 'ff08193d-de77-5bf6-8476-fc5c20f6c217', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d43c76d7-333b-525f-9309-37a635866d31', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. Potential error exists in the database
ii
. Supporter of database recleared its value
iii
. The purpose of this paleobiology data
iv
. Reason why some certain species were not included in it
v
. Duplication of breed but with different names
vi
. Achievement of Paleobiology Databasesince
vii
. Criticism on the project which is waste of fund
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('709a6d48-c57e-577f-869f-064efd629517', 'd43c76d7-333b-525f-9309-37a635866d31', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae85a7b2-2eca-58fa-8f61-c2b5f1f3331d', 'd43c76d7-333b-525f-9309-37a635866d31', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a15527f0-ac9f-58a4-a0e0-8afda40d469f', 'd43c76d7-333b-525f-9309-37a635866d31', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb21511f-b1d4-5ea2-adae-b4afbb2d0d9e', 'd43c76d7-333b-525f-9309-37a635866d31', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364e785f-2f75-557d-93aa-4afb26f55d42', 'd43c76d7-333b-525f-9309-37a635866d31', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92f2c4a4-43a6-51e1-a7de-6efd8e0b22f7', 'd43c76d7-333b-525f-9309-37a635866d31', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43ff956c-be49-5b54-a864-551fa62b02b6', 'd43c76d7-333b-525f-9309-37a635866d31', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dfd88fa-951a-5d90-badc-3f5bd0f4ebb9', 'd43c76d7-333b-525f-9309-37a635866d31', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84a783d5-59c0-5a5f-9bf4-3c58aa05c42e', 'd43c76d7-333b-525f-9309-37a635866d31', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5e6b169-6f0d-5049-8d73-0542cc1e8aae', 'd43c76d7-333b-525f-9309-37a635866d31', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4717166a-5c60-5df8-b8db-93f7f98cea84', 'd43c76d7-333b-525f-9309-37a635866d31', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd4ed872-14f4-5b7c-bcb4-fee8d46a6af1', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Use the information in the passage to match the people (listed
A-D)
with opinions or deeds below. Write the appropriate letters
A-D
in boxes
7-9
on your answer sheet.
A. Jonathan Adrain
B. John Alroy
C. David Jablonsky
D. Edward o. Wilson
7
Creating the Database would help scientist to identify connections of all species
8
Believed in contribution of detailed statistics should cover beyond the known species
9
reached a contradictory finding to the tremendous species die-out

7 ____ Creating the Database would help scientist to identify connections of all species$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e41601a5-47e7-50d4-9978-dbed12bd0767', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Use the information in the passage to match the people (listed
A-D)
with opinions or deeds below. Write the appropriate letters
A-D
in boxes
7-9
on your answer sheet.
A. Jonathan Adrain
B. John Alroy
C. David Jablonsky
D. Edward o. Wilson
7
Creating the Database would help scientist to identify connections of all species
8
Believed in contribution of detailed statistics should cover beyond the known species
9
reached a contradictory finding to the tremendous species die-out

8 ____ Believed in contribution of detailed statistics should cover beyond the known species$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94eb6da8-9c4d-5f50-8117-f37ab1abcab0', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Use the information in the passage to match the people (listed
A-D)
with opinions or deeds below. Write the appropriate letters
A-D
in boxes
7-9
on your answer sheet.
A. Jonathan Adrain
B. John Alroy
C. David Jablonsky
D. Edward o. Wilson
7
Creating the Database would help scientist to identify connections of all species
8
Believed in contribution of detailed statistics should cover beyond the known species
9
reached a contradictory finding to the tremendous species die-out

9 ____ reached a contradictory finding to the tremendous species die-out$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0710c685-a544-57c0-81f5-0b67e66386b7', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Question 12-13
Question 12-13
Choose the correct letter,
A, B, C or D
.
Write your answers in boxes
12-13
on your answer sheet.
12
. According to the passage, jellyfish belongs to which category of
The Paleobiology Database?
A
repetition breed
B
untraceable species
C
specifically detailed species
D
currently living creature
13
. What is the author’s suggestion
according to the end of passage?
A
continue to complete counting the number of species in the Paleobiology Database
B
stop contributing The Paleobiology Database
C
try to create a database of living creature
D
study more in the field rather than in the book

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c83e890-2108-5a78-9100-8ab4743b3c2e', '599ac36b-b6c8-5af1-bb1a-5ae0d2d725f5', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Question 12-13
Question 12-13
Choose the correct letter,
A, B, C or D
.
Write your answers in boxes
12-13
on your answer sheet.
12
. According to the passage, jellyfish belongs to which category of
The Paleobiology Database?
A
repetition breed
B
untraceable species
C
specifically detailed species
D
currently living creature
13
. What is the author’s suggestion
according to the end of passage?
A
continue to complete counting the number of species in the Paleobiology Database
B
stop contributing The Paleobiology Database
C
try to create a database of living creature
D
study more in the field rather than in the book

Choose the correct letter, A, B, C or D .$md$, NULL);

COMMIT;
