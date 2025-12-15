BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-dark-side-of-the-technological-boom-1467'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dark-side-of-the-technological-boom-1467';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dark-side-of-the-technological-boom-1467';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-dark-side-of-the-technological-boom-1467';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('05d53460-72d2-5761-88e1-c65cd83a7d9e', 'ielts-reading-the-dark-side-of-the-technological-boom-1467', $t$The dark side of the technological boom$t$, $md$## The dark side of the technological boom

Nguồn:
- Test: https://mini-ielts.com/1467/reading/the-dark-side-of-the-technological-boom
- Solution: https://mini-ielts.com/1467/view-solution/reading/the-dark-side-of-the-technological-boom$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('549c1788-ef7a-5192-8088-d9ee57fa4a17', '05d53460-72d2-5761-88e1-c65cd83a7d9e', 1, $t$Reading — The dark side of the technological boom$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The dark side of the technological boom

What are the effects on the individual of working in modern technological workplaces?

Changes in the way we work and how our offices are structured come at US faster and faster. Waves of state-of-the-art information technology and instant telecommunications let us reach anyone, anywhere, and speed is the key. Most of US are too busy struggling to keep pace with ongoing innovations to question the implications of our new electronic authority figures. According to a number of psychologists, however, the need to stay on top of the information flow and the vent degree to which we remain in touch with our offices exact a profound toll on US as individuals.

Mass exposure to technological innovations in the workplace has come too recently for psychologists to reach a consensus on its societal implications. Many agree, however, that one of the first signs of the struggle to adapt to the electronic office is often 'technostress, a cognitive shift that results from an over-identification with information systems. Psychologist Craig Brod says people become accustomed to the patterns set by electronic tools - accelerated time and yes/no logic - and internalize these patterns. When they leave the office or go home, Brod says, they need complete isolation to recover from the effects of the technology.

Brod warns that over-reliance on electronic tools could also have serious repercussions on our ability to think creatively and develop new ideas. Because we don't create in a vacuum, he points out, we need to avoid the temptation to replace informal gatherings for bouncing ideas off colleagues with electronic networking. It's also more difficult to spot errors or even evaluate the shape of a project displayed in a flat, two-dimensional way on a screen.

Electronically networked offices can also make it increasingly difficult to convince ourselves that we're doing an adequate job and accumulating enough information to make informed decisions. Philosopher Daniel Dennett points out that modern technology eliminates the possibility of unavoidable ignorance. As the opportunity to amass information grows larger, the obligation to make accurate predictions - the right decisions - becomes more onerous. Instead of consoling ourselves that we're doing as good a job as we can, we are tormented by the knowledge that the world of information is limidess.

For executives near the top of the office pyramid, the benefits of the electronic revolution - like telecommuting and flexible scheduling - may outweigh the disadvantages of being continuously on call. But in Workplace 2000, authors Joseph Boyett and Henry Conn describe a future in which millions of people now charged with analyzing information and making routine decisions will be replaced by less skilled workers using 'intelligent' software to make decisions for them. They predict that a cult of performance excellence will engulf most businesses.

The millions of people on the bottom levels of electronic hierarchies are increasingly likely to spend heir days in an isolated no-man's land, subservient to intelligent information systems that report their progress to unseen supervisors far away. Because computers measure quantity quality, such systems tend to reward employees who work faster more than those who work better.

Service people on the telephone or at a cash register curtly terminate attempts at idle conversation because their performance is being electronically monitored. Once judged on their ability to troubleshoot unexpected situations, they're now evaluated by the number of transactions they complete in a shift or the number of keystroke required to draft a sweatshops', the computers are running the people, not the other way around.

."I think people are going to feel an increased fragmentation of self. They won't be able to hold the pieces together,' human resources consultant Philip Nicholson says. "How do you keep a coherent space if you’re going in and out of spaces that don't exist?' He likens the psychic numbing of electronic information overload to symptoms of post- traumatic stress syndrome (a mental disorder following a horrific event). In office 'wars', people become overwhelmed by the sheer amount of information available, internalize the diversity of the world outside, and fear losing com own lives.

If we are to survive the challenges of information-driven, hardwired offices, says Nicholson, we need to provide psychological support systems. As no one has yet measured the social cost of the workplace revolution, some psychologists are mobilizing efforts to pool information as it is derived. Nicholson started the Technostress International Information Network in Massachusetts to foster an exchange of data and ideas on the effects of computerization and information technology Meanwhile, Brod wants to examine the parallels between electronic work environments and sealed- cabin ecologies' like space capsules or submarines, both totally automated artificial worlds in which people live in highly confined circumstances surrounded by technology that dictates the tenor of their days as well as their survival. He is petitioning other psychologists to convince the American Psychological Association to form a specialized study group.

In addition, Brod suggests that we re-examine our value systems and that we make greater allowances for privacy in order to circumvent potential revolts against technology. We need to coevolve with technology,' he says. "These are wonderful tools, but if we exploit them without imposing appropriate values on their use, they become alienating and dangerous.'$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac571028-9457-595c-9fa0-7307453ec193', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E, in boxes 1-3 on your answer sheet.
1
The speed of technological changes
2
A dependency on technology and computers
3
A deterioration in personal service
A
requires more detailed study by psychologists.
B
means people bave no time to challenge the significance of the new technology.
C
may reduce inventiveness and innovation.
D
suggests computers will take over the workplace.
E
results from increased electronic supervision.

1 ____ The speed of technological changes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31060da2-3bf8-5823-9ce6-5cb2b604752c', 'ac571028-9457-595c-9fa0-7307453ec193', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('996bc10f-49cd-5e8e-9fc4-cf6bc9cba712', 'ac571028-9457-595c-9fa0-7307453ec193', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4880fa2d-3bd7-5d0f-b1b5-bbbca867a289', 'ac571028-9457-595c-9fa0-7307453ec193', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a6eebb1-0e83-5fcc-9172-ea8910e74b5f', 'ac571028-9457-595c-9fa0-7307453ec193', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8562d174-c95d-56e5-a3a4-0e31883202a2', 'ac571028-9457-595c-9fa0-7307453ec193', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E, in boxes 1-3 on your answer sheet.
1
The speed of technological changes
2
A dependency on technology and computers
3
A deterioration in personal service
A
requires more detailed study by psychologists.
B
means people bave no time to challenge the significance of the new technology.
C
may reduce inventiveness and innovation.
D
suggests computers will take over the workplace.
E
results from increased electronic supervision.

2 ____ A dependency on technology and computers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91921a88-b472-5627-acb0-d45f6aaeaa6e', '1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53f28c78-a8eb-5275-8c44-8c9ae80547d9', '1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e997f51f-e106-5ba9-bdb9-452d80138c45', '1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1574ca1e-3aa1-5965-8d1c-a1c8c86e815e', '1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36d3dda2-8add-515f-8c67-53d30c72357f', '1f0f22db-cbbb-5731-b5b9-23fc9dbfe9ca', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08907bc8-3b59-5479-93aa-3209bed6c39d', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E, in boxes 1-3 on your answer sheet.
1
The speed of technological changes
2
A dependency on technology and computers
3
A deterioration in personal service
A
requires more detailed study by psychologists.
B
means people bave no time to challenge the significance of the new technology.
C
may reduce inventiveness and innovation.
D
suggests computers will take over the workplace.
E
results from increased electronic supervision.

3 ____ A deterioration in personal service$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16280210-e0ff-5839-b7bb-89c925dcd08f', '08907bc8-3b59-5479-93aa-3209bed6c39d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('059db128-febb-5756-a263-511a2066094e', '08907bc8-3b59-5479-93aa-3209bed6c39d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('150c6366-f925-5fc6-9a03-40f95b67a70e', '08907bc8-3b59-5479-93aa-3209bed6c39d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f7143b2-560f-5f4a-873c-71cf14f41e90', '08907bc8-3b59-5479-93aa-3209bed6c39d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfcc2b68-7bb4-5b7b-b51e-f4221bfcb477', '08907bc8-3b59-5479-93aa-3209bed6c39d', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4a71faa0-4a76-5b9e-b6b8-15ee88f152d4', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

4 ____ Technology has placed greater expectations on workers not to make mistakes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71f15c15-41e9-5d11-99f7-7fd419fa56f9', '4a71faa0-4a76-5b9e-b6b8-15ee88f152d4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fff260f3-a987-52e7-a319-e615362d0573', '4a71faa0-4a76-5b9e-b6b8-15ee88f152d4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72501d99-42d1-5207-9222-4a442b933d07', '4a71faa0-4a76-5b9e-b6b8-15ee88f152d4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39d15a26-2684-5b37-80be-46197cd0249d', '4a71faa0-4a76-5b9e-b6b8-15ee88f152d4', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82393ed7-fe11-5092-b2c2-5ee00166bd7c', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

5 ____ People will need time away from technology to reduce the frustrations caused by it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('144fa732-2e2e-5d39-8567-9b10d2319eda', '82393ed7-fe11-5092-b2c2-5ee00166bd7c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4e46a84-bc98-5672-8684-4fd0c3d48915', '82393ed7-fe11-5092-b2c2-5ee00166bd7c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f272906-46f9-5882-bd2d-0670125407b9', '82393ed7-fe11-5092-b2c2-5ee00166bd7c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66b85a6c-ef13-51e4-8df4-dc4bd065628d', '82393ed7-fe11-5092-b2c2-5ee00166bd7c', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fc5af61-a397-5460-934b-958745bce8c9', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

6 ____ Interacting with others at work contributes to creative thinking.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db5a8095-e8f9-5cda-a3d2-efa68aafa8fc', '1fc5af61-a397-5460-934b-958745bce8c9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd3256d7-70d0-5d00-8018-4b95d1d7a5e2', '1fc5af61-a397-5460-934b-958745bce8c9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('209f33df-b8c0-56c4-a297-c921af17410f', '1fc5af61-a397-5460-934b-958745bce8c9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad74bf88-401e-5440-a767-cc8a65719f5d', '1fc5af61-a397-5460-934b-958745bce8c9', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8abe052-c211-5455-bd81-3ac8771a76b8', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

7 ____ The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b931b35f-0505-53b3-be34-0c667f897550', 'a8abe052-c211-5455-bd81-3ac8771a76b8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4626b946-9f55-541d-ae83-b6636131df82', 'a8abe052-c211-5455-bd81-3ac8771a76b8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05c0f6ef-c429-561e-a607-fe900391f975', 'a8abe052-c211-5455-bd81-3ac8771a76b8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e503582d-85e6-5541-8f25-70b19f0c9cc9', 'a8abe052-c211-5455-bd81-3ac8771a76b8', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2388c354-8380-5f6b-99f7-91df65caebf4', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

8 ____ Technology will ultimately increase unemployment for more highly qualified personnel.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71969310-fabb-5901-b6f7-4b318024da66', '2388c354-8380-5f6b-99f7-91df65caebf4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e793696-3fbc-5245-a0ff-d6f9fcb0d7a9', '2388c354-8380-5f6b-99f7-91df65caebf4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96c7b9f7-81e4-5412-b591-95d2dff3d4af', '2388c354-8380-5f6b-99f7-91df65caebf4', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b440237b-f20b-52b5-a217-c714d8ba421a', '2388c354-8380-5f6b-99f7-91df65caebf4', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a7fe898-26f6-58ca-a31d-a52ebc7785d4', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 4-9
Questions 4-9
Look at the following statements (Questions 4-9) and the list of people below.
Match each statement with the correct person or people,
A, B, c
or
D.
Write the correct letter,
A, B, c
or
D,
in boxes 30-35 on your answer sheet.
NB
You may use any letter more than once.
4
Technology has placed greater expectations on workers not to make mistakes.
5
People will need time away from technology to reduce the frustrations caused by it.
6
Interacting with others at work contributes to creative thinking.
7
The psychological effect of working with technology is similar to the anxiety felt after surviving a major ordeal.
8
Technology will ultimately increase unemployment for more highly qualified personnel.
9
More counselling is required to help people cope with the demands of the modern workplace.
List of People
A
Craig Brod
B
Daniel Dennett
C
Joseph Boyett and Henry Conn
D
Philip Nicholson

9 ____ More counselling is required to help people cope with the demands of the modern workplace.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b78b566-6f47-5c9d-aa78-4737f3810bc6', '7a7fe898-26f6-58ca-a31d-a52ebc7785d4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('667249f5-5a8e-58b1-99db-d1924dd0cf1d', '7a7fe898-26f6-58ca-a31d-a52ebc7785d4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1177afb6-e822-502b-9d7c-c7f6cf40b23d', '7a7fe898-26f6-58ca-a31d-a52ebc7785d4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fbd51c5-6b10-58cd-996e-d2f38d57dcaa', '7a7fe898-26f6-58ca-a31d-a52ebc7785d4', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('886c07ac-e6a8-5fab-b4de-ea724eb5104f', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes 10-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Our knowledge of the effects of technology on workers is still limited.
11
An early indicator of technological anxiety is a tendency to adopt machine-like thinking.
12
We have now started to doubt our ability to perform well at work.
13
Top level managers may be more negatively affected by changes electronic workplace than junior workers.
14
Employees who learn to use new technology quickly will get promoted.

10 ____ Our knowledge of the effects of technology on workers is still limited.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7675dc57-1377-5cfa-8737-91fe6a839bbf', '886c07ac-e6a8-5fab-b4de-ea724eb5104f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('732eb9f4-86d9-5185-a8bf-dddd5c117775', '886c07ac-e6a8-5fab-b4de-ea724eb5104f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47b3d16b-e5dd-501b-93f4-f7922d3faf1b', '886c07ac-e6a8-5fab-b4de-ea724eb5104f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f98b2f2-9f87-5711-859a-18b77bce4bbe', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes 10-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Our knowledge of the effects of technology on workers is still limited.
11
An early indicator of technological anxiety is a tendency to adopt machine-like thinking.
12
We have now started to doubt our ability to perform well at work.
13
Top level managers may be more negatively affected by changes electronic workplace than junior workers.
14
Employees who learn to use new technology quickly will get promoted.

11 ____ An early indicator of technological anxiety is a tendency to adopt machine-like thinking.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b14a9319-b9c1-5f7b-b6c6-c00d12cd38e6', '6f98b2f2-9f87-5711-859a-18b77bce4bbe', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cedb9929-fd43-524b-af48-5a393cc41eb3', '6f98b2f2-9f87-5711-859a-18b77bce4bbe', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec9e4930-0554-50d1-8b7e-15f541ef5892', '6f98b2f2-9f87-5711-859a-18b77bce4bbe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0182b6e-0e72-582c-9c79-d5f5747ac667', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes 10-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Our knowledge of the effects of technology on workers is still limited.
11
An early indicator of technological anxiety is a tendency to adopt machine-like thinking.
12
We have now started to doubt our ability to perform well at work.
13
Top level managers may be more negatively affected by changes electronic workplace than junior workers.
14
Employees who learn to use new technology quickly will get promoted.

12 ____ We have now started to doubt our ability to perform well at work.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dd9ebe3-ad3f-5941-9b08-30aafc685044', 'c0182b6e-0e72-582c-9c79-d5f5747ac667', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3f6eee1-a736-530a-8210-9a855a22e923', 'c0182b6e-0e72-582c-9c79-d5f5747ac667', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b551900-c9a8-5067-bf29-05c2813c0738', 'c0182b6e-0e72-582c-9c79-d5f5747ac667', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ebabe241-1186-5258-8707-d7cef5fa9db4', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes 10-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Our knowledge of the effects of technology on workers is still limited.
11
An early indicator of technological anxiety is a tendency to adopt machine-like thinking.
12
We have now started to doubt our ability to perform well at work.
13
Top level managers may be more negatively affected by changes electronic workplace than junior workers.
14
Employees who learn to use new technology quickly will get promoted.

13 ____ Top level managers may be more negatively affected by changes electronic workplace than junior workers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2c1a58b-09cf-514a-b979-b3fa3aef235a', 'ebabe241-1186-5258-8707-d7cef5fa9db4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f0a0239-6a5a-5f2f-9dbf-c6dc31124618', 'ebabe241-1186-5258-8707-d7cef5fa9db4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ce899d2-31b1-5238-8d99-f339d6fbfb71', 'ebabe241-1186-5258-8707-d7cef5fa9db4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f07c843-8d7b-5c85-9c25-d3730f9c69dd', '549c1788-ef7a-5192-8088-d9ee57fa4a17', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes 10-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Our knowledge of the effects of technology on workers is still limited.
11
An early indicator of technological anxiety is a tendency to adopt machine-like thinking.
12
We have now started to doubt our ability to perform well at work.
13
Top level managers may be more negatively affected by changes electronic workplace than junior workers.
14
Employees who learn to use new technology quickly will get promoted.

14 ____ Employees who learn to use new technology quickly will get promoted.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fae304bd-1880-53c1-99f7-c2144d051bfc', '0f07c843-8d7b-5c85-9c25-d3730f9c69dd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed0957c-bb59-5a2c-a717-292744234b7a', '0f07c843-8d7b-5c85-9c25-d3730f9c69dd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95fa4cc6-eb2e-5cf8-8865-f5ccf9bdec69', '0f07c843-8d7b-5c85-9c25-d3730f9c69dd', 3, $md$NOT GIVEN$md$, true);

COMMIT;
