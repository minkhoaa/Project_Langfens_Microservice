BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-lighting-up-the-lies-1480'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-lighting-up-the-lies-1480';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-lighting-up-the-lies-1480';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-lighting-up-the-lies-1480';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('06873d9c-b8ff-5949-add8-914326d34be7', 'ielts-reading-lighting-up-the-lies-1480', $t$Lighting up the lies$t$, $md$## Lighting up the lies

Nguồn:
- Test: https://mini-ielts.com/1480/reading/lighting-up-the-lies
- Solution: https://mini-ielts.com/1480/view-solution/reading/lighting-up-the-lies$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', '06873d9c-b8ff-5949-add8-914326d34be7', 1, $t$Reading — Lighting up the lies$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Lighting up the lies

A Last year Sean A. Spence, a professor at the school of medicine at the University of Sheffield in England, performed brain scans that showed that a woman convicted of poisoning a child in her care appeared to be telling the truth when she denied committing the crime. This deception study, along with two others performed by the Sheffield group, was funded by Quickfire Media, a television production company working for the U.K.’s Channel 4, which broadcast videos of the researchers at work as part of a three-part series called “Lie Lab.” The brain study of the woman later appeared in the journal European Psychiatry.

B Functional magnetic resonance imaging (fMRI) purports to detect mendacity by seeing inside the brain instead of tracking peripheral measures of anxiety—such as changes in pulse, blood pressure or respiration —measured by a polygraph. Besides drawing hundreds of thousands of viewers, fMRI has pulled in entrepreneurs. Two companies—Cephos in Pepperell, Mass., and No Lie MRI in Tarzana, Calif.—claim to predict with 90 percent or greater certitude whether you are telling the truth. No Lie MRI, whose name evokes the casual familiarity of a walk-in dental clinic in a strip mall, suggests that the technique may even be used for “risk reduction in dating” .

C Many neuroscientists and legal scholars doubt such claims—and some even question whether brain scans for lie detection will ever be ready for anything but more research on the nature of deception and the brain. An fMRI machine tracks blood flow to activated brain areas. The assumption in lie detection is that the brain must exert extra effort when telling a lie and that the regions that do more work get more blood. Such areas light up in scans; during the lie studies, the illuminated regions are primarily involved in decision making.

D To assess how fMRI and other neurocience findings affect the law, the Mac- Arthur Foundation put up $10 million last year to pilot for three years the Law and Neuroscience Project. Part of the funding will attempt to set criteria for accurate and reliable lie detection using fMRI and other brain-scanning technology. “I think it’s not possible, given the current technology, to trust the results,” says Marcus Raichle, a neuroscientist at the Washington University School of Medicine in St. Louis who heads the project’s study group on lie detection. “But it’s not impossible to set up a research program to determine whether that’s possible.” A major review article last year in the American Journal of Law and Medicine by Henry T. Greely of Stanford University and Judy Illes, now at the University of British Columbia, explores the deficiencies of existing research and what may be needed to move the technology forward. The two scholars found that lie detection studies conducted so far (still less than 20 in all) failed to prove that fMRI is “effective as a lie detector in the real world at any accuracy level.”

Most studies examined groups, not individuals.Subjects in these studies were healthy young adults—making it unclear how the results would apply to someone who takes a drug that affects blood pressure or has a blockage in an artery. And the two researchers questioned the specificity of the lit-up areas; they noted that the regions also correlate with a wide range of cognitive behaviors, including memory, self- monitoring and conscious self-awareness.

The biggest challenge for which the Law and Neuroscience Project is already funding new research—is how to diminish the artificiality of the test protocol. Lying about whether a playing card is the seven of spades may not activate the same areas of the cortex as answering a question about whether you robbed the comer store. In fact, the most realistic studies to date may have come from the Lie Lab television programs. The two companies marketing the technology are not waiting for more data. Cephos is offering scans without charge to people who claim they were falsely accused if they meet certain criteria in an effort to get scans accepted by the courts. Allowing scans as legal evidence could open a potentially huge and lucrative market. “We may have to take many shots on goal before we actually see a courtroom,” says Cephos chief executive Steven

Laken. He asserts that the technology has achieved 97 percent accuracy and that the more than 100 people scanned using the Cephos protocol have provided data that have resolved many of the issues that Greely and Illes cited.

G But until formal clinical trials prove that the machines meet safety and effectiveness criteria, Greely and Illes have called for a ban on non-research uses. Trials envisaged for regulatory approval hint at the technical challenges. Actors, professional poker players and sociopaths would be compared against average Joes. The devout would go in the scanner after nonbelievers. Testing would take into account social setting. White lies—“no, dinner really was fantastic”—would have to be compared against untruths about sexual peccadilloes to ensure that the brain reacts identically.

H There potential for abuse prompts caution. “The danger is that people’s lives can be changed in bad ways because of mistakes in the technology,” Greely says.

“The danger for the science is that it gets a black eye because of this very high profile use of neuroimaging that goes wrong.” Considering the long and controversial history of the polygraph, gradualism may be the wisest course to follow for a new diagnostic that probes an essential quality governing social interaction.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c26373ef-a0b2-51e0-9e0f-1b40883e2c61', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

1 ____ The possibility hidden in a mission impossible$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea2d09ff-59c9-552d-b6ea-7d75e99bbd66', 'c26373ef-a0b2-51e0-9e0f-1b40883e2c61', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3a77dea-a249-5483-9bd4-31db0ddd8bdd', 'c26373ef-a0b2-51e0-9e0f-1b40883e2c61', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ab9db39-d015-5877-9f1e-34d106f51b69', 'c26373ef-a0b2-51e0-9e0f-1b40883e2c61', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cbb086a-4a99-5e66-97f6-5805b5a51622', 'c26373ef-a0b2-51e0-9e0f-1b40883e2c61', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2207db47-d863-5c03-b3ac-51d2902e2b9d', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

2 ____ The uncertain effectiveness of functional magnetic resonance imaging for detecting lies$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46ac9ccd-e25c-5c59-9bab-1b23c6e7b7ce', '2207db47-d863-5c03-b3ac-51d2902e2b9d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('780203d8-88d6-5a80-9511-b7bb69285508', '2207db47-d863-5c03-b3ac-51d2902e2b9d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cb7ddcc-7a75-52f0-b1b5-c7c8810fd4a6', '2207db47-d863-5c03-b3ac-51d2902e2b9d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c2f440c-5f7b-5e3a-9eb7-e37cc04c28d7', '2207db47-d863-5c03-b3ac-51d2902e2b9d', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2724bc1-74af-5058-a0ec-934074fa9b0b', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

3 ____ The hazard lying behind the technology as a lie detector$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b2cae37-4477-52f4-9bdc-c44aca6dd794', 'f2724bc1-74af-5058-a0ec-934074fa9b0b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db1c767b-0fbe-52f1-bd42-527f2d8a7948', 'f2724bc1-74af-5058-a0ec-934074fa9b0b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64128620-7715-5d7a-97e1-d7d8684ed672', 'f2724bc1-74af-5058-a0ec-934074fa9b0b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5318abb-c762-5603-b8e7-e93e9ec4cdd3', 'f2724bc1-74af-5058-a0ec-934074fa9b0b', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72523e9e-4a67-552b-82c0-1e30aecdb62e', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

4 ____ The limited fields for the use of lie detection technology$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('718286c0-db31-5c9a-98fd-009f22d34aba', '72523e9e-4a67-552b-82c0-1e30aecdb62e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27228bf0-594a-5ed9-b4e9-7b6cc7d330e0', '72523e9e-4a67-552b-82c0-1e30aecdb62e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0162858-bf8b-5791-8add-4aeea4d2d9b6', '72523e9e-4a67-552b-82c0-1e30aecdb62e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e3ef7d-2bbb-5d20-b7d6-151f024d1e37', '72523e9e-4a67-552b-82c0-1e30aecdb62e', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eba05a72-9379-556c-9747-00f4adc2c866', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

5 ____ Several successful cases of applying the results from the lie detection technology$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2e24fe6-1c60-5c9d-bef4-e67894605415', 'eba05a72-9379-556c-9747-00f4adc2c866', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e698f01-2372-5e4c-891e-1577b96b062c', 'eba05a72-9379-556c-9747-00f4adc2c866', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13d1545c-fe29-56a8-8839-b0dd4b3ece95', 'eba05a72-9379-556c-9747-00f4adc2c866', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17682735-59e7-543d-90ad-9c20d1322114', 'eba05a72-9379-556c-9747-00f4adc2c866', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('108c4d64-12ac-5137-8c03-c311489ce260', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

6 ____ Cons of the current research related to lie-detector tests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdc3c58b-c7fa-5ac0-a398-b247c258b652', '108c4d64-12ac-5137-8c03-c311489ce260', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d6a9251-eeb0-58ca-849f-183cfb36b9bf', '108c4d64-12ac-5137-8c03-c311489ce260', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ced6b09-c70d-5b71-9a0c-4fe093d5ee04', '108c4d64-12ac-5137-8c03-c311489ce260', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d98cc4f3-7e02-5b88-ae50-1a0cccabe50b', '108c4d64-12ac-5137-8c03-c311489ce260', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('731f05d6-f819-5446-910b-dd07b08cd328', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-7 on your answer sheet.
NB you may use any letter more than once
A Henry T. Greely &Judy Illes
B Steven Laken
c Henry T. Greely
D Marcus Raichle
1
The possibility hidden in a mission impossible
2
The uncertain effectiveness of functional magnetic resonance imaging for detecting lies
3
The hazard lying behind the technology as a lie detector
4
The limited fields for the use of lie detection technology
5
Several successful cases of applying the results from the lie detection technology
6
Cons of the current research related to lie-detector tests
7
There should be some requested work to improve the techniques regarding lie detection

7 ____ There should be some requested work to improve the techniques regarding lie detection$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7780ee9a-f748-52ff-b837-3323e4179283', '731f05d6-f819-5446-910b-dd07b08cd328', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('240cf484-1f4e-584a-9a00-04fcc84e61ac', '731f05d6-f819-5446-910b-dd07b08cd328', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c94cf49-9168-5cb1-8f07-bb08cb2a8971', '731f05d6-f819-5446-910b-dd07b08cd328', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('816bb156-68b8-5c48-a1d3-3a51ada405c7', '731f05d6-f819-5446-910b-dd07b08cd328', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71c9a3c3-78b8-5ff1-b427-269709eb257b', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes 8-10 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
8
The lie detection for a convicted woman was first conducted by researchers in Europe.
9
The legitimization of using scans in the court might mean a promising and profitable business.
10
There is always something wrong with neuroimaging.

8 ____ The lie detection for a convicted woman was first conducted by researchers in Europe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15d04187-df70-59cf-9057-38c05c030286', '71c9a3c3-78b8-5ff1-b427-269709eb257b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7ba6ab1-c7ff-5310-bb78-28c7b82e33cb', '71c9a3c3-78b8-5ff1-b427-269709eb257b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('592a9e4a-5fd9-53a8-bade-749455c23db4', '71c9a3c3-78b8-5ff1-b427-269709eb257b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b3ef8ed-90c2-5519-92f3-622c24276774', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes 8-10 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
8
The lie detection for a convicted woman was first conducted by researchers in Europe.
9
The legitimization of using scans in the court might mean a promising and profitable business.
10
There is always something wrong with neuroimaging.

9 ____ The legitimization of using scans in the court might mean a promising and profitable business.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a422a6f-59c0-5f0d-b3b2-1c4ebd68d30e', '9b3ef8ed-90c2-5519-92f3-622c24276774', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acc2097e-e009-5ba3-a68e-c712e4b3b5f2', '9b3ef8ed-90c2-5519-92f3-622c24276774', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e6d2f33-b4cf-598d-a3ad-95d7b68d6cb1', '9b3ef8ed-90c2-5519-92f3-622c24276774', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f98b461-6965-52e8-bd45-8fb901cce8b1', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes 8-10 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
8
The lie detection for a convicted woman was first conducted by researchers in Europe.
9
The legitimization of using scans in the court might mean a promising and profitable business.
10
There is always something wrong with neuroimaging.

10 ____ There is always something wrong with neuroimaging.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35dc7b46-da3d-5003-9ec4-e5e5bf69937f', '4f98b461-6965-52e8-bd45-8fb901cce8b1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1bffbf4-52bd-54ee-8897-67cccbca54f6', '4f98b461-6965-52e8-bd45-8fb901cce8b1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f45f2101-534b-55a1-a589-2893d77c5fc0', '4f98b461-6965-52e8-bd45-8fb901cce8b1', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fae5538a-9c76-54c9-aa4a-ff3d15460ec2', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up
11
to evaluate the anxiety as
12
does. Audiences as well as
13
are fascinated by this amazing lie-detection technology.

It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up 11 ____ to evaluate the anxiety as 12 ____ does. Audiences as well as 13 ____ are fascinated by this amazing lie-detection technology.$md$, NULL, ARRAY['.*peripheral.*measures.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8d5cca17-da87-52a4-98cb-10b606d9ed9b', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up
11
to evaluate the anxiety as
12
does. Audiences as well as
13
are fascinated by this amazing lie-detection technology.

It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up 11 ____ to evaluate the anxiety as 12 ____ does. Audiences as well as 13 ____ are fascinated by this amazing lie-detection technology.$md$, NULL, ARRAY['.*peripheral.*measures.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('093dc0ea-31ed-5cfe-8aba-256fb2482e7c', '54d71dcc-87c6-5dc7-8953-80ffc5f4b43b', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up
11
to evaluate the anxiety as
12
does. Audiences as well as
13
are fascinated by this amazing lie-detection technology.

It is claimed that functional magnetic resonance imaging can check lies by observing the internal part of the brain rather than following up 11 ____ to evaluate the anxiety as 12 ____ does. Audiences as well as 13 ____ are fascinated by this amazing lie-detection technology.$md$, NULL, ARRAY['.*peripheral.*measures.*']);

COMMIT;
