BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-memory-decoding-1327'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-memory-decoding-1327';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-memory-decoding-1327';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-memory-decoding-1327';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('02762f04-c609-5d28-b4e7-aa72f34d5a57', 'ielts-reading-memory-decoding-1327', $t$Memory Decoding$t$, $md$## Memory Decoding

Nguồn:
- Test: https://mini-ielts.com/1327/reading/memory-decoding
- Solution: https://mini-ielts.com/1327/view-solution/reading/memory-decoding$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', '02762f04-c609-5d28-b4e7-aa72f34d5a57', 1, $t$Reading — Memory Decoding$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Memory Decoding

Try this memory test: Study each face and compose a vivid image for the person’s first and last name. Rose Leo, for example, could be a rosebud and a lion. Fill in the blanks on the next page. The Examinations School at Oxford University is an austere building of oak-paneled rooms, large Gothic windows, and looming portraits of eminent dukes and earls. It is where generations of Oxford students have tested their memory on final exams, and it is where, last August, 34 contestants gathered at the World Memory Championships to be examined in an entirely different manner.

A

In timed trials, contestants were challenged to look at and then recite a two-page poem, memorize rows of 40-digit numbers, recall the names of 110 people after looking at their photographs, and perform seven other feats of extraordinary retention. Some tests took just a few minutes; others lasted hours. In the 14 years since the World Memory Championships was founded, no one has memorized the order of a shuffled deck of playing cards in less than 30 seconds. That nice round number has become the four-minute mile of competitive memory, a benchmark that the world’s best “mental athletes,” as some of them like to be called, is closing in on. Most contestants claim to have just average memories, and scientific testing confirms that they’re not just being modest. Their feats are based on tricks that capitalize on how the human brain encodes information. Anyone can learn them.

B

Psychologists Elizabeth Valentine and John Wilding, authors of the monograph Superior Memory, recently teamed up with Eleanor Maguire, a neuroscientist at University College London to study eight people, including Karsten, who had finished near the top of the World Memory Championships. They wondered if the contestants’ brains were different in some way. The researchers put the competitors and a group of control subjects into an MRI machine and asked them to perform several different memory tests while their brains were being scanned. When it came to memorizing sequences of three-digit numbers, the difference between the memory contestant and the control subjects was, as expected, immense. However, when they were shown photographs of magnified snowflakes, images that the competitors had never tried to memorize before, the champions did no better than the control group. When the researchers analyzed the brain scans, they found that the memory champs were activating some brain regions that were different from those the control subjects were using. These regions, which included the right posterior hippocampus, are known to be involved in visual memory and spatial navigation.

C

It might seem odd that the memory contestants would use visual imagery and spatial navigation to remember numbers, but the activity makes sense when their techniques are revealed. Cooke, a 23-year-old cognitive-science graduate student with a shoulder-length mop of curly hair, is a grand master of brain storage. He can memorize the order of 10 decks of playing cards in less than an hour or one deck of cards in less than a minute. He is closing in on the 30-second deck. In the Lamb and Flag, Cooke pulled out a deck of cards and shuffled it. He held up three cards – the 7 of spades, the queen of clubs, and the 10 of spades. He pointed at a fireplace and said, “Destiny’s Child is whacking Franz Schubert with handbags.” The next three cards were the king of hearts, the king of spades, and the jack of clubs.

D

How did he do it? Cooke has already memorized a specific person, verb, and object that he associates with each card in the deck. For example, for the 7 of spades, the person (or, in this case, persons) is always the singing group Destiny’s Child, the action is surviving a storm, and the image is a dinghy. The queen of clubs is always his friend Henrietta, the action is thwacking with a handbag, and the image is of wardrobes filled with designer clothes. When Cooke commits a deck to memory, he does it three cards at a time. Every three-card group forms a single image of a person doing something to an object. The first card in the triplet becomes the person, the second the verb, the third the object. He then places those images along a specific familiar route, such as the one he took through the Lamb and Flag. In competitions, he uses an imaginary route that he has designed to be as smooth and downhill as possible. When it comes time to recall, Cooke takes a mental walk along his route and translates the images into cards. That’s why the MRIs of the memory contestants showed activation in the brain areas associated with visual imagery and spatial navigation.

E

The more resonant the images are, the more difficult they are to forget. But even meaningful information is hard to remember when there’s a lot of it. That’s why competitive memorizers place their images along an imaginary route. That technique, known as the loci method, reportedly originated in 477 B.C. with the Greek poet Simonides of Ceos. Simonides was the sole survivor of a roof collapse that killed all the other guests at a royal banquet. The bodies were mangled beyond recognition, but Simonides was able to reconstruct the guest list by closing his eyes and recalling each individual around the dinner table. What he had discovered was that our brains are exceptionally good at remembering images and spatial information. Evolutionary psychologists have offered an explanation: Presumably, our ancestors found it important to recall where they found their last meal or the way back to the cave. After Simonides’ discovery, the loci method became popular across ancient Greece as a trick for memorizing speeches and texts. Aristotle wrote about it, and later a number of treatises on the art of memory were published in Rome. Before printed books, the art of memory was considered a staple of classical education, on a par with grammar, logic, and rhetoric.

F

The most famous of the naturals was the Russian journalist S.V. Shereshevski, who could recall long lists of numbers memorized decades earlier, as well as poems, strings of nonsense syllables, and just about anything else he was asked to remember. “The capacity of his memory had no distinct limits,” wrote Alexander Luria, the Russian psychologist who studies Shereshevski also had synesthesia, a rare condition in which the senses become intertwined. For example, every number may be associated with a color or every word with a taste. Synesthetic reactions evoke a response in more areas of the brain, making memory easier.

G

K. Anders Ericsson, a Swedish-born psychologist at Florida State University, thinks anyone can acquire Shereshevski’s skills. He cites an experiment with S. F., an undergraduate who was paid to take a standard test of memory called the digit span for one hour a day, two or three days a week. When he started, he could hold, like most people, only about seven digits in his head at any given time (conveniently, the length of a phone number). Over two years, S. F. completed 250 hours of testing. By then, he had stretched his digit span from 7 to more than 80. The study of S. F. led Ericsson to believe that innately superior memory doesn’t exist at all. When he reviewed original case studies of naturals, he found that exceptional memorizers were using techniques – sometimes without realizing it – and lots of practice. Often, exceptional memory was only for a single type of material, like digits. “If we look at some of these memory tasks, they’re the kind of thing most people don’t even waste one hour practicing, but if they wasted 50 hours, they’d be exceptional at it,” Ericsson says. It would be remarkable, he adds, to find a “person who is exceptional across a number of tasks. I don’t think that there’s any compelling evidence that there are such people.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1012fd90-aea8-5319-bbef-940d52258912', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-5 on your answer sheet.
1
The reason why the competence of super memory is significant in academic settings
2
Mention of a contest for extraordinary memory held in consecutive years
3
A demonstrative example of extraordinary person did an unusual recalling game
4
A belief that extraordinary memory can be gained through enough practice
5
A depiction of the rare ability which assists the extraordinary memory reactions

1 ____ The reason why the competence of super memory is significant in academic settings$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84be59a2-c42b-5cc1-8805-33cbcdc6b5b7', '1012fd90-aea8-5319-bbef-940d52258912', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82a815d5-13a4-5caf-9889-c7c50db11c63', '1012fd90-aea8-5319-bbef-940d52258912', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcd549d6-b6f3-56ff-8bec-3fcc6ece29db', '1012fd90-aea8-5319-bbef-940d52258912', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4782d788-05db-570d-b89b-ea2a56f95242', '1012fd90-aea8-5319-bbef-940d52258912', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac8b67dc-19e5-52b8-b324-808784ba9252', '1012fd90-aea8-5319-bbef-940d52258912', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8360dde2-77fa-5add-b578-c38860c3fe1a', '1012fd90-aea8-5319-bbef-940d52258912', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d64ae2f-755d-5efc-a8e8-fb28b9be540c', '1012fd90-aea8-5319-bbef-940d52258912', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-5 on your answer sheet.
1
The reason why the competence of super memory is significant in academic settings
2
Mention of a contest for extraordinary memory held in consecutive years
3
A demonstrative example of extraordinary person did an unusual recalling game
4
A belief that extraordinary memory can be gained through enough practice
5
A depiction of the rare ability which assists the extraordinary memory reactions

2 ____ Mention of a contest for extraordinary memory held in consecutive years$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff4fbf18-d146-5a09-9a76-3705ef4db45f', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d091d45f-4094-50fa-8b48-f4ed3c53fcdf', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c43cf9-d7bf-5a58-b9ab-66d781ef2b64', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32154d54-fec4-5dc3-bdb3-e914942fc5d3', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d18c2799-58a8-52ce-b6e7-a2fdcd4628a8', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b66a2b26-946c-56d5-b741-47c4afcc2329', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70a7f82a-6edb-55e9-ab3c-500997c6cb01', 'c3fe7f8b-9370-5436-8ece-3ff8f0c145b9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-5 on your answer sheet.
1
The reason why the competence of super memory is significant in academic settings
2
Mention of a contest for extraordinary memory held in consecutive years
3
A demonstrative example of extraordinary person did an unusual recalling game
4
A belief that extraordinary memory can be gained through enough practice
5
A depiction of the rare ability which assists the extraordinary memory reactions

3 ____ A demonstrative example of extraordinary person did an unusual recalling game$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd75c021-7072-566a-bbda-cd34641e017a', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b180a093-2c70-5a64-a10f-b1a93593b45c', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f5cc2b8-4e48-537e-a454-9dac5ca1f7f9', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('231afede-0183-56cd-a482-8e03a6248259', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55ea5c49-ec0c-5fc6-b469-2c8b4580b87d', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('078f6153-f673-5ab4-a821-50733909cc8f', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aed95c6a-6d5e-54e6-baa0-cc5ffcb01693', '0e2d5622-e434-5d39-8e3a-0d7a7b2195c4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-5 on your answer sheet.
1
The reason why the competence of super memory is significant in academic settings
2
Mention of a contest for extraordinary memory held in consecutive years
3
A demonstrative example of extraordinary person did an unusual recalling game
4
A belief that extraordinary memory can be gained through enough practice
5
A depiction of the rare ability which assists the extraordinary memory reactions

4 ____ A belief that extraordinary memory can be gained through enough practice$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27fd486f-2df6-50c6-8331-b084a3b69c59', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ddf817d-bb87-5fc2-85d1-4a1d6dc77b47', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('706575a7-7b2b-55d1-8ee2-53c9712734a9', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12dae21c-e9f3-55e2-83d4-1a9fefc054a9', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbe6b6d8-ee2b-595c-a5c0-3d4224c79093', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf7e8ecc-a450-523f-9fca-c46a2cd56c77', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eb34223-bfc8-5177-88d4-ddced257cb4d', '0973b3d2-e7cb-5c16-8129-a7b54a9e381d', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-5 on your answer sheet.
1
The reason why the competence of super memory is significant in academic settings
2
Mention of a contest for extraordinary memory held in consecutive years
3
A demonstrative example of extraordinary person did an unusual recalling game
4
A belief that extraordinary memory can be gained through enough practice
5
A depiction of the rare ability which assists the extraordinary memory reactions

5 ____ A depiction of the rare ability which assists the extraordinary memory reactions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e48757f8-63ce-54f5-8586-f21bff62d03c', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7c65ee2-79ec-53a3-afb9-b2c8c28b7729', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c249083-5ad3-5eba-b12c-57353696ba86', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bb5a698-8e27-5ca7-9ba8-87db4a83d395', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7c8fd9a-b164-5701-a516-813c310ed0f2', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecc75910-1785-5fc4-9c55-09d769d9ec08', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03485746-e0bd-55f7-af5b-fd2b0ac56d27', 'ace9276f-cdf6-5e6b-bcfa-87c8dd4831ae', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1aa61fb0-e3cd-5905-8688-8d3e4a58be73', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a
6
and the card deck to memory are set to be one time of an order of
7
; When it comes time to recall, Cooke took a
8
along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called
9
which had been a major subject was in ancient
10
.

Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a 6 ____ and the card deck to memory are set to be one time of an order of 7 ____ ; When it comes time to recall, Cooke took a 8 ____ along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called 9 ____ which had been a major subject was in ancient 10 ____ .$md$, NULL, ARRAY['.*specific.*person.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('35594474-3100-5954-b4b8-ff08c391fd72', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a
6
and the card deck to memory are set to be one time of an order of
7
; When it comes time to recall, Cooke took a
8
along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called
9
which had been a major subject was in ancient
10
.

Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a 6 ____ and the card deck to memory are set to be one time of an order of 7 ____ ; When it comes time to recall, Cooke took a 8 ____ along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called 9 ____ which had been a major subject was in ancient 10 ____ .$md$, NULL, ARRAY['.*specific.*person.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4d8bad65-1f72-50d9-87cb-debf0676ee06', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a
6
and the card deck to memory are set to be one time of an order of
7
; When it comes time to recall, Cooke took a
8
along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called
9
which had been a major subject was in ancient
10
.

Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a 6 ____ and the card deck to memory are set to be one time of an order of 7 ____ ; When it comes time to recall, Cooke took a 8 ____ along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called 9 ____ which had been a major subject was in ancient 10 ____ .$md$, NULL, ARRAY['.*specific.*person.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b365a0cd-113d-54ae-8efa-eb3a605b41fa', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a
6
and the card deck to memory are set to be one time of an order of
7
; When it comes time to recall, Cooke took a
8
along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called
9
which had been a major subject was in ancient
10
.

Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a 6 ____ and the card deck to memory are set to be one time of an order of 7 ____ ; When it comes time to recall, Cooke took a 8 ____ along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called 9 ____ which had been a major subject was in ancient 10 ____ .$md$, NULL, ARRAY['.*specific.*person.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('25be143c-9b18-56cd-a6f8-9246f64a3528', 'c183ae7d-c77c-5ab3-bc32-72b66ee1e9c2', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a
6
and the card deck to memory are set to be one time of an order of
7
; When it comes time to recall, Cooke took a
8
along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called
9
which had been a major subject was in ancient
10
.

Using visual imagery and spatial navigation to remember numbers are investigated and explained. A man called Ed Cooke in a pub, spoke a string of odd words when he held 7 of the spades (the first one of any cards group) was remembered as he encoded it to a 6 ____ and the card deck to memory are set to be one time of an order of 7 ____ ; When it comes time to recall, Cooke took a 8 ____ along his way and interpreted the imaginary scene into cards. This superior memory skill can be traced back to Ancient Greece, the strategy was called 9 ____ which had been a major subject was in ancient 10 ____ .$md$, NULL, ARRAY['.*specific.*person.*']);

COMMIT;
