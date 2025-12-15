BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-save-endangered-language-1349'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-save-endangered-language-1349';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-save-endangered-language-1349';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-save-endangered-language-1349';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b898094f-3a97-5ae2-8061-3c2a948ecaf2', 'ielts-reading-save-endangered-language-1349', $t$Save Endangered Language$t$, $md$## Save Endangered Language

Nguồn:
- Test: https://mini-ielts.com/1349/reading/save-endangered-language
- Solution: https://mini-ielts.com/1349/view-solution/reading/save-endangered-language$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('098d5e54-8a14-5883-8d1a-ef71b812a1de', 'b898094f-3a97-5ae2-8061-3c2a948ecaf2', 1, $t$Reading — Save Endangered Language$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Save Endangered Language

“Obviously we must do some serious rethinking of our priorities, lest linguistics go down in history as the only science that presided obviously over the disappearance of 90 percent of the very field to which it is dedicated.” – Michael Krauss, “The World’s Languages in Crisis”.

A

Ten years ago Michael Krauss sent a shudder through the discipline of linguistics with his prediction that half the 6,000 or so languages spoken in the world would cease to be uttered within a century. Unless scientists and community leaders directed a worldwide effort to stabilize the decline of local languages, he warned, nine-tenths of the linguistic diversity of humankind would probably be doomed to extinction. Krauss’s prediction was little more than an educated guess, but other respected linguists had been clanging out similar alarms. Keneth L. Hale of the Massachusetts Institute of Technology noted in the same journal issue that eight languages on which he had done fieldwork had since passed into extinction. A 1990 survey in Australia found that 70 of the 90 surviving Aboriginal languages were no longer used regularly by all age groups. The same was true for all but 20 of the 175 Native American languages spoken or remembered in the US., Krauss told a congressional panel in 1992.

B

Many experts in the field mourn the loss of rare languages, for several reasons. To start, there is scientific self-interest: some of the most basic questions in linguistics have to do with the limits of human speech, which are far from fully explored. Many researchers would like to know which structural elements of grammar and vocabulary – if any – are truly universal and probably, therefore, hardwired into the human brain. Other scientists try to reconstruct ancient migration patterns by comparing borrowed words that appear in otherwise unrelated languages. In each of these cases, the wider the portfolio of languages you study, the more likely you are to get the right answers.

C

Despite the near-constant buzz in linguistics about endangered languages over the past 10 years, the field has accomplished depressingly little. “You would think that there would be some organized response to this dire situation,” some attempt to determine which language can be saved and which should be documented before they disappear, says Sarah G. Thomason, a linguist at the University of Michigan at Ann Arbor. “But there isn’t any such effort organized in the profession. It is only recently that it has become fashionable enough to work on endangered languages.” Six years ago, recalls Douglas H. Whalen of Yale University, “when I asked linguists who were raising money to deal with these problems, I mostly got blank stares.” So Whalen and a few other linguists founded the Endangered Languages Fund. In the five years to 2001, they were able to collect only $80,000 for research grants. A similar foundation in England, directed by Nicholas Ostler, has raised just $8,000 since 1995.

D

But there are encouraging signs that the field has turned a corner. The Volkswagen Foundation, a German charity, just issued its second round of grants totaling more than $2 million. It has created a multimedia archive at the Max Planck Institute for Psycholinguistics in the Netherlands that can house recordings, grammars, dictionaries and other data on endangered languages. To fill the archive, the foundation has dispatched field linguists to document Aweti (100 or so speakers in Brazil), Ega (about 300 speakers in Ivory Coast), Waima’a (a few hundred speakers in East Timor), and a dozen or so other languages unlikely to survive the century. The Ford Foundation has also edged into the arena. Its contributions helped to reinvigorate a master-apprentice program created in 1992 by Leanne Hinton of Berkeley and Native Americans worried about the imminent demise of about 50 indigenous languages in California. Fluent speakers receive $3,000 to teach a younger relative (who is also paid) their native tongue through 360 hours of shared activities, spread over six months. So far about 5 teams have completed the program, Hinton says, transmitting a least some knowledge of 25 languages. “It’s too early to call this language revitalization,” Hinton admits. “In California, the death rate of elderly speakers will always be greater than the recruitment rate of young speakers. But at least we prolong the survival of the language.” That will give linguists more time to record these tongues before they vanish.

E

But the master-apprentice approach hasn’t caught on outside the U.S., and Hinton’s effort is a drop in the sea. At least 440 languages have been reduced to a mere handful of elders, according to the Ethnologue, a catalogue of languages produced by the Dallas-based group SIL International that comes closest to global coverage. For the vast majority of these languages, there is little or no record of their grammar, vocabulary, pronunciation or use in daily life. Even if a language has been fully documented, all that remains once it vanishes from active use is a fossil skeleton, a scattering of features that the scientist was lucky and astute enough to capture. Linguists may be able to sketch an outline of the forgotten language and fix its place on the evolutionary tree, but little more. “How did people start conversations and talk to babies? How dis husbands and wives converse?” Hinton asks. “Those are the first things you want to learn when you want to revitalize the language.”

F

But there is as yet no discipline of “conservation linguistics,” as there is for biology. Almost every strategy tried so far has succeeded in some places but failed in others, and there seems to be no way to predict with certainty what will work where. Twenty years ago in New Zealand, Maori speakers set up “language nests,” in which preschoolers were immersed in the native language. Additional Maori-only classes were added as the children progressed through elementary and secondary school. A similar approach was tried in Hawaii, with some success – the number of native speakers has stabilized at 1,000 or so, reports Joseph E. Grimes of SIL International, who is working on Oahu. Students can now get instruction in Hawaiian all the way through university.

G

One factor that always seems to occur in the demise of a language is that the speakers begin to have collective doubts about the usefulness of language loyalty. Once they start regarding their own language as inferior to the majority language, people stop using it in all situations. Kids pick up on the attitude and prefer the dominant language. In many cases, people don’t notice until they suddenly realize that their kids never speak the language, even at home. This is how Cornish and some dialects of Scottish Gaelic is still only rarely used for daily home life in Ireland, 80 years after the republic was founded with Irish as its first official language.

H

Linguists agree that ultimately, the answer to the problem of language extinction is multilingualism. Even uneducated people can learn several languages, as long as they start as children. Indeed, most people in the world speak more than one tongue, and in places such as Cameroon (279 languages), Papua New Guinea (823) and India (387) it is common to speak three of four distinct languages and a dialect or two as well. Most Americans and Canadians, to the west of Quebec, have a gut reaction that anyone speaking another language in front of them is committing an immoral act. You get the same reaction in Australia and Russia. It is no coincidence that these are the areas where languages are disappearing the fastest. The first step in saving dying languages is to persuade the world’s majorities to allow the minorities among them to speak with their own voices.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f640db73-b675-5829-970a-ceac7411cc55', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a038d222-72f4-5326-9e87-e8b431b0ebb4', 'f640db73-b675-5829-970a-ceac7411cc55', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('421fe236-0d04-56f9-ba0f-1438c481d63e', 'f640db73-b675-5829-970a-ceac7411cc55', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75ec706c-cd63-5734-a613-611b09bd4100', 'f640db73-b675-5829-970a-ceac7411cc55', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9d64712-9ad9-5fcb-be17-9d5c23542511', 'f640db73-b675-5829-970a-ceac7411cc55', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21627d1f-4d83-5581-98df-ce38614ca088', 'f640db73-b675-5829-970a-ceac7411cc55', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('799cbd19-e76a-5a4e-877a-b6dd60c13240', 'f640db73-b675-5829-970a-ceac7411cc55', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2ecdfc2-b22c-523b-aaee-6f2a1667e438', 'f640db73-b675-5829-970a-ceac7411cc55', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10f82209-7a11-5abb-a9e2-754fb25cb247', 'f640db73-b675-5829-970a-ceac7411cc55', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e23c1b8d-50c6-5211-b85e-9f028005c987', 'f640db73-b675-5829-970a-ceac7411cc55', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('401cee81-a205-5341-af50-4181653889b5', 'f640db73-b675-5829-970a-ceac7411cc55', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('536eb59e-3027-58a6-8cb7-73433fa24332', 'f640db73-b675-5829-970a-ceac7411cc55', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1860e596-5ae1-5d6e-9c84-5300059980bc', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e6ad846-da53-5981-81f6-bf80327d708d', '1860e596-5ae1-5d6e-9c84-5300059980bc', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b57e9af-9c24-54b2-ba94-3c95f7daad01', '1860e596-5ae1-5d6e-9c84-5300059980bc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44687059-53a1-5ac1-a88c-44723baecfa6', '1860e596-5ae1-5d6e-9c84-5300059980bc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65bce1b3-02be-585a-8612-679c1e2688fb', '1860e596-5ae1-5d6e-9c84-5300059980bc', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dbc9a2b-6cea-52f9-9190-92922dddab86', '1860e596-5ae1-5d6e-9c84-5300059980bc', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d151b81-ab0f-5bbc-b54e-ab26eb6a2bc9', '1860e596-5ae1-5d6e-9c84-5300059980bc', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebbed796-2a0d-5605-b839-1fa71c8c235b', '1860e596-5ae1-5d6e-9c84-5300059980bc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06fcbb1b-7e83-5d48-bd11-447f943325d7', '1860e596-5ae1-5d6e-9c84-5300059980bc', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa9182e8-40a5-5b6f-9a65-1781517d1db6', '1860e596-5ae1-5d6e-9c84-5300059980bc', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d12346ab-239e-5d18-8399-375a4bf22166', '1860e596-5ae1-5d6e-9c84-5300059980bc', 10, $md$x$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97019442-b9a3-5b78-8585-22a2f458dbcc', '1860e596-5ae1-5d6e-9c84-5300059980bc', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0cb1e45-8f48-58f5-9d59-d11851863d2a', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9255d10-c12f-5966-a058-5986577d4684', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00a63ef3-ebec-5c82-8191-c5c72bbcad8f', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36726c51-b8d3-525d-828a-cdb0b1ba52e6', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab9bc6c-615e-5225-88ad-8310673559fd', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f9fbae7-7a6e-50c0-9eb2-b34632304ca9', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e7be92-c8b8-502a-9ac9-dee6179e6e09', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55e2fd41-85b2-5c6f-822a-4f0581e2a1e9', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f286899-a2d7-5f51-a3d5-2ea755574f87', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa29cffc-7a6e-5ddb-b31d-473fdd7b67b5', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e527637-5114-54bb-8ad7-e23c5dd43a64', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b274672-0f34-5ad2-9449-9a1776822b4c', 'e0cb1e45-8f48-58f5-9d59-d11851863d2a', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae0cc17b-0fa9-5908-a6e7-52e941792a6d', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0a3ad8f-8c70-501c-8274-b70871586055', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae36b586-04b6-5463-92ba-cd9021ca2a50', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac5e2f31-fb45-590f-9cab-3427f52c6cc3', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f58d26b7-eb38-56c1-b596-f8953269dcde', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2536cf9a-c2a3-5d38-87c2-6ca5878467b7', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fe1e6d5-83b9-57c2-8c25-a9863204e3d2', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b288a32-8ac6-5c19-bff2-2ce99a76b849', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcc0cce2-2815-5e99-ba4b-15e261dc03a0', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('965c552d-f9c5-5d0e-b9d3-f34a0aacf4fa', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70d87276-cd16-58be-8d4b-100f929f564e', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('628cc204-7071-5391-97a1-2819cb6829f7', 'ae0cc17b-0fa9-5908-a6e7-52e941792a6d', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d2c0001-2b50-5838-9b9c-370cab7bdf54', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2329341-028e-51d0-8d4e-c4960855fba3', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f12c786e-ed1d-58ea-8f76-9a89b6b2982f', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe5bead8-f670-58fa-bf1d-66b91b61fb70', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('471c5112-fee9-59d7-a672-a15bd3324929', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ad322ef-c357-52b7-838a-d500ba55ffd6', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b34576bc-06fc-568f-9a11-95c8e84dc928', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80fc0f5e-8cac-5d37-ae79-a6702a6fdc91', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('767ca3b1-c882-5c52-9d3f-84fd3a5e117e', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60c6a45a-3f9b-55e2-81a1-7abc5c71718d', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b652a4a-1198-563f-b0ec-e3c797282d7a', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4533da9-f0f3-5401-a4a7-d0aae642b6fd', '0d2c0001-2b50-5838-9b9c-370cab7bdf54', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11768414-681d-5231-bb64-6f41d950531b', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb75bfd7-feb7-5e0e-a512-5dd3376455a3', '11768414-681d-5231-bb64-6f41d950531b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb911004-5e59-572a-ad30-009dba7f3593', '11768414-681d-5231-bb64-6f41d950531b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeee243b-cc5e-5f4f-b2cf-f0e39878d3da', '11768414-681d-5231-bb64-6f41d950531b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('446e4502-db14-54f4-be58-babca1b3ac92', '11768414-681d-5231-bb64-6f41d950531b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c23a748-da48-5617-8fe2-f628634bf9f5', '11768414-681d-5231-bb64-6f41d950531b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12a4c688-a96e-5c1f-919c-1ef983f54607', '11768414-681d-5231-bb64-6f41d950531b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f2d2044-65a5-50cb-86d6-f6ff4c0f61ed', '11768414-681d-5231-bb64-6f41d950531b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65d000b1-7bd4-599b-b0a3-7743a83eb41e', '11768414-681d-5231-bb64-6f41d950531b', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5af2668e-cc79-50fb-9e38-3131231c4ec3', '11768414-681d-5231-bb64-6f41d950531b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9c36806-1a2b-515f-9d2d-4009b6708bc9', '11768414-681d-5231-bb64-6f41d950531b', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efaaf8dc-d031-57a1-9803-1a581eaa1388', '11768414-681d-5231-bb64-6f41d950531b', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('502a78b4-da4f-5eac-b454-00d9c01be9bd', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The reading passage has eight paragraphs,
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of headings
i
data consistency needed for language
ii
consensuses on an initial recommendation for saving dying out languages
iii
positive gains for protection
iv
minimum requirement for saving a language
v
Potential threat to minority language
vi
a period when there was absent of real effort made.
vii
native language programs launched
viii
Lack of confidence in young speakers as a negative factor
ix
Practise in several developing countries
x
Value of minority language to linguists.
xi
government participation in the language field
1
Paragraph A
2
Paragraph B
Example: Paragraph C vi
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H

7 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0e18aa2-c6b5-5f61-925c-afc955deddf8', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d57a12-4b98-57e1-921c-7b1fd2ac0154', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04d7417f-fc09-5176-80b3-cd22a2ee59c2', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7bde103-35e2-5f8f-9b69-76b89e556e1e', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04786fad-4186-597d-8223-b52725d4bb37', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f525614-939d-53ed-ad9b-c83d4e8e30e2', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10e178c2-3da2-5091-a1fa-16c4bcfdfab9', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d4a04e3-a064-525b-9e9e-3c5ff93400a0', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3198194b-1202-50e1-8c34-45da68b2addd', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06f2e7ae-1a04-5d8a-9a2f-e6c1b607c95f', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93ea0782-a6af-5ec7-bd7a-86cecaf9f68d', '502a78b4-da4f-5eac-b454-00d9c01be9bd', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7818fe99-d6d1-5227-af7c-ba13862ca546', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
8-12
on your answer sheet.
A
Nicholas Ostler
B
Michael Krauss
C
Joseph E. Grimes
D
Sarah G. Thomason
E
Keneth L. Hale
F
Douglas H. Whalen
8
Reported language conservation practice in Hawaii
9
Predicted that many languages would disappear soon
10
The experienced process that languages die out personally
11
Raised language fund in England
12
Not enough effort on saving until recent work

8 ____ Reported language conservation practice in Hawaii$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24203486-7817-561d-acb5-0d9c90deb1cb', '7818fe99-d6d1-5227-af7c-ba13862ca546', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8e6c586-3ef1-58d7-9775-d5c17a294e13', '7818fe99-d6d1-5227-af7c-ba13862ca546', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c333ca44-9de9-5a11-b9ef-7ed2cd651740', '7818fe99-d6d1-5227-af7c-ba13862ca546', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dbd73ef-6609-5ea6-bd68-52a58d6338bd', '7818fe99-d6d1-5227-af7c-ba13862ca546', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7e251b9-7391-5fa6-b603-13c4554c3d45', '7818fe99-d6d1-5227-af7c-ba13862ca546', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db758fbf-9a0d-5bc8-a7f7-038a040cf79e', '7818fe99-d6d1-5227-af7c-ba13862ca546', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('346750cc-00a5-5f65-ab65-a3e5e9ac52d7', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
8-12
on your answer sheet.
A
Nicholas Ostler
B
Michael Krauss
C
Joseph E. Grimes
D
Sarah G. Thomason
E
Keneth L. Hale
F
Douglas H. Whalen
8
Reported language conservation practice in Hawaii
9
Predicted that many languages would disappear soon
10
The experienced process that languages die out personally
11
Raised language fund in England
12
Not enough effort on saving until recent work

9 ____ Predicted that many languages would disappear soon$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('906ae691-6c4a-577c-91ba-2493cc5f2409', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bafc790-04ba-517f-9597-7514ca70cde1', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e667ed6f-7249-5e92-ba91-f20a69a0a482', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85b25b05-96d8-5f0b-9f9e-452dcd57bfe8', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a27586e2-dcaf-5512-a8d2-cadd82e28d3e', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecfd06d9-0f42-54aa-8bf9-f38319c779ae', '346750cc-00a5-5f65-ab65-a3e5e9ac52d7', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e76763f-ef3a-53a7-b89c-182b9a5ae096', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
8-12
on your answer sheet.
A
Nicholas Ostler
B
Michael Krauss
C
Joseph E. Grimes
D
Sarah G. Thomason
E
Keneth L. Hale
F
Douglas H. Whalen
8
Reported language conservation practice in Hawaii
9
Predicted that many languages would disappear soon
10
The experienced process that languages die out personally
11
Raised language fund in England
12
Not enough effort on saving until recent work

10 ____ The experienced process that languages die out personally$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11ac57c0-64e0-5338-8bcc-33fb672beede', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d93b84e6-532a-563b-a822-5602c80d5249', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4cd21f4-56f4-5817-964f-d733cf0de7e3', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9796911c-4c42-5f95-93e0-14ad89254ba9', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11de44d3-58fc-534e-8200-9c642c7a580d', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd3c16b2-1504-54ab-b5b4-7129dde7118e', '4e76763f-ef3a-53a7-b89c-182b9a5ae096', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('54502425-0b93-594a-a6f0-64c3340fe24b', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
8-12
on your answer sheet.
A
Nicholas Ostler
B
Michael Krauss
C
Joseph E. Grimes
D
Sarah G. Thomason
E
Keneth L. Hale
F
Douglas H. Whalen
8
Reported language conservation practice in Hawaii
9
Predicted that many languages would disappear soon
10
The experienced process that languages die out personally
11
Raised language fund in England
12
Not enough effort on saving until recent work

11 ____ Raised language fund in England$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d58b1511-b115-5013-bebd-0f7553098ed8', '54502425-0b93-594a-a6f0-64c3340fe24b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('858aa2b0-f8d4-51da-907c-2ee1ba74aba7', '54502425-0b93-594a-a6f0-64c3340fe24b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3c72c43-8ed1-591e-9a6d-32d9f97a4ddb', '54502425-0b93-594a-a6f0-64c3340fe24b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4763ddff-4f6a-591a-b92c-51bc88093b2e', '54502425-0b93-594a-a6f0-64c3340fe24b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab4d31f8-9982-52dc-bb99-4174876d906f', '54502425-0b93-594a-a6f0-64c3340fe24b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c9ee36-c4a4-5a22-9418-e8a68b1037a8', '54502425-0b93-594a-a6f0-64c3340fe24b', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
8-12
on your answer sheet.
A
Nicholas Ostler
B
Michael Krauss
C
Joseph E. Grimes
D
Sarah G. Thomason
E
Keneth L. Hale
F
Douglas H. Whalen
8
Reported language conservation practice in Hawaii
9
Predicted that many languages would disappear soon
10
The experienced process that languages die out personally
11
Raised language fund in England
12
Not enough effort on saving until recent work

12 ____ Not enough effort on saving until recent work$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdb46f94-f05d-5549-9a6f-d62566f60b82', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79bf2fc6-49ec-5b07-b6c5-cefeee1ca6c8', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75a4c1b3-cfd0-58fc-820c-d374e233ab94', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8523f451-ebf7-5efe-969f-7fbb1369f084', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fddf4db2-dddd-5f8d-891c-46dfafa5e0ca', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf03dc49-066c-5c86-8aea-8c6fb7cb8849', '64ba2f7e-7c0e-5ac5-99ce-e1d23d8bc07f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23b269e2-4101-528a-ae4a-cc0a934b8bf9', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
13-14
on your answer sheet.
13.
What is the real result of a
master-apprentice program
sponsored by
The Ford Foundation
?
A
Teach children how to speak
B
Revive some endangered languages in California
C
postpone the dying date for some endangered languages
D
Increase communication between students
14.
What should the majority language speakers do according to the
last paragraph
?
A
They should teach their children endangered language in free lessons
B
They should learn at least four languages
C
They should now their loyalty to a dying language
D
They should be more tolerant of minority language speaker

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8b7a14a-7afa-501e-b05f-76e2b7b91943', '098d5e54-8a14-5883-8d1a-ef71b812a1de', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
13-14
on your answer sheet.
13.
What is the real result of a
master-apprentice program
sponsored by
The Ford Foundation
?
A
Teach children how to speak
B
Revive some endangered languages in California
C
postpone the dying date for some endangered languages
D
Increase communication between students
14.
What should the majority language speakers do according to the
last paragraph
?
A
They should teach their children endangered language in free lessons
B
They should learn at least four languages
C
They should now their loyalty to a dying language
D
They should be more tolerant of minority language speaker

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
