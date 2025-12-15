BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-climate-changers-1212'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-climate-changers-1212';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-climate-changers-1212';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-climate-changers-1212';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d9f1a0cc-ea4a-52c7-a970-b451e9ad597f', 'ielts-reading-the-climate-changers-1212', $t$The Climate Changers$t$, $md$## The Climate Changers

Nguồn:
- Test: https://mini-ielts.com/1212/reading/the-climate-changers
- Solution: https://mini-ielts.com/1212/view-solution/reading/the-climate-changers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2fcd7c03-755c-5e90-9c12-96adead459c3', 'd9f1a0cc-ea4a-52c7-a970-b451e9ad597f', 1, $t$Reading — The Climate Changers$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Climate Changers

The romantic notion that early humans lived in harmony with their environment has taken quite a battering lately. Modem humans may have started eliminating other species right from the start; our ancestors stand accused of wiping out mega fauna – from giant flightless birds in Australia to mammoths in Asia and the ground sloth of North America – as they spread across the planet.

Even so, by around 6,000 years ago there were only about 12 million people on earth – less than a quarter of the current population of Great Britain. That’s a far cry from today’s 6.6 billion, many of us guzzling fossil fuels, churning out greenhouse gases and messing with our planet’s climate like there’s no tomorrow. So it may seem far-fetched to suggest that humans have been causing global warming ever since our ancestors started burning and cutting forests to make way for fields at least 7,000 years ago.

Yet that’s the view of retired climate scientist William Ruddiman, formerly of the University of Virginia, Charlottesville. Ancient farmers were pumping climate-warming carbon dioxide and methane into the atmosphere long before recorded history began , he says. Far from causing catastrophe, however, early farmers halted the planet’s descent into another ice age and kept Earth warm and stable for thousands of years.

Could a few primitive farmers really have changed the climate of the entire globe? If you find this hard to believe, you’re not the only one. Ruddiman’s idea has been hugely controversial ever since he proposed it in 2003. ‘Most new ideas, especially controversial ones, die out pretty fast. It doesn’t take science long to weed them out,’ he says. Yet five years on, his idea is still not dead. On the contrary, he says the latest evidence strengthens his case not proves it correct. ‘It has become clear that natural explanations for the rise in greenhouse gases over the past few thousand years are the ones that are not measuring up, and we can reject them,’he claims.

There is no doubt that the soaring levels of carbon dioxide and other greenhouse gases that we see in the atmosphere today – causing a 0.7° C rise in average global temperature during the 20 th century – are the result of human activities. In the late 1990s, however, Ruddiman started to suspect that our contribution to the global greenhouse began to become significant long before the industrial age began. This was when an ice core drilled at the Vostok station in Antarctica revealed how atmospheric C0 2 and methane levels have changed over the past 400,000 years. Bubbles trapped in the ice provide a record of the ancient atmosphere during the past three interglacials.

What we see is a regular pattern of rises and falls with a period of about 100,000 years, coinciding with the coming and going of ice ages. There are good explanations for these cycles: periodic changes in the planet’s orbit and axis of rotation alter the amount of sunlight reaching the Earth . We are now in one of the relatively brief, warm interglacial periods that follow an ice age.

Within this larger pattern there are regular peaks in methane every 22,000 years that coincide with the times when the Earth’s orbit makes summers in the northern hemisphere warmest. This makes sense, because warm northern summers drive strong tropical monsoons in southern Asia that both encourage the growth of vegetation and cause flooding, during which vegetation rotting in oxygen-poor water will emit methane. Around the Arctic, hot summers thaw wetlands for longer, again promoting both vegetation growth and methane emission.

In recent times, however, this regular pattern has changed. The last methane peak occurred around 11,000 years ago, at about 700 parts per billion (ppb), after which levels began to fall. But instead of continuing to fall to what Ruddiman says should have been a minimum of about 450 ppb today, the atmospheric methane began to climb again 5,000 years ago .

Working with climate modellers Stephen Verves and John Kutzbach, Ruddiman has shown that if the levels of these gases had continued to fall rather than rising when they did, ice sheets would now cover swathes of northern Canada and Siberia. The world would be heading into another ice age.

So why did both methane and C0 2 rise over the past few thousand years? In other words, why has this interglacial period been different from previous ones? Could humans be to blame?

Agriculture emerged around the eastern Mediterranean some 11,000 years ago, then shortly afterwards in China and several thousand years later in the Americas. Farming can release greenhouse gases in various ways: clearing forests liberates lots of stored carbon as the wood rots or is burned, for instance, while flooded rice paddies release methane just as wetlands do.

To find out more about early farming, Ruddiman began to dig around in studies of agricultural history.These revealed that there was a sharp rise in rice cultivation in Asia around 5,000 years ago, with the practice spreading across China and south-east Asia. Here at least was a possible source for the unexpected methane rise.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cde3eb9e-fbc9-598a-8775-70fea724aada', '2fcd7c03-755c-5e90-9c12-96adead459c3', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Choose the correct letter,
A, B, C or D
1.
One of the claims Ruddiman makes is that
A
population growth is responsible for global warming.
B
people have affected the climate for thousands of years.
C
his ideas are not in the least bit controversial.
D
so far scientists have been wrong about global warming.
Locate
2.
What information did the research at Vostok reveal for the first time?
A
that methane levels stabilised about 11,000 years ago
B
that Antarctic ice contains methane bubbles
C
that the methane levels increased about 5,000 years ago
D
that we are now living in a warm interglacial period
Locate
3.
The climate changers of the title are
A
modern humans.
B
climate modellers.
C
primitive farmers.
D
natural causes.
Locate

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a6ad4bfa-d13a-5ee6-b5f7-02e119ad0a1a', '2fcd7c03-755c-5e90-9c12-96adead459c3', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Choose the correct letter,
A, B, C or D
1.
One of the claims Ruddiman makes is that
A
population growth is responsible for global warming.
B
people have affected the climate for thousands of years.
C
his ideas are not in the least bit controversial.
D
so far scientists have been wrong about global warming.
Locate
2.
What information did the research at Vostok reveal for the first time?
A
that methane levels stabilised about 11,000 years ago
B
that Antarctic ice contains methane bubbles
C
that the methane levels increased about 5,000 years ago
D
that we are now living in a warm interglacial period
Locate
3.
The climate changers of the title are
A
modern humans.
B
climate modellers.
C
primitive farmers.
D
natural causes.
Locate

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('223ec909-f557-56e8-b4db-2455212f3529', '2fcd7c03-755c-5e90-9c12-96adead459c3', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Choose the correct letter,
A, B, C or D
1.
One of the claims Ruddiman makes is that
A
population growth is responsible for global warming.
B
people have affected the climate for thousands of years.
C
his ideas are not in the least bit controversial.
D
so far scientists have been wrong about global warming.
Locate
2.
What information did the research at Vostok reveal for the first time?
A
that methane levels stabilised about 11,000 years ago
B
that Antarctic ice contains methane bubbles
C
that the methane levels increased about 5,000 years ago
D
that we are now living in a warm interglacial period
Locate
3.
The climate changers of the title are
A
modern humans.
B
climate modellers.
C
primitive farmers.
D
natural causes.
Locate

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bc5a7307-0840-5a5f-89e6-4c2f9573139d', '2fcd7c03-755c-5e90-9c12-96adead459c3', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 4-8
Questions 4-8
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
To many people the controversial idea that our
4
Locate
were responsible for global warming appears
5
Locate
. Yet Ruddiman believes that high levels of carbon dioxide and methane – both
6
Locate
, or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to
7
Locate
. However, Ruddiman claims that this
had a positive effect, as it may well have saved us from another
8
Locate
.

To many people the controversial idea that our 4 ____ Locate were responsible for global warming appears 5 ____ Locate . Yet Ruddiman believes that high levels of carbon dioxide and methane – both 6 ____ Locate , or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to 7 ____ Locate . However, Ruddiman claims that this had a positive effect, as it may well have saved us from another 8 ____ Locate .$md$, NULL, ARRAY['.*ancestors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2ee765fb-16c6-50d8-9506-60965655d1b4', '2fcd7c03-755c-5e90-9c12-96adead459c3', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 4-8
Questions 4-8
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
To many people the controversial idea that our
4
Locate
were responsible for global warming appears
5
Locate
. Yet Ruddiman believes that high levels of carbon dioxide and methane – both
6
Locate
, or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to
7
Locate
. However, Ruddiman claims that this
had a positive effect, as it may well have saved us from another
8
Locate
.

To many people the controversial idea that our 4 ____ Locate were responsible for global warming appears 5 ____ Locate . Yet Ruddiman believes that high levels of carbon dioxide and methane – both 6 ____ Locate , or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to 7 ____ Locate . However, Ruddiman claims that this had a positive effect, as it may well have saved us from another 8 ____ Locate .$md$, NULL, ARRAY['.*ancestors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bf453d84-ce93-50a9-aaa4-7e2c8cc8ea08', '2fcd7c03-755c-5e90-9c12-96adead459c3', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 4-8
Questions 4-8
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
To many people the controversial idea that our
4
Locate
were responsible for global warming appears
5
Locate
. Yet Ruddiman believes that high levels of carbon dioxide and methane – both
6
Locate
, or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to
7
Locate
. However, Ruddiman claims that this
had a positive effect, as it may well have saved us from another
8
Locate
.

To many people the controversial idea that our 4 ____ Locate were responsible for global warming appears 5 ____ Locate . Yet Ruddiman believes that high levels of carbon dioxide and methane – both 6 ____ Locate , or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to 7 ____ Locate . However, Ruddiman claims that this had a positive effect, as it may well have saved us from another 8 ____ Locate .$md$, NULL, ARRAY['.*ancestors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5e6fcf89-70d1-5e4b-abbc-63db81e8a395', '2fcd7c03-755c-5e90-9c12-96adead459c3', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 4-8
Questions 4-8
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
To many people the controversial idea that our
4
Locate
were responsible for global warming appears
5
Locate
. Yet Ruddiman believes that high levels of carbon dioxide and methane – both
6
Locate
, or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to
7
Locate
. However, Ruddiman claims that this
had a positive effect, as it may well have saved us from another
8
Locate
.

To many people the controversial idea that our 4 ____ Locate were responsible for global warming appears 5 ____ Locate . Yet Ruddiman believes that high levels of carbon dioxide and methane – both 6 ____ Locate , or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to 7 ____ Locate . However, Ruddiman claims that this had a positive effect, as it may well have saved us from another 8 ____ Locate .$md$, NULL, ARRAY['.*ancestors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4e9a9d0f-f9dd-598f-828b-6bb9c605cd72', '2fcd7c03-755c-5e90-9c12-96adead459c3', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 4-8
Questions 4-8
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
To many people the controversial idea that our
4
Locate
were responsible for global warming appears
5
Locate
. Yet Ruddiman believes that high levels of carbon dioxide and methane – both
6
Locate
, or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to
7
Locate
. However, Ruddiman claims that this
had a positive effect, as it may well have saved us from another
8
Locate
.

To many people the controversial idea that our 4 ____ Locate were responsible for global warming appears 5 ____ Locate . Yet Ruddiman believes that high levels of carbon dioxide and methane – both 6 ____ Locate , or greenhouse, gases – were being released into the Earth’s atmosphere in times prior to 7 ____ Locate . However, Ruddiman claims that this had a positive effect, as it may well have saved us from another 8 ____ Locate .$md$, NULL, ARRAY['.*ancestors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79f84cf9-b1b7-5c64-804b-d43195bc45e2', '2fcd7c03-755c-5e90-9c12-96adead459c3', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

9 ____ Some mega fauna have been eliminated by humans in the past 100 years. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bb95258-c7c3-5639-90a2-6e0b43d342e9', '79f84cf9-b1b7-5c64-804b-d43195bc45e2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc41c140-d8e9-551e-b398-29fb75a2e90f', '79f84cf9-b1b7-5c64-804b-d43195bc45e2', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4a27b52-3ae2-5fc3-9a6f-8543b18a0727', '79f84cf9-b1b7-5c64-804b-d43195bc45e2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4dd9621-f3b7-5c54-af55-ba17ce46daa8', '2fcd7c03-755c-5e90-9c12-96adead459c3', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

10 ____ Agriculture is considered a primary cause of global warming today. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5104f874-a269-57b4-b70c-4738c94c5257', 'a4dd9621-f3b7-5c54-af55-ba17ce46daa8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61efdcc0-4d3d-54c6-a189-6e6ccac95648', 'a4dd9621-f3b7-5c54-af55-ba17ce46daa8', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a3cfe6c-7029-58f7-9bcd-a52ade10748b', 'a4dd9621-f3b7-5c54-af55-ba17ce46daa8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('371f1dcf-8b7a-57c3-94d0-7ffb0ed20224', '2fcd7c03-755c-5e90-9c12-96adead459c3', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

11 ____ Ruddimans idea caused a great deal of argument among scientists. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbc103eb-2c97-547e-a173-3af00f96cc46', '371f1dcf-8b7a-57c3-94d0-7ffb0ed20224', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('522563ee-b2cf-51d2-892a-6b325ef0c03a', '371f1dcf-8b7a-57c3-94d0-7ffb0ed20224', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e16bbe1-5be8-5324-ad6a-0b88c6a3e981', '371f1dcf-8b7a-57c3-94d0-7ffb0ed20224', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0e04e29e-dd0e-56b3-a1d9-fd320ebe30ea', '2fcd7c03-755c-5e90-9c12-96adead459c3', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

12 ____ New scientific evidence proves for certain that Ruddimans theory is correct. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('051cbcc0-10b0-536c-8c44-704afaf1bde9', '0e04e29e-dd0e-56b3-a1d9-fd320ebe30ea', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ed42ad1-21a8-527d-af5d-6af6eb88bee3', '0e04e29e-dd0e-56b3-a1d9-fd320ebe30ea', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea11b93f-81d8-5310-a2de-866555b38b03', '0e04e29e-dd0e-56b3-a1d9-fd320ebe30ea', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a711632-c910-5740-914f-bd23796eaf93', '2fcd7c03-755c-5e90-9c12-96adead459c3', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

13 ____ The 20 th century has seen the greatest ever increase in global temperatures.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de74cbe7-24f1-5bac-9420-27f96808ca5d', '1a711632-c910-5740-914f-bd23796eaf93', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50c9e784-6ca5-5551-b287-30d9f6c6ed2d', '1a711632-c910-5740-914f-bd23796eaf93', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6be1a41-1b96-5266-816a-61fbf5569a1c', '1a711632-c910-5740-914f-bd23796eaf93', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a7ec6d3-ac4a-5a22-ab41-2c5c53eb07ca', '2fcd7c03-755c-5e90-9c12-96adead459c3', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Do the following statements agree with the information given in Reading Passage?
In boxes
9-14
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if the there is no information on this
9
Some mega fauna have been eliminated by humans in the past 100 years.
Locate
10
Agriculture is considered a primary cause of global warming today.
Locate
11
Ruddimans idea caused a great deal of argument among scientists.
Locate
12
New scientific evidence proves for certain that Ruddimans theory is correct.
Locate
13
The 20
th
century has seen the greatest ever increase in global temperatures.
14
Changes in the Earths orbit can affect global temperatures.
Locate

14 ____ Changes in the Earths orbit can affect global temperatures. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f1fb622-dd7f-5eca-b93b-a82a2d5ce122', '6a7ec6d3-ac4a-5a22-ab41-2c5c53eb07ca', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('417adbfd-5a53-5fb9-9587-2f57969651c8', '6a7ec6d3-ac4a-5a22-ab41-2c5c53eb07ca', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ba0f576-515b-5799-8222-4f01075e3cc2', '6a7ec6d3-ac4a-5a22-ab41-2c5c53eb07ca', 3, $md$NOT GIVEN$md$, false);

COMMIT;
