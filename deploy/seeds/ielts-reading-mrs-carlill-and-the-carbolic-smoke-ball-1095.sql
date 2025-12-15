BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball-1095'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball-1095';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball-1095';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball-1095';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d52fea65-1663-559a-a6db-a5b4ceec957d', 'ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball-1095', $t$Mrs. Carlill and the Carbolic Smoke Ball$t$, $md$## Mrs. Carlill and the Carbolic Smoke Ball

Nguồn:
- Test: https://mini-ielts.com/1095/reading/mrs-carlill-and-the-carbolic-smoke-ball
- Solution: https://mini-ielts.com/1095/view-solution/reading/mrs-carlill-and-the-carbolic-smoke-ball$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('eb4d4ecb-15d2-599b-93e3-be9316e72468', 'd52fea65-1663-559a-a6db-a5b4ceec957d', 1, $t$Reading — Mrs. Carlill and the Carbolic Smoke Ball$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Mrs. Carlill and the Carbolic Smoke Ball

On 14 January 1892, Queen Victoria’s grandson Prince Albert Victor, second in line to the British throne, died from flu. He had succumbed to the third and most lethal wave of the Russian flu pandemic sweeping the world. The nation was shocked. The people mourned. Albert was relegated to a footnote in history.

Three days later, London housewife Louisa Carlill went down with flu. She was shocked. For two months, she had inhaled thrice daily from a carbolic smoke ball, a preventive measure guaranteed to fend off flu - if you believed the advert. Which she did. And why shouldn’t she when the Carbolic Smoke Ball Company had promised to cough up £100 for any customer who fell ill? Unlike Albert, Louisa recovered, claimed her £100 and set in train events that would win her lasting fame.

It started in the spring of 1889. The first reports of a flu epidemic came from Russia. By the end of the year, the world was in the grip of the first truly global flu pandemic. The disease came in waves, once a year for the next four years, and each worse than the last.

Whole cities came to a standstill. London was especially hard-hit. As the flu reached each annual peak, normal life stopped. The postal service ground to a halt, trains stopped running, banks closed. Even courts stopped sitting for lack of judges. At the height of the third wave in 1892, 200 people were buried every day at just one London cemetery. This flu was far more lethal than previ­ous epidemics, and those who recovered were left weak, depressed, and often unfit for work. It was a picture repeated across the continent.

Accurate figures for the number of the sick and dead were few and far between but Paris, Berlin and Vienna all reported a huge upsurge in deaths. The news­papers took an intense interest in the disease, not just because of the scale of it but because of who it attacked. Most epidemics carried off the poor and weak, the old and frail. This flu was cutting as great a swathe through the upper classes, dealing death to the rich and famous, and the young and fit.

The newspaper-reading public was fed a daily diet of celebrity victims. The flu had worked its way through the Russian imperial family and invaded the royal palaces of Europe. It carried off the Dowager Empress of Germany and the second son of the king of Italy, as well as England’s future king. Aristocrats and politicians, poets and opera singers, bishops and cardinals - none escaped the attentions of the Russian flu.

The public grew increasingly fearful. The press might have been overdoing the doom and gloom, but their hysterical coverage had exposed one terrible fact.

The medical profession had no answer to the disease. This flu, which might ft not even have begun in Russia, was a mystery. What caused it and how did it spread? No one could agree on anything.

By now, the theory that micro-organisms caused disease was gaining ground, but no one had identified an organism responsible for flu (and wouldn’t until 1933). In the absence of a germ, many clung to the old idea of bad airs, or mi­asmas, possibly stirred by some great physical force - earthquakes, perhaps, or electrical phenomena in the upper atmosphere, even a passing comet.

Doctors advised people to eat well avoiding “unnecessary assemblies”, and if they were really worried, to stuff cotton wool up their nostrils. If they fell ill, they should rest, keep warm and eat a nourishing diet of “milk, eggs and farinaceous puddings”. Alcohol figured prominently among the prescriptions: one eminent English doctor suggested champagne, although he conceded “brandy M in considerable quantities has sometimes been given with manifest advantages”. French doctors prescribed warm alcoholic drinks, arguing that they never saw an alcoholic with flu. Their prescription had immediate results: over a three-day period, 1,200 of the 1,500 drunks picked up on the streets of Paris claimed they were following doctor’s orders.

Some doctors gave drugs to ease symptoms - quinine for fever, salicin for head­ache, heroin for an “incessant cough”. But nothing in the pharmacy remotely resembled a cure. Not surprisingly, people looked elsewhere for help. Hoping to cash in while the pandemic lasted, purveyors of patent medicines competed for the public’s custom with ever more outrageous advertisements. One of the most successful was the Carbolic Smoke Ball Company.

The carbolic smoke ball was a hollow rubber ball , 5 centimetres across, with a nozzle covered by gauze . Inside was a powder treated with carbolic acid, or phenol. The idea was to clutch it close to the nose and squeeze gently, inhaling deeply from the emerging cloud of pungent powder. This, the company claimed, would disinfect the mucous membranes, curing any condition related to “taking cold”. In the summer of 1890, sales were steady at 300 smoke balls a month. In January 1891, the figure skyrocketed to 1,500.

Eager to exploit the public’s mounting panic, the Carbolic Smoke Ball Company made increasingly extravagant claims. Oh 13 November 1892, its latest advert in the Pall Mall Gazette caught the eye of south London housewife Louisa Carlill. “Carbolic Smoke Ball,” it declared, “will positively cure colds, coughs, asthma, bronchitis, hoarseness, influenza, croup, whooping cough ...”. And the list went on. But it was the next part Mrs. Carlill found compelling. “A £100 reward will be paid by the Carbolic Smoke Ball Company to any person who contracts the increasing epidemic influenza, colds or any disease caused by taking cold, after having used the carbolic smoke ball according to the printed directions supplied with each ball. £1,000 is deposited with the Alliance bank, Regent Street, showing our sincerity in the matter.”

Mrs. Carlill hurried off to buy a smoke ball, price 10 shillings. After carefully reading the instructions, she diligently dosed herself thrice daily until 17 Janu­ary - when she fell ill.

On 20 January, Louisa’s husband wrote to the Carbolic Smoke Ball Company . Unfortunately for them, Mr. Carlill happened to be a solicitor. His wife, he wrote, had seen their advert and bought a smoke ball on the strength of it. She had followed the instructions to the letter, and yet now - as their doctor could confirm - she had flu.

There was no reply . But £100 was not a sum to be sneezed at. Mr. Carlill per­sisted. The company resisted. Louisa recovered and sued . In June, Mr. Justice Hawkins found in Mrs. Carlill’s favour. The company’s main defence was that adverts were mere “puffery” and only an idiot would believe such extravagant claims. Judge Hawkins pointed out that adverts were not aimed at the wise and thoughtful, but at the credulous and weak . A vendor who made a promise “must not be surprised if occasionally he is held to his promise”.

Carbolic appealed. In December, three lord justices considered the case. Carbolic’s lawyers tried several lines of defence. But in the end, the case came down to a single matter: not whether the remedy was useless, or whether Carbolic had committed fraud, but whether its advert constituted a contract - which the company had broken. A contract required agreement between two parties, argued Carbolic’s lawyers. What agreement had Mrs. Carlill made with them?

There were times, the judges decided, when a contract could be one-sided. The advert had made a very specific offer to purchasers: protection from flu or £100. By using the smoke ball as instructed, Mrs. Carlill had accepted that offer. The company might just have wriggled out of if if it hadn’t added the bit about the £1,000 deposit. That, said the judges, gave buyers reason to believe Carbolic meant what it said. “ It seems to me that if a person chooses to make extrava­gant promises of this kind, he probably does so because it pays him to make them , and, if he has made them, the extravagance of the promises is no reason in law why he should not be bound by them,” pronounced Lord Justice Bowen .

Louisa got her £100. The case established the principle of the unilateral and is frequently cited today .$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ed17791-5941-5816-a01a-68fe86612ca0', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cities rather than rural areas were badly affected by the pandemic flu.
2
At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses.
Locate
3
People used to believe flu was caused by miasmas.
Locate
4
Flu prescriptions often contained harmful ingredients.

1 ____ Cities rather than rural areas were badly affected by the pandemic flu. 2 ____ At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses. Locate 3 ____ People used to believe flu was caused by miasmas. Locate 4 ____ Flu prescriptions often contained harmful ingredients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b138b06e-6d7d-58f5-a223-79f1c937ddc8', '5ed17791-5941-5816-a01a-68fe86612ca0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0b8c121-e508-565d-abda-ae9af902af1f', '5ed17791-5941-5816-a01a-68fe86612ca0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a314c4e-5d9f-5ab0-b879-4dce9fe9a48c', '5ed17791-5941-5816-a01a-68fe86612ca0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8ec64060-d67a-58fc-8733-53cb2d7b21d9', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cities rather than rural areas were badly affected by the pandemic flu.
2
At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses.
Locate
3
People used to believe flu was caused by miasmas.
Locate
4
Flu prescriptions often contained harmful ingredients.

1 ____ Cities rather than rural areas were badly affected by the pandemic flu. 2 ____ At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses. Locate 3 ____ People used to believe flu was caused by miasmas. Locate 4 ____ Flu prescriptions often contained harmful ingredients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd847ef1-f752-5e89-96b8-d9a3cae13818', '8ec64060-d67a-58fc-8733-53cb2d7b21d9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a26d5171-1ace-5467-a872-a7c922319853', '8ec64060-d67a-58fc-8733-53cb2d7b21d9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14a20e85-e8bb-5202-8039-5e10f036bc24', '8ec64060-d67a-58fc-8733-53cb2d7b21d9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6615e8a0-2cf6-5bda-8a3c-6173d6d7a8a2', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cities rather than rural areas were badly affected by the pandemic flu.
2
At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses.
Locate
3
People used to believe flu was caused by miasmas.
Locate
4
Flu prescriptions often contained harmful ingredients.

1 ____ Cities rather than rural areas were badly affected by the pandemic flu. 2 ____ At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses. Locate 3 ____ People used to believe flu was caused by miasmas. Locate 4 ____ Flu prescriptions often contained harmful ingredients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de737d52-e1e0-5825-a482-70b639c3c04a', '6615e8a0-2cf6-5bda-8a3c-6173d6d7a8a2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fea497c5-5368-5527-a2ef-2d85ea4cd99d', '6615e8a0-2cf6-5bda-8a3c-6173d6d7a8a2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f059e25f-5f2a-52a0-87cc-da0a9f918774', '6615e8a0-2cf6-5bda-8a3c-6173d6d7a8a2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e0f5adc-c680-5b1f-9573-2911e98aac79', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cities rather than rural areas were badly affected by the pandemic flu.
2
At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses.
Locate
3
People used to believe flu was caused by miasmas.
Locate
4
Flu prescriptions often contained harmful ingredients.

1 ____ Cities rather than rural areas were badly affected by the pandemic flu. 2 ____ At the time of the flu pandemic, people didn’t know the link between micro-organisms and illnesses. Locate 3 ____ People used to believe flu was caused by miasmas. Locate 4 ____ Flu prescriptions often contained harmful ingredients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dce87c94-c1b5-5e7f-9b6d-faadf8c58027', '2e0f5adc-c680-5b1f-9573-2911e98aac79', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26405627-1cc7-546e-abb9-66efa11ca7a6', '2e0f5adc-c680-5b1f-9573-2911e98aac79', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19979a8b-60af-5781-bca7-3c7d049d5fbf', '2e0f5adc-c680-5b1f-9573-2911e98aac79', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e36a39bc-8170-51d9-b92a-5d24640a5510', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the diagram below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

5 ____ Locate 6 ____ Locate 7 ____ Locate 8 ____ Locate$md$, NULL, ARRAY['.*gauze.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('db2746a6-fe4f-5132-8584-5f49c02dedbf', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the diagram below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

5 ____ Locate 6 ____ Locate 7 ____ Locate 8 ____ Locate$md$, NULL, ARRAY['.*gauze.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('44dd2c58-211e-5422-bf9b-91f30bf6182f', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the diagram below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

5 ____ Locate 6 ____ Locate 7 ____ Locate 8 ____ Locate$md$, NULL, ARRAY['.*gauze.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5b0750c6-3057-5e87-8b56-6c1064e604e5', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the diagram below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

5 ____ Locate 6 ____ Locate 7 ____ Locate 8 ____ Locate$md$, NULL, ARRAY['.*gauze.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('965312ab-d980-540e-9fb9-603c25731c14', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Look at the following people (Questions
9-12
) and the list of statements.
Match each person with the correct statement.
Write the correct letter
A-F
in boxes
9-12
on your answer sheet.
List of Statements
A
Filed a complaint which was never responded to
B
Broke the contract made with Carbolic Smoke Ball Company
C
Initiated a legal case
D
Described the audience of advertisement
E
Claimed that most advertisements are fraudulent
F
Treated advertisement as a type of contract
9
Mrs. Carlill
Locate
10
Mrs. Carlill’s husband
Locate
11
Judge Hawkins
Locate
12
Lord Justice Bowen
Locate

9 ____ Mrs. Carlill Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b631489-b1bf-5465-8f1d-2b7dfb143296', '965312ab-d980-540e-9fb9-603c25731c14', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bfc3dea-e1a5-5cb6-b348-a08ce02ddb34', '965312ab-d980-540e-9fb9-603c25731c14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd7fda54-5b26-55cb-a993-daf9fd5f8778', '965312ab-d980-540e-9fb9-603c25731c14', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26f5b3c5-40f7-55a1-b3c4-f57a543ffe65', '965312ab-d980-540e-9fb9-603c25731c14', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1e21e24-7b8d-5db4-9667-a22dd9a863ff', '965312ab-d980-540e-9fb9-603c25731c14', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6ed8c22-6b4f-50ec-8b85-5504e9504457', '965312ab-d980-540e-9fb9-603c25731c14', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75849c0b-d5fb-554a-954d-43457b585f91', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Look at the following people (Questions
9-12
) and the list of statements.
Match each person with the correct statement.
Write the correct letter
A-F
in boxes
9-12
on your answer sheet.
List of Statements
A
Filed a complaint which was never responded to
B
Broke the contract made with Carbolic Smoke Ball Company
C
Initiated a legal case
D
Described the audience of advertisement
E
Claimed that most advertisements are fraudulent
F
Treated advertisement as a type of contract
9
Mrs. Carlill
Locate
10
Mrs. Carlill’s husband
Locate
11
Judge Hawkins
Locate
12
Lord Justice Bowen
Locate

10 ____ Mrs. Carlill’s husband Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6f40486-d82b-5b4f-b4f7-92b878af0524', '75849c0b-d5fb-554a-954d-43457b585f91', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('628f9d63-0457-5be5-9005-a6bd3d56b95b', '75849c0b-d5fb-554a-954d-43457b585f91', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('266e7d64-61b1-587f-9ec4-cb7bfa0596d2', '75849c0b-d5fb-554a-954d-43457b585f91', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ddcb5df-c14b-5cb6-916c-a72eee9548b9', '75849c0b-d5fb-554a-954d-43457b585f91', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e09b7fd-540d-5d5c-b662-34395337d28d', '75849c0b-d5fb-554a-954d-43457b585f91', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17b0ce49-7167-5fb8-824d-3a7107160960', '75849c0b-d5fb-554a-954d-43457b585f91', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b08b27c7-a688-5a6f-af75-888a1cfc3a08', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Look at the following people (Questions
9-12
) and the list of statements.
Match each person with the correct statement.
Write the correct letter
A-F
in boxes
9-12
on your answer sheet.
List of Statements
A
Filed a complaint which was never responded to
B
Broke the contract made with Carbolic Smoke Ball Company
C
Initiated a legal case
D
Described the audience of advertisement
E
Claimed that most advertisements are fraudulent
F
Treated advertisement as a type of contract
9
Mrs. Carlill
Locate
10
Mrs. Carlill’s husband
Locate
11
Judge Hawkins
Locate
12
Lord Justice Bowen
Locate

11 ____ Judge Hawkins Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fbfca49-9065-5584-affb-92bcaf1236f7', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('566e9ca1-f0ad-5ad2-9a2d-4ab95ec2f2e0', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87fcde7c-1fc8-538b-af06-81580fe6a375', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a4c1055-b4a0-501f-854c-e881ad220340', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('baab293a-bf10-521c-9ac4-8166221ff86e', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e09da369-4f09-51d6-a098-9897a7adaed0', 'b08b27c7-a688-5a6f-af75-888a1cfc3a08', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4a86b746-14cf-5504-a55c-1f5b3df9e40b', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Look at the following people (Questions
9-12
) and the list of statements.
Match each person with the correct statement.
Write the correct letter
A-F
in boxes
9-12
on your answer sheet.
List of Statements
A
Filed a complaint which was never responded to
B
Broke the contract made with Carbolic Smoke Ball Company
C
Initiated a legal case
D
Described the audience of advertisement
E
Claimed that most advertisements are fraudulent
F
Treated advertisement as a type of contract
9
Mrs. Carlill
Locate
10
Mrs. Carlill’s husband
Locate
11
Judge Hawkins
Locate
12
Lord Justice Bowen
Locate

12 ____ Lord Justice Bowen Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('261ecc2a-427a-5795-bae1-e11594d947c7', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6a337a4-4852-55e4-b1ea-d7c3ff945bae', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d14f367-4ca1-5f1b-acfe-1a0445735166', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7935249a-af75-5044-b0da-bb7964989863', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6984711-558d-5860-864d-63e193d4f748', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ca64d2-866d-540e-8b3b-2eb88ed7675c', '4a86b746-14cf-5504-a55c-1f5b3df9e40b', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be28d5be-f7db-5a78-95eb-9a83a4ad9cef', 'eb4d4ecb-15d2-599b-93e3-be9316e72468', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13
Questions 13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
13
on your answer sheet.
13.
Why is Mrs. Carlill’s case often cited in present-day court trials?
A
It proved the untrustworthiness of advertisements.
B
It established the validity of one-sided contract.
C
It explained the nature of contract.
D
It defended the rights of consumers.
Locate

Choose the correct letter, A, B, C or D . Write your answers in boxes 13 on your answer sheet. 13. Why is Mrs. Carlill’s case often cited in present-day court trials?$md$, NULL);

COMMIT;
