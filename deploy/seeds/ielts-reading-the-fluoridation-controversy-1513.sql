BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-fluoridation-controversy-1513'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-fluoridation-controversy-1513';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-fluoridation-controversy-1513';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-fluoridation-controversy-1513';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a3292f86-81b1-51cb-b6f0-b4011caca097', 'ielts-reading-the-fluoridation-controversy-1513', $t$The fluoridation controversy$t$, $md$## The fluoridation controversy

Nguồn:
- Test: https://mini-ielts.com/1513/reading/the-fluoridation-controversy
- Solution: https://mini-ielts.com/1513/view-solution/reading/the-fluoridation-controversy$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('078550cc-c518-5706-b0e7-88c18e485bda', 'a3292f86-81b1-51cb-b6f0-b4011caca097', 1, $t$Reading — The fluoridation controversy$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The fluoridation controversy

The long-standing debate about whether to fluoridate our drinking water continues Fluoridation is the addition of fluorine to public water supplies with the aim of reducing tooth decay. The fluorine, when mixed with water, becomes fluoride and the desired concentration of fluoride in public water is approximately one part per million, depending on the regional temperature and hence the amount of water people are likely to drink. Many studies, such as those by McClure in 1970 through to Burt in 1983, have shown that when children drink fluoridated water, their average rate of tooth decay seems greatly reduced. A typical figure claimed is 50 percent reduction. This apparently enormous benefit for children's teeth is the major argument in favor of fluoridation.

Three main grounds for opposition to fluoridation have been expressed. First, opponents claim the benefits are exaggerated or not established. Second, there are claims of health risks to pans of the population, for example, allergic reactions. It is also accepted that high levels of fluoride can cause discoloration of otherwise healthy teeth. Proponents do not consider this to be a problem in such small concentrations, whereas opponents disagree - especially because some people drink more water and obtain much more than the standard 1 milligram of fluoride per day. Third, fluoridation is thought to be an infringement on individual rights because it is compulsory medication of all members of a community.

An understanding of the fluoridation issue has important implications. If, according to the experts, fluoridation is unquestionably a beneficial and non-hazardous measure, then the wisdom of allowing the public to vote on, and reject it must be questioned.

Almost all studies that have been done have assumed that the scientific aspects of the controversy are unproblematic, and they have excluded science from sociological examination. The traditional view is that science is a special kind of knowledge, which is established through scientific methods and objectively applied by members of a scientific community. However, in recent years there has been a major challenge to this picture by a sociology of science that shows how scientific knowledge is socially negotiated, and inevitably linked to the values of the relevant parties, both scientists and nonscientists. These challengers do not see scientific knowledge as exempt from social inquiry.

Kuhn (1970) argued that scientific knowledge does not always develop as an orderly process, but is characterized by periodic revolutions. in which the methods of study and the assessment criteria change in a fragmented way. According to Kuhn, the shift from one scientific way of thinking to another is not made solely on the basis of clear rules of formal scientific practice, but can include social factors, though Kuhn has never developed a full analysis of what these might be. Collins (1975) took this concept further when he asserted that the outcome of experiments was not something whose meaning could be immediately comprehended, but rather something for interpretation, discussion between scientists, and reinterpretation in the light of other experiments.

One interpretation of this analysis of science is that traditional distinctions between facts and theories, and between scientific knowledge and values, can no longer be justified. Because social processes are involved at all stages of the creation, evaluation, and establishing of scientific knowledge, social values may also be involved.

In the same way as many scientists who study fluoridation have overlooked social values, sociologists have also downplayed an important part of the debate by ignoring the number of eminent scientists who have questioned aspects of fluoridation. An example is the study by Sutton in 1960, which analyzed the classic North American studies of the effect of fluoridation on tooth decay, and found that each showed significant methodological shortcomings. Sutton's detailed study throws doubt as to the extent of reductions in tooth decay from fluoridation. Yet Sutton's book is not cited in a single analysis of the fluoridation issue by any sociologist. In a situation of some scientific uncertainty, differences in values are highlighted. A supporter of fluoridation might argue. The evidence for the benefits of fluoridation is quite substantial, while the evidence for harm is limited and dubious. I think the likely benefits outweigh the possible dangers; hence I support fluoridation because it is the cheapest and easiest way to make sure every child reaps the benefits. An opponent might argue, 'Though the evidence for the benefits of fluoridation is substantial, there is some doubt about it. Since fluoridation is not necessary for good teeth, we should forego the benefits if there is some slight chance of harm. Some scientists claim that a small percentage of the population could be harmed by fluoride. Therefore I oppose fluoridation of water supplies and favor the voluntary use of fluoride tablets by those who want to take them.'

Both arguments consider the scientific evidence concerning fluoridation, but differ in their assessments of the social benefits and costs. This difference is not between rationality and irrationality but is a legitimate difference in values, for example, the positive value placed on good teeth, the negative value placed on possible health risks, and the social benefits or costs of compulsory or voluntary intake of fluorides.

From the sociological point of view, opposition to fluoridation is not necessarily irrational. Rather, claims to rationality and to scientific authority are better seen as part of a strategy to promote fluoridation than as incontrovertible statements of fact. Second, social values are likely to be bound up in any decision about fluoridation, so this is not an issue on which declarations by scientific experts ought to be considered the final word.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4653e350-f9e7-5494-9c01-bf420f13dfd3', '078550cc-c518-5706-b0e7-88c18e485bda', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes 1-5 on your answer sheet
1. The optimum amount of fluorine in fluoridated water is calculated partly according to
A
how hot the area is.
B
how warm the water is.
C
how many dental problems there are in the community.
D
how much fluorine the community chooses to have in its water.
2. One reason given by the writer for opposing fluoridation is that
A
it may contribute to tooth decay
B
it will be unacceptably expensive for the public.
C
obligatory fluoridation takes away personal freedom.
D
excessive fluoride could be added to the water by mistake.
3. The writer mentions Kuhn in order to
A
provide a contrast with the view of Collins.
B
support the rational nature of scientific inquiry.
C
demonstrate that Kuhn did not argue his case adequately.
D
show that science can be influenced by non-scientific considerations
4. What did Sutton's research discover about earlier studies in North America?
A
There were failings in the way they were carried out.
B
The scientists involved had achieved unique results.
C
Proponents of fluoridation had not understood its long-term effects.
D
Fluoridation had a greater effect on tooth decay than previously believed.
5. In the last paragraph, what does the writer say about scientists?
A
They should reveal their true motivations.
B
They should not decide the fluoridation policy.
C
They are solely concerned with scientific truths.
D
They cannot reach agreement on the fluoridation issue.

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fa1708c-e8c2-5dc8-b66c-72dd4d40eeae', '078550cc-c518-5706-b0e7-88c18e485bda', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes 1-5 on your answer sheet
1. The optimum amount of fluorine in fluoridated water is calculated partly according to
A
how hot the area is.
B
how warm the water is.
C
how many dental problems there are in the community.
D
how much fluorine the community chooses to have in its water.
2. One reason given by the writer for opposing fluoridation is that
A
it may contribute to tooth decay
B
it will be unacceptably expensive for the public.
C
obligatory fluoridation takes away personal freedom.
D
excessive fluoride could be added to the water by mistake.
3. The writer mentions Kuhn in order to
A
provide a contrast with the view of Collins.
B
support the rational nature of scientific inquiry.
C
demonstrate that Kuhn did not argue his case adequately.
D
show that science can be influenced by non-scientific considerations
4. What did Sutton's research discover about earlier studies in North America?
A
There were failings in the way they were carried out.
B
The scientists involved had achieved unique results.
C
Proponents of fluoridation had not understood its long-term effects.
D
Fluoridation had a greater effect on tooth decay than previously believed.
5. In the last paragraph, what does the writer say about scientists?
A
They should reveal their true motivations.
B
They should not decide the fluoridation policy.
C
They are solely concerned with scientific truths.
D
They cannot reach agreement on the fluoridation issue.

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62905761-99b5-5e7f-92e2-8eacd2b3221b', '078550cc-c518-5706-b0e7-88c18e485bda', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes 1-5 on your answer sheet
1. The optimum amount of fluorine in fluoridated water is calculated partly according to
A
how hot the area is.
B
how warm the water is.
C
how many dental problems there are in the community.
D
how much fluorine the community chooses to have in its water.
2. One reason given by the writer for opposing fluoridation is that
A
it may contribute to tooth decay
B
it will be unacceptably expensive for the public.
C
obligatory fluoridation takes away personal freedom.
D
excessive fluoride could be added to the water by mistake.
3. The writer mentions Kuhn in order to
A
provide a contrast with the view of Collins.
B
support the rational nature of scientific inquiry.
C
demonstrate that Kuhn did not argue his case adequately.
D
show that science can be influenced by non-scientific considerations
4. What did Sutton's research discover about earlier studies in North America?
A
There were failings in the way they were carried out.
B
The scientists involved had achieved unique results.
C
Proponents of fluoridation had not understood its long-term effects.
D
Fluoridation had a greater effect on tooth decay than previously believed.
5. In the last paragraph, what does the writer say about scientists?
A
They should reveal their true motivations.
B
They should not decide the fluoridation policy.
C
They are solely concerned with scientific truths.
D
They cannot reach agreement on the fluoridation issue.

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d767641-a162-5d29-ac8f-a7ff2570335f', '078550cc-c518-5706-b0e7-88c18e485bda', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes 1-5 on your answer sheet
1. The optimum amount of fluorine in fluoridated water is calculated partly according to
A
how hot the area is.
B
how warm the water is.
C
how many dental problems there are in the community.
D
how much fluorine the community chooses to have in its water.
2. One reason given by the writer for opposing fluoridation is that
A
it may contribute to tooth decay
B
it will be unacceptably expensive for the public.
C
obligatory fluoridation takes away personal freedom.
D
excessive fluoride could be added to the water by mistake.
3. The writer mentions Kuhn in order to
A
provide a contrast with the view of Collins.
B
support the rational nature of scientific inquiry.
C
demonstrate that Kuhn did not argue his case adequately.
D
show that science can be influenced by non-scientific considerations
4. What did Sutton's research discover about earlier studies in North America?
A
There were failings in the way they were carried out.
B
The scientists involved had achieved unique results.
C
Proponents of fluoridation had not understood its long-term effects.
D
Fluoridation had a greater effect on tooth decay than previously believed.
5. In the last paragraph, what does the writer say about scientists?
A
They should reveal their true motivations.
B
They should not decide the fluoridation policy.
C
They are solely concerned with scientific truths.
D
They cannot reach agreement on the fluoridation issue.

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3e9d765-0194-5d91-91d8-b26c3363de9e', '078550cc-c518-5706-b0e7-88c18e485bda', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter,
A, B, C or D
Write the correct letter in boxes 1-5 on your answer sheet
1. The optimum amount of fluorine in fluoridated water is calculated partly according to
A
how hot the area is.
B
how warm the water is.
C
how many dental problems there are in the community.
D
how much fluorine the community chooses to have in its water.
2. One reason given by the writer for opposing fluoridation is that
A
it may contribute to tooth decay
B
it will be unacceptably expensive for the public.
C
obligatory fluoridation takes away personal freedom.
D
excessive fluoride could be added to the water by mistake.
3. The writer mentions Kuhn in order to
A
provide a contrast with the view of Collins.
B
support the rational nature of scientific inquiry.
C
demonstrate that Kuhn did not argue his case adequately.
D
show that science can be influenced by non-scientific considerations
4. What did Sutton's research discover about earlier studies in North America?
A
There were failings in the way they were carried out.
B
The scientists involved had achieved unique results.
C
Proponents of fluoridation had not understood its long-term effects.
D
Fluoridation had a greater effect on tooth decay than previously believed.
5. In the last paragraph, what does the writer say about scientists?
A
They should reveal their true motivations.
B
They should not decide the fluoridation policy.
C
They are solely concerned with scientific truths.
D
They cannot reach agreement on the fluoridation issue.

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6caa779-0e55-5951-93ee-76acc0e564e2', '078550cc-c518-5706-b0e7-88c18e485bda', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES if the statement agrees with the views of the writer
NO if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
6
Scientific knowledge should be kept separate from social values.
7
Many sociologists have disregarded the doubts that some scientists have concerning fluoridation.
8
Sutton's findings have been given insufficient attention by scientists outside of North America.
9
There are valid arguments on both sides of the fluoridation debate.

6 ____ Scientific knowledge should be kept separate from social values.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34d4f5cc-6d9a-5366-a44a-899335d3206a', 'b6caa779-0e55-5951-93ee-76acc0e564e2', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0909b7c6-c51e-5b45-937e-337948047afb', 'b6caa779-0e55-5951-93ee-76acc0e564e2', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f806b5a-c7a5-5989-b617-6db319926b4d', 'b6caa779-0e55-5951-93ee-76acc0e564e2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ad88c74-cb22-564b-81b2-dc92064063bc', '078550cc-c518-5706-b0e7-88c18e485bda', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES if the statement agrees with the views of the writer
NO if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
6
Scientific knowledge should be kept separate from social values.
7
Many sociologists have disregarded the doubts that some scientists have concerning fluoridation.
8
Sutton's findings have been given insufficient attention by scientists outside of North America.
9
There are valid arguments on both sides of the fluoridation debate.

7 ____ Many sociologists have disregarded the doubts that some scientists have concerning fluoridation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b32c8f77-32fe-5409-aede-fe03600a0fd9', '9ad88c74-cb22-564b-81b2-dc92064063bc', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebbead1e-e8dc-54c7-8f6a-7f6dce0a4c2c', '9ad88c74-cb22-564b-81b2-dc92064063bc', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e33f4f5-4f3f-5f92-8c8e-ea4dfdc9477a', '9ad88c74-cb22-564b-81b2-dc92064063bc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f02c1fa5-da30-5ecd-ae9b-b9e63393561a', '078550cc-c518-5706-b0e7-88c18e485bda', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES if the statement agrees with the views of the writer
NO if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
6
Scientific knowledge should be kept separate from social values.
7
Many sociologists have disregarded the doubts that some scientists have concerning fluoridation.
8
Sutton's findings have been given insufficient attention by scientists outside of North America.
9
There are valid arguments on both sides of the fluoridation debate.

8 ____ Sutton's findings have been given insufficient attention by scientists outside of North America.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7bca22b-8380-5aae-84a2-0b17bf2ba018', 'f02c1fa5-da30-5ecd-ae9b-b9e63393561a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5150f89b-940c-5542-870a-10ed3803228e', 'f02c1fa5-da30-5ecd-ae9b-b9e63393561a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b44b4d53-d260-5e5e-ab25-75fec87b6bcd', 'f02c1fa5-da30-5ecd-ae9b-b9e63393561a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b4d19ac-e833-5d87-9e56-08762474f0e7', '078550cc-c518-5706-b0e7-88c18e485bda', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES if the statement agrees with the views of the writer
NO if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
6
Scientific knowledge should be kept separate from social values.
7
Many sociologists have disregarded the doubts that some scientists have concerning fluoridation.
8
Sutton's findings have been given insufficient attention by scientists outside of North America.
9
There are valid arguments on both sides of the fluoridation debate.

9 ____ There are valid arguments on both sides of the fluoridation debate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84040314-0592-51a0-95b3-212e33bc5a85', '6b4d19ac-e833-5d87-9e56-08762474f0e7', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbcb800d-9419-5834-8154-3cc648a9069c', '6b4d19ac-e833-5d87-9e56-08762474f0e7', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a69eb16e-14ce-5f0a-8be1-7e57ee5eaf55', '6b4d19ac-e833-5d87-9e56-08762474f0e7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c75a1788-f090-5f85-8e96-34f2ebde7a21', '078550cc-c518-5706-b0e7-88c18e485bda', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending. A-G. below. Write the correct letter. A-G, in boxes 10-14 on your answer sheet.
10. The traditional view of science is that
10
11. A sociological view of science argues that
11
12. Collins is of the opinion that
12
13. The writer suggests that a supporter of fluoridation may conclude that
13
14. The writer suggests that an opponent of fluoridation may conclude that
14
A the results of scientific research are not always understood at first
B if it is impossible to say what the writer thinks about this
C people should be able to choose whether they want fluoride.
D there is insufficient proof to support a cautious approach.
E the serious damage fluoride causes far outweighs any positive effects.
F children are not the only ones who benefit from fluoridation.
G scientific knowledge is affected by the beliefs of everyone concerned.

10. The traditional view of science is that 10 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ac70b67-73c4-5b79-b33c-275e4f7f24ef', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4a23776-e6a3-5b37-b55b-ca457b7a93d7', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef1b71d9-f6ee-5c1d-8ce6-27a99fec26d9', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a97e18a9-95f6-5ef8-b365-560cae3e913e', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa92faf0-70da-5d8b-80c1-a07b7ac9eea2', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01037590-a6cb-5f46-9f96-3e8f7553225d', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44719e0c-2997-5430-9548-0f605a94807a', 'c75a1788-f090-5f85-8e96-34f2ebde7a21', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f55f10b1-271a-508f-ab77-0e73e5e22f00', '078550cc-c518-5706-b0e7-88c18e485bda', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending. A-G. below. Write the correct letter. A-G, in boxes 10-14 on your answer sheet.
10. The traditional view of science is that
10
11. A sociological view of science argues that
11
12. Collins is of the opinion that
12
13. The writer suggests that a supporter of fluoridation may conclude that
13
14. The writer suggests that an opponent of fluoridation may conclude that
14
A the results of scientific research are not always understood at first
B if it is impossible to say what the writer thinks about this
C people should be able to choose whether they want fluoride.
D there is insufficient proof to support a cautious approach.
E the serious damage fluoride causes far outweighs any positive effects.
F children are not the only ones who benefit from fluoridation.
G scientific knowledge is affected by the beliefs of everyone concerned.

11. A sociological view of science argues that 11 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('320afb19-58da-5ab0-9272-7cdc4cf59591', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b283cc8-ba86-57fb-9337-e191debb66fb', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8207b281-b845-5f22-9508-7191b4e7cb3d', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd5b92a6-d499-5a29-a549-2394a6f096be', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2003cafd-1a30-5b42-a2de-c15f9e547d8d', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dc6bbb7-f839-5744-b179-fa209db3aef5', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a507f49a-737b-5b45-b707-41ee2e1e38c3', 'f55f10b1-271a-508f-ab77-0e73e5e22f00', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('986ee678-8bcf-5bef-a76b-4df2d38da6e3', '078550cc-c518-5706-b0e7-88c18e485bda', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending. A-G. below. Write the correct letter. A-G, in boxes 10-14 on your answer sheet.
10. The traditional view of science is that
10
11. A sociological view of science argues that
11
12. Collins is of the opinion that
12
13. The writer suggests that a supporter of fluoridation may conclude that
13
14. The writer suggests that an opponent of fluoridation may conclude that
14
A the results of scientific research are not always understood at first
B if it is impossible to say what the writer thinks about this
C people should be able to choose whether they want fluoride.
D there is insufficient proof to support a cautious approach.
E the serious damage fluoride causes far outweighs any positive effects.
F children are not the only ones who benefit from fluoridation.
G scientific knowledge is affected by the beliefs of everyone concerned.

12. Collins is of the opinion that 12 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('593ef23b-5387-556f-a851-a6a57beb1e55', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4080479-c007-52fe-9243-e168a1dd1176', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ade495c-625d-5c9e-9eb7-58f1689a702c', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f05e88a-eed0-5180-b5de-0ad546b01ba4', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('175cbb9a-ce8a-536b-93a0-a7f75c67c861', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96c4bd46-ca24-5943-91ae-7c02eb05933b', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da9134d2-f536-571e-93ff-a4b010931ec3', '986ee678-8bcf-5bef-a76b-4df2d38da6e3', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', '078550cc-c518-5706-b0e7-88c18e485bda', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending. A-G. below. Write the correct letter. A-G, in boxes 10-14 on your answer sheet.
10. The traditional view of science is that
10
11. A sociological view of science argues that
11
12. Collins is of the opinion that
12
13. The writer suggests that a supporter of fluoridation may conclude that
13
14. The writer suggests that an opponent of fluoridation may conclude that
14
A the results of scientific research are not always understood at first
B if it is impossible to say what the writer thinks about this
C people should be able to choose whether they want fluoride.
D there is insufficient proof to support a cautious approach.
E the serious damage fluoride causes far outweighs any positive effects.
F children are not the only ones who benefit from fluoridation.
G scientific knowledge is affected by the beliefs of everyone concerned.

13. The writer suggests that a supporter of fluoridation may conclude that 13 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('794a9e9f-4f12-538d-8a87-13f3fde54bee', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58b63a2e-e299-5e2f-8f14-2a7263a930b0', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccb574b0-bfd2-5fb1-ab8e-dc33c165b0f8', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2558d2e6-51ff-5de4-aef3-d5b73f508219', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d96edf46-b2f3-5387-a4c7-f42f0725a87e', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('805c8996-18ac-55cd-ab38-9047db8bbbed', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bbfdafb-a887-5f9d-a5c6-e7eb4041753d', '0fc4f6a4-48d6-524a-8364-9f7be0e12ea6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ee0708d-d806-5e40-89e5-ae380c8b45c9', '078550cc-c518-5706-b0e7-88c18e485bda', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending. A-G. below. Write the correct letter. A-G, in boxes 10-14 on your answer sheet.
10. The traditional view of science is that
10
11. A sociological view of science argues that
11
12. Collins is of the opinion that
12
13. The writer suggests that a supporter of fluoridation may conclude that
13
14. The writer suggests that an opponent of fluoridation may conclude that
14
A the results of scientific research are not always understood at first
B if it is impossible to say what the writer thinks about this
C people should be able to choose whether they want fluoride.
D there is insufficient proof to support a cautious approach.
E the serious damage fluoride causes far outweighs any positive effects.
F children are not the only ones who benefit from fluoridation.
G scientific knowledge is affected by the beliefs of everyone concerned.

14. The writer suggests that an opponent of fluoridation may conclude that 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24a0aabd-5433-50ec-a305-eafa958b42d5', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64bf7f3f-b7de-503b-8383-28e4e89ebbdc', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de5d0fac-a766-5048-bd18-7d145bd585cc', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aaf9bd7-82bd-59aa-8f0e-3dd759edc24b', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('005ab74d-4656-5cdf-a1bc-f19c08c46123', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88b7dcf7-8e13-5f38-aa01-93b4caeaf105', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4f80136-2772-55f4-8fcd-d4eb584b5b2f', '5ee0708d-d806-5e40-89e5-ae380c8b45c9', 7, $md$G$md$, false);

COMMIT;
