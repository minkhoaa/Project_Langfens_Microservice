BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-marketing-and-mind-control-1449'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-marketing-and-mind-control-1449';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-marketing-and-mind-control-1449';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-marketing-and-mind-control-1449';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3cf07e9f-d88c-5022-9457-cc3a9da5659e', 'ielts-reading-marketing-and-mind-control-1449', $t$Marketing And Mind Control$t$, $md$## Marketing And Mind Control

Nguồn:
- Test: https://mini-ielts.com/1449/reading/marketing-and-mind-control
- Solution: https://mini-ielts.com/1449/view-solution/reading/marketing-and-mind-control$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', '3cf07e9f-d88c-5022-9457-cc3a9da5659e', 1, $t$Reading — Marketing And Mind Control$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Marketing And Mind Control

How marketing and advertising appeal to the associative nature of the brain

While there had been a long tradition of giving rings as a commitment to marry, the custom of giving diamond engagement rings was in large part manufactured by one of the most effective marketing campaigns in history . In the early 1900s, diamond sales were declining, posing a serious problem for the company that essentially had control over the diamond market. In 1938, this company hired an advertising agency. Which proposed reshaping social attitudes toward diamonds? As well as magazines showing film stars draped in diamonds, the agency arranged for movies to incorporate diamond engagement rings into their plots. The campaign culminated with the slogan:' A diamond is forever. At the time, the approach was unique. Rather than pushing a brand, the objective was to promote diamonds as the symbol of everlasting love. This was achieved by exploiting the associative nature of the brain: associating neurons! Activated by the concept of' love ' with neurons that encoded the concept of “diamonds. By 1941, diamond sales had increased by 55 %.

Advertising comes in many forms, from blatant neon signs to subtly embedded products in movies. In each case, the goal is to mould our habits, desires and opinions. Our visual system is targeted by an avalanche of information on the internet, street posters, and billboards and in movie theatres. Our auditory system submits to catchy radio jingles and telemarketers. More surreptitiously, our olfactory system is targeted by variations of vanilla and citrus perfumes aimed at enticing US to linger in a retail outlet. It is difficult to measure how effective these campaigns are, but as in the ' A diamond is forever ’ campaign, they can be so successful that they change the fabric of our culture. In the case of bottled water, we are swayed by advertising into paying for something that we can obtain for free. Most people cannot distinguish bottled from tap water, much less between brands of bottled water, which is why you rarely hear of a bottled water company proposing a blind taste test.

So why is marketing such an effective mind - control technique? It is interesting to consider whether other animals exhibit anything analogous to humans ' susceptibility to advertising. If we provide a lab rat with two types of cereal, it will consume approximately the same amount of each. However, if we put that rat with another rat that spent its day eating just one type, when faced with a choice, our rat will now show a preference for the same type as the other rat was eating. Psychologists call this ' socially transmitted food preference ‘.

What many regard as the first documented examples of cultural learning in primates started with a clever monkey that lived in a colony of Japanese monkeys on the island of Koshima. She began taking her dirt - covered sweet potatoes to the river to wash them before eating them. Upon seeing this, a few 11 other open - minded monkeys picked up on the idea. Potato washing then spread from monkey to monkey and, over the course of a few years, most monkeys were eating clean potatoes. Humans are clearly not the only animals to engage in imitation and social learning.

Learning by observation can be an extraordinarily valuable brain feature, this is how we learn to communicate and perform motor skills as well as deal with many everyday problems. For example, a newcomer struggling to purchase tickets and navigate the subway system in a foreign city may step back to learn from the people nearby. Humans and other primates exhibit multiple forms of imitative learning and this is called cultural transmission.

A component of advertising relies on the marketer's ability to tap into the brain’s propensity for imitation. Anybody who has watched TV knows advertisements are disproportionately populated with attractive, successful looking individuals. If we are going to imitate someone, we are more inclined to imitate those who appear to be popular and appealing.

Although not all researchers are convinced by the findings, a number of studies indicate that some animals also imitate dominant members of their group. Primatologist Frans de Waal provides anecdotal evidence of preferential imitation among chimpanzees. He noted that in one particular group the dominant male was hurt and was limping as a result. Soon unlikely if a non-dominant male had been injured.

Imitation is undoubtedly an invaluable ability, but often our propensity to imitate generalises indiscriminately, leading to poor decisions. When athlete Dick Fosbury revolutionised the high jump by jumping over the bar backward in 1968, imitators obviously copied his jumping style, not his brand of sports shoes. However, today, sports people appear in advertisements asking US to buy the laptops or sports drinks that they promote. Rationally, we know these people's success did not depend on these products, so it seems our propensity to purchase products relates more to neural programs that evolved to encourage imitation of those further up the social ladder. Today , companies engage in stealth marketing campaigns in which people are paid to frequent bars or websites to covertly promote certain products , Companies also perform studies in which they track the eye movements of people viewing displays , and carefully craft names , packages and jingles associated with their products. While we may like to believe that manipulation on a grand scale would not be possible, that's not to say that advertising is innately harmful. To the contrary, the marketing of products or ideas is essential to human culture. The point is that we should ensure our choices reflect our actual goals and desires, and we must distinguish between the dissemination of information which is for our own good, and our manipulation for the benefit of companies$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de048af3-d659-5bfd-a1c5-d4a286a4e3a6', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. According to the writer, which marketing technique attempts to make consumers stay in a shop for longer?
in a shop for longer?
A
playing appealing music
B
emitting pleasant scents
C
displaying attractive posters
D
making in - store announcements
2. The writer mentions bottled water in order to show that
A
consumers buy it because of the fact that it is marketed.
B
people purchase it despite the fact that it has no taste.
C
marketers need not do taste tests when a campaign is effective.
D
tests prove that people cannot differentiate it from tap water.
3. According to the writer, socially transmitted food preference occurs when
A
only dominant members of an animal group influence what others eat.
B
the same types of animals naturally prefer the same types of food.
C
animals are influenced by what any other animals of the same species eat.
D
a food type is more desirable because an animal views that food as scarce.
4. According to the writer, how is learning by observation and imitation a useful feature of the brain?
A
it helps people overcome challenges.
B
positive models can influence social behaviour.
C
it can give an advantage when communicating with others.
D
cultural norms and relationships can be understood more easily
5. According to the writer, how does television advertising exploit the human tendency to imitate others ?
A
It shows buying behaviour that marketers want to encourage in viewers.
B
It features people who have a desirable image.
C
It shows older people whom teenagers admire.
D
It features successful people endorsing products responsible for their success.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c16384fb-7305-5515-9ca8-6d72d99e6d1c', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. According to the writer, which marketing technique attempts to make consumers stay in a shop for longer?
in a shop for longer?
A
playing appealing music
B
emitting pleasant scents
C
displaying attractive posters
D
making in - store announcements
2. The writer mentions bottled water in order to show that
A
consumers buy it because of the fact that it is marketed.
B
people purchase it despite the fact that it has no taste.
C
marketers need not do taste tests when a campaign is effective.
D
tests prove that people cannot differentiate it from tap water.
3. According to the writer, socially transmitted food preference occurs when
A
only dominant members of an animal group influence what others eat.
B
the same types of animals naturally prefer the same types of food.
C
animals are influenced by what any other animals of the same species eat.
D
a food type is more desirable because an animal views that food as scarce.
4. According to the writer, how is learning by observation and imitation a useful feature of the brain?
A
it helps people overcome challenges.
B
positive models can influence social behaviour.
C
it can give an advantage when communicating with others.
D
cultural norms and relationships can be understood more easily
5. According to the writer, how does television advertising exploit the human tendency to imitate others ?
A
It shows buying behaviour that marketers want to encourage in viewers.
B
It features people who have a desirable image.
C
It shows older people whom teenagers admire.
D
It features successful people endorsing products responsible for their success.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3813416a-5e44-51c9-92a9-5ddff0fadeef', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. According to the writer, which marketing technique attempts to make consumers stay in a shop for longer?
in a shop for longer?
A
playing appealing music
B
emitting pleasant scents
C
displaying attractive posters
D
making in - store announcements
2. The writer mentions bottled water in order to show that
A
consumers buy it because of the fact that it is marketed.
B
people purchase it despite the fact that it has no taste.
C
marketers need not do taste tests when a campaign is effective.
D
tests prove that people cannot differentiate it from tap water.
3. According to the writer, socially transmitted food preference occurs when
A
only dominant members of an animal group influence what others eat.
B
the same types of animals naturally prefer the same types of food.
C
animals are influenced by what any other animals of the same species eat.
D
a food type is more desirable because an animal views that food as scarce.
4. According to the writer, how is learning by observation and imitation a useful feature of the brain?
A
it helps people overcome challenges.
B
positive models can influence social behaviour.
C
it can give an advantage when communicating with others.
D
cultural norms and relationships can be understood more easily
5. According to the writer, how does television advertising exploit the human tendency to imitate others ?
A
It shows buying behaviour that marketers want to encourage in viewers.
B
It features people who have a desirable image.
C
It shows older people whom teenagers admire.
D
It features successful people endorsing products responsible for their success.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6eda8870-2b5a-5459-82b9-dbeb5db19ac0', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. According to the writer, which marketing technique attempts to make consumers stay in a shop for longer?
in a shop for longer?
A
playing appealing music
B
emitting pleasant scents
C
displaying attractive posters
D
making in - store announcements
2. The writer mentions bottled water in order to show that
A
consumers buy it because of the fact that it is marketed.
B
people purchase it despite the fact that it has no taste.
C
marketers need not do taste tests when a campaign is effective.
D
tests prove that people cannot differentiate it from tap water.
3. According to the writer, socially transmitted food preference occurs when
A
only dominant members of an animal group influence what others eat.
B
the same types of animals naturally prefer the same types of food.
C
animals are influenced by what any other animals of the same species eat.
D
a food type is more desirable because an animal views that food as scarce.
4. According to the writer, how is learning by observation and imitation a useful feature of the brain?
A
it helps people overcome challenges.
B
positive models can influence social behaviour.
C
it can give an advantage when communicating with others.
D
cultural norms and relationships can be understood more easily
5. According to the writer, how does television advertising exploit the human tendency to imitate others ?
A
It shows buying behaviour that marketers want to encourage in viewers.
B
It features people who have a desirable image.
C
It shows older people whom teenagers admire.
D
It features successful people endorsing products responsible for their success.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8653a936-c665-5294-9c31-9a188f9619b7', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, c or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. According to the writer, which marketing technique attempts to make consumers stay in a shop for longer?
in a shop for longer?
A
playing appealing music
B
emitting pleasant scents
C
displaying attractive posters
D
making in - store announcements
2. The writer mentions bottled water in order to show that
A
consumers buy it because of the fact that it is marketed.
B
people purchase it despite the fact that it has no taste.
C
marketers need not do taste tests when a campaign is effective.
D
tests prove that people cannot differentiate it from tap water.
3. According to the writer, socially transmitted food preference occurs when
A
only dominant members of an animal group influence what others eat.
B
the same types of animals naturally prefer the same types of food.
C
animals are influenced by what any other animals of the same species eat.
D
a food type is more desirable because an animal views that food as scarce.
4. According to the writer, how is learning by observation and imitation a useful feature of the brain?
A
it helps people overcome challenges.
B
positive models can influence social behaviour.
C
it can give an advantage when communicating with others.
D
cultural norms and relationships can be understood more easily
5. According to the writer, how does television advertising exploit the human tendency to imitate others ?
A
It shows buying behaviour that marketers want to encourage in viewers.
B
It features people who have a desirable image.
C
It shows older people whom teenagers admire.
D
It features successful people endorsing products responsible for their success.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e3a7f8d5-86ad-562c-a63d-bce746ae89cc', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 6-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
The diamond campaign worked by making a connection in people's minds between diamonds and luxury
7
People are more aware of visual marketing than auditory marketing.
8
The campaign advertising diamonds had a positive influence on society.
9
There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.
10
Consumers make a logical connection between celebrities ' achievements and the products they promote.

6 ____ The diamond campaign worked by making a connection in people's minds between diamonds and luxury$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a85cc038-7fe7-5c71-9af3-5920103096fa', 'e3a7f8d5-86ad-562c-a63d-bce746ae89cc', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('def6880b-ef4e-5936-bd09-18a4d40cc5f9', 'e3a7f8d5-86ad-562c-a63d-bce746ae89cc', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9d77133-788c-5674-b8cc-5111ad9c6778', 'e3a7f8d5-86ad-562c-a63d-bce746ae89cc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80c8fc33-3a4a-5052-9987-c0c1824d4bee', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 6-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
The diamond campaign worked by making a connection in people's minds between diamonds and luxury
7
People are more aware of visual marketing than auditory marketing.
8
The campaign advertising diamonds had a positive influence on society.
9
There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.
10
Consumers make a logical connection between celebrities ' achievements and the products they promote.

7 ____ People are more aware of visual marketing than auditory marketing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('634d6d7e-95cf-548d-ace5-8324dcd03eb7', '80c8fc33-3a4a-5052-9987-c0c1824d4bee', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a98f9a11-a6a8-5b0c-ae98-ec1516584358', '80c8fc33-3a4a-5052-9987-c0c1824d4bee', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d884da16-c4b3-59b0-bce1-b050305db786', '80c8fc33-3a4a-5052-9987-c0c1824d4bee', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('575e093c-e7ca-55b8-91c1-6a4a7d709c51', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 6-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
The diamond campaign worked by making a connection in people's minds between diamonds and luxury
7
People are more aware of visual marketing than auditory marketing.
8
The campaign advertising diamonds had a positive influence on society.
9
There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.
10
Consumers make a logical connection between celebrities ' achievements and the products they promote.

8 ____ The campaign advertising diamonds had a positive influence on society.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76a8323a-1aa1-563c-8f98-c25fb60e4aca', '575e093c-e7ca-55b8-91c1-6a4a7d709c51', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b29a7681-1dd9-5f52-a656-12fe7dda4115', '575e093c-e7ca-55b8-91c1-6a4a7d709c51', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac786bae-04fa-5367-be11-803fb8690c46', '575e093c-e7ca-55b8-91c1-6a4a7d709c51', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84456993-17cf-5a32-8a49-152afa5ff91a', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 6-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
The diamond campaign worked by making a connection in people's minds between diamonds and luxury
7
People are more aware of visual marketing than auditory marketing.
8
The campaign advertising diamonds had a positive influence on society.
9
There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.
10
Consumers make a logical connection between celebrities ' achievements and the products they promote.

9 ____ There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71400764-5f24-5953-8134-a7eb2941c7ea', '84456993-17cf-5a32-8a49-152afa5ff91a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b93985d2-e507-5769-a1fa-b087f194a35c', '84456993-17cf-5a32-8a49-152afa5ff91a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6c0f44d-057f-53d1-9fcc-ed81c03988b2', '84456993-17cf-5a32-8a49-152afa5ff91a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('403e6b3a-be07-50a1-9236-60caab8c2402', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 6-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
The diamond campaign worked by making a connection in people's minds between diamonds and luxury
7
People are more aware of visual marketing than auditory marketing.
8
The campaign advertising diamonds had a positive influence on society.
9
There is still some uncertainty about whether animals copy the behaviour of the most powerful animals among them.
10
Consumers make a logical connection between celebrities ' achievements and the products they promote.

10 ____ Consumers make a logical connection between celebrities ' achievements and the products they promote.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b20989f-2ae0-5527-99d0-ed2532b8e810', '403e6b3a-be07-50a1-9236-60caab8c2402', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e2d986e-9640-5ac9-b060-c625021171ac', '403e6b3a-be07-50a1-9236-60caab8c2402', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38327b15-c670-57f7-ba0b-ae79690d7ed1', '403e6b3a-be07-50a1-9236-60caab8c2402', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49188688-759d-5db2-99fa-0a9c96cd6438', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending , A - G , below
Write the correct letter, A - G , in boxes 37-40 on your answer sheet.
11
The behaviour of the monkeys on the island of Koshima showed that
12
Primatologist Frans de Waal found that
13
Dick Fosbury is mentioned in order to show that
14
A feature of some modern marketing campaigns is that
people imitated behaviour that was linked with success .
younger animals of a certain species are more likely to imitate each other.
an animal would imitate another that had higher status .
imitation of popular sportspeople has occurred for many decades .
products are marketed to potential consumers who are unaware that marketing is occurring .
animals can develop new habits by observation.
incentives are provided for consumers who behave in a certain way.

11 ____ The behaviour of the monkeys on the island of Koshima showed that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f99be074-489a-5ad7-835d-59b44519ec9d', '49188688-759d-5db2-99fa-0a9c96cd6438', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40a20a98-472f-58c5-b6dd-dff230ff2c9f', '49188688-759d-5db2-99fa-0a9c96cd6438', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d16fffa-55ba-5892-abd0-dc0f63fb44d9', '49188688-759d-5db2-99fa-0a9c96cd6438', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a435d19-c1ac-5d67-9dc0-8f76d61847a1', '49188688-759d-5db2-99fa-0a9c96cd6438', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32363d1c-c0d8-5ab7-af97-e07835cd8064', '49188688-759d-5db2-99fa-0a9c96cd6438', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6770de50-1cf3-5d4b-a0d5-a179c63538ee', '49188688-759d-5db2-99fa-0a9c96cd6438', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dd7dab3-21fb-55a9-ba46-4ba47c9dba28', '49188688-759d-5db2-99fa-0a9c96cd6438', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f44716cb-8437-59a6-a890-0997de28978c', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending , A - G , below
Write the correct letter, A - G , in boxes 37-40 on your answer sheet.
11
The behaviour of the monkeys on the island of Koshima showed that
12
Primatologist Frans de Waal found that
13
Dick Fosbury is mentioned in order to show that
14
A feature of some modern marketing campaigns is that
people imitated behaviour that was linked with success .
younger animals of a certain species are more likely to imitate each other.
an animal would imitate another that had higher status .
imitation of popular sportspeople has occurred for many decades .
products are marketed to potential consumers who are unaware that marketing is occurring .
animals can develop new habits by observation.
incentives are provided for consumers who behave in a certain way.

12 ____ Primatologist Frans de Waal found that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62e192f3-e7b2-5a7b-9e8d-427c49279847', 'f44716cb-8437-59a6-a890-0997de28978c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65279500-aaf2-5417-b498-e4818f1d9390', 'f44716cb-8437-59a6-a890-0997de28978c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0ed8ad1-d96a-5a4a-85fa-53ffada45de2', 'f44716cb-8437-59a6-a890-0997de28978c', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c954b008-c181-5c92-9996-e8de1047ed8f', 'f44716cb-8437-59a6-a890-0997de28978c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b19e4d6-0d0e-5964-a56a-f207698e5a82', 'f44716cb-8437-59a6-a890-0997de28978c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3062db67-272c-5342-9422-f8588ba6d11c', 'f44716cb-8437-59a6-a890-0997de28978c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f1960b3-c8e7-5f9b-adae-6b940163023f', 'f44716cb-8437-59a6-a890-0997de28978c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('36303c02-0721-5eeb-8215-d0692d825f2d', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending , A - G , below
Write the correct letter, A - G , in boxes 37-40 on your answer sheet.
11
The behaviour of the monkeys on the island of Koshima showed that
12
Primatologist Frans de Waal found that
13
Dick Fosbury is mentioned in order to show that
14
A feature of some modern marketing campaigns is that
people imitated behaviour that was linked with success .
younger animals of a certain species are more likely to imitate each other.
an animal would imitate another that had higher status .
imitation of popular sportspeople has occurred for many decades .
products are marketed to potential consumers who are unaware that marketing is occurring .
animals can develop new habits by observation.
incentives are provided for consumers who behave in a certain way.

13 ____ Dick Fosbury is mentioned in order to show that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82da5b1e-b71c-58c3-b3d1-bcafe25cf8b1', '36303c02-0721-5eeb-8215-d0692d825f2d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d58c6d8d-28be-5729-8e93-e9ea44622ea1', '36303c02-0721-5eeb-8215-d0692d825f2d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e00b5b91-afa9-5f1b-8bfe-cd065dfb4c3c', '36303c02-0721-5eeb-8215-d0692d825f2d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c592270-3dc2-51c3-91a4-a0028a205043', '36303c02-0721-5eeb-8215-d0692d825f2d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a96f1626-76c4-598f-98d9-abdb3155c4dd', '36303c02-0721-5eeb-8215-d0692d825f2d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92ca92b6-0460-5b07-b9ae-8efcaa616eca', '36303c02-0721-5eeb-8215-d0692d825f2d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1740148f-1ca2-5999-8407-1bab57a845f1', '36303c02-0721-5eeb-8215-d0692d825f2d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d42c0990-24ce-5507-99a9-dd31c2e23290', 'e2286ff3-ccf5-5a61-b601-0ce1c17b85fb', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending , A - G , below
Write the correct letter, A - G , in boxes 37-40 on your answer sheet.
11
The behaviour of the monkeys on the island of Koshima showed that
12
Primatologist Frans de Waal found that
13
Dick Fosbury is mentioned in order to show that
14
A feature of some modern marketing campaigns is that
people imitated behaviour that was linked with success .
younger animals of a certain species are more likely to imitate each other.
an animal would imitate another that had higher status .
imitation of popular sportspeople has occurred for many decades .
products are marketed to potential consumers who are unaware that marketing is occurring .
animals can develop new habits by observation.
incentives are provided for consumers who behave in a certain way.

14 ____ A feature of some modern marketing campaigns is that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cb1d52c-de25-5e44-908a-857e7d2932f5', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac40cb79-db7b-51e0-9759-ed42da62d918', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35962dae-2516-56a9-8f85-26cfce6c66f2', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb55f37c-3023-5e6e-830c-fce14449bcc2', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca1a5591-9b47-5f29-89b2-ea31767dfe43', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e3afa54-f868-50a3-8b45-20f086ef004a', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22d36562-c510-598b-9886-99e01ae7f9b7', 'd42c0990-24ce-5507-99a9-dd31c2e23290', 7, $md$G$md$, false);

COMMIT;
