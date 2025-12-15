BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-synaesthesia-1253'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-synaesthesia-1253';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-synaesthesia-1253';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-synaesthesia-1253';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('200a4f10-c441-5296-b44e-805ce13f5a35', 'ielts-reading-synaesthesia-1253', $t$Synaesthesia$t$, $md$## Synaesthesia

Nguồn:
- Test: https://mini-ielts.com/1253/reading/synaesthesia
- Solution: https://mini-ielts.com/1253/view-solution/reading/synaesthesia$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('934d4313-2dea-52c6-a2c4-fcf993590c3f', '200a4f10-c441-5296-b44e-805ce13f5a35', 1, $t$Reading — Synaesthesia$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Synaesthesia

A

Imagine a page with a square box in the middle. The box is lined with rows of the number 5, repeated over and over. All of the 5s are identical in size, font and colour, and equally distributed across the box. There is, however, a trick: among those 5s, hiding in plain sight is a single, capital letter S. Almost the same in shape, it is impossible to spot without straining your eyes for a good few minutes. Unless that is, you are a grapheme – colour synaesthete – a person who sees each letter and number in diﬀerent colours. With all the 5s painted in one colour and the rogue S painted in another, a grapheme – colour synaesthete will usually only need a split second to identify the latter.

B

Synaesthesia, loosely translated as “senses coming together” from the Greek words syn (“with”) and aesthesis (“sensation”), is an interesting neurological phenomenon that causes diﬀerent senses to be combined. This might mean that words have a particular taste (for example, the word “door” might taste like bacon), or that certain smells produce a particular colour. It might also mean that each letter and number has its own personality-the letter A might be perky, the letter B might be shy and self-conscious, etc. Some synaesthetes might even experience other people’s sensations, for example feeling pain in their chest when they witness a film character gets shot. The possibilities are endless: even though synaesthesia is believed to aﬀect less than 5% of the general population, at least 60 diﬀerent combinations of senses have been reported so far. What all these sensory associations have in common is that they are all involuntary and impossible to repress and that they usually remain quite stable over time.

C

Synaesthesia was first documented in the early 19th century by German physician Georg Sachs, who dedicated two pages of his dissertation on his own experience with the condition. It wasn’t, however, until the mid-1990s that empirical research proved its existence when Professor Simon Baron-Cohen and his colleagues used fMRls on six synaesthetes and discovered that the parts of the brain associated with vision were active during auditory stimulation, even though the subjects were blindfolded.

D

What makes synaesthesia a particularly interesting condition is that it isn’t an illness at all. If anything, synaesthetes often report feeling sorry for the rest of the population, as they don’t have the opportunity to experience the world in a multisensory fashion like they do. Very few drawbacks have been described, usually minimal: for instance, some words might have an unpleasant taste (imagine the word “hello” tasting like spoilt milk), while some synaesthetes find it distressing when they encounter people with names which don’t reflect their personality (imagine meeting a very interesting person named “Lee”, when the letter E has a dull or hideous colour for you-or vice versa). Overall, however, synaesthesia is widely considered more of a blessing than a curse and it is often linked to intelligence and creativity, with celebrities such as Lady Gaga and Pharrell Williams claiming to have it.

E

Another fascinating side of synaesthesia is the way it could potentially benefit future generations. In a 2013 study, Dr Witthof and Dr Winawer discovered that grapheme-colour synaesthetes who had never met each other before experienced strikingly similar pairings between graphemes and colours-pairings which were later traced back to a popular set of Fischer-Price magnets that ten out of eleven participants distinctly remembered possessing as children. This was particularly peculiar as synaesthesia is predominantly considered to be a hereditary condition, and the findings suggested that a synaesthete’s environment might play a determining role in establishing synaesthetic associations. If that was true, researchers asked, then might it not be possible that synaesthesia can actually be taught?

F

As it turns out, the benefits of teaching synaesthesia would be tremendous. According to research conducted by Dr Clare Jonas at the University of East London, teaching people to create grapheme-colour associations the same way as a synaesthete may have the possibility to improve cognitive function and memory. As she put it, ‘one possibility is guarding against cognitive decline in older people-using synaesthesia in the creation of mnemonics to remember things such as shopping lists.’ To that end, researchers in the Netherlands have already begun developing a web browser plug-in that will change the colours of certain letters. Rothen and his colleagues corroborate the theory: in a paper published in 2011, they suggest that synaesthesia might be more than a hereditary condition, as the non-synaesthetic subjects of their study were able to mimic synaesthetic associations long after leaving the lab.

G

There is obviously still a long way to go before we can fully understand synaesthesia and what causes it. Once we do, however, it might not be too long before we find out how to teach non-synaesthetes how to imitate its symptoms in a way that induces the same benefits 4.4% of the world’s population currently enjoy.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f51789ad-5c12-5354-83f5-bd36ef56f6c7', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

1 ____ some of the disadvantages related to synaesthesia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0be9adfa-e7c5-5472-9063-84a5ff435ed9', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d0e8a3a-450d-5698-9cc1-316d838c54de', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07178b22-8b19-56f8-8229-f5e53c7ecba6', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d63b41c-cfd2-54c0-a296-aee4ee6f716a', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fcf7950-8ff9-5962-885b-2ae689deefbf', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32fd28ed-d6ad-51be-b233-38f57586e6bc', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c016ba1-2a37-559a-823b-c91b19c20303', 'f51789ad-5c12-5354-83f5-bd36ef56f6c7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6de1de2d-d857-5f53-943e-dd33135d84f8', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

2 ____ what scientists think about synaesthesia’s real-life usefulness$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5960ed1f-89fe-544d-919b-de98b367d558', '6de1de2d-d857-5f53-943e-dd33135d84f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc262fab-4f42-5560-902d-45d1bf1de49e', '6de1de2d-d857-5f53-943e-dd33135d84f8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc5fae53-a889-573f-a659-c0a5ee375875', '6de1de2d-d857-5f53-943e-dd33135d84f8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0a15cc9-9ea4-5e12-b147-5f302bd87b2c', '6de1de2d-d857-5f53-943e-dd33135d84f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51585dfd-7550-5091-9445-f0cb71a5ceb6', '6de1de2d-d857-5f53-943e-dd33135d84f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('922549ef-0ae1-52cd-8562-d181b7849dd1', '6de1de2d-d857-5f53-943e-dd33135d84f8', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4667deb4-e8d2-53dd-9aeb-097ecc7a7585', '6de1de2d-d857-5f53-943e-dd33135d84f8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1ec45c29-6389-595e-a01d-76d345b092ab', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

3 ____ a prediction for the future of synaesthesia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f068c89-b3d6-5dac-a601-9345202e5327', '1ec45c29-6389-595e-a01d-76d345b092ab', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9db90aca-cbde-5fee-bba0-19c7190c2fbb', '1ec45c29-6389-595e-a01d-76d345b092ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb95052d-d8d8-599b-b8cc-48210a7fd439', '1ec45c29-6389-595e-a01d-76d345b092ab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcfd44c5-7ae8-521b-905b-ba56f173564e', '1ec45c29-6389-595e-a01d-76d345b092ab', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dcc370f-9ce2-5dbe-858e-cc01d6231e5b', '1ec45c29-6389-595e-a01d-76d345b092ab', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9510575c-14c2-577e-bee0-9d990c8106c1', '1ec45c29-6389-595e-a01d-76d345b092ab', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51cde4b9-06a4-574e-b360-48e170a5be8a', '1ec45c29-6389-595e-a01d-76d345b092ab', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27b9caa2-96ff-553c-9253-c245e72ca174', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

4 ____ an example of how grapheme-colour synaesthesia works$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be35123a-696d-5f94-805b-3be32b726411', '27b9caa2-96ff-553c-9253-c245e72ca174', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89c2eb9e-01c8-5a7f-9d49-beeb2062f8a6', '27b9caa2-96ff-553c-9253-c245e72ca174', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4698f388-a9a0-50fb-8547-f9bd629794e9', '27b9caa2-96ff-553c-9253-c245e72ca174', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2c85e35-8ae9-55aa-b5af-1ea26cd59d7b', '27b9caa2-96ff-553c-9253-c245e72ca174', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7af31b05-f40f-5a1b-938c-63bc68663023', '27b9caa2-96ff-553c-9253-c245e72ca174', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e456c94-57fa-5447-8666-42f387f83f89', '27b9caa2-96ff-553c-9253-c245e72ca174', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feca0a5c-df82-5fac-8106-f3dd62fde881', '27b9caa2-96ff-553c-9253-c245e72ca174', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b066d364-b92c-592b-922b-e3c33e6d90f1', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

5 ____ a brief history of synaesthesia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cc7b5b6-1a65-5074-9055-98484584e99c', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09df42bc-6ca4-5a4b-9fb4-6ca3583050e2', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae4442ba-90f9-5303-b600-335b8acf647d', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34a2a505-731a-58ae-bd4d-d4717e3353e5', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f6117b5-495f-5dd6-9587-18f9257cedd4', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aea89d4-a272-5c10-8390-4367185c831c', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f399b6c-00ef-5e00-8011-ac2b6fb62b87', 'b066d364-b92c-592b-922b-e3c33e6d90f1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6320f027-d576-5d88-a457-5abdfbd7c0aa', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

6 ____ some of the various different types of synaesthesia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1aeb34f-5d9e-5640-b001-160ad7b28d36', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8af4bc3a-f0bb-5093-8343-3cf70f1fb11a', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31a66583-7c34-5cae-ac22-a0a86c19319e', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f85c41f7-79d6-59fa-a2a8-dd9e61303146', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72ad0a23-f5c3-5f23-b99d-afdaea4fb166', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccc6e4a8-fb93-5c18-bf08-91193ab27de7', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98ad82da-aa7a-5387-88bb-ceb8a2f06b4e', '6320f027-d576-5d88-a457-5abdfbd7c0aa', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1d49304-7c86-580c-890c-f429d045e7b1', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
he reading passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
1-7
on your answer sheet.
1
some of the disadvantages related to synaesthesia
2
what scientists think about synaesthesia’s real-life usefulness
3
a prediction for the future of synaesthesia
4
an example of how grapheme-colour synaesthesia works
5
a brief history of synaesthesia
6
some of the various different types of synaesthesia
7
information about a study that suggests synaesthetic symptoms aren’t arbitrary

7 ____ information about a study that suggests synaesthetic symptoms aren’t arbitrary$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d84a9c22-5c36-58bb-8dba-5a351a932965', 'b1d49304-7c86-580c-890c-f429d045e7b1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c031d67-7092-5514-b36f-5fa0219f27d5', 'b1d49304-7c86-580c-890c-f429d045e7b1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a297053e-9e08-5d54-bc94-e5a67bbe108e', 'b1d49304-7c86-580c-890c-f429d045e7b1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe5164a-d161-5d87-84d7-f41ccfc632d1', 'b1d49304-7c86-580c-890c-f429d045e7b1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b9faad0-42aa-5d51-b3e9-9492b43229d4', 'b1d49304-7c86-580c-890c-f429d045e7b1', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebeb9699-7fde-5a7d-9d57-e4dee13737ec', 'b1d49304-7c86-580c-890c-f429d045e7b1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1baf8c4-ff4a-53d1-8d18-6c4b39efa455', 'b1d49304-7c86-580c-890c-f429d045e7b1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2d37f54-1175-57ad-9453-2b2218138946', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement is true according to the passage
FALSE
if the statement is false according to the passage
NOT GIVEN
if the information is not given in the passage
8
There are 60 different types of synaesthesia.
9
Before Professor Simon Baron-Cohen’s research, synaesthesia was thought to be a myth.
10
A lot of celebrities are aﬀected by synaesthesia.
11
Most scientists believe that synaesthesia runs in families.

8 ____ There are 60 different types of synaesthesia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7bdda37-8178-5380-ab29-6423c6d59ac3', 'c2d37f54-1175-57ad-9453-2b2218138946', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea136d93-7e45-5426-be4c-5475806a2cc4', 'c2d37f54-1175-57ad-9453-2b2218138946', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24ce34cc-d482-51a6-a3c3-9420cfb52936', 'c2d37f54-1175-57ad-9453-2b2218138946', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ca5c594-e00f-53a6-ac29-9df5381339e8', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement is true according to the passage
FALSE
if the statement is false according to the passage
NOT GIVEN
if the information is not given in the passage
8
There are 60 different types of synaesthesia.
9
Before Professor Simon Baron-Cohen’s research, synaesthesia was thought to be a myth.
10
A lot of celebrities are aﬀected by synaesthesia.
11
Most scientists believe that synaesthesia runs in families.

9 ____ Before Professor Simon Baron-Cohen’s research, synaesthesia was thought to be a myth.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd4b92a4-8f1e-5c94-9673-a0b57de763cd', '7ca5c594-e00f-53a6-ac29-9df5381339e8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66504772-1d7f-56e6-84b4-19361e0240c1', '7ca5c594-e00f-53a6-ac29-9df5381339e8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9388aa5-fa9a-56fa-bc13-219315374bae', '7ca5c594-e00f-53a6-ac29-9df5381339e8', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a9c34a9e-cb76-54c6-9ddd-3c50e730b77a', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement is true according to the passage
FALSE
if the statement is false according to the passage
NOT GIVEN
if the information is not given in the passage
8
There are 60 different types of synaesthesia.
9
Before Professor Simon Baron-Cohen’s research, synaesthesia was thought to be a myth.
10
A lot of celebrities are aﬀected by synaesthesia.
11
Most scientists believe that synaesthesia runs in families.

10 ____ A lot of celebrities are aﬀected by synaesthesia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9e9be72-784f-5fcf-9e1d-686a60704e94', 'a9c34a9e-cb76-54c6-9ddd-3c50e730b77a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93a59676-f8ab-5847-b7a9-39344535325a', 'a9c34a9e-cb76-54c6-9ddd-3c50e730b77a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41ce474a-2c65-582b-93a5-22e4fcd5ef8c', 'a9c34a9e-cb76-54c6-9ddd-3c50e730b77a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4617206a-035f-536a-a26c-146ab8f4ca23', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement is true according to the passage
FALSE
if the statement is false according to the passage
NOT GIVEN
if the information is not given in the passage
8
There are 60 different types of synaesthesia.
9
Before Professor Simon Baron-Cohen’s research, synaesthesia was thought to be a myth.
10
A lot of celebrities are aﬀected by synaesthesia.
11
Most scientists believe that synaesthesia runs in families.

11 ____ Most scientists believe that synaesthesia runs in families.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b6ea540-1f36-5988-87f2-52905c09a86b', '4617206a-035f-536a-a26c-146ab8f4ca23', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61bd56d1-13ce-52e0-bb17-48fbe678ad17', '4617206a-035f-536a-a26c-146ab8f4ca23', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('249dd8aa-1ad4-5b0a-94d6-89650ac4b5a2', '4617206a-035f-536a-a26c-146ab8f4ca23', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2d6c68be-1233-52ec-b43a-81c35ecc2b8e', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Complete the summary.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet
Synaesthesia is a unique neurological condition that causes different senses to get mixed.
Recent research has suggested that teaching synaesthesia to non-synaesthetes can
enhance
12
and guard against the deterioration of cognitive
13
;
unfortunately, it might be a while before we come up with a beneficial way to
14
it to the general population.

enhance 12 ____ and guard against the deterioration of cognitive 13 ____ ;$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9f748f30-95e2-5886-98be-f4f5f463653c', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Complete the summary.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet
Synaesthesia is a unique neurological condition that causes different senses to get mixed.
Recent research has suggested that teaching synaesthesia to non-synaesthetes can
enhance
12
and guard against the deterioration of cognitive
13
;
unfortunately, it might be a while before we come up with a beneficial way to
14
it to the general population.

enhance 12 ____ and guard against the deterioration of cognitive 13 ____ ;$md$, NULL, ARRAY['.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('01f0d961-ca82-501d-819f-643962752bf2', '934d4313-2dea-52c6-a2c4-fcf993590c3f', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Complete the summary.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet
Synaesthesia is a unique neurological condition that causes different senses to get mixed.
Recent research has suggested that teaching synaesthesia to non-synaesthetes can
enhance
12
and guard against the deterioration of cognitive
13
;
unfortunately, it might be a while before we come up with a beneficial way to
14
it to the general population.

14 ____ it to the general population.$md$, NULL, ARRAY['.*teach.*']);

COMMIT;
