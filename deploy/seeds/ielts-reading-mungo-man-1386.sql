BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mungo-man-1386'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mungo-man-1386';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mungo-man-1386';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mungo-man-1386';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4bed043d-1017-5523-b2e2-fc7ae130dbf0', 'ielts-reading-mungo-man-1386', $t$Mungo Man$t$, $md$## Mungo Man

Nguồn:
- Test: https://mini-ielts.com/1386/reading/mungo-man
- Solution: https://mini-ielts.com/1386/view-solution/reading/mungo-man$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b092b3b5-42c1-555e-975f-355de1810fdd', '4bed043d-1017-5523-b2e2-fc7ae130dbf0', 1, $t$Reading — Mungo Man$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Mungo Man

A

Fifty thousand years ago, a lush landscape greeted the first Australians making their way towards the south-east of the continent. Temperatures were cooler than now. Megafauna – giant prehistoric animals such as marsupial lions, goannas and the rhinoceros-sized diprotodon – were abundant. The Lake Mungo remains are three prominent sets of fossils which tell the archeologists the story: Mungo Man lived around the shores of Lake Mungo with his family. When he was young Mungo Man lost his two lower canine teeth, possible knocked out in a ritual. He grew into a man nearly 1.7m in height. Over the years his molar teeth became worn and scratched, possibly from eating a gritty diet or stripping the long leaves of water reeds with his teeth to make twine. As Mungo Man grew older his bones ached with arthritis, especially his right elbow, which was so damaged that bits of bone were completely worn out or broken away. Such wear and tear are typical of people who have used a woomera to throw spears over many years. Mungo Man reached a good age for the hard life of a hunter-gatherer and died when he was about 50. His family mourned for him, and carefully buried him in the lunette, on his back with his hands crossed in his lap, and sprinkled with red ochre. Mungo Man is the oldest known example in the world of such a ritual.

B

This treasure-trove of history was found by the University of Melbourne geologist Professor Jim Bowler in 1969. He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated. And in 1974, he found a second complete skeleton, Mungo Man, buried 300 metres away. Using carbon-dating, a technique only reliable to around 40,000 years old, the skeleton was first estimated at 28,000 to 32,000 years old. The comprehensive study of 25 different sediment layers at Mungo concludes that both graves are 40,000 years old.

C

This is much younger than the 62,000 years Mungo Man was attributed within 1999 by a team led by Professor Alan Thorne, of the Australian National University. The modern-day story of the science of Mungo also has its fair share of rivalry. Because Thorne is the country’s leading opponent of the Out of Africa theory – that Homo sapiens had a single place of origin. “Dr Alan Thorne supports the multi-regional explanation (that modern humans arose simultaneously in Africa, Europe and Asia from one of our predecessors, Homo erectus, who left Africa more than 1.5 million years ago.) if Mungo Man was descended from a person who had left Africa in the past 200,000 years, Thorne argues, then his mitochondrial DNA should have looked like that of the other samples.”

D

However, Out of Africa supporters are not about to let go of their beliefs because of the Australian research, Professor Chris Stringer, from the Natural History Museum in London, UK, said that the research community would want to see the work repeated in other labs before major conclusions were drawn from the Australian research. But even assuming the DNA sequences were correct, Professor Stringer said it could just mean that there was much more genetic diversity in the past than was previously realised. There is no evidence here that the ancestry of these Australian fossils goes back a million or two million years. It’s much more likely that modern humans came out of Africa.” For Bowler, these debates are irritating speculative distractions from the study’s main findings. At 40,000 years old, Mungo Man and Mungo Lady remain Australian’s oldest human burials and the earliest evidence on Earth of cultural sophistication, he says. Modern humans had not even reached North America by this time. In 1997, Pddbo’s research group recovered an mtDNA fingerprint from the Feldholer Neanderthal skeleton uncovered in Germany in 1865 – the first Neanderthal remains ever found.

E

In its 1999 study, Thorne’s team used three techniques to date Mungo Man at 62,000 years old, and it stands by its figures. It dated bone, teeth enamel and some sand. Bowler has strongly challenged the results ever since. Dating human bones is “notoriously unreliable”, he says. As well, the sand sample Thorne’s group dated was taken hundreds of metres from the burial site. “You don’t have to be a gravedigger … to realize the age of the sand is not the same as the age of the grave,” says Bowler.

F

Thorne counters that Bowler’s team used one dating technique, while he used three. The best practice is to have at least two methods produce the same result. A Thorne team member, Professor Rainer Grün, says the fact that the latest results were consistent between laboratories doesn’t mean they are absolutely correct. We now have two data sets that are contradictory. I do not have a plausible explanation.” Now, however, Thorne says the age of Mungo Man is irrelevant to this origins debate. Recent fossils find show modern humans were in China 110,000 years ago. “So he has got a long time to turn up in Australia. It doesn’t matter if he is 40,000 or 60,000 years old.

G

Dr Tim Flannery, a proponent of the controversial theory that Australia’s megafauna were wiped out 46,000 years ago in a “blitzkrieg” of hunting by the arriving people, also claims the new Mungo dates support this view. In 2001 a member of Bowler’s team, Dr Richard Roberts of Wollongong University, along with Flannery, director of the South Australian Museum, published research on their blitzkrieg theory. They dated 28 sites across the continent, arguing their analysis showed the megafauna died out suddenly 46,000 years ago. Flannery praises the Bowler team’s research on Mungo Man as “the most thorough and rigorous dating” of ancient human remains. He says the finding that humans arrived at Lake Mungo between 46,000 and 50,000 years ago was a critical time in Australia’s history. There is no evidence of a dramatic climatic change then, he says. “It’s my view that humans arrived and extinction took place in almost the same geological instant.”

H

Bowler, however, is skeptical of Flannery’s theory and says the Mungo study provides no definitive new evidence to support it. He argues that climate change at 40,000 years ago was more intense than had been previously realized and could have played a role in the megafauna’s demise. “To blame the earliest Australians for their complete extinction is drawing a longbow.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33468767-36ee-5cfd-8aae-28618a194a89', 'b092b3b5-42c1-555e-975f-355de1810fdd', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

1 ____ He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9976abd3-1e3f-5ebe-8b8d-cfc57304c6ff', '33468767-36ee-5cfd-8aae-28618a194a89', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17660521-a7ba-5048-b868-b376e02fe1e6', '33468767-36ee-5cfd-8aae-28618a194a89', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97e47180-e121-5a14-9806-b691ca091c00', '33468767-36ee-5cfd-8aae-28618a194a89', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f35de217-d3b3-542f-985e-9e9369f6a6a6', '33468767-36ee-5cfd-8aae-28618a194a89', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f631d2f-46e7-539a-baaa-2906327da841', '33468767-36ee-5cfd-8aae-28618a194a89', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dfc2973-5d37-57c1-8cc7-3fed78cd883d', '33468767-36ee-5cfd-8aae-28618a194a89', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1ea36139-8f3b-522b-b7ed-04876f03f0d1', 'b092b3b5-42c1-555e-975f-355de1810fdd', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

2 ____ Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbaaebe3-95cc-58a7-9656-4c808f7a86da', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aacb9733-a76f-5b21-91c8-db5669e69fbb', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aa04a7c-4a63-57d7-8be3-0197af123165', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbcc4aec-1da2-59d8-905b-958e15cc0ba7', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('583cd1f4-cd5c-5d12-b7e3-f197e6fb2e10', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f97b1b20-3859-5267-a955-cb505778d6eb', '1ea36139-8f3b-522b-b7ed-04876f03f0d1', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9137615-a69a-5904-9e0b-c9916a79b756', 'b092b3b5-42c1-555e-975f-355de1810fdd', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

3 ____ Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49635360-095e-5139-bfa1-c738fad8203d', 'd9137615-a69a-5904-9e0b-c9916a79b756', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c5a4754-dfb2-5768-96bf-e523446669fb', 'd9137615-a69a-5904-9e0b-c9916a79b756', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aa9be62-7e3b-56bb-ad63-0ca352fcefc6', 'd9137615-a69a-5904-9e0b-c9916a79b756', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c3a205-1583-51ca-95d0-7b83dfa78546', 'd9137615-a69a-5904-9e0b-c9916a79b756', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0b288d4-3010-5e8c-838c-752b8773b579', 'd9137615-a69a-5904-9e0b-c9916a79b756', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf12dc1-425d-5e57-b194-5320b7e48734', 'd9137615-a69a-5904-9e0b-c9916a79b756', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 'b092b3b5-42c1-555e-975f-355de1810fdd', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

4 ____ determining the age of Mungo Man has little to do with controversy for the origins of Australians.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6265a726-6a52-56a1-8516-c787c7280dfe', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0c3b778-de77-51de-9be2-2af1619dc209', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04c04124-402f-5be1-8db9-ee97086d872d', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51983b69-1f35-5e09-92dc-ba82ec4fa947', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bb941e8-d923-5e1d-8930-798443e3777c', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85ca5e3a-153d-513d-9144-869eaafb3b3a', 'f52640e7-f98e-5c3a-840d-bcee0c9d1e9c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb3717a3-b2d3-5010-8f82-a14f988d880c', 'b092b3b5-42c1-555e-975f-355de1810fdd', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

5 ____ research group who recovered a biological proof of the first Neanderthal found in Europe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be46e68c-17a0-54b6-89b5-97434ca40d22', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98823be2-0e87-57e7-a5f3-0d7fc33a1421', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e77d6b16-49c6-581e-a40a-85e3e58febb2', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22310d53-3043-50da-aa8c-2b330aee3f7a', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a86e7584-4794-524d-8f53-fb1d4b1770f4', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8353cc2b-1b85-5b41-86b4-0f63a17655c4', 'bb3717a3-b2d3-5010-8f82-a14f988d880c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('13584f87-bfb9-5823-8390-ce57bf788c30', 'b092b3b5-42c1-555e-975f-355de1810fdd', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

6 ____ a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fd49a8b-276a-52c8-9e5f-68e47486ab39', '13584f87-bfb9-5823-8390-ce57bf788c30', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb715bd1-3623-5ba2-96e4-acde7aca395e', '13584f87-bfb9-5823-8390-ce57bf788c30', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b8ee997-e0f5-52dc-8679-1657deb15d15', '13584f87-bfb9-5823-8390-ce57bf788c30', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4795f7ef-1de0-5a4d-8c9f-f4f9c40b2de3', '13584f87-bfb9-5823-8390-ce57bf788c30', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2abb8a1c-5cf5-5fea-a9ae-84bc8f0f3139', '13584f87-bfb9-5823-8390-ce57bf788c30', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3e0ae5f-816c-5042-89f8-e8fd3bcb8b56', '13584f87-bfb9-5823-8390-ce57bf788c30', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 'b092b3b5-42c1-555e-975f-355de1810fdd', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

7 ____ Instead of keep arguing a single source origin, multi-regional explanation has been raised.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54e328b8-06d2-56f3-b52c-c2e9b5096c8e', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b16eb70-225e-5468-bd25-93509371725d', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('634b0dcd-014f-5524-9b8c-28a51f2964c1', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1abcc7c-4aa4-59cc-95ae-113de8a268dd', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('546ad668-1547-5451-ac64-0f7924aeb528', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e60ed149-6b87-53a8-9c07-d813de5b1f24', '1a052c3e-c6fe-53bf-a3d2-b42c39d177eb', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df734a80-4c54-58bb-aae2-f91bd2f827dd', 'b092b3b5-42c1-555e-975f-355de1810fdd', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once.
A
Jim Bowler
B
Alan Thorne
C
Pddbo
D
Tim Flannery
E
Chris Stringer
F
Rainer Grün
1
He was searching for ancient lakes and came across the charred remains of Mungo Lady, who had been cremated.
2
Professor who hold a skeptical attitude towards reliability for DNA analysis on some fossils.
3
Professor whose determination of the age of Mungo Man to be much younger than the former result which is older than the 62,000 years.
4
determining the age of Mungo Man has little to do with controversy for the origins of Australians.
5
research group who recovered a biological proof of the first Neanderthal found in Europe.
6
a supporter of the idea that Australia’s megafauna was extinct due to the hunting by the ancient human beings.
7
Instead of keep arguing a single source origin, multi-regional explanation has been raised.
8
Climate change rather than prehistoric human activities resulted in megafauna’s extinction.

8 ____ Climate change rather than prehistoric human activities resulted in megafauna’s extinction.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eef81dbc-930a-50cb-89eb-64b9ae4899e3', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ff4f148-5c77-5316-a32b-cdc045a5e0d3', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97cc5edf-7631-5354-9a6c-b8dc790e60e5', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('371a099e-7630-5eb2-8029-6d7f9944afa5', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59bd180a-d565-55f3-83c4-83c3c23778da', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('959c551b-a139-599b-a6b9-8143cab1dbbb', 'df734a80-4c54-58bb-aae2-f91bd2f827dd', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a60708bd-2287-549b-9f7f-533bf60822da', 'b092b3b5-42c1-555e-975f-355de1810fdd', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

9 ____ The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23f550e9-3360-51e4-803d-e42839e053c2', 'a60708bd-2287-549b-9f7f-533bf60822da', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5a5dd30-d3ee-5518-bce6-206d94be5fab', 'a60708bd-2287-549b-9f7f-533bf60822da', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2caab97-0e71-56aa-a9ba-90582256d4d6', 'a60708bd-2287-549b-9f7f-533bf60822da', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1558b22d-aefa-55a6-a40b-71f027537b53', 'b092b3b5-42c1-555e-975f-355de1810fdd', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

10 ____ In Lake Mungo remains, weapons were found used by the Mungo.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21a03ba6-60cb-5850-9d3e-774e13eb7b2b', '1558b22d-aefa-55a6-a40b-71f027537b53', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63b11792-544a-5ee2-982d-e8a3911c0652', '1558b22d-aefa-55a6-a40b-71f027537b53', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('767ee709-2c7c-527e-9791-fbf708d8223b', '1558b22d-aefa-55a6-a40b-71f027537b53', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33ae242c-27be-54a5-85fc-b7e563b97d65', 'b092b3b5-42c1-555e-975f-355de1810fdd', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

11 ____ Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3badf09-79da-50ca-b1b5-2bc8efe7079f', '33ae242c-27be-54a5-85fc-b7e563b97d65', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fe7c6fb-f523-5a52-87e0-abb305d33b59', '33ae242c-27be-54a5-85fc-b7e563b97d65', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('860a3a78-9b38-5363-ad40-d2994799c473', '33ae242c-27be-54a5-85fc-b7e563b97d65', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('487a8e53-f4c2-56c6-be56-655f8691bab9', 'b092b3b5-42c1-555e-975f-355de1810fdd', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

12 ____ Mungo Man and woman’s skeletons were uncovered in the same year.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7964244-ac6e-5afe-9269-93746ae71e51', '487a8e53-f4c2-56c6-be56-655f8691bab9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff3838b1-9f67-57c4-ac8c-5ae52cfd775e', '487a8e53-f4c2-56c6-be56-655f8691bab9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fcbafbd-a263-5768-a291-4b319f82aa13', '487a8e53-f4c2-56c6-be56-655f8691bab9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b52a357a-1685-5d1a-8a06-cee600941cfa', 'b092b3b5-42c1-555e-975f-355de1810fdd', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

13 ____ There is controversy among scientists about the origin of the oldest Homo sapiens.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04e9c6b3-355c-5c0c-b246-a7cf1c00e144', 'b52a357a-1685-5d1a-8a06-cee600941cfa', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28a4c7e8-f65a-5380-8ea2-7b198f5fb5d0', 'b52a357a-1685-5d1a-8a06-cee600941cfa', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('646c7e1d-9141-5a26-94a8-57b3a6d5c79c', 'b52a357a-1685-5d1a-8a06-cee600941cfa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33d596c5-95ed-5ddb-8011-e2fb8475dc7f', 'b092b3b5-42c1-555e-975f-355de1810fdd', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
9
The Lake Mungo remains offer the archeologists the evidence of graphic illustration of human activities around.
10
In Lake Mungo remains, weapons were found used by the Mungo.
11
Mungo Man is one of the oldest known archeological evidence in the world of cultural sophistication such as a burying ritual.
12
Mungo Man and woman’s skeletons were uncovered in the same year.
13
There is controversy among scientists about the origin of the oldest Homo sapiens.
14
Out of Africa supporters have criticised Australian professors for using an outmoded research method.

14 ____ Out of Africa supporters have criticised Australian professors for using an outmoded research method.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0412a899-79b3-567b-9eaa-622b235d7398', '33d596c5-95ed-5ddb-8011-e2fb8475dc7f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2b38f2b-ea37-508a-bfc6-48ea36a3251b', '33d596c5-95ed-5ddb-8011-e2fb8475dc7f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f043b73b-ee18-57cf-a93e-cf113dcec07d', '33d596c5-95ed-5ddb-8011-e2fb8475dc7f', 3, $md$NOT GIVEN$md$, true);

COMMIT;
