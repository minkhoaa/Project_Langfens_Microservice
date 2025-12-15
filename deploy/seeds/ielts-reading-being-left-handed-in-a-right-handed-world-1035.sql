BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-being-left-handed-in-a-right-handed-world-1035'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-being-left-handed-in-a-right-handed-world-1035';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-being-left-handed-in-a-right-handed-world-1035';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-being-left-handed-in-a-right-handed-world-1035';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ece0d074-df0e-59c9-8d4c-e7d33cb3869f', 'ielts-reading-being-left-handed-in-a-right-handed-world-1035', $t$Being Left-handed in a Right-handed World$t$, $md$## Being Left-handed in a Right-handed World

Nguồn:
- Test: https://mini-ielts.com/1035/reading/being-left-handed-in-a-right-handed-world
- Solution: https://mini-ielts.com/1035/view-solution/reading/being-left-handed-in-a-right-handed-world$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8e1b1d92-f4b9-5dae-b49f-dda461f68339', 'ece0d074-df0e-59c9-8d4c-e7d33cb3869f', 1, $t$Reading — Being Left-handed in a Right-handed World$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Being Left-handed in a Right-handed World

The world is designed for right-handed people. Why does a tenth of the population prefer the left?

A The probability that two right-handed people would have a left-handed child is only about 9.5 percent . The chance rises to 19.5 percent if one parent is a lefty and 26 percent if both parents are left-handed. The preference, however, could also stem from an infant’s imitation of his parents. To test genetic influence, starting in the 1970s British biologist Marian Annett of the University of Leicester hypothesized that no single gene determines handedness . Rather, during fetal development, a certain molecular factor helps to strengthen the brain’s left hemisphere, which increases the probability that the right hand will be dominant, because the left side of the brain controls the right side of the body, and vice versa . Among the minority of people who lack this factor, handedness develops entirely by chance. Research conducted on twins complicates the theory, however. One in fivesets of identical twins involves one right-handed and one left-handed person, despite the fact that their genetic material is the same. Genes, therefore, are not solely responsible for handedness .

B Genetic theory is also undermined by results from Peter Hepper and his team at Queen’s University in Belfast, Ireland. In 2004 the psychologists used ultrasound to show that by the 15th week of pregnancy, fetuses already have a preference as to which thumb they suck . In most cases, the preference continued after birth. At 15 weeks, though, the brain does not yet have control over the body’s limbs. Hepper speculates that fetuses tend to prefer whichever side of the body is developing quicker and that their movements, in turn, influence the brain’s development. Whether this early preference is temporary or holds up throughout development and infancy is unknown. Genetic predetermination is also contradicted by the widespread observation that children do not settle on either their right or left hand until they are two or three years old.

C But even if these correlations were true, they did not explain what actually causes left-handedness. Furthermore, specialization on either side of the body is common among animals . Cats will favor one paw over another when fishing toys out from under the couch. Horses stomp more frequently with one hoof than the other. Certain crabs motion predominantly with the left or right claw. In evolutionary terms, focusing power and dexterity in one limb is more efficient than having to train two, four or even eight limbs equally. Yet for most animals, the preference for one side or the other is seemingly random. The overwhelming dominance of the right hand is associated only with humans. That fact directs attention toward the brain’s two hemispheres and perhaps toward language.

D Interest in hemispheres dates back to at least 1836. That year, at a medical conference, French physician Marc Dax reported on an unusual commonality among his patients. During his many years as a country doctor, Dax had encountered more than 40 men and women for whom speech was difficult, the result of some kind of brain damage. What was unique was that every individual suffered damage to the left side of the brain. At the conference, Dax elaborated on his theory, stating that each half of the brain was responsible for certain functions and that the left hemisphere controlled speech . Other experts showed little interest in the Frenchman’s ideas. Over time, however, scientists found more and more evidence of peopleexperiencing speech difficulties following injury to the left brain. Patients with damage to the right hemisphere most often displayed disruptions in perception or concentration. Major advancements in understanding the brain’s asymmetry were made in the 1960s as a result of so-called split-brain surgery, developed to help patients with epilepsy. During this operation, doctors severed the corpus callosum—the nerve bundle that connects the two hemispheres. The surgical cut also stopped almost all normal communication between the two hemispheres, which offered researchers the opportunity to investigate each side’s activity.

E In 1949 neurosurgeon Juhn Wada devised the first test to provide access to the brain’s functional organization of language. By injecting an anesthetic into the right or left carotid artery, Wada temporarily paralyzed one side of a healthy brain, enabling him to more closely study the other side’s capabilities. Based on this approach, Brenda Milner and the late Theodore Rasmussen of the Montreal Neurological Institute published a major study in 1975 that confirmed the theory that country doctor Dax had formulated nearly 140 years earlier: in 96 percent of right-handed people, language is processed much more intensely in the left hemisphere . The correlation is not as clear in lefties, however. For two thirds of them, the left hemisphere is still the most active language processor. But for the remaining third, either the right side is dominant or both sides work equally, controlling different language functions. That last statistic has slowed acceptance of the notion that the predominance of right-handedness is driven by left-hemisphere dominance in language processing. It is not at all clear why language control should somehow have dragged the control of body movement with it. Some experts think one reason the left hemisphere reigns over language is because the organs of speech processing—the larynx and tongue—are positioned on the body’s symmetry axis. Because these structures were centered, it may have been unclear, in evolutionary terms, which side of the brain should control them, and it seems unlikely that shared operation would result in smooth motor activity. Language and handedness could have developed preferentially for very different reasons as well. For example, some researchers, including evolutionary psychologist Michael C. Corballis of the University of Auckland in New Zealand, think that the origin of human speech lies in gestures. Gestures predated words and helped language emerge. If the left hemisphere began to dominate speech, it would have dominated gestures, too, and because the left brain controls the right side of the body, the right hand developed more strongly .

F Perhaps we will know more soon. In the meantime, we can revel in what, if any, differences handedness brings to our human talents. Popular wisdom says right-handed, left-brained people excel at logical, analytical thinking. Lefthanded, right-brained individuals are thought to possess more creative skills and may be better at combining the functional features emergent in both sides of the brain. Yet some neuroscientists see such claims as pure speculation. Fewer scientists are ready to claim that left-handedness means greater creative potential. Yet lefties are prevalent among artists, composers and the generally acknowledged great political thinkers. Possibly if these individuals are among the lefties whose language abilities are evenly distributed between hemispheres, the intense interplay required could lead to unusual mental capabilities.

G Or perhaps some lefties become highly creative simply because they must be more clever to get by in our right-handed world. This battle, which begins during the very early stages of childhood, may lay the groundwork for exceptional achievements.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ca359233-8162-5af3-ba4d-a05336849ead', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has seven sections
A-G
.
Which section contains the following information?
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
Preference of using one side of the body in animal species.
Locate
2
How likely one-handedness is born.
Locate
3
The age when the preference of using one hand is settled.
Locate
4
Occupations usually found in left-handed population.
Locate
5
A reference to an early discovery of each hemisphere’s function.
Locate

1 ____ Preference of using one side of the body in animal species. Locate 2 ____ How likely one-handedness is born. Locate 3 ____ The age when the preference of using one hand is settled. Locate 4 ____ Occupations usually found in left-handed population. Locate 5 ____ A reference to an early discovery of each hemisphere’s function. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4905412-0c16-52f6-98f3-1f6a6fcb35b0', 'ca359233-8162-5af3-ba4d-a05336849ead', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f87cd117-971c-554b-a59f-060032efcfbc', 'ca359233-8162-5af3-ba4d-a05336849ead', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b633156d-66e7-58e4-b210-f0e800ad3e39', 'ca359233-8162-5af3-ba4d-a05336849ead', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34589bcb-f235-5878-9cf8-c39bce96c429', 'ca359233-8162-5af3-ba4d-a05336849ead', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1261db7d-34b5-51f2-b9ce-3bd8f8378f15', 'ca359233-8162-5af3-ba4d-a05336849ead', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba5e99c4-2c77-52ca-968c-47b7faa88499', 'ca359233-8162-5af3-ba4d-a05336849ead', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8dd7481-2e5b-5e18-88be-74c9fed47d07', 'ca359233-8162-5af3-ba4d-a05336849ead', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3aa3ba9d-22f0-5646-ad19-74690305a8d8', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has seven sections
A-G
.
Which section contains the following information?
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
Preference of using one side of the body in animal species.
Locate
2
How likely one-handedness is born.
Locate
3
The age when the preference of using one hand is settled.
Locate
4
Occupations usually found in left-handed population.
Locate
5
A reference to an early discovery of each hemisphere’s function.
Locate

1 ____ Preference of using one side of the body in animal species. Locate 2 ____ How likely one-handedness is born. Locate 3 ____ The age when the preference of using one hand is settled. Locate 4 ____ Occupations usually found in left-handed population. Locate 5 ____ A reference to an early discovery of each hemisphere’s function. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a418f24d-d466-59b8-bde8-dd0b391ce15e', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4b64837-fd5e-593d-a246-ace6191184d4', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e22431e2-ef06-532f-8e7c-cef6f30a1487', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7be4b78b-b4c0-5331-a72b-0365c22601cf', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d338da7-96d6-577f-b1c2-964c9500aa94', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ad55043-7870-5bc4-927e-7dabd8c8ac2b', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f552f10d-e8ec-5136-9b9e-9e0260c36406', '3aa3ba9d-22f0-5646-ad19-74690305a8d8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15b88ce3-c10c-5cc2-98da-536c13440d4b', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has seven sections
A-G
.
Which section contains the following information?
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
Preference of using one side of the body in animal species.
Locate
2
How likely one-handedness is born.
Locate
3
The age when the preference of using one hand is settled.
Locate
4
Occupations usually found in left-handed population.
Locate
5
A reference to an early discovery of each hemisphere’s function.
Locate

1 ____ Preference of using one side of the body in animal species. Locate 2 ____ How likely one-handedness is born. Locate 3 ____ The age when the preference of using one hand is settled. Locate 4 ____ Occupations usually found in left-handed population. Locate 5 ____ A reference to an early discovery of each hemisphere’s function. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bad4ae02-5ec3-56d9-a358-28f3eac1b064', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('395cfaeb-4216-5f1d-b805-fb9522e1acca', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36ea2974-d7d3-59a8-b6ea-d43a28341cf5', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c579e7f-2886-5509-a5ca-865c498d4492', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34bedcfb-a83d-5217-9a91-b85dbdd0c0d3', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98159fe2-78ef-5b49-88fb-34bbac94f7fc', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06955e46-3699-5cf0-a45e-e42075766c36', '15b88ce3-c10c-5cc2-98da-536c13440d4b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65b594e3-9a87-5da5-b1f3-ca386ecae1f3', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has seven sections
A-G
.
Which section contains the following information?
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
Preference of using one side of the body in animal species.
Locate
2
How likely one-handedness is born.
Locate
3
The age when the preference of using one hand is settled.
Locate
4
Occupations usually found in left-handed population.
Locate
5
A reference to an early discovery of each hemisphere’s function.
Locate

1 ____ Preference of using one side of the body in animal species. Locate 2 ____ How likely one-handedness is born. Locate 3 ____ The age when the preference of using one hand is settled. Locate 4 ____ Occupations usually found in left-handed population. Locate 5 ____ A reference to an early discovery of each hemisphere’s function. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('873d41c0-bee9-5b2a-932d-33fe61009b2b', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61b66049-301b-5ec9-b8e9-32840decaac1', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ab743de-6063-56db-bdef-17f8f9a2eb6b', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e85ae97-de64-59e7-ba98-fb6da6fa36ce', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9072985-5993-582a-958d-83ed0fdfbc4b', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13da64cd-0c7c-5108-bc77-998ce100bea7', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8459fc83-6141-5225-9b48-1c2ce5049a39', '65b594e3-9a87-5da5-b1f3-ca386ecae1f3', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb882312-749d-5b12-bc1d-e9954fa9afd6', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has seven sections
A-G
.
Which section contains the following information?
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
Preference of using one side of the body in animal species.
Locate
2
How likely one-handedness is born.
Locate
3
The age when the preference of using one hand is settled.
Locate
4
Occupations usually found in left-handed population.
Locate
5
A reference to an early discovery of each hemisphere’s function.
Locate

1 ____ Preference of using one side of the body in animal species. Locate 2 ____ How likely one-handedness is born. Locate 3 ____ The age when the preference of using one hand is settled. Locate 4 ____ Occupations usually found in left-handed population. Locate 5 ____ A reference to an early discovery of each hemisphere’s function. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9175e254-c056-5275-98b5-6ea8dbe3b3b6', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7be0b36-7c06-57c7-97da-193c738b1613', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bff3f4e1-d7c8-5f19-b56c-6dd4325d29c4', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('854d5b6f-2a1b-5b3f-9458-649a39917497', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('016fd622-cb39-50e6-8173-f0b7a4277be4', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44f6637a-4944-5d7b-9d08-56efa793a000', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('617cb745-8efc-524b-ab7b-e9591d22dd38', 'fb882312-749d-5b12-bc1d-e9954fa9afd6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('162ee358-bd4e-5359-b202-ac652e48060b', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Look at the following researchers (Questions
6-9
) and the list of findings below.
Match each researcher with the correct finding.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
List of Findings
A
Early language evolution is correlated to body movement and thus affecting the preference of use of one hand.
B
No single biological component determines the handedness of a child.
C
Each hemisphere of the brain is in charge of different body functions.
D
Language process is mainly centered in the left-hemisphere of the brain.
E
Speech difficulties are often caused by brain damage.
F
The rate of development of one side of the body has influence on hemisphere preference in fetus.
G
Brain function already matures by the end of the fetal stage.
6
Marian Annett
Locate
7
Peter Hepper
Locate
8
Brenda Milner & Theodore Rasmussen
Locate
9
Michael Corballis
Locate

6 ____ Marian Annett Locate 7 ____ Peter Hepper Locate 8 ____ Brenda Milner & Theodore Rasmussen Locate 9 ____ Michael Corballis Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c6424d6-b5a5-583b-a67f-24b9f8f1b897', '162ee358-bd4e-5359-b202-ac652e48060b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c070bf0-6b94-5185-a79c-b9f1001057ff', '162ee358-bd4e-5359-b202-ac652e48060b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('239e3797-654e-583a-9493-6c8fff718561', '162ee358-bd4e-5359-b202-ac652e48060b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a545f2bd-1695-5252-be6b-b5ec88d623ae', '162ee358-bd4e-5359-b202-ac652e48060b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1ce0b6e-de22-5dd2-9547-833d99d9aaad', '162ee358-bd4e-5359-b202-ac652e48060b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34c39a11-b4c6-5310-a581-8742ee14d65a', '162ee358-bd4e-5359-b202-ac652e48060b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8126028-5453-5939-88e2-0723bea7cc40', '162ee358-bd4e-5359-b202-ac652e48060b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98295732-7107-5cfb-afef-c79607a9af72', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Look at the following researchers (Questions
6-9
) and the list of findings below.
Match each researcher with the correct finding.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
List of Findings
A
Early language evolution is correlated to body movement and thus affecting the preference of use of one hand.
B
No single biological component determines the handedness of a child.
C
Each hemisphere of the brain is in charge of different body functions.
D
Language process is mainly centered in the left-hemisphere of the brain.
E
Speech difficulties are often caused by brain damage.
F
The rate of development of one side of the body has influence on hemisphere preference in fetus.
G
Brain function already matures by the end of the fetal stage.
6
Marian Annett
Locate
7
Peter Hepper
Locate
8
Brenda Milner & Theodore Rasmussen
Locate
9
Michael Corballis
Locate

6 ____ Marian Annett Locate 7 ____ Peter Hepper Locate 8 ____ Brenda Milner & Theodore Rasmussen Locate 9 ____ Michael Corballis Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d405971d-b6c6-5078-8fff-1cecb6589cb8', '98295732-7107-5cfb-afef-c79607a9af72', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62cc54b0-3c10-5a59-8b35-76e1f28e6db9', '98295732-7107-5cfb-afef-c79607a9af72', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cf9d7a4-82c2-51ae-bd5e-a02bfa9aeb8f', '98295732-7107-5cfb-afef-c79607a9af72', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dc72298-3d58-5861-b902-6495db014472', '98295732-7107-5cfb-afef-c79607a9af72', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12bd8580-c35c-5c54-9f8f-75f1ea1b8dfd', '98295732-7107-5cfb-afef-c79607a9af72', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5451212-ae6d-5687-93b5-736080389205', '98295732-7107-5cfb-afef-c79607a9af72', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6177973a-57c0-5ff8-bc9c-11dfbd25d129', '98295732-7107-5cfb-afef-c79607a9af72', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08d43f30-2a25-5165-83b9-7566a7d56f63', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Look at the following researchers (Questions
6-9
) and the list of findings below.
Match each researcher with the correct finding.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
List of Findings
A
Early language evolution is correlated to body movement and thus affecting the preference of use of one hand.
B
No single biological component determines the handedness of a child.
C
Each hemisphere of the brain is in charge of different body functions.
D
Language process is mainly centered in the left-hemisphere of the brain.
E
Speech difficulties are often caused by brain damage.
F
The rate of development of one side of the body has influence on hemisphere preference in fetus.
G
Brain function already matures by the end of the fetal stage.
6
Marian Annett
Locate
7
Peter Hepper
Locate
8
Brenda Milner & Theodore Rasmussen
Locate
9
Michael Corballis
Locate

6 ____ Marian Annett Locate 7 ____ Peter Hepper Locate 8 ____ Brenda Milner & Theodore Rasmussen Locate 9 ____ Michael Corballis Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7820993c-10f7-52ce-9f28-c1363de4a8cd', '08d43f30-2a25-5165-83b9-7566a7d56f63', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('461aeb7a-ead1-5556-838d-eec33226ef83', '08d43f30-2a25-5165-83b9-7566a7d56f63', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57eda89a-25ea-59cc-93f2-3aaca44c25e7', '08d43f30-2a25-5165-83b9-7566a7d56f63', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56c82a03-2dbf-567e-8ec3-a5cc13fe43db', '08d43f30-2a25-5165-83b9-7566a7d56f63', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18f4a92c-a448-5732-9a1e-13642e739f22', '08d43f30-2a25-5165-83b9-7566a7d56f63', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9936e1d2-6527-5384-96ac-258b1e39b365', '08d43f30-2a25-5165-83b9-7566a7d56f63', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1234b82e-c247-514b-a003-878846fef64d', '08d43f30-2a25-5165-83b9-7566a7d56f63', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Look at the following researchers (Questions
6-9
) and the list of findings below.
Match each researcher with the correct finding.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
List of Findings
A
Early language evolution is correlated to body movement and thus affecting the preference of use of one hand.
B
No single biological component determines the handedness of a child.
C
Each hemisphere of the brain is in charge of different body functions.
D
Language process is mainly centered in the left-hemisphere of the brain.
E
Speech difficulties are often caused by brain damage.
F
The rate of development of one side of the body has influence on hemisphere preference in fetus.
G
Brain function already matures by the end of the fetal stage.
6
Marian Annett
Locate
7
Peter Hepper
Locate
8
Brenda Milner & Theodore Rasmussen
Locate
9
Michael Corballis
Locate

6 ____ Marian Annett Locate 7 ____ Peter Hepper Locate 8 ____ Brenda Milner & Theodore Rasmussen Locate 9 ____ Michael Corballis Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('676ea6a8-ed56-5e2c-8b44-1744c8bda954', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27dee8cb-0ab5-5fec-8691-6616305f585e', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58edcbb4-a0b8-502f-b837-615afcc821d3', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f39d028-427b-5ba5-a191-3aa6136054e4', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0f541ba-74ca-53ee-b651-6d839f7b683e', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('000f0d39-0346-575f-ba67-95b34c3f2d66', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bfe2ec6-7c25-59d9-92d9-9a70d55f87b4', 'd6e6a5cc-1d9f-59a3-b07f-e8592b0dfae5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1dd56b5-b27b-5a4a-ac65-d292b8e64945', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The study of twins shows that genetic determinationis not the only factor for left-handedness.
Locate
11
Marc Dax’s report was widely accepted in his time.
Locate
12
Juhn Wada based his findings on his research of people with language problems.
13
There tend to be more men with left-handedness than women.

10 ____ The study of twins shows that genetic determinationis not the only factor for left-handedness. Locate 11 ____ Marc Dax’s report was widely accepted in his time. Locate 12 ____ Juhn Wada based his findings on his research of people with language problems. 13 ____ There tend to be more men with left-handedness than women.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('256478ac-e0f5-58b0-a8bd-3db7c6565fda', 'e1dd56b5-b27b-5a4a-ac65-d292b8e64945', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7af2e4-94f7-5b18-9c7d-52bbbe89ea36', 'e1dd56b5-b27b-5a4a-ac65-d292b8e64945', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('288eea9f-9729-5ae2-8245-3e3c5e18f60a', 'e1dd56b5-b27b-5a4a-ac65-d292b8e64945', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('290fda2b-898a-5910-ab08-64666a57ea20', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The study of twins shows that genetic determinationis not the only factor for left-handedness.
Locate
11
Marc Dax’s report was widely accepted in his time.
Locate
12
Juhn Wada based his findings on his research of people with language problems.
13
There tend to be more men with left-handedness than women.

10 ____ The study of twins shows that genetic determinationis not the only factor for left-handedness. Locate 11 ____ Marc Dax’s report was widely accepted in his time. Locate 12 ____ Juhn Wada based his findings on his research of people with language problems. 13 ____ There tend to be more men with left-handedness than women.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ef9cc65-d310-5b2a-b880-4e5b0cbd1a8a', '290fda2b-898a-5910-ab08-64666a57ea20', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60ed6499-5249-5261-a7d6-e62710016882', '290fda2b-898a-5910-ab08-64666a57ea20', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc7b0c8f-c5e3-584e-a834-4a3bdd7a21a2', '290fda2b-898a-5910-ab08-64666a57ea20', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aef96898-f4d5-5e04-b8c5-d3020e268849', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The study of twins shows that genetic determinationis not the only factor for left-handedness.
Locate
11
Marc Dax’s report was widely accepted in his time.
Locate
12
Juhn Wada based his findings on his research of people with language problems.
13
There tend to be more men with left-handedness than women.

10 ____ The study of twins shows that genetic determinationis not the only factor for left-handedness. Locate 11 ____ Marc Dax’s report was widely accepted in his time. Locate 12 ____ Juhn Wada based his findings on his research of people with language problems. 13 ____ There tend to be more men with left-handedness than women.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d0dce20-0bed-5ebe-a99e-144d98152f46', 'aef96898-f4d5-5e04-b8c5-d3020e268849', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44351afc-acae-59d7-8b3a-0946fb6fc132', 'aef96898-f4d5-5e04-b8c5-d3020e268849', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fc47ca0-aa69-59c5-9dd1-b48b0778fb83', 'aef96898-f4d5-5e04-b8c5-d3020e268849', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68c67976-d809-5085-81a4-4285a303ccf6', '8e1b1d92-f4b9-5dae-b49f-dda461f68339', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The study of twins shows that genetic determinationis not the only factor for left-handedness.
Locate
11
Marc Dax’s report was widely accepted in his time.
Locate
12
Juhn Wada based his findings on his research of people with language problems.
13
There tend to be more men with left-handedness than women.

10 ____ The study of twins shows that genetic determinationis not the only factor for left-handedness. Locate 11 ____ Marc Dax’s report was widely accepted in his time. Locate 12 ____ Juhn Wada based his findings on his research of people with language problems. 13 ____ There tend to be more men with left-handedness than women.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fd2b763-6f6a-51d7-869a-6244374f3466', '68c67976-d809-5085-81a4-4285a303ccf6', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce12a8bb-bcff-549a-9f8b-f07e63ca07b3', '68c67976-d809-5085-81a4-4285a303ccf6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98ac6dcf-e53f-57c3-9f7f-2e0c4ac4a297', '68c67976-d809-5085-81a4-4285a303ccf6', 3, $md$NOT GIVEN$md$, false);

COMMIT;
