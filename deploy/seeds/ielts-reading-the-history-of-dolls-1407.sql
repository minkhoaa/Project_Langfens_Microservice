BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-dolls-1407'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-dolls-1407';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-dolls-1407';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-dolls-1407';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c542454c-c7d8-5490-9f03-57f884561d85', 'ielts-reading-the-history-of-dolls-1407', $t$The History of Dolls$t$, $md$## The History of Dolls

Nguồn:
- Test: https://mini-ielts.com/1407/reading/the-history-of-dolls
- Solution: https://mini-ielts.com/1407/view-solution/reading/the-history-of-dolls$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5d9d6879-e631-5a84-a66d-15e583712ea8', 'c542454c-c7d8-5490-9f03-57f884561d85', 1, $t$Reading — The History of Dolls$t$, $md$Read the passage and answer questions **1–0**.

### Passage: The History of Dolls

Dolls have been a part of humankind since prehistoric times. Used to depict religious figures or used as playthings, early dolls were probably made from primitive materials such as clay, fur, or wood. No dolls have survived from prehistoric times, although a fragment of an alabaster doll with movable arms from the Babylonian period was recovered.

Dolls constructed of flat pieces of wood, painted with various designs and with “hair” made of strings of clay or wooden beads, have often been found in Egyptian graves dating back to 2000 BC. Egyptian tombs of wealthy families have included pottery dolls . Dolls placed in these graves leads some to believe that they were cherished possessions.

Dolls were also buried in Greek and Roman children’s graves. Girls from Greece and Rome dedicated their wooden dolls to goddesses after they were too “grown-up” to play with dolls.

Most ancient dolls that were found in children’s tombs were very simple creations, often made from such materials as clay, rags, wood, or bone. Some of the more unique dolls were made with ivory or wax . The main goal was to make the doll as “ lifelike” as possible . That ideal lead to the creation of dolls with movable limbs and removable garments, dating back to 600 B.C.

Following the era of the ancient dolls, Europe became a major hub for doll production. These dolls were primarily made of wood. Primitive wooden stump dolls from 16th and 17th century England number less than 30 today. The Grodnertal area of Germany produced many peg wooden dolls, a type of doll that has very simple peg joints and resembles a clothespin.

An alternative to wood was developed in the 1800s . Composition is a collective term for mixtures of pulped wood or paper that were used to make doll heads and bodies. These mixtures were molded under pressure, creating a durable doll that could be mass produced. Manufacturers closely guarded the recipes for their mixtures, sometimes using strange ingredients like ash or eggshells . Papier-mache , a type of composition, was one of the most popular mixtures.

In addition to wooden dolls, wax dolls were popular in the 17th and 18th centuries. Munich was a major manufacturing center for wax dolls, but some of the most distinctive wax dolls were created in England between 1850 and 1930. Wax modelers would model a doll head in wax or clay, and then use plaster to create a mold from the head. Then they would pour melted wax into the cast. The wax for the head would be very thin, no more than 3 mm. One of the first dolls that portrayed a baby was made in England from wax at the beginning of the 19th century.

Porcelain became popular at the beginning of the 19th century. Porcelain is made by firing special clays in a kiln at more than 2372 degrees Fahrenheit. Only a few clays can withstand firing at such high temperatures. Porcelain is used generically to refer to both china and bisque dolls . China is glazed, whereas bisque is unglazed . Germany, France, and Denmark started creating china heads for dolls in the 1840s. China heads were replaced by heads made of bisque in the 1860s. Bisque, which is fired twice with color added to it after the first firing, looked more like skin than china did.$md$, NULL, NULL);

COMMIT;
