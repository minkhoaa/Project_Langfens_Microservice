BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-why-good-ideas-fail-1438'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-why-good-ideas-fail-1438';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-why-good-ideas-fail-1438';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-why-good-ideas-fail-1438';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a163cb7c-9436-52fc-bcf8-2f6ddea38958', 'ielts-reading-why-good-ideas-fail-1438', $t$Why good ideas fail$t$, $md$## Why good ideas fail

Nguồn:
- Test: https://mini-ielts.com/1438/reading/why-good-ideas-fail
- Solution: https://mini-ielts.com/1438/view-solution/reading/why-good-ideas-fail$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c9cf0678-da07-510e-945c-4c4cdc051e4f', 'a163cb7c-9436-52fc-bcf8-2f6ddea38958', 1, $t$Reading — Why good ideas fail$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Why good ideas fail

As part of a marketing course, two marketing experts comment on a hypothetical case study involving TF, a fiction retail giant specializing in home furnishing. The experts give concrete solutions and advice to assist students.

Hypothetical case study:

TF became a retail success in the 1970s when it succeeded in spotting homeware trends and meeting the needs of its then trendy young customers. However; by 2004, the IF stores were failing and a rethink was clearly necessary. Tibal Fisher, TF's founder and CEO, decided to change its focus under the new brand name of TVs Nextstage. His aim was to recapture the now ageing customers that had given him his early success and target consumers aged 60+ with devices and gadgets specifically designed to assist them with the problems associated with ageing: mobile phones with screens that were easy to read; kitchen gadgets with comfortable grips; electronic devices that were easy to set and adjust. TF’s market research proved to be very positive, showing strong consumer support for the products

In 2007, the stores were remodelled at a cost of US $40 million and the new brand was launched. Each store was made more comfortable and featured a coffee shop to help increase traffic - Tibal had predicted that if they could get customers into the stores then the products would sell themselves. However, by 2009 it was clear that the idea was a failure and the stores consistently remained empty. Customers complained that the new stores felt like a senior center and reminded them that they were growing old.

Feedback from expert

Expert 1: Donna Sturgess, global head of innovation, GlaxoSmithKline

The TReam's customer research efforts are a classic case of missing the subconscious associations at work in consumers' minds. Tlbal and his executives looked only at surface attitudes. Since those attitudes make up a relatively small part of the total consumer response, the executives are clueless about the reason for the poor sales. It's critical for companies to understand that every customer relates to a brand emotionally, and it’s those emotions that trigger - or block - purchases

That's why we’ve focused on using emotional strategies behind branding for a number of years now. A great example Is Alli (pronounced 'ally'), a drug to aid weight loss. The product deals with a highly emotional issue, so in marketing it, we faced the same challenge that the new TFstores are facing: the very thought of buying the product reminds customers that they have problems they feel negatively In the case of TF’s Nextstage, the problems are age and infirmity. In the case of Alli, the problems are excessive weight and all consequences. There's always a risk that consumers' negative feelings will discourage them from starting or staying on a diet. So, after extensive market research, we took a number of steps to inject emotions into the whole process of using the product.

First we came up with a name that sounds like a helpful partner. We also aimed to make the container both beautiful and functional — something that didn’t just hold pills but could later be used to store diet guides and recipes. Traditional market research is unlikely to uncover Ideas like this, so we use a wide variety of techniques. Even simple techniques such as one-on-one interviews, or ethnographical observation that involves going into people's houses to examine their behaviour, can provide valuable data.

Expert 2: Alex Lee, president of 0X0 International, maker of 0X0 Good Grips household products

This retailer can get back on track by remembering a principle that applies to consumers In general and those aged 60+ in particular: they’re attracted by brands they associate with the type of people they’d like to be - not the type they really are. That's why marketing campaigns for surf gear feature surfers, not the city dwellers who will wear the products while doing their shopping

Although the needs of elderly users and those with deteriorating vision or dexterity are very much taken into consideration when we develop new designs, we try to offer that appeal to 20- and 30-year-olds. We believe that referring to these products as helping tools would serve only to harm the brand in our customers' eyes. That's why our philosophy of universal design, which involves creating products that are comfortably useable by the largest possible range of people, is never explicitly stated as part of our marketing position.

We’ve found that market research does not need to be very sophisticated. For instance, we have conducted simple surveys in the lobby of our building offering free products in exchange for people's opinions. Some may call this unscientific but we have uncovered great insights this way. Sometimes the most important signals come from an executive's own instincts. In Tibal fisher's case, this could have told him what his surveys and focus groups didn't: 60-plus-year-olds won't support a business that expects them to act their age.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b6b915e-2fdc-59ba-bf58-b6e6c04d94ce', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage ? In boxes 1-5 on your answer, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The TF Nextstage stores planned to sell products to make life easier for older people
2
TF’s market research indicated that people liked the products.
3
It cost more than expected to remodel the TF stores.
4
The TF Nextstage coffee shops sold their own brand of food and drink.
5
TF Nextstage customers liked the atmosphere in the new stores

1 ____ The TF Nextstage stores planned to sell products to make life easier for older people$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fddd711-14fa-58ab-95c1-6af33dc40041', '9b6b915e-2fdc-59ba-bf58-b6e6c04d94ce', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90bb23ed-08d5-5bfc-8f36-770e6d4b643e', '9b6b915e-2fdc-59ba-bf58-b6e6c04d94ce', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f5602a3-957b-5fdc-8ec2-f2e3b4aa9503', '9b6b915e-2fdc-59ba-bf58-b6e6c04d94ce', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac6d3ef9-bb57-5f52-bb34-86afe3e62101', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage ? In boxes 1-5 on your answer, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The TF Nextstage stores planned to sell products to make life easier for older people
2
TF’s market research indicated that people liked the products.
3
It cost more than expected to remodel the TF stores.
4
The TF Nextstage coffee shops sold their own brand of food and drink.
5
TF Nextstage customers liked the atmosphere in the new stores

2 ____ TF’s market research indicated that people liked the products.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('693ebcc5-7028-5ab5-85a1-ce241432c89e', 'ac6d3ef9-bb57-5f52-bb34-86afe3e62101', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9acfca59-81ac-58d4-ab3f-1fdbdfb700dc', 'ac6d3ef9-bb57-5f52-bb34-86afe3e62101', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b5571f1-2376-5315-acb3-4a0748d8d0f6', 'ac6d3ef9-bb57-5f52-bb34-86afe3e62101', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4511e5ab-2acf-5231-8b08-0255e4c1276e', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage ? In boxes 1-5 on your answer, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The TF Nextstage stores planned to sell products to make life easier for older people
2
TF’s market research indicated that people liked the products.
3
It cost more than expected to remodel the TF stores.
4
The TF Nextstage coffee shops sold their own brand of food and drink.
5
TF Nextstage customers liked the atmosphere in the new stores

3 ____ It cost more than expected to remodel the TF stores.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('025bd1c9-8d39-56fd-8e23-6f19edccb68a', '4511e5ab-2acf-5231-8b08-0255e4c1276e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccb6f0dc-334f-5c73-8892-37ee553e7834', '4511e5ab-2acf-5231-8b08-0255e4c1276e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcb9bf6c-be34-53cc-b0e0-3ba5f212199c', '4511e5ab-2acf-5231-8b08-0255e4c1276e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('353592f9-75f1-5cbf-9b77-fcf1c29880cf', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage ? In boxes 1-5 on your answer, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The TF Nextstage stores planned to sell products to make life easier for older people
2
TF’s market research indicated that people liked the products.
3
It cost more than expected to remodel the TF stores.
4
The TF Nextstage coffee shops sold their own brand of food and drink.
5
TF Nextstage customers liked the atmosphere in the new stores

4 ____ The TF Nextstage coffee shops sold their own brand of food and drink.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fdd6402-e9f6-5bdd-878f-569a9eadec28', '353592f9-75f1-5cbf-9b77-fcf1c29880cf', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3103d967-8361-5969-9940-a1ab92d2d9bb', '353592f9-75f1-5cbf-9b77-fcf1c29880cf', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed4fa69f-cdd9-51c0-a2e0-df3820e4c637', '353592f9-75f1-5cbf-9b77-fcf1c29880cf', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdaa2909-22d9-508d-8f97-8f4c47096bd4', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage ? In boxes 1-5 on your answer, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The TF Nextstage stores planned to sell products to make life easier for older people
2
TF’s market research indicated that people liked the products.
3
It cost more than expected to remodel the TF stores.
4
The TF Nextstage coffee shops sold their own brand of food and drink.
5
TF Nextstage customers liked the atmosphere in the new stores

5 ____ TF Nextstage customers liked the atmosphere in the new stores$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb7f9af3-8bba-52da-87a2-b8f2ef6ecf8e', 'fdaa2909-22d9-508d-8f97-8f4c47096bd4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76812467-f308-5214-af5f-0ad98d8bab29', 'fdaa2909-22d9-508d-8f97-8f4c47096bd4', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a76e449-dae1-5eb2-8a0a-0475b4f732a3', 'fdaa2909-22d9-508d-8f97-8f4c47096bd4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d2ec4546-882c-58df-a953-363ffaa69e99', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

TF team limited their research to attitudes that occur at a 6 ____ level in customers' minds$md$, NULL, ARRAY['.*surface.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d91cf99f-e3a2-5532-bc2e-a08389e424b3', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Use: help people achieve 7 ____$md$, NULL, ARRAY['.*weight.*loss.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6bf8aa3f-b5ec-5541-a99c-071bf44ca831', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Giving the product a 8 ____ that seems helpful and supportive$md$, NULL, ARRAY['.*name.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('34c58c5d-b371-5795-af66-e1e8d4c8431c', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Giving the product a reusable 9 ____$md$, NULL, ARRAY['.*container.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7ce0fae3-de1a-574d-a925-3b5e775ee3de', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Good information can come from interviews or studying the 10 ____ of consumers in the home$md$, NULL, ARRAY['.*behavior.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5cdd2b4a-f0db-5580-b65a-75eaaad8eede', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

We organised 11 ____ to find out what images customers associate with$md$, NULL, ARRAY['.*focus.*groups.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f678b061-ffc0-59b3-991d-e9dcb685521c', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Can be basic, e.g. by doing 12 ____$md$, NULL, ARRAY['.*simople.*surveys.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fe1e5486-e197-5ce0-a87b-58c87db03631', 'c9cf0678-da07-510e-945c-4c4cdc051e4f', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 6 -13
Questions 6 -13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet
Feedback from experts
Donna Sturgess
Problems with customer research:
TF team limited their research to attitudes that occur at a
6
level in customers' minds
TF didn't consider customers' emotions
How my company dealt with a similar problem:
Product: Alli
Use: help people achieve
7
Marketing aim: help customers see the product a positive way by:
Giving the product a
8
that seems helpful and supportive
Giving the product a reusable
9
Market research
Does not need to be complex
Good information can come from interviews or studying the
10
of consumers in the home
Alex
Lee
Problem:
Customers are attracted to the ideal not the reality, e.g. ads for surf gear
How my company dealt with a similar problem:
We organised
11
to find out what images customers associate with
our products
we do not call our products helping tools in our marketing campaigns
Market research:
Can be basic, e.g. by doing
12
Company executives should follow their
13

Company executives should follow their 13 ____$md$, NULL, ARRAY['.*instincts.*']);

COMMIT;
