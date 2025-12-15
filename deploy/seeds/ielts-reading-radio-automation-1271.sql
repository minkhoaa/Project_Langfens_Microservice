BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-radio-automation-1271'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-radio-automation-1271';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-radio-automation-1271';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-radio-automation-1271';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5b5e79af-879f-5dd8-a554-b9b5eaaf02c4', 'ielts-reading-radio-automation-1271', $t$Radio Automation$t$, $md$## Radio Automation

Nguồn:
- Test: https://mini-ielts.com/1271/reading/radio-automation
- Solution: https://mini-ielts.com/1271/view-solution/reading/radio-automation$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('95c5d78d-8e5d-54d4-aea4-791edb46ca76', '5b5e79af-879f-5dd8-a554-b9b5eaaf02c4', 1, $t$Reading — Radio Automation$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Radio Automation

Today they are everywhere. Production lines controlled by computers and operated by robots. There’s no chatter of assembly workers, just the whirr and click of machines. In the mid-1940s, the workerless factory was still the stuff of science fiction. There were no computers to speak of and electronics was primitive. Yet hidden away in the English countryside was a highly automated production line called ECME, which could turn out 1500 radio receivers a day with almost no help from human hands.

A . John Sargrove, the visionary engineer who developed the technology, was way ahead of his time. For more than a decade, Sargrove had been trying to figure out how to make cheaper radios. Automating the manufacturing process would help. But radios didn’t lend themselves to such methods: there were too many parts to fit together and too many wires to solder. Even a simple receiver might have 30 separate components and 80 hand-soldered connections. At every stage, things had to be tested and inspected. Making radios required highly skilled labour—and lots of it.

B . In 1944, Sargrove came up with the answer. His solution was to dispense with most of the fiddly bits by inventing a primitive chip—a slab of Bakelite with all the receiver’s electrical components and connections embedded in it. This was something that could be made by machines, and he designed those too. At the end of the war, Sargrove built an automatic production line, which he called ECME (electronic circuit-making equipment), in a small factory in Effingham, Surrey.

C . An operator sat at one end of each ECME line, feeding in die plates. She didn’t need much skill, only quick hands. From now on, everything was controlled by electronic switches and relays. First stop was the sandblaster, which roughened the surface of the plastic BO that molten metal would stick to it The plates were then cleaned to remove any traces of grit The machine automatically checked that the surface was rough enough before sending the plate to the spraying section. There, eight nozzles rotated into position and sprayed molten zinc over both sides of the plate. Again, the nozzles only began to spray when a plate was in place. The plate whizzed on. The next stop was the milling machine, which ground away the surface layer of metal to leave the circuit and other components in the grooves and recesses. Now the plate was a composite of metal and plastic. It sped on to be lacquered and have its circuits tested. By the time it emerged from the end of the line, robot hands had fitted it with sockets to attach components such as valves and loudspeakers. When ECME was working flat out; the whole process took 20 seconds.

D . ECME was astonishingly advanced. Electronic eyes, photocells that generated a small current when a panel arrived, triggered each step in the operation, BO avoiding excessive wear and tear on the machinery. The plates were automatically tested at each stage as they moved along the conveyor. And if more than two plates in succession were duds, the machines were automatically adjusted—or if necessary halted In a conventional factory, I workers would test faulty circuits and repair them. But Sargrove’s assembly line produced circuits so cheaply they just threw away the faulty ones. Sargrove’s circuit board was even more astonishing for the time. It predated the more familiar printed circuit, with wiring printed on aboard, yet was more sophisticated. Its built-in components made it more like a modem chip.

E . When Sargrove unveiled his invention at a meeting of the British Institution of Radio Engineers in February 1947, the assembled engineers were impressed. So was the man from The Times. ECME, he reported the following day, “produces almost without human labour, a complete radio receiving set. This new method of production can be equally well applied to television and other forms of electronic apparatus.

F . The receivers had many advantages over their predecessors, wit components they were more robust. Robots didn’t make the sorts of mistakes human assembly workers sometimes did. “Wiring mistakes just cannot happen,” wrote Sargrove. No w ừ es also meant the radios were lighter and cheaper to ship abroad. And with no soldered wires to come unstuck, the radios were more reliable. Sargrove pointed out that the drcuit boards didn’t have to be flat. They could be curved, opening up the prospect of building the electronics into the cabinet of Bakelite radios.

G . Sargrove was all for introducing this type of automation to other products. It could be used to make more complex electronic equipment than radios, he argued. And even if only part of a manufacturing process were automated, the savings would be substantial. But while his invention was brilliant, his timing was bad. ECME was too advanced for its own good. It was only competitive on huge production runs because each new job meant retooling the machines. But disruption was frequent. Sophisticated as it was, ECME still depended on old- fashioned electromechanical relays and valves—which failed with monotonous regularity. The state of Britain’s economy added to Sargrove’s troubles. Production was dogged by power cuts and post-war shortages of materials. Sargrove’s financial backers began to get cold feet.

H . There was another problem Sargrove hadn’t foreseen. One of ECME’s biggest advantages—the savings on the cost of labour—also accelerated its downfall. Sargrove’s factory had two ECME production lines to produce the two c ữ cuits needed for each radio. Between them these did what a thousand assembly workers would otherwise have done. Human hands were needed only to feed the raw material in at one end and plug the valves into then sockets and fit the loudspeakers at the other. After that, the only job left was to fit the pair of Bakelite panels into a radio cabinet and check that it worked.

I . Sargrove saw automation as the way to solve post-war labour shortages. With somewhat Utopian idealism, he imagined his new technology would free people from boring, repetitive jobs on the production line and allow them to do more interesting work. “Don’t get the idea that we are out to rob people of then jobs,” he told the Daily Mnror. “Our task is to liberate men and women from being slaves of machines.”

J . The workers saw things differently. They viewed automation in the same light as the everlasting light bulb or the suit that never wears out—as a threat to people’s livelihoods. If automation spread, they wouldn’t be released to do more exciting jobs. They’d be released to join the dole queue. Financial backing for ECME fizzled out. The money dried up. And Britain lost its lead in a technology that would transform industry just a few years later.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('504877ae-3c38-5e95-b6cc-441f9d6651ea', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

1 ____$md$, NULL, ARRAY['.*chip.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('875d0721-e843-5f44-967b-a89f43d7efca', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

2 ____$md$, NULL, ARRAY['.*grit.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7b3ad517-8b8a-5569-9597-418bed5bf619', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

3 ____$md$, NULL, ARRAY['.*milten.*zinc.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('da62ba54-6b8b-5566-b3ee-b16fed887c98', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

4 ____$md$, NULL, ARRAY['.*milling.*machine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d5912935-a39d-5698-98d0-083a75d22caf', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

5 ____$md$, NULL, ARRAY['.*sockets.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('57361924-55d2-520f-a317-94d4edff1b3a', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

6 ____$md$, NULL, ARRAY['.*loudspeakers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('98ba009f-a104-578c-9647-ad9a70cba2bd', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Summary
The following diagram explains the process of ECME:
Complete the following chart of the paragraphs of Reading Passage, using
no more than two
words from the Reading Passage for each answer. Write your answers in boxes
1-7
on your answer sheet
1
2
3
4
5
6
7

7 ____$md$, NULL, ARRAY['.*valves.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('48e25f29-b714-5529-a6c4-c7ac094d6ec4', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Complete the following summary of the paragraphs of Reading Passage. using NO more than
two words
from the Reading Passage for each answer. Writs your answers inboxes
8-11
on your answer sheet
Summary
Sargrove had been dedicated to create a
8
radio by automation of manufacture. The old version of radio had a large number of independent
9
. After this innovation made, wireless-style radios became
10
and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced
11
of manual work; which can be easily copied to other industries of manufacturing electronic devices.

Sargrove had been dedicated to create a 8 ____ radio by automation of manufacture. The old version of radio had a large number of independent 9 ____ . After this innovation made, wireless-style radios became 10 ____ and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced 11 ____ of manual work; which can be easily copied to other industries of manufacturing electronic devices.$md$, NULL, ARRAY['.*cheaper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6beb4d5c-ba6e-5a6c-a586-0763a8674ded', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Complete the following summary of the paragraphs of Reading Passage. using NO more than
two words
from the Reading Passage for each answer. Writs your answers inboxes
8-11
on your answer sheet
Summary
Sargrove had been dedicated to create a
8
radio by automation of manufacture. The old version of radio had a large number of independent
9
. After this innovation made, wireless-style radios became
10
and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced
11
of manual work; which can be easily copied to other industries of manufacturing electronic devices.

Sargrove had been dedicated to create a 8 ____ radio by automation of manufacture. The old version of radio had a large number of independent 9 ____ . After this innovation made, wireless-style radios became 10 ____ and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced 11 ____ of manual work; which can be easily copied to other industries of manufacturing electronic devices.$md$, NULL, ARRAY['.*cheaper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8b9d21c0-3486-54b2-b848-4fe1d9087b98', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Complete the following summary of the paragraphs of Reading Passage. using NO more than
two words
from the Reading Passage for each answer. Writs your answers inboxes
8-11
on your answer sheet
Summary
Sargrove had been dedicated to create a
8
radio by automation of manufacture. The old version of radio had a large number of independent
9
. After this innovation made, wireless-style radios became
10
and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced
11
of manual work; which can be easily copied to other industries of manufacturing electronic devices.

Sargrove had been dedicated to create a 8 ____ radio by automation of manufacture. The old version of radio had a large number of independent 9 ____ . After this innovation made, wireless-style radios became 10 ____ and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced 11 ____ of manual work; which can be easily copied to other industries of manufacturing electronic devices.$md$, NULL, ARRAY['.*cheaper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd8739be-d507-55e1-af10-c059b14fbfb2', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Complete the following summary of the paragraphs of Reading Passage. using NO more than
two words
from the Reading Passage for each answer. Writs your answers inboxes
8-11
on your answer sheet
Summary
Sargrove had been dedicated to create a
8
radio by automation of manufacture. The old version of radio had a large number of independent
9
. After this innovation made, wireless-style radios became
10
and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced
11
of manual work; which can be easily copied to other industries of manufacturing electronic devices.

Sargrove had been dedicated to create a 8 ____ radio by automation of manufacture. The old version of radio had a large number of independent 9 ____ . After this innovation made, wireless-style radios became 10 ____ and inexpensive to export oversea. As the Saigrove saw it, the real benefit of ECME’s radio was that it reduced 11 ____ of manual work; which can be easily copied to other industries of manufacturing electronic devices.$md$, NULL, ARRAY['.*cheaper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22d3943d-436c-5d7e-949b-d759686ae1ab', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Choose the correct letter
A, B, C or D.
Write your answers inboxes
12-13
on your answer sheet
12. What were workers attitude towards
ECME Model initialy
A
anxious
B
welcoming
C
boring
D
inspiring
13. What is the main idea of this passage?
A
approach to reduce the price of radio
B
a new generation of fully popular products and successful business
C
in application of die automation in the early stage
D
ECME technology can be applied in many product fields

Choose the correct letter A, B, C or D. Write your answers inboxes 12-13 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0b0ce9c7-d76f-519d-9d20-b52b1fba2af9', '95c5d78d-8e5d-54d4-aea4-791edb46ca76', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Choose the correct letter
A, B, C or D.
Write your answers inboxes
12-13
on your answer sheet
12. What were workers attitude towards
ECME Model initialy
A
anxious
B
welcoming
C
boring
D
inspiring
13. What is the main idea of this passage?
A
approach to reduce the price of radio
B
a new generation of fully popular products and successful business
C
in application of die automation in the early stage
D
ECME technology can be applied in many product fields

Choose the correct letter A, B, C or D. Write your answers inboxes 12-13 on your answer sheet$md$, NULL);

COMMIT;
