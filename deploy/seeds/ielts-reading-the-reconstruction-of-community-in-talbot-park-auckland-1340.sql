BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-reconstruction-of-community-in-talbot-park-auckland-1340'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-reconstruction-of-community-in-talbot-park-auckland-1340';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-reconstruction-of-community-in-talbot-park-auckland-1340';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-reconstruction-of-community-in-talbot-park-auckland-1340';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('252d7055-b46d-57cb-8cb8-f882d520de84', 'ielts-reading-the-reconstruction-of-community-in-talbot-park-auckland-1340', $t$The reconstruction of community in Talbot Park, Auckland$t$, $md$## The reconstruction of community in Talbot Park, Auckland

Nguồn:
- Test: https://mini-ielts.com/1340/reading/the-reconstruction-of-community-in-talbot-park-auckland
- Solution: https://mini-ielts.com/1340/view-solution/reading/the-reconstruction-of-community-in-talbot-park-auckland$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('eaf26b0e-18ae-5609-b351-eb31fd26efcc', '252d7055-b46d-57cb-8cb8-f882d520de84', 1, $t$Reading — The reconstruction of community in Talbot Park, Auckland$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The reconstruction of community in Talbot Park, Auckland

A . An architecture of disguise is almost complete at Talbot Park in the heart of Auckland’s Glen Innes. The place was once described as a state housing ghetto, rife with crime, vandalism and other social problems. But today after a $48 million urban renewal makeover, the site is home to 700 residents — 200 more than before — and has people regularly inquiring whether they can buy or rent there. “It doesn’t look like social housing,” Housing New Zealand housing services manager Dene Busby says of the tidy brick and weatherboard apartments and townhouses which would look just as much at home in “there is no reason why public housing should look cheap in my view,” says Design Group architect Neil of the eight three-bedroom terrace houses his firm designed.

B . Talbot Park is a triangle of government-owned land bounded by Apirana Ave, Pilkington Rd and Point England Rd. In the early 1960s it was developed for state housing built around a linear park that ran through the middle. Initially, there was a strong sense of a family-friendly community. Former residents recall how the Talbot Park reserve played a big part in their childhoods — a place where the kids in the block came together to play softball, cricket, tiggy, leapfrog and bullrush. Sometimes they’d play “Maoris against Pakehas” but without any animosity. “It was all just good fun”, says Georgie Thompson in Ben Schrader’s We Call it Home: A History of State Housing in New Zealand. “We had respect for our neighbours and addressed them by title Mr. and Mrs. soand-so,” she recalls.

C. Quite what went wrong with Talbot Park is not clear. We call it Home Records that the community began to change in the late 1970s as more Pacific Islanders and Europeans moved in. The new arrivals didn’t readily integrate with the community, a “them and us” mentality developed, and residents interacted with their neighbours less. What was clear was the buildings were deteriorating and becoming dilapidated, petty crime was on the rise and the reserve — focus of fond childhood memories — had become a wasteland and was considered unsafe.

D . But it wasn’t until 2002 that Housing New Zealand decided the properties needed upgrading. The master renewal plan didn’t take advantage of the maximum accommodation density allowable (one unit per 100 sq metres ) but did increase density to one emit per 180 sq m by refurbishing all 108 star flat units, removing the multis and building 111 new home. The Talbot strategy can be summed up as mix, match and manage. Mix up the housing with variety plans from a mix of architects, match house styles to what 7 s built by the private sector, match tenants to the mix, and manage their occupancy. Inevitably cost comes into the equation.” If you’re going to build low cost homes, you’ve got to keep them simple and you can’t afford a fancy bit on them. ” says Michael Thompson of Architectus which designed the innovative threelevel Atrium apartments lining two sides of a covered courtyard. At $300,000 per two bedroom unit, the building is more expensive but provides for independent disabled accommodation as well as offering solar hot water heating and rainwater collection for toilet cisterns and outside taps.

E . The renewal project budget at $1.5 million which will provide park pathways, planting, playgrounds, drinking fountains, seating, skateboard rails, a half-size basketball hard court, and a pavilion. But if there was any doubt this is a low socio-economic area, the demographics for the surrounding Tamaki area are sobering. Of the 5000 households there, 55 percent are state houses, 28 per cent privately owned (compared to about 65 percent nationally) and 17 percent are private rental. The area has a high concentration of households with incomes in the $5000 to $15,000 range and very few with an income over $70,000. That’s in sharp contrast to the more affluent suburbs like Kohimarama and St John’s that surround the area.

F . “The design is for people with different culture background,” says architect James Lunday of Common Ground which designed the 21 large family homes. “Architecturally we decided to be relatively conservative — nice house in its own garden with a bit of space and good indoor outdoor flow.” There’s a slight reflection of the whare and a Pacific fale, but not overplayed “The private sector is way behind in urban design and sustainable futures,” says Bracey. “Redesigning sheets and parks is a big deal and very difficult to do. The private sector won’t do it, because It’s so hard.”

G . There’s no doubt good urban design and good architecture play a significant part in the scheme. But probably more important is a new standard of social control. Housing New Zealand calls it “intensive tenancy management”. Others view it as social engineering. “It’s a model that we are looking at going forward,” according to Housing New Zealand’s central Auckland regional manager Graham Bodman.1 The focus is on frequent inspections, helping tenants to get to know each other and trying to create an environment of respect for neighbours, ” says Bodman. That includes some strict rules — no loud parties after 10 pm, no dogs, no cats in the apartments, no washing hung over balcony rails and a requirement to mow lawns and keep the property tidy. Housing New Zealand has also been active in organising morning teas and sheet barbecues for residents to meet their neighbours. “IVs all based on the intensification,” says Community Renewal project manager Stuart Bracey. “We acknowledge if you are going to put more people living closer together, you have to actually help them to live closer together because it creates tension — especially for people that aren’t used to it.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a97b3b76-e47c-570e-a204-4dbcaba62871', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c71c86e-3b1f-5276-8073-c7c03c75ac51', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('224fc36c-9dc6-5463-abe6-f5616eb0bd3b', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b90825d-53aa-5f2b-a99e-4058bdf17f40', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054c02de-26fb-52e0-bbaa-9f4ac195eb2e', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34bc0ea4-2b6d-5e7d-98b6-07f1f92b7fae', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60e7e1e9-3efd-5172-a3c5-a5d6f3e3a2cd', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11b4c6b3-fee1-5e5d-99c9-7b03054ea9fa', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e27cf5ba-5453-56da-a908-d2fb59735a33', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbc2f64b-4d9a-5345-a334-cac7a7672a88', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd6c9f2e-7e65-5530-9020-0a53ffb7ed41', 'ed2feb39-b521-55ef-a4ca-799dc0f2c11c', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('559ed702-14db-51ee-9438-2ee43fb0e59e', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84f71f97-cdac-523f-8aaa-69b4b8e13152', '559ed702-14db-51ee-9438-2ee43fb0e59e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ae796c1-78ac-5724-8e50-04e025ae36c6', '559ed702-14db-51ee-9438-2ee43fb0e59e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aeb78e0c-82a1-511d-a123-52ee1262f073', '559ed702-14db-51ee-9438-2ee43fb0e59e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d91e9557-538d-5d0b-9508-a1b24d775f14', '559ed702-14db-51ee-9438-2ee43fb0e59e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11802b86-71a1-5cfb-b3c6-e4babf284e63', '559ed702-14db-51ee-9438-2ee43fb0e59e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('580e4805-8413-562b-be43-7adecffa828d', '559ed702-14db-51ee-9438-2ee43fb0e59e', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91dbbd59-b975-5440-a346-5665a8039aeb', '559ed702-14db-51ee-9438-2ee43fb0e59e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f02f3ca1-8c3e-59c2-90bb-d295073359b3', '559ed702-14db-51ee-9438-2ee43fb0e59e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54518d26-b7b4-5ae5-8e9a-05a89b97438b', '559ed702-14db-51ee-9438-2ee43fb0e59e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90fcbc55-f51a-5b9d-b8f8-2a8bdb7af166', '559ed702-14db-51ee-9438-2ee43fb0e59e', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c3a17d1-e0fa-57eb-802a-b87d8d90748d', '559ed702-14db-51ee-9438-2ee43fb0e59e', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c8894c1e-073f-592d-ad22-1b3fa44b663b', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc6b661c-ac47-5010-957e-ac16e5bd58b6', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a66fae38-8411-5893-8b9c-003c8b2b25a4', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ae7eb27-44d0-5b54-9e27-b81ccd4298cb', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35e77d87-6723-5aab-82db-03dcc260786a', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e95bde2-ce06-5c16-b8a8-583632d50af6', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39bd490b-0546-59d8-9ef0-39ff0bcc1ed3', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ba41c53-15c8-5dee-b4a9-acf12f61b89c', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a28908c9-51a2-58ac-8589-587ab58fc76c', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af7de948-fe4a-5a13-b8bd-f284627c8ed2', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cd69365-9da6-5e54-b7d4-6e8bb2f89921', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b222fc5d-8f39-50de-a2d8-897fd3726647', 'c8894c1e-073f-592d-ad22-1b3fa44b663b', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f206463a-5379-518a-8022-3943c032443d', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d476aa3e-6d88-5fa0-bbbb-b914f301b002', 'f206463a-5379-518a-8022-3943c032443d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d21a0ecf-549a-55bc-9c0d-c7a9a581b9a2', 'f206463a-5379-518a-8022-3943c032443d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed94dd78-0be9-50b1-b325-3b46e6c041ff', 'f206463a-5379-518a-8022-3943c032443d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3fd9d8a-d8cf-5718-b618-3374233c5b87', 'f206463a-5379-518a-8022-3943c032443d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51df76b2-6c4e-5873-b981-51122ca7a95c', 'f206463a-5379-518a-8022-3943c032443d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d36b10c4-80c9-5fb9-8a42-ada7721b891a', 'f206463a-5379-518a-8022-3943c032443d', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3dc43dd-246c-5a14-9dd4-18dfba829a23', 'f206463a-5379-518a-8022-3943c032443d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1330ffc6-9662-543c-bf35-e9c355c4d500', 'f206463a-5379-518a-8022-3943c032443d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bd2558f-2e70-5f13-a542-4b917c50f311', 'f206463a-5379-518a-8022-3943c032443d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a56d8d60-10e4-5dcd-b293-7f01c8ea16d7', 'f206463a-5379-518a-8022-3943c032443d', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f63f13bc-c4ce-5157-8d3a-e83a7b9e1ea4', 'f206463a-5379-518a-8022-3943c032443d', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39e38123-54c0-5848-bf46-1774f1bd45de', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4dd4c0c-0304-5206-8fdf-a860a532ef98', '39e38123-54c0-5848-bf46-1774f1bd45de', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e732142c-51f5-5aca-b660-3c8501c8db62', '39e38123-54c0-5848-bf46-1774f1bd45de', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc53e5f5-cb16-5b34-a195-752a2e2181d0', '39e38123-54c0-5848-bf46-1774f1bd45de', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23d4be63-117c-57e6-9cb5-33cea402ee54', '39e38123-54c0-5848-bf46-1774f1bd45de', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10bd634f-c8e2-5903-82d0-502b8fb964e2', '39e38123-54c0-5848-bf46-1774f1bd45de', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cbae9bc-3798-518f-8380-61e3f7aee227', '39e38123-54c0-5848-bf46-1774f1bd45de', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0655103-1577-569e-9fc3-2f53c9edbbf8', '39e38123-54c0-5848-bf46-1774f1bd45de', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('def5558e-6c04-5b06-b202-51ecc0ca6e14', '39e38123-54c0-5848-bf46-1774f1bd45de', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22c1f96d-7437-5c81-a59d-a16815d6959e', '39e38123-54c0-5848-bf46-1774f1bd45de', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb489d76-5b10-5382-8ffd-53eed2408545', '39e38123-54c0-5848-bf46-1774f1bd45de', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe467e15-77b0-5930-b8ae-900397b17779', '39e38123-54c0-5848-bf46-1774f1bd45de', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7f2e199-ef84-5c35-8c72-0a526df717c2', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90929ac6-d7de-5e8c-811e-e0a61f5e42f7', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05c4633a-84a6-5c06-84b2-7cafe00ce4e0', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfaed784-e3fe-51cb-831e-64b7a9c8a436', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d439699-bd27-5655-a10b-e04c64f088a5', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2aa299b-6372-5951-bb31-8324ae2b2230', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfbed3bc-3b90-5dba-ba38-e2361558163f', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a664704e-0706-545a-8350-bd0705678be9', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b82a18ba-b8e6-554c-a5dd-4d7ff29c4f81', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94140adc-26b1-502e-95d2-0ccbbab4749a', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6ac1b74-242c-5bc0-b1da-5bfb1c594413', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db7c4bae-7b40-5937-b570-409d4aeaf838', 'd7f2e199-ef84-5c35-8c72-0a526df717c2', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58e94292-9b49-54c0-8d12-dcc0c48287d2', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs, A-G.
Choose the correct heading for paragraphs, A-G from the list below.
Write the correct number, i-xi, in boxes
1-7
on your answer sheet.
List of Headings
i Financial hardship of community
ii A good tendency of strengthening the supervision
iii Details of plans for the community’s makeover and upgrade
iv Architecture suits families of various ethnic origins
v Problems arise then the mentality of alienation developed later
vi Introduction of a social housing community with unexpected high standard
vii A practical design and need assist and cooperate in future
viii closer relationship among neighbors in original site
ix different need from a makeup of a low financial background should be considered
x How to make the community feel safe
xi a plan with details for house structure
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53d4905b-42bb-5515-9199-18ba2b6de27b', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('419c9605-88c8-54a4-a331-4874bf189e5d', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e3218a0-986e-58c2-951b-f2a24c0d72e4', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76eff537-07d8-5ee3-8267-71ea2577f61c', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59376aeb-47e1-5d64-a0ea-7790437a369d', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24273a46-24dc-5ce5-8e64-6d50a3090e19', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b0b43a3-046a-5c5e-909c-73e14b60f945', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a06b932-4503-5ab3-94e6-a675e51cd064', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7b1cbb9-bfc7-5cbe-b36c-7eda450e2ca5', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d85febd0-6769-5cb0-8d58-9bf95bd11ad9', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbefdcf0-6950-53d6-bf10-b4db2846fbc5', '58e94292-9b49-54c0-8d12-dcc0c48287d2', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('943f66c0-a4bf-5384-818a-c3e0c7e16a08', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Use the information in the passage to match the people (listed A-E) with opinions or deeds below.
Write the appropriate letters, A-E, in boxes
8-10
on your answer sheet.
8
Design should meet the need of mix-raced cultural background
9
for better living environment, regulations and social control should be imperative
10
organising more community’s activities helps strengthening relationship in community
List of people
A Michael Thompson
B Graham Bodman
C Stuart Bracey
D James Lunday
E Dene Busby

Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters, A-E, in boxes 8-10 on your answer sheet. 8 ____ Design should meet the need of mix-raced cultural background 9 ____ for better living environment, regulations and social control should be imperative 10 ____ organising more community’s activities helps strengthening relationship in community$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c39b8f95-7548-560e-95df-9de001f17ddd', '943f66c0-a4bf-5384-818a-c3e0c7e16a08', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df0e853b-c555-55af-8603-1a08e58fe864', '943f66c0-a4bf-5384-818a-c3e0c7e16a08', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bc47d52-4b88-579c-92bd-1b81d30db7f9', '943f66c0-a4bf-5384-818a-c3e0c7e16a08', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a149c3-a0f0-585f-acf3-dee8b2a11b83', '943f66c0-a4bf-5384-818a-c3e0c7e16a08', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('009dc2b5-eb5b-5612-9df6-0198400b7cf9', '943f66c0-a4bf-5384-818a-c3e0c7e16a08', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50453e1f-06c3-5b3d-a71a-8af462aeef81', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Use the information in the passage to match the people (listed A-E) with opinions or deeds below.
Write the appropriate letters, A-E, in boxes
8-10
on your answer sheet.
8
Design should meet the need of mix-raced cultural background
9
for better living environment, regulations and social control should be imperative
10
organising more community’s activities helps strengthening relationship in community
List of people
A Michael Thompson
B Graham Bodman
C Stuart Bracey
D James Lunday
E Dene Busby

Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters, A-E, in boxes 8-10 on your answer sheet. 8 ____ Design should meet the need of mix-raced cultural background 9 ____ for better living environment, regulations and social control should be imperative 10 ____ organising more community’s activities helps strengthening relationship in community$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb2fd006-9f26-53fa-9f82-95a071cdb4d8', '50453e1f-06c3-5b3d-a71a-8af462aeef81', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acb24a55-1c06-5b63-8828-07e7e9c9eece', '50453e1f-06c3-5b3d-a71a-8af462aeef81', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05c43504-6652-56b7-8c23-3e99e991296a', '50453e1f-06c3-5b3d-a71a-8af462aeef81', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d6927d2-d21e-5965-9b11-712394827c4e', '50453e1f-06c3-5b3d-a71a-8af462aeef81', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('630131ca-2c35-51e0-b813-be27b1f7e629', '50453e1f-06c3-5b3d-a71a-8af462aeef81', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f5e0f12-6a78-5275-abab-d7137e3fa88b', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Use the information in the passage to match the people (listed A-E) with opinions or deeds below.
Write the appropriate letters, A-E, in boxes
8-10
on your answer sheet.
8
Design should meet the need of mix-raced cultural background
9
for better living environment, regulations and social control should be imperative
10
organising more community’s activities helps strengthening relationship in community
List of people
A Michael Thompson
B Graham Bodman
C Stuart Bracey
D James Lunday
E Dene Busby

Use the information in the passage to match the people (listed A-E) with opinions or deeds below. Write the appropriate letters, A-E, in boxes 8-10 on your answer sheet. 8 ____ Design should meet the need of mix-raced cultural background 9 ____ for better living environment, regulations and social control should be imperative 10 ____ organising more community’s activities helps strengthening relationship in community$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('371313f2-514f-5139-b559-bb6bd62f5278', '4f5e0f12-6a78-5275-abab-d7137e3fa88b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2a165dc-2240-593e-812a-a6ee2dfb64c8', '4f5e0f12-6a78-5275-abab-d7137e3fa88b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0767fc4f-acd7-569a-8600-ffc58d6dca2e', '4f5e0f12-6a78-5275-abab-d7137e3fa88b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f7da14e-38cb-59af-a40a-1f0910a35f0c', '4f5e0f12-6a78-5275-abab-d7137e3fa88b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('453ea8b5-4f08-52ca-84fb-c559e40079ea', '4f5e0f12-6a78-5275-abab-d7137e3fa88b', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('36e13cf8-6717-5b3a-ba99-fe9352964d46', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living
11
. And as the variety plans were complemented under the designs of many
12
together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low
13
; finally, just as expert predicted residents will agree on building a relatively conventional house in its own
14
, which provides considerable space to move around

In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living 11 ____ . And as the variety plans were complemented under the designs of many 12 ____ together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low 13 ____ ; finally, just as expert predicted residents will agree on building a relatively conventional house in its own 14 ____ , which provides considerable space to move around$md$, NULL, ARRAY['.*density.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5c432f25-e647-525e-949f-fb282b0e996d', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living
11
. And as the variety plans were complemented under the designs of many
12
together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low
13
; finally, just as expert predicted residents will agree on building a relatively conventional house in its own
14
, which provides considerable space to move around

In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living 11 ____ . And as the variety plans were complemented under the designs of many 12 ____ together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low 13 ____ ; finally, just as expert predicted residents will agree on building a relatively conventional house in its own 14 ____ , which provides considerable space to move around$md$, NULL, ARRAY['.*density.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f7e990fe-b8c1-5543-8838-ffc7b44c3d3e', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living
11
. And as the variety plans were complemented under the designs of many
12
together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low
13
; finally, just as expert predicted residents will agree on building a relatively conventional house in its own
14
, which provides considerable space to move around

In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living 11 ____ . And as the variety plans were complemented under the designs of many 12 ____ together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low 13 ____ ; finally, just as expert predicted residents will agree on building a relatively conventional house in its own 14 ____ , which provides considerable space to move around$md$, NULL, ARRAY['.*density.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1bd4bc6f-4c41-5308-a6ec-3077c28bdcdc', 'eaf26b0e-18ae-5609-b351-eb31fd26efcc', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living
11
. And as the variety plans were complemented under the designs of many
12
together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low
13
; finally, just as expert predicted residents will agree on building a relatively conventional house in its own
14
, which provides considerable space to move around

In the year 2002, the Talbot decided to raise housing standard, yet the plan was to build homes go much beyond the accommodation limit and people complain about the high living 11 ____ . And as the variety plans were complemented under the designs of many 12 ____ together, made house styles go with the part designed by individuals, matched tenants from different culture. As for the finance, reconstruction program’s major concern is to build a house within low 13 ____ ; finally, just as expert predicted residents will agree on building a relatively conventional house in its own 14 ____ , which provides considerable space to move around$md$, NULL, ARRAY['.*density.*']);

COMMIT;
