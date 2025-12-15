BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-internal-and-external-marketing-1282'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-internal-and-external-marketing-1282';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-internal-and-external-marketing-1282';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-internal-and-external-marketing-1282';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6c3ece67-fd6b-5894-98bb-8014f03e652a', 'ielts-reading-internal-and-external-marketing-1282', $t$Internal and External Marketing$t$, $md$## Internal and External Marketing

Nguồn:
- Test: https://mini-ielts.com/1282/reading/internal-and-external-marketing
- Solution: https://mini-ielts.com/1282/view-solution/reading/internal-and-external-marketing$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b69577ba-03e8-56f2-b997-4f26705a1c2f', '6c3ece67-fd6b-5894-98bb-8014f03e652a', 1, $t$Reading — Internal and External Marketing$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Internal and External Marketing

A

Employees need to hear the same messages that you send out to the marketplace. At most companies, however, internal and external communications are often mismatched. This can be very confusing, and it threatens employees’ perceptions of the company’s integrity: They are told one thing by management but observe that a different message is being sent to the public. One health insurance company, for instance, advertised that the welfare of patients was the company’s number one priority, while employees were told that their main goal was to increase the value of their stock options through cost reductions. And one major financial services institution told customers that it was making a major shift in focus from being a financial retailer to a financial adviser, but, a year later, research showed that the customer experience with the company had not changed. It turned out that company leaders had not made an effort to sell the change internally, so employees were still churning out transactions and hadn’t changed their behavior to match their new adviser role.

B

Enabling employees to deliver on customer expectations is important, of course, but it’s not the only reason a company needs to match internal and external messages. Another reason is to help push the company to achieve goals that might otherwise be out of reach. In 1997, when IBM launched its e-business campaign (which is widely credited for turning around the company’s image), it chose to ignore research that suggested consumers were unprepared to embrace IBM as a leader in e-business. Although to the outside world this looked like an external marketing effort, IBM was also using the campaign to align employees around the idea of the Internet as the future of technology. The internal campaign changed the way employees thought about everything they did, from how they named products to how they organized staff to how they approached selling. The campaign was successful largely because it gave employees a sense of direction and purpose, which in turn restored their confidence in IBM’s ability to predict the future and lead the technology industry. Today, research shows that people are four times more likely to associate the term “e-business” with IBM than with its nearest competitor, Microsoft.

C

The type of “two-way branding” that IBM did so successfully strengthens both sides of the equation. Internal marketing becomes stronger because it can draw on the same “big idea” as advertising. Consumer marketing becomes stronger because the messages are developed based on employees’ behavior and attitudes, as well as on the company’s strengths and capabilities – indeed, the themes are drawn from the company’s very soul. This process can result in a more distinct advertising idea because marketers are more likely to create a message that’s unique to the company.

D

Perhaps even more important, by taking employees into account, a company can avoid creating a message that doesn’t resonate with staff or, worse, one that builds resentment. In 1996, United Airlines shelved its “Come Fly the Friendly Skies” slogan when presented with a survey that revealed the depth of customer resentment toward the airline industry. In an effort to own up to the industry’s shortcomings, United launched a new campaign, “Rising,” in which it sought to differentiate itself by acknowledging poor service and promising incremental improvements such as better meals. While this was a logical premise for the campaign given the tenor of the times, a campaign focusing on customers’ distaste for flying was deeply discouraging to the staff. Employee resentment ultimately made it impossible for United to deliver the improvements it was promising, which in turn undermined the “Rising” pledge. Three years later, United decided employee opposition was undermining its success and pulled the campaign. It has since moved to a more inclusive brand message with the line “United,” which both audiences can embrace. Here, a fundamental principle of advertising – find and address a customer concern – failed United because it did not consider the internal market.

E

When it comes to execution, the most common and effective way to link internal and external marketing campaigns is to create external advertising that targets both audiences. IBM used this tactic very effectively when it launched its e-business campaign. It took out an eight-page ad in the Wall Street Journal declaring its new vision, a message directed at both customers and internal stakeholders . This is an expensive way to capture attention, but if used sparingly, it is the most powerful form of communication; in fact, you need do it only once for everyone in the company to read it. There’s a symbolic advantage as well. Such a tactic signals that the company is taking its pledge very seriously; it also signals transparency – the same message going out to both audiences.

F

Advertising isn’t the only way to link internal and external marketing. At Nike, a number of senior executives now hold the additional title of “Corporate Storyteller.” They deliberately avoid stories of financial successes and concentrate on parables of “just doing it,” reflecting and reinforcing the company’s ad campaigns. One tale, for example, recalls how legendary coach and Nike co-founder Bill Bowerman, in an effort to build a better shoe for his team, poured rubber into the family waffle iron, giving birth to the prototype of Nike’s famous Waffle Sole. By talking about such inventive moves, the company hopes to keep the spirit of innovation that characterizes its ad campaigns alive and well within the company.

G

But while their messages must be aligned, companies must also keep external promises a little ahead of internal realities. Such promises provide incentives for employees and give them something to live up to. In the 1980s, Ford turned “ Quality is Job! ” from an internal rallying cry into a consumer slogan in response to the threat from cheaper, more reliable Japanese cars. It did so before the claim was fully justified, but by placing it in the public arena, it gave employees an incentive to match the Japanese. If the promise is pushed too far ahead, however, it loses credibility. When a beleaguered British Rail launched a campaign announcing service improvement under the banner “We’re Getting There,” it did so prematurely. By drawing attention to the gap between the promise and the reality, it prompted destructive press coverage. This, in turn, demoralized staff, who had been legitimately proud of the service advances they had made.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 1, 'CLASSIFICATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

1 ____ One health insurance Company$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42b1ee38-8871-5f80-9cb3-66ee2091c1f1', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb607537-339d-532a-b1d6-293f10b2cc10', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a8b6dce-eb05-591b-be50-4397900da082', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d0d42e3-c70e-50ba-ba7c-552514b7fdd8', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b0c7a91-2c2c-500f-b38f-424a6689dabd', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c710fc9f-9631-57b7-8ad6-e322472fb410', '2cc2137c-c91e-5cb5-9f80-7fe9ebce6d5a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28601cbb-4496-5200-8e45-50b1c5b65080', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 2, 'CLASSIFICATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

2 ____ British Rail$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('033a3c6e-e4ed-5df1-aa64-4f20917dd42a', '28601cbb-4496-5200-8e45-50b1c5b65080', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63c420dd-b030-5b1d-a938-48d200199fc2', '28601cbb-4496-5200-8e45-50b1c5b65080', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd9c2c47-063f-5697-bcd5-6ff53ec06d72', '28601cbb-4496-5200-8e45-50b1c5b65080', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e22c0ef3-00a2-530d-9659-f96668729442', '28601cbb-4496-5200-8e45-50b1c5b65080', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef4bb385-f26b-5179-9992-b7bfe6a23e72', '28601cbb-4496-5200-8e45-50b1c5b65080', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('761f7722-5809-5650-b853-9e693a615003', '28601cbb-4496-5200-8e45-50b1c5b65080', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97825fd6-63bb-58e7-b071-fd726bf3f7f8', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 3, 'CLASSIFICATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

3 ____ IBM$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c527df88-47c3-593e-8444-b2b20093d98a', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a208439f-4c11-54a2-9a07-3068d32a5aa1', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a80613c0-4d8d-5ff5-96fc-ac49009dc1ce', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e03c1ff-31fd-50d5-9111-55e64f82f273', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be4d4bff-8b40-5020-abdb-f562081ff8a2', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f1e5bb7-d336-51a3-9c0c-46575b7e6eba', '97825fd6-63bb-58e7-b071-fd726bf3f7f8', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c6264f85-caa0-5335-8f93-9034ff4976a0', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 4, 'CLASSIFICATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

4 ____ United Airline$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e6f46fe-bee3-593a-96e1-9c14695ef5ee', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ece214ea-5b96-5920-ab1e-c3d5a63a0f73', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e48c2b0e-35bb-5297-a2bd-c10c222cf634', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6998417-a4f6-5fa1-8413-e0f0a577cf2c', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cb3bd7d-7774-58ae-8a30-b0d63425f460', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d81f8c9b-24da-536b-ad93-f270f9c742b2', 'c6264f85-caa0-5335-8f93-9034ff4976a0', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('637c0615-383b-58ce-bee3-474c71bdf960', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

5 ____ A financial service company$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dc71c59-0172-5bb5-baea-e949892f5a6d', '637c0615-383b-58ce-bee3-474c71bdf960', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('996b053d-ca1b-5e9e-90ae-b9084d74b3ce', '637c0615-383b-58ce-bee3-474c71bdf960', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1d29ee1-53b4-58a8-9291-8c003ce248d9', '637c0615-383b-58ce-bee3-474c71bdf960', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d373fec-cab3-53bc-97e2-b41a75d166d1', '637c0615-383b-58ce-bee3-474c71bdf960', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39595de6-304b-583a-a6b0-1678641c471f', '637c0615-383b-58ce-bee3-474c71bdf960', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2e756da-666e-557b-b5f1-f285e2e15902', '637c0615-383b-58ce-bee3-474c71bdf960', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8ddf070-6451-54f2-9d57-143f5b2ad3b8', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 6, 'CLASSIFICATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

6 ____ A Shoemaking company (Nike)$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('141f3eec-f127-5253-b96e-b55ba1ba58bd', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ad9a38b-7f51-5e86-856c-de30ca01e926', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9159b7bc-14b2-5ee3-b285-24dae64e9e05', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68240049-7737-5a1e-a6c1-428637596b59', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e43f88e-e277-51c8-ac4c-e8fc19f56a60', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e9314d3-1288-53a4-b705-57099e8e14e3', 'd8ddf070-6451-54f2-9d57-143f5b2ad3b8', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8024bcd8-daa2-5b8e-96ce-707d5352935b', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 7, 'CLASSIFICATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Use the information in the passage to match the company (listed
A-F
) with correct category or deeds below.
Write the appropriate letters
A-F
in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once
A
legendary anecdote inspire employee successfully
B
advertisement campaign inspire employees and ensure a leading role in business
C
improper ads campaign brings negative effect
D
internal and external announcement are different
E
campaign brings positive and realistic expectation internally
F
a bad slogan that failed both to win support internally and raise standard to its poor service
1
One health insurance Company
2
British Rail
3
IBM
4
United Airline
5
A financial service company
6
A Shoemaking company (Nike)
7
The Company of (Ford)

7 ____ The Company of (Ford)$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e3762c0-3cb3-5a86-8aad-bf1a2edff414', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c292909-46ab-5979-9340-223f8526b2c7', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9883783a-6326-5dab-8dc9-fa2447d8d5f8', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bffea6c-08c1-5856-b0ef-215334825803', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a119f6b-1ae6-593f-88e2-2f876373e01c', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('375b2ec4-ca4d-5749-8122-f5551c50ef3a', '8024bcd8-daa2-5b8e-96ce-707d5352935b', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b59a2cd0-7a81-5d58-a7d4-e0c59d18d637', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
35-38
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Employers in almost all companies successfully make their employees fully understand the outside campaign.
9
Currently IBM is more prominent in the area of E-business
10
United Airline finally gave up an ads slogan due to a survey in 1996.
11
Nike had improved company performance through telling employees legendary corporation stories.

8 ____ Employers in almost all companies successfully make their employees fully understand the outside campaign.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab7eda65-8da4-5d41-aab6-4848a5ab0630', 'b59a2cd0-7a81-5d58-a7d4-e0c59d18d637', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d29a5e5f-03a1-5b86-9fa3-9d2ba5967cbd', 'b59a2cd0-7a81-5d58-a7d4-e0c59d18d637', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7212974c-b4be-516d-a204-f61a5c85aa68', 'b59a2cd0-7a81-5d58-a7d4-e0c59d18d637', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('539720dd-abb7-593a-9d00-5e19af8f2f71', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
35-38
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Employers in almost all companies successfully make their employees fully understand the outside campaign.
9
Currently IBM is more prominent in the area of E-business
10
United Airline finally gave up an ads slogan due to a survey in 1996.
11
Nike had improved company performance through telling employees legendary corporation stories.

9 ____ Currently IBM is more prominent in the area of E-business$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('433087e0-0697-56b6-878a-c69a0dfc213a', '539720dd-abb7-593a-9d00-5e19af8f2f71', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e557be93-7075-50e3-ab43-e4593684de54', '539720dd-abb7-593a-9d00-5e19af8f2f71', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0aa129f5-c78b-5fdd-aa4f-a1a16da34e30', '539720dd-abb7-593a-9d00-5e19af8f2f71', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('10294af6-19c1-5c61-9b76-e6a2b7af400d', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
35-38
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Employers in almost all companies successfully make their employees fully understand the outside campaign.
9
Currently IBM is more prominent in the area of E-business
10
United Airline finally gave up an ads slogan due to a survey in 1996.
11
Nike had improved company performance through telling employees legendary corporation stories.

10 ____ United Airline finally gave up an ads slogan due to a survey in 1996.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b868b3d1-fca8-5cb6-8ad6-e01f5e161d5e', '10294af6-19c1-5c61-9b76-e6a2b7af400d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7f470d6-f615-56f9-ab87-ca6a3a71335a', '10294af6-19c1-5c61-9b76-e6a2b7af400d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4ff69a2-55fb-5eda-8022-849bf4e682ed', '10294af6-19c1-5c61-9b76-e6a2b7af400d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1296b1a-210e-59c3-b6a8-d537154765cb', 'b69577ba-03e8-56f2-b997-4f26705a1c2f', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
35-38
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Employers in almost all companies successfully make their employees fully understand the outside campaign.
9
Currently IBM is more prominent in the area of E-business
10
United Airline finally gave up an ads slogan due to a survey in 1996.
11
Nike had improved company performance through telling employees legendary corporation stories.

11 ____ Nike had improved company performance through telling employees legendary corporation stories.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ae0441c-8855-5625-8185-2a7993807d53', 'e1296b1a-210e-59c3-b6a8-d537154765cb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cfc9952-201b-5837-abbc-186102c25048', 'e1296b1a-210e-59c3-b6a8-d537154765cb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0718c610-83ce-5027-94bc-95d35fae2119', 'e1296b1a-210e-59c3-b6a8-d537154765cb', 3, $md$NOT GIVEN$md$, true);

COMMIT;
