BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-sunny-days-for-silicon-1496'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sunny-days-for-silicon-1496';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sunny-days-for-silicon-1496';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-sunny-days-for-silicon-1496';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2b5c7261-e124-56fb-b033-393289b21dbe', 'ielts-reading-sunny-days-for-silicon-1496', $t$Sunny Days For Silicon$t$, $md$## Sunny Days For Silicon

Nguồn:
- Test: https://mini-ielts.com/1496/reading/sunny-days-for-silicon
- Solution: https://mini-ielts.com/1496/view-solution/reading/sunny-days-for-silicon$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', '2b5c7261-e124-56fb-b033-393289b21dbe', 1, $t$Reading — Sunny Days For Silicon$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Sunny Days For Silicon

A The old saw that "the devil is in the details" characterizes the kind of needling obstacles that prevent an innovative concept from becoming a working technology. It also often describes the type of problems that must be overcome to shave cost from the resulting product so that people will buy it. Emanuel Sachs of the Massachusetts Institute of Technology has struggled with many such little devils in his career-tong endeavor to develop low-cost, high-efficiency solar cells. In his latest effort, Sachs has found incremental ways to boost the amount of electricity that common photovoltaics (PVs) generate from sunlight without increasing the costs. Specifically, he has raised the conversion efficiency of test cells made from multi-crystalline silicon from the typical 15.5 percent to nearly 20 percent—on par with pricier single-crystal silicon cells. Such improvements could bring the cost of PV power down from the current $1.90 to $2.10 per watt to $1.65 per watt. With additional tweaks, Sachs anticipates creating within Four years solar cells that can produce juice at a dollar per watt, a feat that would make electricity (rum the sun competitive with that from coal-burning power plants.

B Most PV cells, such as those on home rooftops, rely on silicon to convert sunlight into electric current. Metal interconnects then funnel the electricity out from the silicon to power devices or to feed an electrical grid. Since solar cells became practical and affordable three decades ago, engineers have mostly favored using single-crystal silicon as the active material, says Michael Rogol, managing director of Germany- based Photon Consulting. Wafers of the substance are typically sawed from an ingot consisting of one large crystal that has been pulled like taffy out of a vat of molten silicon. Especially at first, the high-purity ingots were left over from integrated-circuit manufacture, but later the process was used to make PV cells themselves, Rogol recounts. Although single-crystal cells offer high conversion efficiencies, they are expensive to make. The alternatives- multi-crystalline silicon cells, which factories fabricate from lower-purity, cast ingots composed of many smaller crystals—are cheaper to make, but unfortunately they are less efficient than single-crystal cells.

C Sachs, who has pioneered several novel ways to make silicon solar cells less costly and more effective, recently turned his focus to the details of multi-crystalline silicon cell manufacture. The first small improvement concerns the little silver fingers that gather electric current from the surface of the bulk silicon," he explains. In conventional fabrication processes, cell manufacturers use screen-printing techniques ("like high-accuracy silk-screening of T-shirts," Sachs notes) and inks containing, silver particles to create these bus wires. The trouble is that standard silver wires come out wide and short, about 120 by 10 microns, and include many nonconductive voids. As a result, they block considerable sunlight and do not carry as much current as they should.

D At his start-up company—Lexington, Mass- based 1366 Technologies (the number refers to the flux of sunlight that strikes the earth's outer atmosphere: 1.366 watts per square meter)—Sachs is employing "a proprietary wet process that can produce thinner and taller" wires that are 20 by 20 microns. The slimmer bus wires use less costly silver and can be placed closer together so they can draw more current from the neighboring active material, through which free electrons can travel only so far. At the same time, the wires block less incoming light than their standard counterparts.

E The second innovation alters the wide, flat interconnect wires that collect current from the silver bus wires and electrically link adjacent cells. Interconnect wires at the top can shade as much as 5 percent of the area of a cell. "We place textured mirror surfaces on the faces of these rolled wires. These little mirrors reflect incoming light at a lower angle--around 30 degrees-—so that when the reflected rays hit the glass layer at Lire top, they stay within the silicon wafer by way of total internal reflection,” Sachs explains. (Divers and snorkelers commonly see this optical effect when they view water surfaces from below.) The longer that light remains inside, the more chance it has to be absorbed and transformed into electricity.

F Sachs expects that new antireflection coatings will further raise multi-crystal line cell efficiencies. One of his firm's future goals will be a switch from expensive silver bus wires to cheaper copper ones. And he has a few ideas regarding how to successfully make the substitution. "Unlike silver, copper poisons the performance of silicon PVs," Sachs says, "so it will be crucial to include a low-cost diffusion barrier that stops direct contact between copper and the silicon." In this business, it's always the little devilish details that count.

G The cost of silicon solar cells is likely to fall as bulk silicon prices drop, according to the U.S. Energy information Administration and the industry tracking firm Solarbuzz. A steep rise in solar panel sales in recent years had led to a global shortage of silicon because production capacity for the active material lagged behind, but now new silicon manufacturing plants are coming online. The reduced materials costs and resulting lower system prices will greatly boost demand for solar-electric technology, according to market watcher Michael Rogol of Photon Consulting.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5655997-c1aa-5444-a4f0-00ff9639c038', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the people or companies (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter
more than once
A. Emanuel Sach
B. Michael Rogol
C. Solarbuzz
1
Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.
2
Made a joint prediction with another national agency.
3
Established an enterprise with a meaningful name.
4
Led forward in the solar-electric field by reducing the cost while raising the efficiency.
5
Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.

1 ____ Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12e8813c-f2de-53a0-ad12-73a949245b38', 'e5655997-c1aa-5444-a4f0-00ff9639c038', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe4f99b-06ab-546b-8dd5-3f2432d70eb5', 'e5655997-c1aa-5444-a4f0-00ff9639c038', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8784592d-f888-51b1-9924-6011ed7b0ac8', 'e5655997-c1aa-5444-a4f0-00ff9639c038', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b368c33c-22c8-5fc3-8eb0-76c6f511e437', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the people or companies (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter
more than once
A. Emanuel Sach
B. Michael Rogol
C. Solarbuzz
1
Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.
2
Made a joint prediction with another national agency.
3
Established an enterprise with a meaningful name.
4
Led forward in the solar-electric field by reducing the cost while raising the efficiency.
5
Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.

2 ____ Made a joint prediction with another national agency.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('644772ca-d0ca-5895-9bed-16e71e3e094f', 'b368c33c-22c8-5fc3-8eb0-76c6f511e437', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7913e7c7-9d19-5d83-8f9f-b3f143eb87de', 'b368c33c-22c8-5fc3-8eb0-76c6f511e437', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83820bfb-6b7d-5494-b5be-5fcdb650d131', 'b368c33c-22c8-5fc3-8eb0-76c6f511e437', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdd41939-6ad7-5e6b-acb1-6c64b526a9da', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the people or companies (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter
more than once
A. Emanuel Sach
B. Michael Rogol
C. Solarbuzz
1
Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.
2
Made a joint prediction with another national agency.
3
Established an enterprise with a meaningful name.
4
Led forward in the solar-electric field by reducing the cost while raising the efficiency.
5
Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.

3 ____ Established an enterprise with a meaningful name.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d955eac-0f1b-556b-806f-16f2efbb1bd1', 'fdd41939-6ad7-5e6b-acb1-6c64b526a9da', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1d50218-ff50-58ba-a8eb-7acdfd9609cf', 'fdd41939-6ad7-5e6b-acb1-6c64b526a9da', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4b9b2bf-829d-57af-8f7f-61add1b389d1', 'fdd41939-6ad7-5e6b-acb1-6c64b526a9da', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08291b88-fbba-5f90-85e4-a38457972175', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the people or companies (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter
more than once
A. Emanuel Sach
B. Michael Rogol
C. Solarbuzz
1
Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.
2
Made a joint prediction with another national agency.
3
Established an enterprise with a meaningful name.
4
Led forward in the solar-electric field by reducing the cost while raising the efficiency.
5
Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.

4 ____ Led forward in the solar-electric field by reducing the cost while raising the efficiency.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4858124-a647-523d-9e00-322dceed382a', '08291b88-fbba-5f90-85e4-a38457972175', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38fb6b40-10ac-5e8b-b53a-fd822a452973', '08291b88-fbba-5f90-85e4-a38457972175', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65da9724-0003-50c7-b04a-5c4d7f8a70fa', '08291b88-fbba-5f90-85e4-a38457972175', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4179a44-0f65-59eb-bc2a-b91527b70b16', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the people or companies (listed A-C) with opinions or deeds below. Write the appropriate letters A-C in boxes 1-5 on your answer sheet.
NB you may use any letter
more than once
A. Emanuel Sach
B. Michael Rogol
C. Solarbuzz
1
Gives a brief account of the history of the common practice to manufacture silicon batteries for a long time.
2
Made a joint prediction with another national agency.
3
Established an enterprise with a meaningful name.
4
Led forward in the solar-electric field by reducing the cost while raising the efficiency.
5
Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.

5 ____ Expects to lower the cost of solar cells to a level that they could contend with the traditional way to generate electricity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ed6c39a-c93d-5993-9561-bc25fdf74340', 'd4179a44-0f65-59eb-bc2a-b91527b70b16', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a07599-390f-53bd-b624-829b4d0ead98', 'd4179a44-0f65-59eb-bc2a-b91527b70b16', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea640ead-ab47-533f-bc53-831b8c7aaae4', 'd4179a44-0f65-59eb-bc2a-b91527b70b16', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bdaf143f-aa9f-574b-8f0f-7e079b5de4e6', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes 6-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
The Achille’s heel of single-crystal cells is the high cost.
7
The multi-crystalline silicon cells are ideal substitutions for single-crystal cells.
8
Emanuel Sachs has some determining dues about the way to block the immediate contact between an alternative metal for silver and the silicon.
9
In the last few years, there is a sharp increase in the demand for solar panels.

6 ____ The Achille’s heel of single-crystal cells is the high cost.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d48e9be-0cf7-546c-ad6a-9687898e781f', 'bdaf143f-aa9f-574b-8f0f-7e079b5de4e6', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31cd9b3d-4a2a-54a3-a729-fe5c5a8ee98c', 'bdaf143f-aa9f-574b-8f0f-7e079b5de4e6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1128997-bb99-5749-bdba-8467bef28a42', 'bdaf143f-aa9f-574b-8f0f-7e079b5de4e6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6523dd0-d045-5f0f-a74e-93392bc48bab', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes 6-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
The Achille’s heel of single-crystal cells is the high cost.
7
The multi-crystalline silicon cells are ideal substitutions for single-crystal cells.
8
Emanuel Sachs has some determining dues about the way to block the immediate contact between an alternative metal for silver and the silicon.
9
In the last few years, there is a sharp increase in the demand for solar panels.

7 ____ The multi-crystalline silicon cells are ideal substitutions for single-crystal cells.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76765472-4502-5b60-bdf2-a8c683b30b5a', 'f6523dd0-d045-5f0f-a74e-93392bc48bab', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3db1de01-7218-5c21-a004-ec4774013709', 'f6523dd0-d045-5f0f-a74e-93392bc48bab', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aab4ea06-632e-532b-98f3-ca173db17bfc', 'f6523dd0-d045-5f0f-a74e-93392bc48bab', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1f1ff27-e8bb-5936-8235-86cfc2411525', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes 6-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
The Achille’s heel of single-crystal cells is the high cost.
7
The multi-crystalline silicon cells are ideal substitutions for single-crystal cells.
8
Emanuel Sachs has some determining dues about the way to block the immediate contact between an alternative metal for silver and the silicon.
9
In the last few years, there is a sharp increase in the demand for solar panels.

8 ____ Emanuel Sachs has some determining dues about the way to block the immediate contact between an alternative metal for silver and the silicon.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0ce0da4-e480-5429-82b4-b954a824b2be', 'c1f1ff27-e8bb-5936-8235-86cfc2411525', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb492c3e-382c-5c9b-a4ac-bb0b9dc9c508', 'c1f1ff27-e8bb-5936-8235-86cfc2411525', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb9642ee-ad6b-5a7d-9192-d717564283fd', 'c1f1ff27-e8bb-5936-8235-86cfc2411525', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('398b58a5-7ec5-5efa-b990-db68aa991989', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes 6-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
The Achille’s heel of single-crystal cells is the high cost.
7
The multi-crystalline silicon cells are ideal substitutions for single-crystal cells.
8
Emanuel Sachs has some determining dues about the way to block the immediate contact between an alternative metal for silver and the silicon.
9
In the last few years, there is a sharp increase in the demand for solar panels.

9 ____ In the last few years, there is a sharp increase in the demand for solar panels.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8680a1a-1a8a-509a-9d90-4c180a7bdf44', '398b58a5-7ec5-5efa-b990-db68aa991989', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8118e100-2836-5faf-b5eb-360e32b3d8b9', '398b58a5-7ec5-5efa-b990-db68aa991989', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9141a8d-e9e9-5ba9-81c5-9aea1412b58a', '398b58a5-7ec5-5efa-b990-db68aa991989', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b5187dff-7575-53d2-b4f0-cb4649e6bc1b', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Emanuel Sachs made two major changes to the particulars of the manufacture
10
. One is to take a
11
in the production of finer wires which means more current could be attracted from the
12
. The other one is to set
13
above the interconnect silver bus wires to keep the incoming sunlight by
14
.

Emanuel Sachs made two major changes to the particulars of the manufacture 10 ____ . One is to take a 11 ____ in the production of finer wires which means more current could be attracted from the 12 ____ . The other one is to set 13 ____ above the interconnect silver bus wires to keep the incoming sunlight by 14 ____ .$md$, NULL, ARRAY['.*multi.*crystalline.*silicon.*cell.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7188fb54-9916-5699-ac32-190b33d5fc4d', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Emanuel Sachs made two major changes to the particulars of the manufacture
10
. One is to take a
11
in the production of finer wires which means more current could be attracted from the
12
. The other one is to set
13
above the interconnect silver bus wires to keep the incoming sunlight by
14
.

Emanuel Sachs made two major changes to the particulars of the manufacture 10 ____ . One is to take a 11 ____ in the production of finer wires which means more current could be attracted from the 12 ____ . The other one is to set 13 ____ above the interconnect silver bus wires to keep the incoming sunlight by 14 ____ .$md$, NULL, ARRAY['.*multi.*crystalline.*silicon.*cell.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c2063ecb-4b0d-52a1-9248-bfadb6bf80f5', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Emanuel Sachs made two major changes to the particulars of the manufacture
10
. One is to take a
11
in the production of finer wires which means more current could be attracted from the
12
. The other one is to set
13
above the interconnect silver bus wires to keep the incoming sunlight by
14
.

Emanuel Sachs made two major changes to the particulars of the manufacture 10 ____ . One is to take a 11 ____ in the production of finer wires which means more current could be attracted from the 12 ____ . The other one is to set 13 ____ above the interconnect silver bus wires to keep the incoming sunlight by 14 ____ .$md$, NULL, ARRAY['.*multi.*crystalline.*silicon.*cell.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4e836f43-3e08-59ad-aa88-141de2791e71', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Emanuel Sachs made two major changes to the particulars of the manufacture
10
. One is to take a
11
in the production of finer wires which means more current could be attracted from the
12
. The other one is to set
13
above the interconnect silver bus wires to keep the incoming sunlight by
14
.

Emanuel Sachs made two major changes to the particulars of the manufacture 10 ____ . One is to take a 11 ____ in the production of finer wires which means more current could be attracted from the 12 ____ . The other one is to set 13 ____ above the interconnect silver bus wires to keep the incoming sunlight by 14 ____ .$md$, NULL, ARRAY['.*multi.*crystalline.*silicon.*cell.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d8ed724c-63e9-5478-bf8d-ccc3903baf36', 'db25fc8b-47b2-55f2-b9ec-4b9e2ba4a80f', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using No More than Three words from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Emanuel Sachs made two major changes to the particulars of the manufacture
10
. One is to take a
11
in the production of finer wires which means more current could be attracted from the
12
. The other one is to set
13
above the interconnect silver bus wires to keep the incoming sunlight by
14
.

Emanuel Sachs made two major changes to the particulars of the manufacture 10 ____ . One is to take a 11 ____ in the production of finer wires which means more current could be attracted from the 12 ____ . The other one is to set 13 ____ above the interconnect silver bus wires to keep the incoming sunlight by 14 ____ .$md$, NULL, ARRAY['.*multi.*crystalline.*silicon.*cell.*']);

COMMIT;
