BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-smell-and-memory-smell-like-yesterday-1303'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-smell-and-memory-smell-like-yesterday-1303';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-smell-and-memory-smell-like-yesterday-1303';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-smell-and-memory-smell-like-yesterday-1303';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2c408a86-2846-5b8a-9bac-c43a352f3709', 'ielts-reading-smell-and-memory-smell-like-yesterday-1303', $t$Smell and Memory: Smell like yesterday$t$, $md$## Smell and Memory: Smell like yesterday

Nguồn:
- Test: https://mini-ielts.com/1303/reading/smell-and-memory-smell-like-yesterday
- Solution: https://mini-ielts.com/1303/view-solution/reading/smell-and-memory-smell-like-yesterday$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', '2c408a86-2846-5b8a-9bac-c43a352f3709', 1, $t$Reading — Smell and Memory: Smell like yesterday$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Smell and Memory: Smell like yesterday

Why does the scent of a fragrance or the mustiness of an old trunk trigger such powerful memories of childhood? New research has the answer, writes Alexandra Witze.

A. You probably pay more attention to a newspaper with your eyes than with your nose. But lift the paper to your nostrils and inhale. The smell of newsprint might carry you back to your childhood, when your parents perused the paper on Sunday mornings. Or maybe some other smell takes you back-the scent of your mother’s perfume, the pungency of a driftwood campfire. Specific odours can spark a flood of reminiscences.

Psychologists call it the “Proustian phenomeno” after French novelist Marcel Proust. Near the beginning of the masterpiece In Search of Lost Time, Proust’s narrator dunks a madeleine cookie into a cup of tea and the scent and taste unleash a torrent of childhood memories for 3000 pages.

B. Now, this phenomenon is getting the scientific treatment. Neuroscientists Rachel Herz, a cognitive neuroscientist at Brown University in Providence, Rhode Island, have discovered, for instance, how sensory memories are shared across the brain, with different brain regions remembering the sights, smells, tastes and sounds of a particular experience. Meanwhile, psychologists have demonstrated that memories triggered by smells can be more emotional, as well as more detailed, than memories not related to smells.

When you inhale, odour molecules set brain cells dancing within a region known as the imygdala ( E ) , a part of the brain that helps control emotion. In contrast, the other senses, such as taste or touch, get routed through other parts of the brain before reaching the amygdala. The direct link between odours and the amygdala may help explain the emotional potency of smells. ’’There is this unique connection between the sense of smell and the part of the brain that processes emotion,” says Rachel Herz.

C. But the links don’t stop there. Like an octopus reaching its tentacles outward, the memory of smells affects other brain regions as well. In recent experiments, neuroscientists at University College London (UCL) asked 15 volunteers to look at pictures while smelling unrelated odours. For instance, the subjects might see a photo of a duck paired with the scent of a rose, and then be asked to create a story linking the two.

Brain scans taken at the time revealed that the volunteers’ brains were particularly active in a region known as the factory cortex, which is known to be involved in processing smells. Five minutes later, the volunteers were shown the duck photo again, but without the rose smell. And in their brains, the olfactory cortex lit up again, the scientists reported recently. The fact that the olfactory cortex became active in the absence of the odour suggests that people’s sensory memory of events is spread across different brain regions.

Imagine going on a seaside holiday, says UCL team leader, Jay Gottfried. The sight of the waves becomes stored in one area, whereas the crash of the surf goes elsewhere, and the smell of seaweed in yet another place. There could be advantageous to having memories spread around the brain. ’’You can reawaken that memory from any one of the sensory triggers,” says Gottfried. “Maybe the smell of the sun lotion, or a particular sound from that day, or the sight of a rock formation.” Or – in the case of an early hunter and gatherer (out on a plain – the sight of a lion might be enough to trigger the urge to flee, rather than having to wait for the sound of its roar and the stench of its hide to kick in as well.

D. Remembered smells may also carry extra emotional baggage, says Herz. Her research suggests that memories triggered by odours are more emotional than memories triggered by other cues. In one recent study, Herz recruited five volunteers who had vivid memories associated with a particular perfume, such as opium for Women and Juniper Breeze from Bath and Body Works.

She took images of the volunteers’ brains as they sniffed that perfume and an unrelated perfume without knowing which was which. (They were also shown photos of each perfume bottle.) Smelling the specified perfume activated the volunteers brains the most, particularly in the amygdala, and in a region called the hippocampus which helps in memory formation. Herz published the work earlier this year in the journal Neuropsychologia.

E. But she couldn’t be sure that the other senses wouldn’t also elicit a strong response. So in another study Herz compared smells with sounds and pictures. She had 70 people describe an emotional memory involving three items – popcorn, fresh-cut grass and a campfire. Then they compared the items through sights, sounds and smells. For instance, the person might see a picture of a lawnmower, then sniff the scent of grass and finally listen to the lawnmower’s sound. Memories triggered by smell were more evocative than memories triggered by either sights or sounds.

F . Odour-evoked memories may be not only more emotional, but more detailed as well. Working with colleague John Downes, psychologist Simon Chu of the University of Liverpool started researching odour and memory partly because of his grandmother’s stories about Chinese culture. As generations gathered to share oral histories, they would pass a small pot of spice or incense around; later, when they wanted to remember the story in as much detail as possible, they would pass the same smell around again.

”It’s kind of fits with a lot of anecdotal evidence on how smells can be really good reminders of past experiences,” Chu says. And scientific research seems to bear out the anecdotes. In one experiment, Chu and Downes asked 42 volunteers to tell a life story, then tested to see whether odours such as coffee and cinnamon could help them remember more detail in the story. They could.

G. Despite such studies, not everyone is convinced that Proust can be scientifically analysed. In the June issue of Chemical Senses, Chu and Downes exchanged critiques with renowned perfumer and chemist J. Stephan Jellinek. Jellinek chided the Liverpool researchers for, among other things, presenting the smells and asking the volunteers to think of memories, rather than seeing what memories were spontaneously evoked by the odours. But there’s only so much science can do to test a phenomenon that’s inherently different for each person, Chu says.

Meanwhile, Jellinek has also been collecting anecdotal accounts of Proustian experiences, hoping to find some common links between the experiences. “I think there is a case to be made that surprise may be a major aspect of the Proust phenomenon,” he says. “That’s why people are so struck by these memories.” No one knows whether Proust ever experienced such a transcendental moment. But his notions of memory, written as fiction nearly a century ago, continue to inspire scientists of today.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e17aa5b-3523-515b-a072-3815480c62bc', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB:
you may use any letter more than once
A Rachel Herz
B Simon Chu
C Jay Gottfried
1
Found pattern of different sensory memories stored in various zones of a brain.
2
Smell brings detailed event under a smell of certain substance.
3
Connection of smell and certain zones of brain is different with that of other senses.
4
Diverse locations of stored information help US keep away the hazard.
5
There is no necessary correlation between smell and processing zone of brain.

A Rachel Herz B Simon Chu C Jay Gottfried 1 ____ Found pattern of different sensory memories stored in various zones of a brain. 2 ____ Smell brings detailed event under a smell of certain substance. 3 ____ Connection of smell and certain zones of brain is different with that of other senses. 4 ____ Diverse locations of stored information help US keep away the hazard. 5 ____ There is no necessary correlation between smell and processing zone of brain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce23897d-f129-5536-9ae3-7ea5a09d2c24', '6e17aa5b-3523-515b-a072-3815480c62bc', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59a50503-5675-5dab-910c-55978dae1bf2', '6e17aa5b-3523-515b-a072-3815480c62bc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b9bad35-5840-5592-8354-b09005c9867e', '6e17aa5b-3523-515b-a072-3815480c62bc', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('851194e2-e5f2-51b5-9eec-8da22c0ef8f5', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB:
you may use any letter more than once
A Rachel Herz
B Simon Chu
C Jay Gottfried
1
Found pattern of different sensory memories stored in various zones of a brain.
2
Smell brings detailed event under a smell of certain substance.
3
Connection of smell and certain zones of brain is different with that of other senses.
4
Diverse locations of stored information help US keep away the hazard.
5
There is no necessary correlation between smell and processing zone of brain.

A Rachel Herz B Simon Chu C Jay Gottfried 1 ____ Found pattern of different sensory memories stored in various zones of a brain. 2 ____ Smell brings detailed event under a smell of certain substance. 3 ____ Connection of smell and certain zones of brain is different with that of other senses. 4 ____ Diverse locations of stored information help US keep away the hazard. 5 ____ There is no necessary correlation between smell and processing zone of brain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d143ded-27b6-50b2-b5b8-f026d1f11603', '851194e2-e5f2-51b5-9eec-8da22c0ef8f5', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('772be96f-0cea-5309-ac06-35acdc2e353b', '851194e2-e5f2-51b5-9eec-8da22c0ef8f5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9575e59-6343-5f80-ac57-35e1ce643b7a', '851194e2-e5f2-51b5-9eec-8da22c0ef8f5', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c344977-eb3b-5487-8760-b52b22e615ff', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB:
you may use any letter more than once
A Rachel Herz
B Simon Chu
C Jay Gottfried
1
Found pattern of different sensory memories stored in various zones of a brain.
2
Smell brings detailed event under a smell of certain substance.
3
Connection of smell and certain zones of brain is different with that of other senses.
4
Diverse locations of stored information help US keep away the hazard.
5
There is no necessary correlation between smell and processing zone of brain.

A Rachel Herz B Simon Chu C Jay Gottfried 1 ____ Found pattern of different sensory memories stored in various zones of a brain. 2 ____ Smell brings detailed event under a smell of certain substance. 3 ____ Connection of smell and certain zones of brain is different with that of other senses. 4 ____ Diverse locations of stored information help US keep away the hazard. 5 ____ There is no necessary correlation between smell and processing zone of brain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e53594b-5605-56d5-bf16-05d34a86e9bf', '0c344977-eb3b-5487-8760-b52b22e615ff', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b4e6632-bdfe-5c84-817f-e8a13457f6da', '0c344977-eb3b-5487-8760-b52b22e615ff', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b273ea2c-f766-5f5f-93a2-6c4acbd8eb7c', '0c344977-eb3b-5487-8760-b52b22e615ff', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4ecfff6-ccf5-5785-99e1-fd337458038f', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB:
you may use any letter more than once
A Rachel Herz
B Simon Chu
C Jay Gottfried
1
Found pattern of different sensory memories stored in various zones of a brain.
2
Smell brings detailed event under a smell of certain substance.
3
Connection of smell and certain zones of brain is different with that of other senses.
4
Diverse locations of stored information help US keep away the hazard.
5
There is no necessary correlation between smell and processing zone of brain.

A Rachel Herz B Simon Chu C Jay Gottfried 1 ____ Found pattern of different sensory memories stored in various zones of a brain. 2 ____ Smell brings detailed event under a smell of certain substance. 3 ____ Connection of smell and certain zones of brain is different with that of other senses. 4 ____ Diverse locations of stored information help US keep away the hazard. 5 ____ There is no necessary correlation between smell and processing zone of brain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d69a206-ab85-5b15-a451-e13db20ed59f', 'd4ecfff6-ccf5-5785-99e1-fd337458038f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b484686-321b-54d8-91f3-7236074a1b18', 'd4ecfff6-ccf5-5785-99e1-fd337458038f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71fdd714-a901-50ad-92a7-a5a4a28fa129', 'd4ecfff6-ccf5-5785-99e1-fd337458038f', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1916157-2318-59c9-a521-14a15c979490', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed A-C) with opinions or deeds below.
Write the appropriate letters A-C in boxes
1-5
on your answer sheet.
NB:
you may use any letter more than once
A Rachel Herz
B Simon Chu
C Jay Gottfried
1
Found pattern of different sensory memories stored in various zones of a brain.
2
Smell brings detailed event under a smell of certain substance.
3
Connection of smell and certain zones of brain is different with that of other senses.
4
Diverse locations of stored information help US keep away the hazard.
5
There is no necessary correlation between smell and processing zone of brain.

A Rachel Herz B Simon Chu C Jay Gottfried 1 ____ Found pattern of different sensory memories stored in various zones of a brain. 2 ____ Smell brings detailed event under a smell of certain substance. 3 ____ Connection of smell and certain zones of brain is different with that of other senses. 4 ____ Diverse locations of stored information help US keep away the hazard. 5 ____ There is no necessary correlation between smell and processing zone of brain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b801006b-4dde-5df8-aaac-df03f8d13106', 'b1916157-2318-59c9-a521-14a15c979490', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('544cabf6-2345-5e46-89f3-846d1a634694', 'b1916157-2318-59c9-a521-14a15c979490', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c469dfb-ad22-5061-9016-71cb91b74cbf', 'b1916157-2318-59c9-a521-14a15c979490', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77baa183-9c85-587b-928f-5b6609e24579', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Choose the correct letter, A, B, c or D.
Write your answers in boxes
6-9
on your answer sheet.
6.
In paragraph B, what do the experiments conducted by Herz and other scientists show?
A
Women are more easily addicted to opium medicine
B
Smell is superior to other senses in connection to the brain
C
Smell is more important than other senses
D
certain part of brain relates the emotion to the sense of smell
7.
What does the second experiment conducted by Herz suggest?
A
Result directly conflicts with the first one
B
Result of her first experiment is correct
C
Sights and sounds trigger memories at an equal level
D
Lawnmower is a perfect example in the experiment
8.
What is the outcome of experiment conducted by Chu and Downes?
A
smell is the only functional under Chinese tradition
B
half of volunteers told detailed stories
C
smells of certain odours assist story tellers
D
odours of cinnamon is stronger than that of coffee
9.
What is the comment of Jellinek to Chu and Downers in the issue of Chemical Senses’.
A
Jellinek accused their experiment of being unscientific
B
Jellinek thought Liverpool is not a suitable place for experiment
C
Jellinek suggested that there was no further clue of what specific memories aroused
D
Jellinek stated that experiment could be remediedoffee

Choose the correct letter, A, B, c or D. Write your answers in boxes 6-9 on your answer sheet. 6. In paragraph B, what do the experiments conducted by Herz and other scientists show?$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64b54091-24b4-56dd-9bce-6790912440e8', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Choose the correct letter, A, B, c or D.
Write your answers in boxes
6-9
on your answer sheet.
6.
In paragraph B, what do the experiments conducted by Herz and other scientists show?
A
Women are more easily addicted to opium medicine
B
Smell is superior to other senses in connection to the brain
C
Smell is more important than other senses
D
certain part of brain relates the emotion to the sense of smell
7.
What does the second experiment conducted by Herz suggest?
A
Result directly conflicts with the first one
B
Result of her first experiment is correct
C
Sights and sounds trigger memories at an equal level
D
Lawnmower is a perfect example in the experiment
8.
What is the outcome of experiment conducted by Chu and Downes?
A
smell is the only functional under Chinese tradition
B
half of volunteers told detailed stories
C
smells of certain odours assist story tellers
D
odours of cinnamon is stronger than that of coffee
9.
What is the comment of Jellinek to Chu and Downers in the issue of Chemical Senses’.
A
Jellinek accused their experiment of being unscientific
B
Jellinek thought Liverpool is not a suitable place for experiment
C
Jellinek suggested that there was no further clue of what specific memories aroused
D
Jellinek stated that experiment could be remediedoffee

Choose the correct letter, A, B, c or D. Write your answers in boxes 6-9 on your answer sheet. 6. In paragraph B, what do the experiments conducted by Herz and other scientists show?$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5df55d9b-ed48-5040-ab66-0b9201b02e78', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Choose the correct letter, A, B, c or D.
Write your answers in boxes
6-9
on your answer sheet.
6.
In paragraph B, what do the experiments conducted by Herz and other scientists show?
A
Women are more easily addicted to opium medicine
B
Smell is superior to other senses in connection to the brain
C
Smell is more important than other senses
D
certain part of brain relates the emotion to the sense of smell
7.
What does the second experiment conducted by Herz suggest?
A
Result directly conflicts with the first one
B
Result of her first experiment is correct
C
Sights and sounds trigger memories at an equal level
D
Lawnmower is a perfect example in the experiment
8.
What is the outcome of experiment conducted by Chu and Downes?
A
smell is the only functional under Chinese tradition
B
half of volunteers told detailed stories
C
smells of certain odours assist story tellers
D
odours of cinnamon is stronger than that of coffee
9.
What is the comment of Jellinek to Chu and Downers in the issue of Chemical Senses’.
A
Jellinek accused their experiment of being unscientific
B
Jellinek thought Liverpool is not a suitable place for experiment
C
Jellinek suggested that there was no further clue of what specific memories aroused
D
Jellinek stated that experiment could be remediedoffee

Choose the correct letter, A, B, c or D. Write your answers in boxes 6-9 on your answer sheet. 6. In paragraph B, what do the experiments conducted by Herz and other scientists show?$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20ddedd4-1fe2-5c90-be36-ef4759c8a5ed', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Choose the correct letter, A, B, c or D.
Write your answers in boxes
6-9
on your answer sheet.
6.
In paragraph B, what do the experiments conducted by Herz and other scientists show?
A
Women are more easily addicted to opium medicine
B
Smell is superior to other senses in connection to the brain
C
Smell is more important than other senses
D
certain part of brain relates the emotion to the sense of smell
7.
What does the second experiment conducted by Herz suggest?
A
Result directly conflicts with the first one
B
Result of her first experiment is correct
C
Sights and sounds trigger memories at an equal level
D
Lawnmower is a perfect example in the experiment
8.
What is the outcome of experiment conducted by Chu and Downes?
A
smell is the only functional under Chinese tradition
B
half of volunteers told detailed stories
C
smells of certain odours assist story tellers
D
odours of cinnamon is stronger than that of coffee
9.
What is the comment of Jellinek to Chu and Downers in the issue of Chemical Senses’.
A
Jellinek accused their experiment of being unscientific
B
Jellinek thought Liverpool is not a suitable place for experiment
C
Jellinek suggested that there was no further clue of what specific memories aroused
D
Jellinek stated that experiment could be remediedoffee

Choose the correct letter, A, B, c or D. Write your answers in boxes 6-9 on your answer sheet. 6. In paragraph B, what do the experiments conducted by Herz and other scientists show?$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6d3dd582-6e7d-564f-8dd1-e0ad27033b0d', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer.
Write your answers in boxes
11-13
on your answer sheet.
In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to
10
for a connection. A method called
11
suggested that specific area of brain named
12
were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of
13
or incense around.

In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to 10 ____ for a connection. A method called 11 ____ suggested that specific area of brain named 12 ____ were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of 13 ____ or incense around.$md$, NULL, ARRAY['.*create.*a.*story.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('db261688-4a8e-574e-aaae-52f4e6d48dd0', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer.
Write your answers in boxes
11-13
on your answer sheet.
In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to
10
for a connection. A method called
11
suggested that specific area of brain named
12
were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of
13
or incense around.

In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to 10 ____ for a connection. A method called 11 ____ suggested that specific area of brain named 12 ____ were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of 13 ____ or incense around.$md$, NULL, ARRAY['.*create.*a.*story.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a7315a6f-8a21-5e0f-a10a-6ea8aae0ae20', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer.
Write your answers in boxes
11-13
on your answer sheet.
In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to
10
for a connection. A method called
11
suggested that specific area of brain named
12
were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of
13
or incense around.

In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to 10 ____ for a connection. A method called 11 ____ suggested that specific area of brain named 12 ____ were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of 13 ____ or incense around.$md$, NULL, ARRAY['.*create.*a.*story.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0c5c1169-866d-5887-91f9-9e44080b3959', 'fcb692e1-bc5d-55de-82cb-f0e87e70fe4d', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
no more than three words
from the Reading Passage for each answer.
Write your answers in boxes
11-13
on your answer sheet.
In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to
10
for a connection. A method called
11
suggested that specific area of brain named
12
were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of
13
or incense around.

In the experiments conducted by UCL, participants were asked to look at a picture with a scent of a flower, then in the next stage, everyone would have to 10 ____ for a connection. A method called 11 ____ suggested that specific area of brain named 12 ____ were quite active. Then in an another parallelled experiment about Chinese elders, storytellers could recall detailed anecdotes when smelling a bowl of 13 ____ or incense around.$md$, NULL, ARRAY['.*create.*a.*story.*']);

COMMIT;
