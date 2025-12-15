BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-maori-fish-hooks-1497'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-maori-fish-hooks-1497';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-maori-fish-hooks-1497';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-maori-fish-hooks-1497';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1580577e-9096-59be-8adf-157ca9fe1595', 'ielts-reading-maori-fish-hooks-1497', $t$Maori Fish Hooks$t$, $md$## Maori Fish Hooks

Nguồn:
- Test: https://mini-ielts.com/1497/reading/maori-fish-hooks
- Solution: https://mini-ielts.com/1497/view-solution/reading/maori-fish-hooks$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('96e08676-d843-5b43-8336-e3c101622a4e', '1580577e-9096-59be-8adf-157ca9fe1595', 1, $t$Reading — Maori Fish Hooks$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Maori Fish Hooks

A . Maori fish hooks, made from wood, bone, stone and flax, are intended to have the best possible design and function. The hooks are designed to target specific species with precision. In the industry of commercial long-line fishing, there are some Maori hook designs which are making a splash.

B . When Polynesians first came New Zealand sometime within the years 1100-1300 AD, they didn’t have the technology necessary to heat and manipulate metal out of rocks. Meanwhile, fish was the settlers’ main food source at the time, so fishermen made their hooks and fishing gear out of wood, bone, stone and shells. Other plants native to the island of New Zealand, like as flax (harakeke), cabbage tree (ti) and astelia (kiekie) gave the necessary fibrous material to make fishing lines and nets of greater or equal strength to the jute, which was being used by the Europeans at the time. However, as a material, metal is more malleable, and can be changed into any shape, while natural materials are limited in the shapes they can take on. The Maori fish hooks needed to be more innovative in the ways that they dealt with these limitations.

C . Early accounts of Europeans who settled and explored New Zealand claimed that Maori hooks, known as matau, were “odd”, “of doubtful efficacy”, “very clumsy affairs” or “impossible looking.” Archaeologists from more recent times have also mentioned the round hook appearing as odd, with comments such as, “shaped in a manner which makes it very difficult to imagine could ever be effective in catching a fish.” William Anderson, who was aboard the Resolution during Cook’s third voyage in 1777 as the ship’s surgeon, commented that the Maori “live chiefly by fishing, making use…of wooden fish hooks pointed with bone, but so oddly made that a stranger is at a loss to know how they can answer such a purpose.”

D . The Museum of New Zealand Te Papa Tongarewa did their own recent study on Maori fish hooks two hundred and thirty years later, and were able to demonstrate that the unique hook design was a matter of function. The hook’s design allowed it to catch fish by spinning away from the direction of the point and catching their jaws, instead of poking a hole through the fish or by being used as a lever, which some archaeologists also suggested. It seems that the design of the Maori fish hook is, perhaps, the world’s most efficiently and masterfully designed fish hook, likely superior to any modern metal fish hook of today.

E . To make larger hooks, Maori used shanks made of strong wood, with stout points made of bone or shell. They tied tree branches and saplings together to grow them into the ideal shapes for building, then harvested the plants when they grew to the appropriate size. They hardened wood by carefully drying it and burying underground with fires lit above it. Human bone was often used for bone points, which they lashed securely to a groove at the end of the shank with pre-made flax materials (muka). When they wanted to catch larger species like sharks, groper and ling, they used composite hook. However, average the traditional hook was usually not longer than a three finger breadth (128 mm length).

F . To capture seabirds for food and feathers, like albatross, the islanders used slender hooks which can be differentiated from other hooks intended to catch fish by their lighter build and lack of an inturned point. Many of these hooks were collected by early explorers, suggesting that the taking of seabirds with hook and line was an important source of food and feathers for Maori. (105 mm length). Slender hooks with wide gapes were used to capture albatross and other seabirds for food and feathers, and can be distinguished from hooks intended to catch fish by the lighter construction and lack of an inturned point. Early explorers collected many of these hooks which could indicated that catching seabirds with a hook and line provided significant amounts of food and feathers for the Maori. (105 mm length)

G . Maori adopted new materials quickly once they became available with European explorers, sealers and whalers who began to arrive towards the end of the 1700s. At this point, the Maori were still making their fish hooks, but now using metals and imported materials. Wooden and flax parts of old, abandoned fish hooks decomposed quickly as traditional hooks were cast away in favor of new ones. Tools made of luxury materials such as ivory or greenstone may have been kept around as decorations items, with stylized Maori fish hooks seen today as a symbol of cultural revitalization.

H . The Maori kept recreating traditional designs even as new materials poured in, preferring hook shapes which were introduced by Pakeha into the 1800s. By following the tradition of the rotating hook design, they remained connected with a part of their traditional culture. In the end, though, it was only a matter of time before the amount of mass-produced metal European hooks finally overwhelmed the area, highlighting the difficulty of making hooks from nails, horseshoes and other metal objects, and finally the use of the traditional designs fell out of favor.

I . By the end of the 19th and beginning of the 20th century, tourists and collectors’ demands for Maori artifacts had grown, leading manufacturers to produce large quantities of forged hooks. These replicas were then traded with both Maoris and Europeans to use as forgeries of the real thing, sometimes directly commissioned by artifact dealers themselves. Fake hooks can be spotted by their cheap construction, inconsistent materials, rudimentary lashings, odd or over-elaborate decorative carvings, and finally, by the lack of in-turned points or angled grooves used to actually attach the fishing line.

J . The ways that matau have changed throughout their history is somewhat symbolic of how Maori have adapted to use European tools, materials and technology to their purposes over time, as well as the ways that European influence and technology contributed to, rather overtook, generally compatible Maori skills, and traditional materials were replaced or complemented by metals and, more recently, artificial materials. Commercial longline fishermen everywhere have begun using the circle hook design today, one that is nearly the same as the traditional matau in both its appearance and functionality. It seems that the advantages and improved catch rates of this Maori technology have been recognized once more.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f65b42ca-480d-567a-b20c-3e9e67ed32ef', '96e08676-d843-5b43-8336-e3c101622a4e', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

1 ____ Instruction on how to recognise authentic Maori hooks from counterfeit ones$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7e4882c8-e739-5258-8426-4e144166a172', '96e08676-d843-5b43-8336-e3c101622a4e', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

2 ____ A description of a different type of hooks that are not used to catch fish$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17497a8f-ee80-5ee5-898b-7e45c6a5e23b', '96e08676-d843-5b43-8336-e3c101622a4e', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

3 ____ An acknowledgement that Maori design and craftsmanship are still relevant in the modern world$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eeb43146-d246-5e66-b5ad-926d474f05bb', '96e08676-d843-5b43-8336-e3c101622a4e', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

4 ____ An investigation into how the hooks functioned so effectively$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35c04128-987a-5472-b305-c22005078ec4', '96e08676-d843-5b43-8336-e3c101622a4e', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

5 ____ A description of how modern technology began to dominate and eventually took over from traditional hook construction$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6af0da02-efc3-5b50-aa2d-a1e77e25a170', '96e08676-d843-5b43-8336-e3c101622a4e', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

6 ____ A list of raw materials used to construct hooks$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('536f1d1b-6fdb-5cdc-bab1-16a53c74f0bc', '96e08676-d843-5b43-8336-e3c101622a4e', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

7 ____ An outline of how different styles of hooks and types of materials were employed to catch larger fish$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9279dd4-b534-5460-b16a-df006acdf52a', '96e08676-d843-5b43-8336-e3c101622a4e', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
The reading passage has ten paragraphs labelled A-J.
Which paragraph contains the following information?
Write the correct letter A-J in boxes 1-8 on your answer sheet.
NB You may use any letter more than once.
1
Instruction on how to recognise authentic Maori hooks from counterfeit ones
2
A description of a different type of hooks that are not used to catch fish
3
An acknowledgement that Maori design and craftsmanship are still relevant in the modern world
4
An investigation into how the hooks functioned so effectively
5
A description of how modern technology began to dominate and eventually took over from traditional hook construction
6
A list of raw materials used to construct hooks
7
An outline of how different styles of hooks and types of materials were employed to catch larger fish
8
An account of how the Maori employed new technology and adapted it

8 ____ An account of how the Maori employed new technology and adapted it$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de6502fa-7dd0-5bcb-9325-913e1f168fa0', '96e08676-d843-5b43-8336-e3c101622a4e', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage? In boxes 9-13 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
9
The early European settlers quickly understood how the Maori fish hook worked
10
The hook works by making a hole and embedding itself in the mouth of the fish
11
The Maoris catch seabirds by their feet
12
There used to be a demand for Maori fish hooks and many counterfeit ones were produced
13
Today European style hooks have completely replaced the traditional styles used by the Maoris

9 ____ The early European settlers quickly understood how the Maori fish hook worked$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fe2edd7-0477-5cc1-9594-1f84a2fbe9e0', 'de6502fa-7dd0-5bcb-9325-913e1f168fa0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04b083d5-d034-55a2-af2a-c732ab4dd91e', 'de6502fa-7dd0-5bcb-9325-913e1f168fa0', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b89eca16-8293-5ca8-bf09-474b6555605d', 'de6502fa-7dd0-5bcb-9325-913e1f168fa0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68c3b33a-5e4f-5406-a2c5-a105a13a223a', '96e08676-d843-5b43-8336-e3c101622a4e', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage? In boxes 9-13 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
9
The early European settlers quickly understood how the Maori fish hook worked
10
The hook works by making a hole and embedding itself in the mouth of the fish
11
The Maoris catch seabirds by their feet
12
There used to be a demand for Maori fish hooks and many counterfeit ones were produced
13
Today European style hooks have completely replaced the traditional styles used by the Maoris

10 ____ The hook works by making a hole and embedding itself in the mouth of the fish$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685af8bc-1fb3-5e82-bff2-374ddd6d041e', '68c3b33a-5e4f-5406-a2c5-a105a13a223a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e99df1c-77d2-54bf-bad4-9e8119181f8d', '68c3b33a-5e4f-5406-a2c5-a105a13a223a', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('972e2075-27d9-564d-9af9-757b5fd059fc', '68c3b33a-5e4f-5406-a2c5-a105a13a223a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3684ceed-b45a-5ef1-9563-58709bc11495', '96e08676-d843-5b43-8336-e3c101622a4e', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage? In boxes 9-13 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
9
The early European settlers quickly understood how the Maori fish hook worked
10
The hook works by making a hole and embedding itself in the mouth of the fish
11
The Maoris catch seabirds by their feet
12
There used to be a demand for Maori fish hooks and many counterfeit ones were produced
13
Today European style hooks have completely replaced the traditional styles used by the Maoris

11 ____ The Maoris catch seabirds by their feet$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44734180-d709-51c7-b55b-919ca499a0a7', '3684ceed-b45a-5ef1-9563-58709bc11495', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13c69a5f-1ed4-5c6b-84a2-63b730a2f461', '3684ceed-b45a-5ef1-9563-58709bc11495', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5366816e-ebc6-57ef-a154-4ac84bc6901b', '3684ceed-b45a-5ef1-9563-58709bc11495', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6405d6c3-ecdd-5a66-9562-dcca5cbd29d4', '96e08676-d843-5b43-8336-e3c101622a4e', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage? In boxes 9-13 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
9
The early European settlers quickly understood how the Maori fish hook worked
10
The hook works by making a hole and embedding itself in the mouth of the fish
11
The Maoris catch seabirds by their feet
12
There used to be a demand for Maori fish hooks and many counterfeit ones were produced
13
Today European style hooks have completely replaced the traditional styles used by the Maoris

12 ____ There used to be a demand for Maori fish hooks and many counterfeit ones were produced$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec8711f2-fb17-5fd9-a888-148e8c61fe3c', '6405d6c3-ecdd-5a66-9562-dcca5cbd29d4', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06203145-e906-5a64-b456-31f253164eed', '6405d6c3-ecdd-5a66-9562-dcca5cbd29d4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1346483-755a-512a-9e57-ad255a4ce054', '6405d6c3-ecdd-5a66-9562-dcca5cbd29d4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4422081-a3ff-5005-a5a3-aa9970bc639e', '96e08676-d843-5b43-8336-e3c101622a4e', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in the reading passage? In boxes 9-13 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
9
The early European settlers quickly understood how the Maori fish hook worked
10
The hook works by making a hole and embedding itself in the mouth of the fish
11
The Maoris catch seabirds by their feet
12
There used to be a demand for Maori fish hooks and many counterfeit ones were produced
13
Today European style hooks have completely replaced the traditional styles used by the Maoris

13 ____ Today European style hooks have completely replaced the traditional styles used by the Maoris$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a409abc0-32b5-5323-80d4-b4040d487d72', 'b4422081-a3ff-5005-a5a3-aa9970bc639e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2171e94-8ff6-532d-8d1b-3cb555c248ca', 'b4422081-a3ff-5005-a5a3-aa9970bc639e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5929e616-9b56-5e15-887e-3c0545238719', 'b4422081-a3ff-5005-a5a3-aa9970bc639e', 3, $md$NOT GIVEN$md$, false);

COMMIT;
