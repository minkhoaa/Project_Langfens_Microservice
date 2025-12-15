BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-multitasking-debate-1334'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-multitasking-debate-1334';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-multitasking-debate-1334';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-multitasking-debate-1334';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('99e3eb00-3aa2-59bc-bb81-6329cf2907a7', 'ielts-reading-multitasking-debate-1334', $t$Multitasking Debate$t$, $md$## Multitasking Debate

Nguồn:
- Test: https://mini-ielts.com/1334/reading/multitasking-debate
- Solution: https://mini-ielts.com/1334/view-solution/reading/multitasking-debate$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2cc2c9ba-bf2f-5366-813d-049258c485e6', '99e3eb00-3aa2-59bc-bb81-6329cf2907a7', 1, $t$Reading — Multitasking Debate$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Multitasking Debate

A

Talking on the phone while driving isn’t the only situation where we’re worse at multitasking than we might like to think we are. New studies have identified a bottleneck in our brains that some say means we are fundamentally incapable of true multitasking. If experimental findings reflect real-world performance, people who think they are multitasking are probably just underperforming in all – or at best, all but one – of their parallel pursuits. Practice might improve your performance, but you will never be as good as when focusing on one task at a time.

B

The problem, according to René Marois, a psychologist at Vanderbilt University in Nashville, Tennessee, is that there’s a sticking point in the brain. To demonstrate this, Marois devised an experiment to locate it. Volunteers watch a screen and when a particular image appears, a red circle, say, they have to press a key with their index finger. Different coloured circles require presses from different fingers. Typical response time is about half a second, and the volunteers quickly reach their peak performance. Then they learn to listen to different recordings and respond by making a specific sound. For instance, when they hear a bird chirp, they have to say “ba”; an electronic sound should elicit a “ko”, and so on. Again, no problem. A normal person can do that in about half a second, with almost no effort.

C

The trouble comes when Marois shows the volunteers an image, and then almost immediately plays them a sound. Now they’re flummoxed. “If you show an image and play a sound at the same time, one task is postponed,” he says. In fact, if the second task is introduced within the half-second or so it takes to process and react to the first, it will simply be delayed until the first one is done. The largest dual-task delays occur when the two tasks are presented simultaneously; delays progressively shorten as the interval between presenting the tasks lengthens.

D

There are at least three points where we seem to get stuck, says Marois. The first is in simply identifying what we’re looking at. This can take a few tenths of a second, during which time we are not able to see and recognise a second item. This limitation is known as the “attentional blink”: experiments have shown that if you’re watching out for a particular event and a second one shows up unexpectedly any time within this crucial window of concentration, it may register in your visual cortex but you will be unable to act upon it. Interestingly, if you don’t expect the first event, you have no trouble to respond to the second. What exactly causes the attentional blink is still a matter for debate.

E

A second limitation is in our short-term visual memory. It’s estimated that we can keep track of about four items at a time, fewer if they are complex. This capacity shortage is thought to explain, in part, our astonishing inability to detect even huge changes in scenes that are otherwise identical, so-called “change blindness”. Show people pairs of near-identical photos – say, aircraft engines in one picture have disappeared in the other – and they will fail to spot the differences. Here again, though, there is disagreement about what the essential limiting factor really is. Does it come down to a dearth of storage capacity, or is it about how much attention a viewer is paying?

F

A third limitation is that choosing a response to a stimulus – braking when you see a child in the road, for instance, or replying when your mother tells you over the phone that she’s thinking of leaving your dad – also takes brainpower. Selecting a response to one of these things will delay by some tenths of a second your ability to respond to the other. This is called the “response selection bottleneck” theory, first proposed in 1952.

G

But David Meyer, a psychologist at the University of Michigan, Ann Arbor, doesn’t buy the bottleneck idea. He thinks dual-task interference is just evidence of a strategy used by the brain to prioritise multiple activities. Meyer is known as something of an optimist by his peers. He has written papers with titles like “Virtually perfect time-sharing in dual-task performance: Uncorking the central cognitive bottleneck”. His experiments have shown that with enough practice – at least 2000 tries – some people can execute two tasks simultaneously as competently as if they were doing them one after the other. He suggests that there is a central cognitive processor that coordinates all this and, what’s more, he thinks it used discretion: sometimes it chooses to delay one task while completing another.

H

Marois agrees that practice can sometimes erase interference effects. He has found that with just 1 hour of practice each day for two weeks, volunteers show a huge improvement at managing both his tasks at once. Where he disagrees with Meyer is in what the brain is doing to achieve this. Marois speculates that practice might give us the chance to find less congested circuits to execute a task – rather like finding trusty back streets to avoid heavy traffic on main roads – effectively making our response to the task subconscious. After all, there are plenty of examples of subconscious multitasking that most of us routinely manage: walking and talking, eating and reading, watching TV and folding the laundry.

I

It probably comes as no surprise that, generally speaking, we get worse at multitasking as we age. According to Art Kramer at the University of Illinois at Urbana- Champaign, who studies how ageing affects our cognitive abilities, we peak in our 20s. Though the decline is slow through our 30s and on into our 50s, it is there; and after 55, it becomes more precipitous. In one study, he and his colleagues had both young and old participants do a simulated driving task while carrying on a conversation. He found that while young drivers tended to miss background changes, older drivers failed to notice things that were highly relevant. Likewise, older subjects had more trouble paying attention to the more important parts of a scene than young drivers.

J

It’s not all bad news for over-55s, though. Kramer also found that older people can benefit from the practice. Not only did they learn to perform better, but brain scans also showed that underlying that improvement was a change in the way their brains become active. While it’s clear that practice can often make a difference, especially as we age, the basic facts remain sobering. “We have this impression of an almighty complex brain,” says Marois, “and yet we have very humbling and crippling limits.” For most of our history, we probably never needed to do more than one thing at a time, he says, and so we haven’t evolved to be able to. Perhaps we will in future, though. We might yet look back one day on people like Debbie and Alun as ancestors of a new breed of true multitaskers.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('715580e8-13d8-5eac-8f97-af12ba280e00', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
A theory explained delay happens when selecting one reaction
2
Different age group responds to important things differently
3
Conflicts happened when visual and audio element emerge simultaneously
4
An experiment designed to demonstrates the critical part of the brain for multitasking
5
A viewpoint favors the optimistic side of multitasking performance

1 ____ A theory explained delay happens when selecting one reaction$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfaf1d7f-d419-5c3d-958e-468fa8e6e781', '715580e8-13d8-5eac-8f97-af12ba280e00', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d24cc2c-682e-535c-83eb-1b62526f3b5d', '715580e8-13d8-5eac-8f97-af12ba280e00', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ba91b84-744e-5eba-b29f-2c0f324947db', '715580e8-13d8-5eac-8f97-af12ba280e00', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd186889-1abd-543f-8c3e-bd3587880cbc', '715580e8-13d8-5eac-8f97-af12ba280e00', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('632193d5-b72c-5588-b948-0e231f5235f1', '715580e8-13d8-5eac-8f97-af12ba280e00', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d187b122-3fcf-5529-bcc9-2dcc481424d7', '715580e8-13d8-5eac-8f97-af12ba280e00', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5861d37-2f35-5969-a31e-acb543182947', '715580e8-13d8-5eac-8f97-af12ba280e00', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d02c4db-f5d6-5b0d-b0f9-2f7da4e638dd', '715580e8-13d8-5eac-8f97-af12ba280e00', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a387b2b6-4cc5-5296-aad4-260fd5ac3ac2', '715580e8-13d8-5eac-8f97-af12ba280e00', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83fe130b-6c8a-56ce-bcac-967951797710', '715580e8-13d8-5eac-8f97-af12ba280e00', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac2bdae8-f561-5d3b-b844-69ae00921f85', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
A theory explained delay happens when selecting one reaction
2
Different age group responds to important things differently
3
Conflicts happened when visual and audio element emerge simultaneously
4
An experiment designed to demonstrates the critical part of the brain for multitasking
5
A viewpoint favors the optimistic side of multitasking performance

2 ____ Different age group responds to important things differently$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aec6f0e8-4fa4-540b-ad83-a1224147ee85', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e811708-37cd-5d42-beb1-8ad6e742f276', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0259ceb-04cb-529b-9e8a-ddf5b905ce6b', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('607b5ee3-5470-572b-a9e0-55484daa5897', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fcc3c96-f153-5ee1-a509-5dbfde939b19', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5031de98-060c-55a1-871e-a3835e6460cc', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0693771-a047-56eb-a0d9-92e71fdc70ac', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1183f72a-4f77-5011-ab72-72c0633171c9', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b969e93-70cf-5678-819a-48c3fa4adc7c', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5386b9b-2307-5754-8065-b73f2467f586', 'ac2bdae8-f561-5d3b-b844-69ae00921f85', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('31d681fd-1bb9-54ef-9ca6-666ec46cc06f', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
A theory explained delay happens when selecting one reaction
2
Different age group responds to important things differently
3
Conflicts happened when visual and audio element emerge simultaneously
4
An experiment designed to demonstrates the critical part of the brain for multitasking
5
A viewpoint favors the optimistic side of multitasking performance

3 ____ Conflicts happened when visual and audio element emerge simultaneously$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('515bf987-c06b-5c7b-8bf8-6234f75a2a7a', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('191ea20c-ff5f-5bb1-b448-04c850f18d4a', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('774263ce-f5f6-5780-ae20-d3982e4b488d', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faab606c-dd75-5185-8cbe-6843eb6221c2', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e43cfcbc-473c-583e-8fe7-b70979ade327', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99660161-74e9-5225-bf36-bf2cfc2ed7be', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d9d18a9-f2df-5292-ab56-5e2349983c63', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae998092-c0f0-50af-9bb8-eb6646549af8', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a70f5261-8bbd-5247-9fb9-3818b18215a0', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8ec0b95-2967-55bb-9856-589a641d91a3', '31d681fd-1bb9-54ef-9ca6-666ec46cc06f', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('960de10b-28c2-52c5-837d-b681a78e3622', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
A theory explained delay happens when selecting one reaction
2
Different age group responds to important things differently
3
Conflicts happened when visual and audio element emerge simultaneously
4
An experiment designed to demonstrates the critical part of the brain for multitasking
5
A viewpoint favors the optimistic side of multitasking performance

4 ____ An experiment designed to demonstrates the critical part of the brain for multitasking$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47a4ebe5-dc73-5ded-8cb8-8d734bf7e8fa', '960de10b-28c2-52c5-837d-b681a78e3622', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf963517-8b59-5fda-a6b1-27eeea6bbba7', '960de10b-28c2-52c5-837d-b681a78e3622', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('400c90fa-aa33-5aaa-be2c-92f877e90ceb', '960de10b-28c2-52c5-837d-b681a78e3622', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c8c0601-bfd1-513e-89c1-001272214dcb', '960de10b-28c2-52c5-837d-b681a78e3622', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('027fc62d-cd3f-5e3a-b125-8ce471af9e39', '960de10b-28c2-52c5-837d-b681a78e3622', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('296a1b72-282e-50ec-9c05-27deb284aab0', '960de10b-28c2-52c5-837d-b681a78e3622', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed01ea04-9303-5801-9873-c64bfbe2adcd', '960de10b-28c2-52c5-837d-b681a78e3622', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8eb5b559-cd99-5efb-a30e-a04ca7c878dc', '960de10b-28c2-52c5-837d-b681a78e3622', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6be1fdf9-5cff-5ee0-bd3a-3211a62a844f', '960de10b-28c2-52c5-837d-b681a78e3622', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fb7d42d-c931-5dff-b1f9-9938fc656f4d', '960de10b-28c2-52c5-837d-b681a78e3622', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9e92e1c-029f-55b1-9f38-a4e93bc06fda', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
A theory explained delay happens when selecting one reaction
2
Different age group responds to important things differently
3
Conflicts happened when visual and audio element emerge simultaneously
4
An experiment designed to demonstrates the critical part of the brain for multitasking
5
A viewpoint favors the optimistic side of multitasking performance

5 ____ A viewpoint favors the optimistic side of multitasking performance$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15224a31-3d33-581c-9211-1d160e4360b9', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1e6a88b-abdc-5c81-8c16-a21e4b137c91', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aae8feac-62b2-5a77-b0f4-8b12a85cefd9', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0880bf8-9f9a-5a92-978b-8b2ca22e3d58', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42345824-38c8-5249-86f8-aac5ceef6f55', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c1e49e4-d918-5229-b08c-628cf7e18ce7', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fb4bbc2-dd9c-5d38-8440-1a1e88e10bf7', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d25f9235-1689-58f6-adeb-f14b227149b8', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e2795ca-5815-55a0-8298-c8a159a19164', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0da4a31f-48a9-5260-8b7b-33eaa7112e9a', 'f9e92e1c-029f-55b1-9f38-a4e93bc06fda', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c961604d-0794-5797-b861-b3743d49d191', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
Which one is correct about the experiment conducted by
René Marois
?
A
participants performed poorly on the listening task solely
B
volunteers press a different key on different color
C
participants need to use different fingers on the different colored object
D
they did a better fob on Mixed image and sound information
7.
Which statement is correct about the
first limitation
of Marois’s experiment?
A
“attentional blink” takes about ten seconds
B
lag occurs if we concentrate on one object while the second one appears
C
we always have trouble in reaching the second one
D
first limitation can be avoided by certain measures
8.
Which one is
NOT
correct about
Meyer’s experiments
and statements?
A
just after failure in several attempts can people execute dual-task
B
Practice can overcome dual-task interference
C
Meyer holds a different opinion on Marois’s theory
D
an existing processor decides whether to delay another task or not

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9dae7b3f-f55c-53d9-b5fb-f2ab56b9c873', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
Which one is correct about the experiment conducted by
René Marois
?
A
participants performed poorly on the listening task solely
B
volunteers press a different key on different color
C
participants need to use different fingers on the different colored object
D
they did a better fob on Mixed image and sound information
7.
Which statement is correct about the
first limitation
of Marois’s experiment?
A
“attentional blink” takes about ten seconds
B
lag occurs if we concentrate on one object while the second one appears
C
we always have trouble in reaching the second one
D
first limitation can be avoided by certain measures
8.
Which one is
NOT
correct about
Meyer’s experiments
and statements?
A
just after failure in several attempts can people execute dual-task
B
Practice can overcome dual-task interference
C
Meyer holds a different opinion on Marois’s theory
D
an existing processor decides whether to delay another task or not

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e969534-8f10-5a9d-b4ec-81bae2899096', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
Which one is correct about the experiment conducted by
René Marois
?
A
participants performed poorly on the listening task solely
B
volunteers press a different key on different color
C
participants need to use different fingers on the different colored object
D
they did a better fob on Mixed image and sound information
7.
Which statement is correct about the
first limitation
of Marois’s experiment?
A
“attentional blink” takes about ten seconds
B
lag occurs if we concentrate on one object while the second one appears
C
we always have trouble in reaching the second one
D
first limitation can be avoided by certain measures
8.
Which one is
NOT
correct about
Meyer’s experiments
and statements?
A
just after failure in several attempts can people execute dual-task
B
Practice can overcome dual-task interference
C
Meyer holds a different opinion on Marois’s theory
D
an existing processor decides whether to delay another task or not

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d61489bc-7268-56ab-9b62-398253cced75', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
The longer gap between two presenting tasks means shorter delay toward the second one.
10
Incapable of human memory cause people to sometimes miss the differences when presented two similar images.
11
Marois has a different opinion on the claim that training removes the bottleneck effect.
12
Art Kramer proved there is a correlation between multitasking performance and genders
13
The author doesn’t believe that the effect of practice could bring any variation.

9 ____ The longer gap between two presenting tasks means shorter delay toward the second one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6142043-9c53-5546-a23d-185c004b0cfc', 'd61489bc-7268-56ab-9b62-398253cced75', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('353862b3-3b52-55c3-a3e3-a811f8466fb3', 'd61489bc-7268-56ab-9b62-398253cced75', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76d4bab7-7480-56c5-b196-b0a21c612edf', 'd61489bc-7268-56ab-9b62-398253cced75', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4de4d795-6222-556d-b145-6f41c4a33a00', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
The longer gap between two presenting tasks means shorter delay toward the second one.
10
Incapable of human memory cause people to sometimes miss the differences when presented two similar images.
11
Marois has a different opinion on the claim that training removes the bottleneck effect.
12
Art Kramer proved there is a correlation between multitasking performance and genders
13
The author doesn’t believe that the effect of practice could bring any variation.

10 ____ Incapable of human memory cause people to sometimes miss the differences when presented two similar images.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95a54256-6fbb-5d5f-a887-87be2e871411', '4de4d795-6222-556d-b145-6f41c4a33a00', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5d07fbb-76e9-54e5-90d0-89175e56fa43', '4de4d795-6222-556d-b145-6f41c4a33a00', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb96ab8e-6cb3-5834-afec-feaa0b4e8aca', '4de4d795-6222-556d-b145-6f41c4a33a00', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ddaccaa-d70a-55b0-a1f6-886429f5cc2f', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
The longer gap between two presenting tasks means shorter delay toward the second one.
10
Incapable of human memory cause people to sometimes miss the differences when presented two similar images.
11
Marois has a different opinion on the claim that training removes the bottleneck effect.
12
Art Kramer proved there is a correlation between multitasking performance and genders
13
The author doesn’t believe that the effect of practice could bring any variation.

11 ____ Marois has a different opinion on the claim that training removes the bottleneck effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94f7f138-b1c1-562d-a8c1-c9692f80ecba', '2ddaccaa-d70a-55b0-a1f6-886429f5cc2f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22fc46da-f3fc-5dc9-86eb-57ff08629bbc', '2ddaccaa-d70a-55b0-a1f6-886429f5cc2f', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee8954c1-7394-517d-99fc-65c5d72c99c6', '2ddaccaa-d70a-55b0-a1f6-886429f5cc2f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a4e899c-ec4e-5d9a-98cf-e8786e42dfe5', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
The longer gap between two presenting tasks means shorter delay toward the second one.
10
Incapable of human memory cause people to sometimes miss the differences when presented two similar images.
11
Marois has a different opinion on the claim that training removes the bottleneck effect.
12
Art Kramer proved there is a correlation between multitasking performance and genders
13
The author doesn’t believe that the effect of practice could bring any variation.

12 ____ Art Kramer proved there is a correlation between multitasking performance and genders$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c00d5cfd-3cd9-549a-8fbc-4ce260886a55', '1a4e899c-ec4e-5d9a-98cf-e8786e42dfe5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ed1d7fc-d8f4-54c7-9a0a-05a62a59b020', '1a4e899c-ec4e-5d9a-98cf-e8786e42dfe5', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fd4235d-75cb-5c97-aa34-11e50ee75f43', '1a4e899c-ec4e-5d9a-98cf-e8786e42dfe5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81fb8075-f14e-5c62-b203-d85a302f5c34', '2cc2c9ba-bf2f-5366-813d-049258c485e6', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
The longer gap between two presenting tasks means shorter delay toward the second one.
10
Incapable of human memory cause people to sometimes miss the differences when presented two similar images.
11
Marois has a different opinion on the claim that training removes the bottleneck effect.
12
Art Kramer proved there is a correlation between multitasking performance and genders
13
The author doesn’t believe that the effect of practice could bring any variation.

13 ____ The author doesn’t believe that the effect of practice could bring any variation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd5f3017-7e74-511f-82ba-1f970ae87d15', '81fb8075-f14e-5c62-b203-d85a302f5c34', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f7b246-6365-55ed-91a8-77bdc42a81c8', '81fb8075-f14e-5c62-b203-d85a302f5c34', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5429b52-e1a4-586b-9f02-b4950fb4b5ec', '81fb8075-f14e-5c62-b203-d85a302f5c34', 3, $md$NOT GIVEN$md$, false);

COMMIT;
