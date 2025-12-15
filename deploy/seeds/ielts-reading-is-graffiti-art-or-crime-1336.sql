BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-is-graffiti-art-or-crime-1336'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-is-graffiti-art-or-crime-1336';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-is-graffiti-art-or-crime-1336';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-is-graffiti-art-or-crime-1336';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a1b2e953-72e8-5b60-aef9-d9800942d3ca', 'ielts-reading-is-graffiti-art-or-crime-1336', $t$Is Graffiti Art or Crime$t$, $md$## Is Graffiti Art or Crime

Nguồn:
- Test: https://mini-ielts.com/1336/reading/is-graffiti-art-or-crime
- Solution: https://mini-ielts.com/1336/view-solution/reading/is-graffiti-art-or-crime$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('80ef0a65-4694-554b-aa6c-cc8b22669544', 'a1b2e953-72e8-5b60-aef9-d9800942d3ca', 1, $t$Reading — Is Graffiti Art or Crime$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Is Graffiti Art or Crime

A

The term graffiti derives from the Italian graffito meaning ‘scratching’ and can be defined as uninvited marking or writing scratched or applied to objects, built structures and natural features. It is not a new phenomenon: examples can be found on ancient structures around the world, in some cases predating the Greeks and Romans. In such circumstances it has acquired invaluable historical and archaeological significance, providing a social history of life and events at that time. Graffiti is now a problem that has become pervasive, as a result of the availability of cheap and quick means of mark-making.

B

It is usually considered a priority to remove graffiti as quickly as possible after it appears. This is for several reasons. The first is to prevent ‘copy-cat’ emulation which can occur rapidly once a clean surface is defaced. It may also be of a racist or otherwise offensive nature and many companies and councils have a policy of removing this type of graffiti within an hour or two of it being reported. Also, as paints, glues and inks dry out over time they can become increasingly difficult to remove and are usually best dealt with as soon as possible after the incident. Graffiti can also lead to move serious forms of vandalism and, ultimately, the deterioration of an area, contributing to social decline.

C

Although graffiti may be regarded as an eyesore, any proposal to remove it from sensitive historic surfaces should be carefully considered: techniques designed for more robust or utilitarian surfaces may result in considerable damage. In the event of graffiti incidents, it is important that the owners of buildings or other structures and their consultants are aware of the approach they should take in dealing with the problem. The police should be informed as there may be other related attacks occurring locally. An incidence pattern can identify possible culprits, as can stylised signatures or nicknames, known as ‘tags’, which may already be familiar to local police. Photographs are useful to record graffiti incidents and may assist the police in bringing a prosecution. Such images are also required for insurance claims and can be helpful in cleaning operatives, allowing them to see the problem area before arriving on site.

D

There are a variety of methods that are used to remove graffiti. Broadly these divide between chemical and mechanical systems. Chemical preparations are based on dissolving the media; these solvents can range from water to potentially hazardous chemical ‘cocktails’. Mechanical systems such as wire-brushing and grit-blasting attempt to abrade or chip the media from the surface. Care should be taken to comply with health and safety legislation with regard to the protection of both passers-by and any person carrying out the cleaning. Operatives should follow product guidelines in terms of application and removal, and wear the appropriate protective equipment. Measures must be taken to ensure that run-off, aerial mists, drips and splashes do not threaten unprotected members of the public. When examining a graffiti incident it is important to assess the ability of the substrate to withstand the prescribed treatment. If there is any doubt regarding this, then small trial areas should be undertaken to assess the impact of more extensive treatment.

E

A variety of preventive strategies can be adopted to combat a recurring problem of graffiti at a given site. As no two sites are the same, no one set of protection measures will be suitable for all situations. Each site must be looked at individually. Surveillance systems such as closed-circuit television may also help. In cities and towns around the country, prominently placed cameras have been shown to reduce anti-social behavior of all types including graffiti. Security patrols will also act as a deterrent to prevent recurring attacks. However, the cost of this may be too high for most situations. A physical barriers such as a wall, railings, doors or gates can be introduced to discourage unauthorized access to a vulnerable site. However, consideration has to be given to the impact measures have on the structure being protected. In the worst cases, they can be almost as damaging to the quality of the environment as the graffiti they prevent. In others, they might simply provide a new surface for graffiti.

F

One of the most significant problems associated with graffiti removal is the need to remove it from surfaces that are repeatedly attacked. Under these circumstances, the repeated removal of graffiti using even the most gentle methods will ultimately cause damage to the surface material. There may be situations where the preventive strategies mentioned above do not work or are not a viable proposition at a given site. Anti-graffiti coatings are usually applied by brush or spray leaving a thin veneer that essentially serves to isolate the graffiti from the surface.

G

Removal of graffiti from a surface that has been treated in this way is much easier, usually using low-pressure water which reduces the possibility of damage. Depending on the type of barrier selected it may be necessary to reapply the coating after each graffiti removal exercise.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfd2071d-6a32-5eae-97da-5d187162f560', '80ef0a65-4694-554b-aa6c-cc8b22669544', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

1 ____ why chemically cleaning graffiti may cause damage$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a8a115b-acee-5fb8-8fc8-685b84e2258b', 'bfd2071d-6a32-5eae-97da-5d187162f560', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e336a810-30d5-58c5-9b28-440532bcaa9c', 'bfd2071d-6a32-5eae-97da-5d187162f560', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('753f0af5-f4e0-53ec-bc67-bd2fe1c16626', 'bfd2071d-6a32-5eae-97da-5d187162f560', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87d99024-10d2-5475-9023-0ff3ed9051fe', 'bfd2071d-6a32-5eae-97da-5d187162f560', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11b6bd5f-42c1-54d7-9fc1-95877308e318', 'bfd2071d-6a32-5eae-97da-5d187162f560', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('405e24a5-f9ed-5fed-91a9-e4bd155bcd56', 'bfd2071d-6a32-5eae-97da-5d187162f560', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57fc0aa5-6685-5c67-b365-13aaadb802f8', 'bfd2071d-6a32-5eae-97da-5d187162f560', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac588ead-e518-5750-8ba3-654bd24ce22c', '80ef0a65-4694-554b-aa6c-cc8b22669544', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

2 ____ the benefit of a precautionary strategy on the gentle removal$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa967250-d658-5ced-b7f7-a4921bf22fcd', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bcbb068-1f39-5d7c-ba2a-4363ab4daeae', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1e49113-55b4-5049-aaf5-f4d1a7bca6e8', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe3dcc5-dd28-5d5f-94de-9d70ab0aae73', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7926ded-b200-5c5c-8ced-45f5c9a3a5b4', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48b7c619-9e29-5fdd-a93c-dac9579ae0e2', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bf251ad-26fa-5f3e-8df7-c6029a78857c', 'ac588ead-e518-5750-8ba3-654bd24ce22c', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae917396-c5fe-5f5e-9fe9-af7943a1edc1', '80ef0a65-4694-554b-aa6c-cc8b22669544', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

3 ____ the damaging and accumulative impact of graffiti on the community$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2294dfa7-8af6-55a7-a812-a13ea8805ef7', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71c48695-44b1-5310-8acf-3fb04b6aa569', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0be6793a-127e-5358-a92d-2885cbd6cfaf', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('227d557e-187a-5111-a6e2-93a7ce7f7c7d', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fa5c633-80b1-548b-a5af-0e607a0c8c73', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be5d0d6d-884d-5c91-ab93-a8df97162768', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39bf10c2-0bbe-5e57-a0dc-0c9ffe4ae751', 'ae917396-c5fe-5f5e-9fe9-af7943a1edc1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9dc6fd27-8748-5622-9916-126f25c97e43', '80ef0a65-4694-554b-aa6c-cc8b22669544', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

4 ____ the need for different preventive measures being taken to cope with graffiti$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e08c2cda-d45a-5006-ac11-8be3a1881207', '9dc6fd27-8748-5622-9916-126f25c97e43', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bcf997c-6385-5a95-b4ea-a963a575d419', '9dc6fd27-8748-5622-9916-126f25c97e43', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cf045ea-7949-58b3-9ec1-50f2279f2112', '9dc6fd27-8748-5622-9916-126f25c97e43', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bb6e6c1-edba-584c-a305-881b431f6d0c', '9dc6fd27-8748-5622-9916-126f25c97e43', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5454dc2d-5714-5e1d-99a2-72f435e0a00f', '9dc6fd27-8748-5622-9916-126f25c97e43', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10b21075-6903-5050-903d-5b3cd51f967f', '9dc6fd27-8748-5622-9916-126f25c97e43', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('251f04e1-1f88-5b91-b455-a93ba5fd2d03', '9dc6fd27-8748-5622-9916-126f25c97e43', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('acc4c6b7-bf40-5fce-9d25-08197d3f4924', '80ef0a65-4694-554b-aa6c-cc8b22669544', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

5 ____ a legal proposal made to the owner of building against graffiti$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a8e59ed-4cf0-5829-88ca-9a6dd0d17a7a', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87bb20d9-6d2b-5d0d-9402-6ca4c5b6581a', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b98d6da-97b0-5b46-8a0e-f099133d479f', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7627bc3-9cb6-5c04-8793-031e6b2303e6', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8103d4cc-2a02-5abe-9e39-ac217fc82c2b', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8916ceb8-9da1-58c1-be45-791201ddaab5', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c9fa41d-8b73-5870-a5ac-4c8add1fd252', 'acc4c6b7-bf40-5fce-9d25-08197d3f4924', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd383c50-7686-59c3-8449-c5b75a4f0339', '80ef0a65-4694-554b-aa6c-cc8b22669544', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
why chemically cleaning graffiti may cause damage
2
the benefit of a precautionary strategy on the gentle removal
3
the damaging and accumulative impact of graffiti on the community
4
the need for different preventive measures being taken to cope with graffiti
5
a legal proposal made to the owner of building against graffiti
6
the reasons for removing graffiti as soon as possible.

6 ____ the reasons for removing graffiti as soon as possible.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d38c8345-658a-56de-8a27-fddd41197ca4', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c270e3-0437-5534-a8ba-548cf691fd16', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c268ec1-eedf-592d-9808-1d5dabd0ba3e', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aebbf029-52b7-5852-88a7-2d10613d396f', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c483957a-7c2b-56c6-8d45-2ff845f614d5', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec657c46-6e7e-53ec-9edd-a4b3a10c720f', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9941d817-35fe-5850-9af6-479ec24141d7', 'fd383c50-7686-59c3-8449-c5b75a4f0339', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e75e04bf-f863-53ac-b273-5f0dc50ee1a6', '80ef0a65-4694-554b-aa6c-cc8b22669544', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the Summary of the paragraphs of Reading Passage.
Use
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Ancient graffiti is of significance and records the
11
of details life for that period.
The police can recognize newly committed incidents of graffiti by the signature which is called
12
that they are familiar with
Operatives ought to comply with relevant rules during the operation, and put on the suitable
13
Removal of graffiti from a new type of coating surface can be much convenient of using
14
.

Ancient graffiti is of significance and records the 11 ____ of details life for that period.$md$, NULL, ARRAY['.*social.*history.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('83bc4fb7-ef19-5816-ac27-3f2b15360a3f', '80ef0a65-4694-554b-aa6c-cc8b22669544', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the Summary of the paragraphs of Reading Passage.
Use
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Ancient graffiti is of significance and records the
11
of details life for that period.
The police can recognize newly committed incidents of graffiti by the signature which is called
12
that they are familiar with
Operatives ought to comply with relevant rules during the operation, and put on the suitable
13
Removal of graffiti from a new type of coating surface can be much convenient of using
14
.

The police can recognize newly committed incidents of graffiti by the signature which is called 12 ____ that they are familiar with$md$, NULL, ARRAY['.*tag.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f6bf2b86-1e1b-5b70-9ad5-7dc7ffa5ca9e', '80ef0a65-4694-554b-aa6c-cc8b22669544', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the Summary of the paragraphs of Reading Passage.
Use
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Ancient graffiti is of significance and records the
11
of details life for that period.
The police can recognize newly committed incidents of graffiti by the signature which is called
12
that they are familiar with
Operatives ought to comply with relevant rules during the operation, and put on the suitable
13
Removal of graffiti from a new type of coating surface can be much convenient of using
14
.

Operatives ought to comply with relevant rules during the operation, and put on the suitable 13 ____$md$, NULL, ARRAY['.*protective.*equipment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ba5a0f5e-34f9-56bc-98ad-af62bd796a52', '80ef0a65-4694-554b-aa6c-cc8b22669544', 14, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the Summary of the paragraphs of Reading Passage.
Use
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Ancient graffiti is of significance and records the
11
of details life for that period.
The police can recognize newly committed incidents of graffiti by the signature which is called
12
that they are familiar with
Operatives ought to comply with relevant rules during the operation, and put on the suitable
13
Removal of graffiti from a new type of coating surface can be much convenient of using
14
.

Removal of graffiti from a new type of coating surface can be much convenient of using 14 ____ .$md$, NULL, ARRAY['.*water.*']);

COMMIT;
